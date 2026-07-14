import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  //  أدمن القاعدة (Database Admin)
  userLogin, userLogout, profileDataUpdated, accountSuspended,

  //  أدمن عادي (Admin)
  welcomeAdmin, announcementCreated, announcementExpired, newDoctorRequest, judgeRequestCompleted,
  
  //  إشعارات الأبحاث والأنشطة
  newResearchSubmitted, newActivitySubmitted, researchStatusUpdated, activityStatusUpdated,

  //  دكتور (Doctor)
  welcomeDoctor, newCompetition, competitionResult, requestStatusUpdate,

  //  محكم (Judge)
  welcomeJudge, newArbitrationRequest,

  // عام
  general,
}

// ✅ إضافة الـ Target لتحديد مين يشوف الإشعار
enum NotificationTarget {
  adminOnly,
  doctorOnly,
  judgeOnly,
  adminAndDoctor,
  adminAndJudge,
  allUsers,
  specificUser,
}

class AppNotificationModel {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final NotificationTarget target; // ✅ الجديد
  final bool isRead;
  final Timestamp timestamp;
  final String? relatedId;     
  final String receiverId;     
  final String? senderName;    
  final String? doctorUid;     

  AppNotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.target, // ✅ الجديد
    this.isRead = false,
    required this.timestamp,
    this.relatedId,
    required this.receiverId,
    this.senderName,
    this.doctorUid,            
  });

  // ✅ دالة copyWith عشان نقدر نغير حاجات بسيطة في الموديل بسهولة
  AppNotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    NotificationTarget? target,
    bool? isRead,
    Timestamp? timestamp,
    String? relatedId,
    String? receiverId,
    String? senderName,
    String? doctorUid,
  }) {
    return AppNotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      target: target ?? this.target,
      isRead: isRead ?? this.isRead,
      timestamp: timestamp ?? this.timestamp,
      relatedId: relatedId ?? this.relatedId,
      receiverId: receiverId ?? this.receiverId,
      senderName: senderName ?? this.senderName,
      doctorUid: doctorUid ?? this.doctorUid,
    );
  }

  factory AppNotificationModel.fromFirestore(Map<String, dynamic> json, String docId) {
    return AppNotificationModel(
      id: docId,
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: _parseType(json['type'] ?? 'general'),
      target: _parseTarget(json['target'] ?? 'allUsers'), // ✅ الجديد
      isRead: json['is_read'] ?? false,
      timestamp: json['timestamp'] ?? Timestamp.now(),
      relatedId: json['related_id'],
      receiverId: json['receiver_id'] ?? '', 
      senderName: json['sender_name'],
      doctorUid: json['doctor_uid'],        
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'message': message,
      'type': type.name,
      'target': target.name, // ✅ الجديد
      'is_read': isRead,
      'timestamp': timestamp,
      'related_id': relatedId,
      'receiver_id': receiverId,
      'sender_name': senderName,
      'doctor_uid': doctorUid,             
    };
  }

  static NotificationType _parseType(String type) {
    switch (type) {
      case 'userLogin': return NotificationType.userLogin;
      case 'userLogout': return NotificationType.userLogout;
      case 'profileDataUpdated': return NotificationType.profileDataUpdated;
      case 'accountSuspended': return NotificationType.accountSuspended;
      case 'welcomeAdmin': return NotificationType.welcomeAdmin;
      case 'announcementCreated': return NotificationType.announcementCreated;
      case 'announcementExpired': return NotificationType.announcementExpired;
      case 'newDoctorRequest': return NotificationType.newDoctorRequest;
      case 'judgeRequestCompleted': return NotificationType.judgeRequestCompleted;
      case 'newResearchSubmitted': return NotificationType.newResearchSubmitted;
      case 'newActivitySubmitted': return NotificationType.newActivitySubmitted;
      case 'researchStatusUpdated': return NotificationType.researchStatusUpdated;
      case 'activityStatusUpdated': return NotificationType.activityStatusUpdated;
      case 'welcomeDoctor': return NotificationType.welcomeDoctor;
      case 'newCompetition': return NotificationType.newCompetition;
      case 'competitionResult': return NotificationType.competitionResult;
      case 'requestStatusUpdate': return NotificationType.requestStatusUpdate;
      case 'welcomeJudge': return NotificationType.welcomeJudge;
      case 'newArbitrationRequest': return NotificationType.newArbitrationRequest;
      default: return NotificationType.general;
    }
  }

  // ✅ دالة تحويل الـ String للـ Target Enum
  static NotificationTarget _parseTarget(String target) {
    switch (target) {
      case 'adminOnly': return NotificationTarget.adminOnly;
      case 'doctorOnly': return NotificationTarget.doctorOnly;
      case 'judgeOnly': return NotificationTarget.judgeOnly;
      case 'adminAndDoctor': return NotificationTarget.adminAndDoctor;
      case 'adminAndJudge': return NotificationTarget.adminAndJudge;
      case 'specificUser': return NotificationTarget.specificUser;
      default: return NotificationTarget.allUsers;
    }
  }
}