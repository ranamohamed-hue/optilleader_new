import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:optialeader/feature/notification/data/model/app_notification_model.dart';
import 'package:optialeader/feature/notification/data/repo/notification_repo.dart';

class NotificationRepoImpl extends NotificationRepo {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  @override
  Future<Either<String, Unit>> sendNotification(AppNotificationModel notification) async {
    try {
      await firebaseFirestore
          .collection('users')
          .doc(notification.receiverId)
          .collection('notifications')
          .add(notification.toMap());
      return right(unit);
    } catch (e) {
      return left("فشل إرسال الإشعار: ${e.toString()}");
    }
  }

  @override
  Future<Either<String, Unit>> sendRoleBasedNotification(AppNotificationModel notification) async {
    try {
      final List<String> roles = _getRolesForTarget(notification.target);
            if (roles.isEmpty) return right(unit);

      final usersQuery = await firebaseFirestore
          .collection('users')
          .where('role', whereIn: roles)
          .get();

      if (usersQuery.docs.isEmpty) return right(unit);

      final int batchSize = 400;
      for (int i = 0; i < usersQuery.docs.length; i += batchSize) {
        final batch = firebaseFirestore.batch();
        final end = (i + batchSize > usersQuery.docs.length) ? usersQuery.docs.length : i + batchSize;

        for (int j = i; j < end; j++) {
          final uid = usersQuery.docs[j].id;
          final docRef = firebaseFirestore
              .collection('users')
              .doc(uid)
              .collection('notifications')
              .doc();

          final notificationMap = notification.copyWith(id: docRef.id, receiverId: uid).toMap();
          batch.set(docRef, notificationMap);
        }
        await batch.commit();
      }
      
      return right(unit);
    } catch (e) {
      return left("فشل إرسال الإشعار الجماعي: ${e.toString()}");
    }
  }

  // ✅ أضفنا distinct() لمنع التكرار نهائياً
  @override
  Stream<List<AppNotificationModel>> getNotifications(String receiverId) {
    return firebaseFirestore
        .collection('users')
        .doc(receiverId)
        .collection('notifications')
        .where('is_read', isEqualTo: false) 
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return AppNotificationModel.fromFirestore(doc.data(), doc.id);
          }).toList();
        })
        .distinct((prevList, nextList) {
          if (prevList.length != nextList.length) return false;
          final prevIds = prevList.map((e) => e.id).toSet();
          final nextIds = nextList.map((e) => e.id).toSet();
          return prevIds.containsAll(nextIds) && nextIds.containsAll(prevIds);
        });
  }

  @override
  Future<Either<String, Unit>> markAsRead(String receiverId, String notificationId) async {
    try {
      await firebaseFirestore
          .collection('users')
          .doc(receiverId)
          .collection('notifications')
          .doc(notificationId)
          .update({'is_read': true});
      return right(unit);
    } catch (e) {
      return left("فشل تحديث الإشعار: ${e.toString()}");
    }
  }

  @override
  Future<Either<String, Unit>> deleteNotification(String receiverId, String notificationId) async {
    try {
      await firebaseFirestore
          .collection('users')
          .doc(receiverId)
          .collection('notifications')
          .doc(notificationId)
          .delete();
      return right(unit);
    } catch (e) {
      return left("فشل حذف الإشعار: ${e.toString()}");
    }
  }

  // ✅ غيرنا الدالة: بدل ما تمسح المقروء، هتمسح اللي على الشاشة (غير مقروء)
  @override
  Future<void> clearAllNotifications(String receiverId) async {
    try {
      final querySnapshot = await firebaseFirestore
          .collection('users')
          .doc(receiverId)
          .collection('notifications')
          .where('is_read', isEqualTo: false) 
          .get();

      final int batchSize = 400;
      for (int i = 0; i < querySnapshot.docs.length; i += batchSize) {
        final batch = firebaseFirestore.batch();
        final end = (i + batchSize > querySnapshot.docs.length) ? querySnapshot.docs.length : i + batchSize;
        
        for (int j = i; j < end; j++) {
          batch.delete(querySnapshot.docs[j].reference);
        }
        await batch.commit();
      }
    } catch (e) {
      print("خطأ أثناء التنظيف الجماعي: $e");
    }
  }

  List<String> _getRolesForTarget(NotificationTarget target) {
    switch (target) {
      case NotificationTarget.adminOnly:
        return ['admin'];
      case NotificationTarget.doctorOnly:
        return ['doctor'];
      case NotificationTarget.judgeOnly:
        return ['judge'];
      case NotificationTarget.adminAndDoctor:
        return ['admin', 'doctor'];
      case NotificationTarget.adminAndJudge:
        return ['admin', 'judge'];
      case NotificationTarget.allUsers:
        return ['admin', 'doctor', 'judge'];
      case NotificationTarget.specificUser:
        return [];
    }
  }
}