import 'package:optialeader/feature/doctor/data/model/verefication_status.dart';

enum CourseCategory {
  none,
  general,
  specialized,
  administrative,
}

enum CourseScope {
  none,
  local,
  international,
}

enum CourseType {
  mandatory,
  graded,
}

class CourseModel {
  final String id;
  final String title;
  final String organization;
  final String date;
  final int? durationHours;

  final CourseType type;
  final CourseCategory courseCategory;
  final CourseScope courseScope;

  // ==========================================================
  // ✅ مفتاح الدورة الإلزامية
  //
  // يأتي من MandatoryLeadershipData
  //
  // مثال:
  // addActivity.mandatory_course_1
  // ==========================================================
  final String? mandatoryKey;

  // ==========================================================
  // ✅ هل الدورة ICDL؟
  // ==========================================================
  final bool isIcdl;

  // ==========================================================
  // ملف الشهادة
  // ==========================================================
  final String certificateUrl;
  final String? certificateFileType;

  // ==========================================================
  // حالة اعتماد الدورة
  // ==========================================================
  final VerificationStatus status;

  // سبب الرفض إن وجد
  final String? rejectionReason;

  // ==========================================================
  // Constructor
  // ==========================================================
  CourseModel({
    required this.id,
    required this.title,
    required this.organization,
    required this.date,
    this.durationHours,

    required this.type,

    this.courseCategory = CourseCategory.none,
    this.courseScope = CourseScope.none,

    // ✅ مفتاح الدورة الإلزامية
    this.mandatoryKey,

    // ✅ ICDL
    this.isIcdl = false,

    required this.certificateUrl,

    this.certificateFileType = 'image',

    // ✅ أي دورة جديدة تبدأ قيد المراجعة
    this.status = VerificationStatus.pending,

    this.rejectionReason,
  });

  // ==========================================================
  // Sentinel لـ copyWith
  //
  // الهدف:
  // نفرق بين:
  //
  // copyWith()
  // => الاحتفاظ بالقيمة القديمة
  //
  // copyWith(mandatoryKey: null)
  // => مسح القيمة القديمة فعلًا
  // ==========================================================

  static const Object _notProvided = Object();

  // ==========================================================
  // حساب نقاط الدورة
  // ==========================================================

  double get points {
    // ----------------------------------------------------------
    // الدورات الإلزامية لا تحصل على نقاط
    // ----------------------------------------------------------
    if (type == CourseType.mandatory) {
      return 0.0;
    }

    // ----------------------------------------------------------
    // لو الفئة أو النطاق غير محدد
    // ----------------------------------------------------------
    if (courseCategory == CourseCategory.none ||
        courseScope == CourseScope.none) {
      return 0.0;
    }

    // ----------------------------------------------------------
    // الدورات الإدارية
    // ----------------------------------------------------------
    if (courseCategory == CourseCategory.administrative) {
      return courseScope == CourseScope.international
          ? 6.0
          : 5.0;
    }

    // ----------------------------------------------------------
    // الدورات التخصصية
    // ----------------------------------------------------------
    if (courseCategory == CourseCategory.specialized) {
      return courseScope == CourseScope.international
          ? 4.0
          : 3.0;
    }

    // ----------------------------------------------------------
    // الدورات العامة
    // ----------------------------------------------------------
    if (courseCategory == CourseCategory.general) {
      return courseScope == CourseScope.international
          ? 2.0
          : 1.0;
    }

    return 0.0;
  }

  // ==========================================================
  // هل الدورة إلزامية؟
  // ==========================================================

  bool get isMandatory {
    return type == CourseType.mandatory;
  }

  // ==========================================================
  // هل الدورة من الدورات القيادية المحددة؟
  // ==========================================================

  bool get isMandatoryLeadershipCourse {
    return isMandatory &&
        mandatoryKey != null &&
        mandatoryKey!.trim().isNotEmpty;
  }

  // ==========================================================
  // fromJson
  // ==========================================================

  factory CourseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    // --------------------------------------------------------
    // Parse CourseType
    // --------------------------------------------------------
    CourseType parseCourseType(dynamic val) {
      if (val == null ||
          val.toString().trim().isEmpty) {
        return CourseType.graded;
      }

      final str = val
          .toString()
          .trim()
          .toLowerCase();

      return CourseType.values.firstWhere(
        (e) => e.name == str,
        orElse: () => CourseType.graded,
      );
    }

    // --------------------------------------------------------
    // Parse CourseCategory
    // --------------------------------------------------------
    CourseCategory parseCourseCategory(
      dynamic val,
    ) {
      if (val == null ||
          val.toString().trim().isEmpty) {
        return CourseCategory.none;
      }

      final str = val
          .toString()
          .trim()
          .toLowerCase();

      return CourseCategory.values.firstWhere(
        (e) => e.name == str,
        orElse: () => CourseCategory.none,
      );
    }

