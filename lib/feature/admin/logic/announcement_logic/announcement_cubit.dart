import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:optialeader/feature/admin/data/model/announcement_model.dart';
import 'package:optialeader/feature/admin/data/repo/announcement_repos/announcement_repo.dart';
import 'package:optialeader/feature/notification/data/model/app_notification_model.dart';
import 'package:optialeader/feature/notification/data/repo/notification_repo.dart';
import 'announcement_state.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
class AnnouncementCubit extends Cubit<AnnouncementState> {
  final IAnnouncementRepository _repository;
  final NotificationRepo _notificationRepo;
StreamSubscription? _announcementSubscription;

  AnnouncementCubit(
    this._repository,
    this._notificationRepo,
  ) : super(AnnouncementInitial()) {
    fetchAnnouncements();
  }
void fetchAnnouncements() {
  print('🚀 FETCH ANNOUNCEMENTS CALLED');

  emit(AnnouncementLoading());

  _announcementSubscription?.cancel();

  _announcementSubscription =
      _repository.getAnnouncements().listen(
    (data) {
      print('📥 ANNOUNCEMENTS RECEIVED: ${data.length}');

      final now = DateTime.now();

      final correctedData = data.map((a) {
        if (a.status == 'Active' &&
            a.deadline.isBefore(now)) {
          return a.copyWith(status: 'Closed');
        }

        return a;
      }).toList();

      _autoCloseExpired(data);

      emit(
        AnnouncementLoaded(correctedData),
      );
    },
    onError: (error, stackTrace) {
      print('❌ ANNOUNCEMENT STREAM ERROR: $error');
      print(stackTrace);

      emit(
        AnnouncementError(
          "ERROR_FETCH_ANNOUNCEMENT",
        ),
      );
    },
  );
}
  Future<void> _autoCloseExpired(
      List<AnnouncementModel> announcements) async {
    final now = DateTime.now();
    final needsClose = announcements.any(
      (a) => a.status == 'Active' && a.deadline.isBefore(now),
    );
    if (needsClose) {
      await _repository.autoCloseExpiredAnnouncements(announcements);
    }
  }

