import 'package:optialeader/feature/notification/data/model/app_notification_model.dart';

abstract class NotificationState {}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<AppNotificationModel> notifications;
  final int unreadCount;

  NotificationLoaded(this.notifications)
      : unreadCount = notifications.where((n) => !n.isRead).length;
}

class NotificationError extends NotificationState {
  final String message;
  NotificationError(this.message);
}
