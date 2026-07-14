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

  // ✅✅✅ الحقل الجديد لتحديد هل تم إعلان النتيجة
  bool? isResultAnnounced;

  // 🏛️ بيانات الكلية والقسم (للأدوار الأكاديمية)
  String? collegeId;
  String? collegeName;
  String? departmentId;
  String? departmentName;

  // 📋 بيانات الإدارة (للدور الإداري admin_manager)
  String? adminSectorId;
  String? adminSectorName;
  String? adminSubDeptId;
  String? adminSubDeptName;

  static const List<String> targetRoleList = [
    'general',
    'dean',
    'vice_dean',
    'head_department',
    'quality_manager',
    'admin_manager',
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
    this.isResultAnnounced, // ✅ أضيف هنا
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
      isResultAnnounced: map['isResultAnnounced'] ?? false, // ✅ أضيف هنا
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
      // isResultAnnounced مش محتاج هنا لأنه بيتحدث من الكيوبت مباشرة
      'collegeId': collegeId,
      'collegeName': collegeName,
      'departmentId': departmentId,
      'departmentName': departmentName,
      'adminSectorId': adminSectorId,
      'adminSectorName': adminSectorName,
      'adminSubDeptId': adminSubDeptId,
      'adminSubDeptName': adminSubDeptName,
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
    bool? isResultAnnounced, // ✅ أضيف هنا
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
      isResultAnnounced: isResultAnnounced ?? this.isResultAnnounced, // ✅ أضيف هنا
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