   Future<void> addAnnouncement(
  AnnouncementModel announcement, {
  String? imagePath,
}) async {
  try {
    emit(AnnouncementLoading());

    print('====================================');
    print('📢 ADD ANNOUNCEMENT START');
    print('📢 title: ${announcement.title}');
    print('📢 imagePath: $imagePath');

    // ==========================================
    // 1. رفع الصورة
    // ==========================================

    if (imagePath != null && imagePath.isNotEmpty) {
      print('📸 جاري رفع الصورة...');

      final uploadResult =
          await _repository.uploadAnnouncementImage(imagePath);

      if (uploadResult.isLeft()) {
        final error = uploadResult.fold(
          (error) => error,
          (_) => '',
        );

        print('❌ فشل رفع الصورة: $error');

        emit(AnnouncementError(error));
        return;
      }

      final imageUrl = uploadResult.getOrElse(() => '');

      print('✅ imageUrl: $imageUrl');

      announcement = announcement.copyWith(
        imageUrl: imageUrl,
      );
    }

    // ==========================================
    // 2. حفظ الإعلان في Firestore
    // ==========================================

    print('🔥 جاري حفظ الإعلان في Firestore...');

    final result = await _repository.addAnnouncement(
      announcement,
    );

    if (result.isLeft()) {
      final error = result.fold(
        (error) => error,
        (_) => '',
      );

      print('❌ فشل حفظ الإعلان: $error');

      emit(AnnouncementError(error));
      return;
    }

    final generatedId = result.getOrElse(() => '');

    print('✅ تم حفظ الإعلان في Firestore');
    print('🆔 ID: $generatedId');

    // ==========================================
    // 3. إرسال الإشعار
    // ==========================================

    print('🔔 جاري إرسال الإشعار...');

    await _broadcastAnnouncementNotification(
      announcement.copyWith(
        id: generatedId,
      ),
    );

    print('✅ تم الانتهاء من إرسال الإشعار');

    emit(
      AnnouncementActionSuccess(
        "SUCCESS_ADD_ANNOUNCEMENT",
      ),
    );

    print('📢 ADD ANNOUNCEMENT FINISHED');
    print('====================================');
  } catch (e, stackTrace) {
    print('🚨 ADD ANNOUNCEMENT ERROR: $e');
    print(stackTrace);

    emit(
      AnnouncementError(
        e.toString(),
      ),
    );
  }
}
   
   
    Future<void> _broadcastAnnouncementNotification(
    AnnouncementModel announcement,
  ) async {
    print("🔥 بداية إرسال الإشعار لـ: ${announcement.title}");
    print("🔥 الكلية: ${announcement.collegeName}");
    print("🔥 القطاع: ${announcement.adminSectorId}");
    print("🔥 الإدارة الفرعية: ${announcement.adminSubDeptId}");

    try {
      final String title = 'إعلان جديد: ${announcement.title}';
      final String body =
          announcement.description ?? 'تم نشر إشعار جديد يرجى المتابعة';

      // =================================================================
      // 1. إعلان موجه لدكاترة (كلية معينة + قسم اختياري)
      // =================================================================
      if (announcement.collegeName != null &&
          announcement.collegeName!.isNotEmpty) {
        
        print("🟢 [دكاترة] جاري البحث عن دكاترة الكلية: ${announcement.collegeName}");
        
        Query query = FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'doctor')
            .where('profile.faculty_ar', isEqualTo: announcement.collegeName);

        if (announcement.departmentName != null &&
            announcement.departmentName!.isNotEmpty) {
          print("🟢 [دكاترة] فلترة على قسم: ${announcement.departmentName}");
          query = query.where('profile.department_ar', isEqualTo: announcement.departmentName);
        }

        final snapshot = await query.get();
        print(" [دكاترة] تم إيجاد ${snapshot.docs.length} دكتور");

        //  استخدام الـ Batch عشان السرعة
        if (snapshot.docs.isNotEmpty) {
          WriteBatch batch = FirebaseFirestore.instance.batch();
          for (var doc in snapshot.docs) {
            final notifRef = FirebaseFirestore.instance
                .collection('users')
                .doc(doc.id)
                .collection('notifications')
                .doc(); // إنشاء ID تلقائي
            
            final notificationMap = AppNotificationModel(
              id: notifRef.id,
              title: title,
              message: body,
              type: NotificationType.announcementCreated,
              target: NotificationTarget.specificUser,
              timestamp: Timestamp.now(),
              receiverId: doc.id,
              relatedId: announcement.id,
            ).toMap();
            
            batch.set(notifRef, notificationMap);
          }
          await batch.commit(); // ✅ إرسال كل الإشعارات في ثانية واحدة!
        }
        return; 
      }

      // =================================================================
      // 2. إعلان موجه لموظفين/إداريين (قطاع معين + إدارة فرعية اختيارية)
      // =================================================================
      if (announcement.adminSectorId != null &&
          announcement.adminSectorId!.isNotEmpty) {
        
        print("🟢 [موظفين] جاري البحث عن موظفي القطاع: ${announcement.adminSectorId}");
        
        Query query = FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'admin_manager')
            .where('admin_data.sector_id', isEqualTo: announcement.adminSectorId);

        if (announcement.adminSubDeptId != null &&
            announcement.adminSubDeptId!.isNotEmpty) {
          print("🟢 [موظفين] فلترة على إدارة فرعية: ${announcement.adminSubDeptId}");
          query = query.where('admin_data.sub_dept_id', isEqualTo: announcement.adminSubDeptId);
        }

        final snapshot = await query.get();
        print("🟢 [موظفين] تم إيجاد ${snapshot.docs.length} موظف");

        // ✅ استخدام الـ Batch عشان السرعة
        if (snapshot.docs.isNotEmpty) {
          WriteBatch batch = FirebaseFirestore.instance.batch();
          for (var doc in snapshot.docs) {
            final notifRef = FirebaseFirestore.instance
                .collection('users')
                .doc(doc.id)
                .collection('notifications')
                .doc();
            
            final notificationMap = AppNotificationModel(
              id: notifRef.id,
              title: title,
              message: body,
              type: NotificationType.announcementCreated,
              target: NotificationTarget.specificUser,
              timestamp: Timestamp.now(),
              receiverId: doc.id,
              relatedId: announcement.id,
            ).toMap();
            
            batch.set(notifRef, notificationMap);
          }
          await batch.commit(); // ✅ إرسال كل الإشعارات في ثانية واحدة!
        }
        return; 
      }

      // =================================================================
      // 3. إعلان عام (مفيش كلية ولا قطاع)
      // =================================================================
      print("🟢 [عام] إعلان عام - بعت لكل المستخدمين");
      final notification = AppNotificationModel(
        id: '',
        title: title,
        message: body,
        type: NotificationType.announcementCreated,
        target: NotificationTarget.allUsers,
        timestamp: Timestamp.now(),
        receiverId: '',
        relatedId: announcement.id,
      );
      await _notificationRepo.sendRoleBasedNotification(notification);
      
    } catch (e) {
      print("🚨 فشل إرسال الإشعار: $e");
    }
  }
  Future<void> updateAnnouncement(
    AnnouncementModel announcement, {
    String? imagePath,
  }) async {
    emit(AnnouncementLoading());
    if (imagePath != null) {
      final uploadResult =
          await _repository.uploadAnnouncementImage(imagePath);
      if (uploadResult.isLeft()) {
        uploadResult.fold(
          (error) => emit(AnnouncementError(error)),
          (_) => null,
        );
        return;
      }
      final newImageUrl = uploadResult.getOrElse(() => '');
      if (announcement.imageUrl != null &&
          announcement.imageUrl!.isNotEmpty) {
        await _repository
            .deleteAnnouncementImage(announcement.imageUrl!);
      }
      announcement = announcement.copyWith(imageUrl: newImageUrl);
    }
    final result = await _repository.updateAnnouncement(announcement);
    result.fold(
      (error) => emit(AnnouncementError(error)),
      (_) => emit(
          AnnouncementActionSuccess("SUCCESS_UPDATE_ANNOUNCEMENT")),
    );
  }

  Future<void> deleteAnnouncement(String id, String? imageUrl) async {
    final result = await _repository.deleteAnnouncement(id, imageUrl);
    result.fold(
      (error) => emit(AnnouncementError(error)),
      (_) => emit(
          AnnouncementActionSuccess("SUCCESS_DELETE_ANNOUNCEMENT")),
    );
  }


}