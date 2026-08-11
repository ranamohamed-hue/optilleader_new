import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:optialeader/feature/admin/data/model/announcement_model.dart';
import 'package:optialeader/feature/admin/data/repo/announcement_repos/announcement_repo.dart';
import 'package:optialeader/feature/notification/data/model/app_notification_model.dart';
import 'package:optialeader/feature/notification/data/repo/notification_repo.dart';
import 'announcement_state.dart';
import 'dart:async';

class AnnouncementCubit extends Cubit<AnnouncementState> {
  final IAnnouncementRepository _repository;
  final NotificationRepo _notificationRepo;
  final bool isAdmin; // ✅✅✅ المتغير اللي كان ناقص ✅✅✅
  
  StreamSubscription? _announcementSubscription;

  AnnouncementCubit(
    this._repository,
    this._notificationRepo, {
    this.isAdmin = false, // ✅✅✅ ووضعه في الكونستركتر ✅✅✅
  }) : super(AnnouncementInitial()) {
    fetchAnnouncements();
  }

  void fetchAnnouncements() {
    print('🚀 FETCH ANNOUNCEMENTS CALLED (${isAdmin ? "ADMIN" : "USER"})');

    emit(AnnouncementLoading());

    _announcementSubscription?.cancel();

    // ✅✅✅ لو أدمن جيب الكل، لو مستخدم عادي جيب الموجه ليهم بس ✅✅✅
    final stream = isAdmin 
        ? _repository.getAllAnnouncements() 
        : _repository.getAnnouncements();

    _announcementSubscription = stream.listen(
      (data) {
        print('📥 ANNOUNCEMENTS RECEIVED: ${data.length}');

        final now = DateTime.now();

        final correctedData = data.map((a) {
          if (a.status == 'Active' && a.deadline.isBefore(now)) {
            return a.copyWith(status: 'Closed');
          }
          return a;
        }).toList();

        _autoCloseExpired(data);

        emit(AnnouncementLoaded(correctedData));
      },
      onError: (error, stackTrace) {
        print('❌ ANNOUNCEMENT STREAM ERROR: $error');
        print(stackTrace);
        emit(AnnouncementError("ERROR_FETCH_ANNOUNCEMENT"));
      },
    );
  }

  Future<void> _autoCloseExpired(List<AnnouncementModel> announcements) async {
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

      if (imagePath != null && imagePath.isNotEmpty) {
        print('📸 جاري رفع الصورة...');
        final uploadResult = await _repository.uploadAnnouncementImage(imagePath);

        if (uploadResult.isLeft()) {
          final error = uploadResult.fold((error) => error, (_) => '');
          print('❌ فشل رفع الصورة: $error');
          emit(AnnouncementError(error));
          return;
        }

        final imageUrl = uploadResult.getOrElse(() => '');
        print('✅ imageUrl: $imageUrl');
        announcement = announcement.copyWith(imageUrl: imageUrl);
      }

      print('🔥 جاري حفظ الإعلان في Firestore...');
      final result = await _repository.addAnnouncement(announcement);

      if (result.isLeft()) {
        final error = result.fold((error) => error, (_) => '');
        print('❌ فشل حفظ الإعلان: $error');
        emit(AnnouncementError(error));
        return;
      }

      final generatedId = result.getOrElse(() => '');
      print('✅ تم حفظ الإعلان في Firestore');
      print('🆔 ID: $generatedId');

      _repository.migrateUserMatchKeys().then((result) {
        result.fold(
          (error) => print('⚠️ فحص خلفي للمستخدمين: فشل $error'),
          (count) => print('✅ فحص خلفي للمستخدمين: تم تحديث $count مستخدم'),
        );
      });

      print('🔔 جاري إرسال الإشعار...');
      await _broadcastAnnouncementNotification(
        announcement.copyWith(id: generatedId),
      );
      print('✅ تم الانتهاء من إرسال الإشعار');

      emit(AnnouncementActionSuccess("SUCCESS_ADD_ANNOUNCEMENT"));
      print('📢 ADD ANNOUNCEMENT FINISHED');
      print('====================================');
    } catch (e, stackTrace) {
      print('🚨 ADD ANNOUNCEMENT ERROR: $e');
      print(stackTrace);
      emit(AnnouncementError(e.toString()));
    }
  }

  Future<void> _broadcastAnnouncementNotification(
    AnnouncementModel announcement,
  ) async {
    print("🔥 بداية إرسال الإشعار لـ: ${announcement.title}");
    print("🔥 نوع الاستهداف: ${announcement.targetRole}");

    try {
      final String title = 'إعلان جديد: ${announcement.title}';
      final String body = announcement.description.isNotEmpty
          ? announcement.description
          : 'تم نشر إشعار جديد يرجى المتابعة';

      if (announcement.targetRole == 'general') {
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
        return;
      }

      print("🟢 [موجه] جاري البحث عن المستخدمين المستهدفين...");
      final targetUsersResult = await _repository.getTargetUserUids(announcement);

      await targetUsersResult.fold(
        (error) {
          print("🚨 فشل جلب المستخدمين المستهدفين: $error");
        },
        (targetUids) async {
          print("🟢 تم إيجاد ${targetUids.length} مستخدم مستهدف");

          if (targetUids.isEmpty) {
            print("⚠️ مفيش مستخدمين مطابقين لهذا الاستهداف");
            return;
          }

          WriteBatch batch = FirebaseFirestore.instance.batch();

          for (final uid in targetUids) {
            final notifRef = FirebaseFirestore.instance
                .collection('users')
                .doc(uid)
                .collection('notifications')
                .doc();

            final notificationMap = AppNotificationModel(
              id: notifRef.id,
              title: title,
              message: body,
              type: NotificationType.announcementCreated,
              target: NotificationTarget.specificUser,
              timestamp: Timestamp.now(),
              receiverId: uid,
              relatedId: announcement.id,
            ).toMap();

            batch.set(notifRef, notificationMap);
          }

          await batch.commit();
          print("✅ تم إرسال ${targetUids.length} إشعار بنجاح");
        },
      );
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
      final uploadResult = await _repository.uploadAnnouncementImage(imagePath);
      if (uploadResult.isLeft()) {
        uploadResult.fold(
          (error) => emit(AnnouncementError(error)),
          (_) => null,
        );
        return;
      }
      final newImageUrl = uploadResult.getOrElse(() => '');
      if (announcement.imageUrl != null && announcement.imageUrl!.isNotEmpty) {
        await _repository.deleteAnnouncementImage(announcement.imageUrl!);
      }
      announcement = announcement.copyWith(imageUrl: newImageUrl);
    }
    final result = await _repository.updateAnnouncement(announcement);
    result.fold(
      (error) => emit(AnnouncementError(error)),
      (_) => emit(AnnouncementActionSuccess("SUCCESS_UPDATE_ANNOUNCEMENT")),
    );
  }

  Future<void> deleteAnnouncement(String id, String? imageUrl) async {
    final result = await _repository.deleteAnnouncement(id, imageUrl);
    result.fold(
      (error) => emit(AnnouncementError(error)),
      (_) => emit(AnnouncementActionSuccess("SUCCESS_DELETE_ANNOUNCEMENT")),
    );
  }
}