import 'package:dartz/dartz.dart';
import 'package:optialeader/feature/notification/data/model/app_notification_model.dart';

abstract class NotificationRepo {
  Future<Either<String, Unit>> sendNotification(AppNotificationModel notification);
  Future<Either<String, Unit>> sendRoleBasedNotification(AppNotificationModel notification);
  
  Stream<List<AppNotificationModel>> getNotifications(String receiverId);
  
  Future<Either<String, Unit>> markAsRead(String receiverId, String notificationId);
  Future<Either<String, Unit>> deleteNotification(String receiverId, String notificationId);
  
  // ✅ الاسم الجديد اللي متوافق مع الريبو والكيوبت
  Future<void> clearAllNotifications(String receiverId);
}