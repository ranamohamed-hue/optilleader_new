import 'package:cloud_firestore/cloud_firestore.dart';

class AnnouncementModel {
  String? id;
  String title;
  String description;
  String status;
  DateTime deadline;
  int applicants;
  String? imageUrl;
  String targetRole;
  DateTime createdAt;

  // ✅ حقل القطاع الجديد (لنائب الرئيس ووكيل الكلية)
  String? targetSector;

  bool? isResultAnnounced;

  String? collegeId;
  String? collegeName;
  String? departmentId;
  String? departmentName;

  String? adminSectorId;
  String? adminSectorName;
  String? adminSubDeptId;
  String? adminSubDeptName;

  // ✅ تم تحديث القائمة لتشمل كل الأدوار الموجودة في المحرك
  static const List<String> targetRoleList = [
    'general',
    'university_president', // ✅ رئيس الجامعة
    'vice_president', // ✅ نائب رئيس الجامعة
    'dean', // عميد الكلية
    'vice_dean', // وكيل الكلية
    'head_department', // رئيس القسم
    'quality_manager', // مدير الجودة
    'admin_manager', // مدير إداري
  ];

  // ✅ قائمة القطاعات الثابتة (حسب القانون)
  static const List<String> sectorList = [
    'postgraduate', // الدراسات العليا والبحوث
    'education', // شؤون التعليم والطلاب
    'environment', // خدمة المجتمع وتنمية البيئة
  ];

  static const List<String> statusList = ['Active', 'Pending', 'Closed'];

  AnnouncementModel({
    this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.deadline,
    this.applicants = 0,
    this.imageUrl,
    required this.targetRole,
    required this.createdAt,
    this.targetSector, // ✅ إضافة الحقل للكنستركتور
    this.isResultAnnounced,
    this.collegeId,
    this.collegeName,
    this.departmentId,
    this.departmentName,
    this.adminSectorId,
    this.adminSectorName,
    this.adminSubDeptId,
    this.adminSubDeptName,
  });

  factory AnnouncementModel.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    return AnnouncementModel(
      id: documentId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      status: map['status'] ?? 'Active',
      deadline: (map['deadline'] != null)
          ? (map['deadline'] as dynamic).toDate()
          : DateTime.now(),
      applicants: map['applicants'] ?? 0,
      imageUrl: map['imageUrl'],
      targetRole: map['targetRole'] ?? 'general',
      createdAt: (map['createdAt'] != null)
          ? (map['createdAt'] as dynamic).toDate()
          : DateTime.now(),
      targetSector: map['targetSector'], // ✅ قراءة القطاع
      isResultAnnounced: map['isResultAnnounced'] ?? false,
      collegeId: map['collegeId'],
      collegeName: map['collegeName'],
      departmentId: map['departmentId'],
      departmentName: map['departmentName'],
      adminSectorId: map['adminSectorId'],
      adminSectorName: map['adminSectorName'],
      adminSubDeptId: map['adminSubDeptId'],
      adminSubDeptName: map['adminSubDeptName'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'status': status,
      'deadline': Timestamp.fromDate(deadline),
      'applicants': applicants,
      'imageUrl': imageUrl,
      'targetRole': targetRole,
      'createdAt': Timestamp.fromDate(createdAt),
      'targetSector': targetSector, // ✅ حفظ القطاع
      'isResultAnnounced': isResultAnnounced ?? false,
      'collegeId': collegeId, 'collegeName': collegeName,
      'departmentId': departmentId, 'departmentName': departmentName,
      'adminSectorId': adminSectorId, 'adminSectorName': adminSectorName,
      'adminSubDeptId': adminSubDeptId, 'adminSubDeptName': adminSubDeptName,
    };
  }

  AnnouncementModel copyWith({
    String? id,
    String? title,
    String? description,
    String? status,
    DateTime? deadline,
    int? applicants,
    String? imageUrl,
    String? targetRole,
    DateTime? createdAt,
    String? targetSector, // ✅ إضافة القطاع للنسخ
    bool? isResultAnnounced,
    String? collegeId,
    String? collegeName,
    String? departmentId,
    String? departmentName,
    String? adminSectorId,
    String? adminSectorName,
    String? adminSubDeptId,
    String? adminSubDeptName,
  }) {
    return AnnouncementModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      deadline: deadline ?? this.deadline,
      applicants: applicants ?? this.applicants,
      imageUrl: imageUrl ?? this.imageUrl,
      targetRole: targetRole ?? this.targetRole,
      createdAt: createdAt ?? this.createdAt,
      targetSector: targetSector ?? this.targetSector,
      isResultAnnounced: isResultAnnounced ?? this.isResultAnnounced,
      collegeId: collegeId ?? this.collegeId,
      collegeName: collegeName ?? this.collegeName,
      departmentId: departmentId ?? this.departmentId,
      departmentName: departmentName ?? this.departmentName,
      adminSectorId: adminSectorId ?? this.adminSectorId,
      adminSectorName: adminSectorName ?? this.adminSectorName,
      adminSubDeptId: adminSubDeptId ?? this.adminSubDeptId,
      adminSubDeptName: adminSubDeptName ?? this.adminSubDeptName,
    );
  }
}
