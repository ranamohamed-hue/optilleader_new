import 'package:cloud_firestore/cloud_firestore.dart';

class EmployeeCourseModel {
  String? id;

  String title;
  String organization;
  String date;
  String? durationHours;
  String courseType;

  String? certificateFileUrl;
  String? certificateFileType;

  String status;
  DateTime createdAt;

  String? rejectionReason;

  EmployeeCourseModel({
    this.id,
    required this.title,
    required this.organization,
    required this.date,
    this.durationHours,
    required this.courseType,
    this.certificateFileUrl,
    this.certificateFileType,
    this.status = 'pending',
    required this.createdAt,
    this.rejectionReason,
  });

  // ============================================================
  // From Firestore
  // ============================================================

  factory EmployeeCourseModel.fromMap(
    Map<String, dynamic> map,
    String docId,
  ) {
    DateTime parseDate(dynamic value) {
      if (value == null) {
        return DateTime.now();
      }

      if (value is Timestamp) {
        return value.toDate();
      }

      if (value is DateTime) {
        return value;
      }

      if (value is String) {
        return DateTime.tryParse(value) ?? DateTime.now();
      }

      return DateTime.now();
    }

    return EmployeeCourseModel(
      id: docId,

      title: map['title'] ?? '',
      organization: map['organization'] ?? '',
      date: map['date'] ?? '',

      durationHours: map['durationHours'],

      courseType: map['courseType'] ?? 'general',

      certificateFileUrl: map['certificateFileUrl'],
      certificateFileType: map['certificateFileType'],

      status: map['status'] ?? 'pending',

      createdAt: parseDate(map['createdAt']),

      rejectionReason: map['rejectionReason'],
    );
  }

  // ============================================================
  // To Firestore
  // ============================================================

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'organization': organization,
      'date': date,
      'durationHours': durationHours,
      'courseType': courseType,

      'certificateFileUrl': certificateFileUrl,
      'certificateFileType': certificateFileType,

      'status': status,

      'createdAt': FieldValue.serverTimestamp(),

      'rejectionReason': rejectionReason,
    };
  }

  // ============================================================
  // Copy With
  // ============================================================

  EmployeeCourseModel copyWith({
    String? id,
    String? title,
    String? organization,
    String? date,
    String? durationHours,
    String? courseType,
    String? certificateFileUrl,
    String? certificateFileType,
    String? status,
    DateTime? createdAt,
    String? rejectionReason,
  }) {
    return EmployeeCourseModel(
      id: id ?? this.id,

      title: title ?? this.title,
      organization: organization ?? this.organization,
      date: date ?? this.date,
      durationHours: durationHours ?? this.durationHours,
      courseType: courseType ?? this.courseType,

      certificateFileUrl:
          certificateFileUrl ?? this.certificateFileUrl,

      certificateFileType:
          certificateFileType ?? this.certificateFileType,

      status: status ?? this.status,

      createdAt: createdAt ?? this.createdAt,

      rejectionReason:
          rejectionReason ?? this.rejectionReason,
    );
  }
}