    // --------------------------------------------------------
    // Parse CourseScope
    // --------------------------------------------------------
    CourseScope parseCourseScope(
      dynamic val,
    ) {
      if (val == null ||
          val.toString().trim().isEmpty) {
        return CourseScope.none;
      }

      final str = val
          .toString()
          .trim()
          .toLowerCase();

      return CourseScope.values.firstWhere(
        (e) => e.name == str,
        orElse: () => CourseScope.none,
      );
    }

    return CourseModel(
      id: json['id'] ?? '',

      title: json['title'] ?? '',

      organization:
          json['organization'] ?? '',

      date: json['date'] ?? '',

      durationHours:
          json['durationHours'],

      type: parseCourseType(
        json['type'],
      ),

      courseCategory:
          parseCourseCategory(
        json['courseCategory'],
      ),

      courseScope:
          parseCourseScope(
        json['courseScope'],
      ),

      // ======================================================
      // ✅ قراءة mandatoryKey
      // ======================================================
      mandatoryKey:
          json['mandatoryKey'],

      // ======================================================
      // ✅ قراءة ICDL
      // ======================================================
      isIcdl:
          json['isIcdl'] ?? false,

      // ======================================================
      // ملف الشهادة
      // ======================================================
      certificateUrl:
          json['certificateUrl'] ?? '',

      certificateFileType:
          json['certificateFileType'] ??
              'image',

      // ======================================================
      // حالة الاعتماد
      // ======================================================
      status:
          parseVerificationStatus(
        json['status'],
      ),

      // ======================================================
      // سبب الرفض
      // ======================================================
      rejectionReason:
          json['rejectionReason'],
    );
  }

  // ==========================================================
  // toMap
  // ==========================================================

  Map<String, dynamic> toMap() {
    return {
      'id': id,

      'title': title,

      'organization':
          organization,

      'date': date,

      'durationHours':
          durationHours,

      'type':
          type.name,

      'courseCategory':
          courseCategory.name,

      'courseScope':
          courseScope.name,

      // ======================================================
      // ✅ حفظ mandatoryKey
      // ======================================================
      'mandatoryKey':
          mandatoryKey,

      // ======================================================
      // ✅ حفظ ICDL
      // ======================================================
      'isIcdl':
          isIcdl,

      // ======================================================
      // ملف الشهادة
      // ======================================================
      'certificateUrl':
          certificateUrl,

      'certificateFileType':
          certificateFileType,

      // ======================================================
      // حالة الاعتماد
      // ======================================================
      'status':
          status.name,

      // ======================================================
      // سبب الرفض
      // ======================================================
      'rejectionReason':
          rejectionReason,
    };
  }

  // ==========================================================
  // copyWith
  // ==========================================================

  CourseModel copyWith({
    String? id,
    String? title,
    String? organization,
    String? date,
    int? durationHours,

    CourseType? type,
    CourseCategory? courseCategory,
    CourseScope? courseScope,

    // ========================================================
    // ✅ Object? بدل String?
    //
    // عشان نقدر نفرق بين:
    //
    // عدم إرسال القيمة
    // وإرسال null لمسحها
    // ========================================================
    Object? mandatoryKey = _notProvided,

    bool? isIcdl,

    String? certificateUrl,
    String? certificateFileType,

    VerificationStatus? status,
    String? rejectionReason,
  }) {
    return CourseModel(
      id: id ?? this.id,

      title: title ?? this.title,

      organization:
          organization ?? this.organization,

      date: date ?? this.date,

      durationHours:
          durationHours ?? this.durationHours,

      type: type ?? this.type,

      courseCategory:
          courseCategory ??
              this.courseCategory,

      courseScope:
          courseScope ??
              this.courseScope,

      // ======================================================
      // ✅ mandatoryKey
      //
      // لو لم يتم إرساله => القديم
      // لو أرسل null => يتم مسحه
      // لو أرسل String => يتم تحديثه
      // ======================================================
      mandatoryKey:
          identical(
                  mandatoryKey,
                  _notProvided,
                )
              ? this.mandatoryKey
              : mandatoryKey as String?,

      // ======================================================
      // ✅ ICDL
      // ======================================================
      isIcdl:
          isIcdl ?? this.isIcdl,

      certificateUrl:
          certificateUrl ??
              this.certificateUrl,

      certificateFileType:
          certificateFileType ??
              this.certificateFileType,

      status:
          status ?? this.status,

      rejectionReason:
          rejectionReason ??
              this.rejectionReason,
    );
  }
}