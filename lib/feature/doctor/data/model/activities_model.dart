import 'package:optialeader/feature/doctor/data/model/verefication_status.dart';

// إضافة الـ Enums بتاعة تصنيف الدورات عشان محرك النقاط
enum CourseCategory { none, general, specialized, administrative }
enum CourseScope { none, local, international }

class ActivityModel {
  final String id;               
  final String type;
  final String title;
  final String organization;
  final String date;
  final int? durationHours;
  final String participationType;
  
  //  الحقول الجديدة لتصنيف الدورات التدريبية
  final CourseCategory courseCategory; // إدارية، تخصصية، عامة
  final CourseScope courseScope;       // دولية، محلية
  
  final VerificationStatus status;
  final String? proofUrl;        
  final String? proofFileType;   

  ActivityModel({
    required this.id,
    required this.type,
    required this.title,
    required this.organization,
    required this.date,
    this.durationHours,
    required this.participationType,
    this.courseCategory = CourseCategory.none, 
    this.courseScope = CourseScope.none,       
    this.status = VerificationStatus.pending,
    this.proofUrl,
    this.proofFileType,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      organization: json['organization'] ?? '',
      date: json['date'] ?? '',
      durationHours: json['duration_hours'],
      participationType: json['participation_type'] ?? '',
      
      //  قراءة الـ Enums الجديدة بأمان
      courseCategory: _parseCourseCategory(json['course_category'] ?? 'none'),
      courseScope: _parseCourseScope(json['course_scope'] ?? 'none'),
      
      status: parseVerificationStatus(json['status']),
      proofUrl: json['proofUrl'],
      proofFileType: json['proofFileType'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'organization': organization,
      'date': date,
      'duration_hours': durationHours,
      'participation_type': participationType,
      'course_category': courseCategory.name, 
      'course_scope': courseScope.name,       
      'status': status.name,
      'proofUrl': proofUrl,
      'proofFileType': proofFileType,
    };
  }

  ActivityModel copyWith({
    String? id,
    String? type,
    String? title,
    String? organization,
    String? date,
    int? durationHours,
    String? participationType,
    CourseCategory? courseCategory, 
    CourseScope? courseScope,       
    VerificationStatus? status,
    String? proofUrl,
    String? proofFileType,
  }) {
    return ActivityModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      organization: organization ?? this.organization,
      date: date ?? this.date,
      durationHours: durationHours ?? this.durationHours,
      participationType: participationType ?? this.participationType,
      courseCategory: courseCategory ?? this.courseCategory, 
      courseScope: courseScope ?? this.courseScope,         
      status: status ?? this.status,
      proofUrl: proofUrl ?? this.proofUrl,
      proofFileType: proofFileType ?? this.proofFileType,
    );
  }

  //  دوال مساعدة لتحويل الـ String للـ Enum
  static CourseCategory _parseCourseCategory(String value) {
    return CourseCategory.values.firstWhere(
      (e) => e.name == value,
      orElse: () => CourseCategory.none,
    );
  }

  static CourseScope _parseCourseScope(String value) {
    return CourseScope.values.firstWhere(
      (e) => e.name == value,
      orElse: () => CourseScope.none,
    );
  }
}