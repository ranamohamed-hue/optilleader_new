import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:optialeader/feature/admin/data/model/announcement_model.dart';
import 'package:optialeader/feature/admin/data/repo/announcement_repos/announcement_repo.dart';
import 'package:optialeader/feature/notification/data/model/app_notification_model.dart';
import 'package:optialeader/feature/notification/data/repo/notification_repo.dart';
import 'announcement_state.dart';

class AnnouncementCubit extends Cubit<AnnouncementState> {
  final IAnnouncementRepository _repository;
  final NotificationRepo _notificationRepo;

  AnnouncementCubit(this._repository, this._notificationRepo)
      : super(AnnouncementInitial());

  void fetchAnnouncements() {
    emit(AnnouncementLoading());
    _repository.getAnnouncements().listen((data) {
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
        onError: (error) =>
            emit(AnnouncementError("ERROR_FETCH_ANNOUNCEMENT")));
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
      final imageUrl = uploadResult.getOrElse(() => '');
      announcement = announcement.copyWith(imageUrl: imageUrl);
    }
    final result = await _repository.addAnnouncement(announcement);
    result.fold((error) => emit(AnnouncementError(error)), (generatedId) {
      emit(AnnouncementActionSuccess("SUCCESS_ADD_ANNOUNCEMENT"));
      _broadcastAnnouncementNotification(
        announcement.copyWith(id: generatedId),
      );
    });
  }

  Future<void> _broadcastAnnouncementNotification(
    AnnouncementModel announcement,
  ) async {
    try {
      NotificationType type = NotificationType.announcementCreated;
      NotificationTarget target;
      switch (announcement.targetRole) {
        case 'dean':
        case 'rector':
        case 'vice_chancellor':
        case 'head_department':
        case 'vice_dean':
        case 'quality_manager':
        case 'administrative':
          target = NotificationTarget.doctorOnly;
          break;
        default:
          target = NotificationTarget.allUsers;
      }
      final notification = AppNotificationModel(
        id: '',
        title: 'إعلان جديد: ${announcement.title}',
        message:
            announcement.description ?? 'تم نشر إعلان جديد يرجى المتابعة',
        type: type,
        target: target,
        timestamp: Timestamp.now(),
        receiverId: '',
        relatedId: announcement.id,
      );
      await _notificationRepo.sendRoleBasedNotification(notification);
    } catch (e) {
      print("🚨 فشل إرسال إشعار الإعلان: $e");
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