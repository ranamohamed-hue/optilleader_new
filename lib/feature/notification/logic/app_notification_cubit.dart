import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart'; 
import 'package:optialeader/feature/notification/data/model/app_notification_model.dart';
import 'package:optialeader/feature/notification/data/repo/notification_repo.dart';
import 'package:optialeader/feature/notification/logic/app_notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> with WidgetsBindingObserver {
  final NotificationRepo notificationRepo;
  
  String userId; 
  StreamSubscription? _notificationSubscription; 

  NotificationCubit({required this.notificationRepo, required this.userId}) : super(NotificationInitial()) {
    WidgetsBinding.instance.addObserver(this);
    
    if (userId.isNotEmpty) {
      fetchNotifications();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _notificationSubscription?.pause();
    } else if (state == AppLifecycleState.resumed) {
      _notificationSubscription?.resume();
    }
  }

  void updateUserIdAndFetch(String newUserId) {
    if (newUserId.isNotEmpty && newUserId != userId) {
      userId = newUserId; 
      fetchNotifications(); 
    }
  }

  void fetchNotifications() {
    emit(NotificationLoading());
    _notificationSubscription?.cancel(); 
    
    _notificationSubscription = notificationRepo.getNotifications(userId)
      .debounceTime(const Duration(milliseconds: 300)) 
      .listen(
        (notifications) {
          emit(NotificationLoaded(notifications));
        }, 
        onError: (error) {
          print("خطأ لايف في الـ Stream للإشعارات: $error");
          emit(NotificationError("فشل جلب الإشعارات"));
        },
      );
  }

  Future<void> sendNotificationSmartly(AppNotificationModel notification) async {
    if (notification.target == NotificationTarget.specificUser && notification.receiverId.isNotEmpty) {
      await notificationRepo.sendNotification(notification);
    } else {
      await notificationRepo.sendRoleBasedNotification(notification);
    }
  }

  Future<void> markAsRead(String notificationId) async {
    await notificationRepo.markAsRead(userId, notificationId);
  }

  Future<void> deleteNotification(String notificationId) async {
    await notificationRepo.deleteNotification(userId, notificationId);
  }

  // ✅ غيرنا اسم الدالة عشان تتطابق مع الريبو
  Future<void> clearAllNotifications() async {
    await notificationRepo.clearAllNotifications(userId);
  }

  void resetOnLogout() {
    _notificationSubscription?.cancel();
    _notificationSubscription = null;
    userId = ''; 
    emit(NotificationInitial());
  }

  @override
  Future<void> close() {
    WidgetsBinding.instance.removeObserver(this); 
    _notificationSubscription?.cancel();
    return super.close();
  }
}