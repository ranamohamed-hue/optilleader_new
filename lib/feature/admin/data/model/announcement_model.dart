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

  // ✅✅✅ مفاتيح المطابقة - يتم حسابها تلقائياً وحفظها في Firestore ✅✅✅
  List<String> matchKeys;

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

  // ✅ أسماء الأدوار بالعربي (للعرض في الـ UI)
  static const Map<String, String> targetRoleArNames = {
    'general': 'عام (الجميع)',
    'university_president': 'رئيس جامعة',
    'vice_president': 'نائب رئيس جامعة',
    'dean': 'عميد كلية',
    'vice_dean': 'وكيل كلية',
    'head_department': 'رئيس قسم',
    'quality_manager': 'مدير الجودة',
    'admin_manager': 'مدير إداري',
  };

  // ✅ قائمة القطاعات الثابتة (حسب القانون)
  static const Map<String, String> sectorArNames = {
    'postgraduate': 'الدراسات العليا والبحوث',
    'education': 'شؤون التعليم والطلاب',
    'environment': 'خدمة المجتمع وتنمية البيئة',
  };

  // ✅✅✅ قائمة القطاعات (للفلترة في الـ UI) ✅✅✅
  static const List<String> sectorList = [
    'postgraduate',
    'education',
    'environment',
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
    this.targetSector, 
    this.isResultAnnounced,
    this.collegeId,
    this.collegeName,
    this.departmentId,
    this.departmentName,
    this.adminSectorId,
    this.adminSectorName,
    this.adminSubDeptId,
    this.adminSubDeptName,
    this.matchKeys = const ['general'],
  });

  // ✅✅✅ دالة أمان لتحويل أي نوع تاريخ لـ DateTime ✅✅✅
  static DateTime _safeParseDate(dynamic dateField) {
    if (dateField == null) return DateTime.now();
    if (dateField is Timestamp) return dateField.toDate();
    if (dateField is String) return DateTime.tryParse(dateField) ?? DateTime.now();
    if (dateField is DateTime) return dateField;
    return DateTime.now();
  }

  // ✅✅✅ دالة أمان لتحويل match_keys من Firestore ✅✅✅
  static List<String> _safeParseMatchKeys(dynamic raw) {
    if (raw == null) return ['general'];
    if (raw is List) {
      return raw.map((e) => e.toString()).toList();
    }
    return ['general'];
  }

  factory AnnouncementModel.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    return AnnouncementModel(
      id: documentId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      status: map['status'] ?? 'Active',
      deadline: _safeParseDate(map['deadline']),
      applicants: map['applicants'] ?? 0,
      imageUrl: map['imageUrl'],
      targetRole: map['targetRole'] ?? 'general',
      createdAt: _safeParseDate(map['createdAt']),
      targetSector: map['targetSector'], 
      isResultAnnounced: map['isResultAnnounced'] ?? false,
      collegeId: map['collegeId'],
      collegeName: map['collegeName'],
      departmentId: map['departmentId'],
      departmentName: map['departmentName'],
      adminSectorId: map['adminSectorId'],
      adminSectorName: map['adminSectorName'],
      adminSubDeptId: map['adminSubDeptId'],
      adminSubDeptName: map['adminSubDeptName'],
      matchKeys: _safeParseMatchKeys(map['match_keys']),
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
      'targetSector': targetSector, 
      'isResultAnnounced': isResultAnnounced ?? false,
      'collegeId': collegeId, 'collegeName': collegeName,
      'departmentId': departmentId, 'departmentName': departmentName,
      'adminSectorId': adminSectorId, 'adminSectorName': adminSectorName,
      'adminSubDeptId': adminSubDeptId, 'adminSubDeptName': adminSubDeptName,
      'match_keys': matchKeys,
    };
  }

  // ═══════════════════════════════════════════════════════
  // ✅✅✅ حساب مفاتيح المطابقة بناءً على الاستهداف ✅✅✅
  // ═══════════════════════════════════════════════════════
  List<String> computeMatchKeys() {
    final keys = <String>[];

    switch (targetRole) {
      case 'university_president':
      case 'vice_president':
      case 'vice_dean':
      case 'quality_manager':
        keys.add('doctor');
        break;

      case 'dean':
        if (collegeName != null && collegeName!.isNotEmpty) {
          keys.add('doctor:$collegeName');
        } else {
          keys.add('doctor');
        }
        break;

      case 'head_department':
        if (collegeName != null &&
            collegeName!.isNotEmpty &&
            departmentName != null &&
            departmentName!.isNotEmpty) {
          keys.add('doctor:$collegeName:$departmentName');
        } else if (collegeName != null && collegeName!.isNotEmpty) {
          keys.add('doctor:$collegeName');
        } else {
          keys.add('doctor');
        }
        break;

      case 'admin_manager':
        keys.add('role:admin_manager');
        if (adminSectorName != null && adminSectorName!.isNotEmpty) {
          keys.add('admin_manager:$adminSectorName');
        }
        break;

      case 'general':
      default:
        keys.add('general');
        break;
    }

    // ❌❌❌ امسح الخمس سطور دول كويس ❌❌❌
    // if (!keys.contains('general')) {
    //   keys.add('general');
    // }

    return keys;
  }
  // ═══════════════════════════════════════════════════════
  // ✅✅✅ وصف من سيستلم الإعلان (لعرضه في الـ UI) ✅✅✅
  // ═══════════════════════════════════════════════════════
  String get targetDescription {
    switch (targetRole) {
      case 'general':
        return 'جميع المستخدمين';
      case 'university_president':
        return 'جميع الدكاترة (للوظيفة: رئيس جامعة)';
      case 'vice_president':
        return 'جميع الدكاترة (للوظيفة: نائب رئيس جامعة)';
      case 'vice_dean':
        return 'جميع الدكاترة (للوظيفة: وكيل كلية)';
      case 'quality_manager':
        return 'جميع الدكاترة (للوظيفة: مدير جودة)';
      case 'dean':
        if (collegeName != null && collegeName!.isNotEmpty) {
          return 'دكاترة $collegeName فقط';
        }
        return 'جميع الدكاترة (لم يتم تحديد كلية)';
      case 'head_department':
        if (collegeName != null && departmentName != null) {
          return 'دكاترة $departmentName - $collegeName فقط';
        } else if (collegeName != null) {
          return 'دكاترة $collegeName فقط';
        }
        return 'جميع الدكاترة (لم يتم تحديد كلية وقسم)';
      case 'admin_manager':
        if (adminSectorName != null && adminSectorName!.isNotEmpty) {
          return 'مديري قطاع $adminSectorName';
        }
        return 'جميع المديرين الإداريين';
      default:
        return 'جميع المستخدمين';
    }
  }

  // ═══════════════════════════════════════════════════════
  // ✅✅✅ هل يحتاج اختيار كلية؟ ✅✅✅
  // ═══════════════════════════════════════════════════════
  bool get requiresCollege {
    return targetRole == 'dean' || targetRole == 'head_department';
  }

  // ═══════════════════════════════════════════════════════
  // ✅✅✅ هل يحتاج اختيار قسم؟ ✅✅✅
  // ═══════════════════════════════════════════════════════
  bool get requiresDepartment {
    return targetRole == 'head_department';
  }

  // ═══════════════════════════════════════════════════════
  // ✅✅✅ هل يحتاج اختيار قطاع؟ ✅✅✅
  // ═══════════════════════════════════════════════════════
  bool get requiresSector {
    return targetRole == 'admin_manager';
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
    String? targetSector, 
    bool? isResultAnnounced,
    String? collegeId,
    String? collegeName,
    String? departmentId,
    String? departmentName,
    String? adminSectorId,
    String? adminSectorName,
    String? adminSubDeptId,
    String? adminSubDeptName,
    List<String>? matchKeys,
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
      matchKeys: matchKeys ?? this.matchKeys,
    );
  }
}