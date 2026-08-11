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

  factory EmployeeCourseModel.fromMap(Map<String, dynamic> map, String docId) {
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
      createdAt: (map['createdAt'] != null) ? (map['createdAt'] as dynamic).toDate() : DateTime.now(),
      rejectionReason: map['rejectionReason'],
    );
  }

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
}