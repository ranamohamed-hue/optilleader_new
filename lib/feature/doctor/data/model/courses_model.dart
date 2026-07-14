import 'package:optialeader/feature/doctor/data/model/verefication_status.dart';

enum CourseCategory { none, general, specialized, administrative }

enum CourseScope { none, local, international }

enum CourseType { mandatory, graded }

class CourseModel {
  final String id;
  final String title;
  final String organization;
  final String date;
  final int? durationHours;

  final CourseType type;
  final CourseCategory courseCategory;
  final CourseScope courseScope;

  // ✅ تم إضافة الحقل هنا
  final bool isIcdl;

  final String certificateUrl;
  final String? certificateFileType;

  final VerificationStatus status;
  final String? rejectionReason;

  CourseModel({
    required this.id,
    required this.title,
    required this.organization,
    required this.date,
    this.durationHours,
    required this.type,
    this.courseCategory = CourseCategory.none,
    this.courseScope = CourseScope.none,
    this.isIcdl = false, // ✅ القيمة الافتراضية false
    required this.certificateUrl,
    this.certificateFileType = 'image',
    this.status = VerificationStatus.pending,
    this.rejectionReason,
  });

  /// ✅ حساب نقاط الدورة (بدون شرط الصفر للـ mandatory، شغل الـ Engine)
  double get points {
    if (courseCategory == CourseCategory.none ||
        courseScope == CourseScope.none) {
      return 0.0;
    }

    if (courseCategory == CourseCategory.administrative) {
      return courseScope == CourseScope.international ? 6.0 : 5.0;
    } else if (courseCategory == CourseCategory.specialized) {
      return courseScope == CourseScope.international ? 4.0 : 3.0;
    } else if (courseCategory == CourseCategory.general) {
      return courseScope == CourseScope.international ? 2.0 : 1.0;
    }

    return 0.0;
  }

  bool get isMandatory => type == CourseType.mandatory;

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    CourseType parseCourseType(dynamic val) {
      if (val == null || val.toString().trim().isEmpty)
        return CourseType.graded;
      final str = val.toString().trim().toLowerCase();
      return CourseType.values.firstWhere(
        (e) => e.name == str,
        orElse: () => CourseType.graded,
      );
    }

    CourseCategory parseCourseCategory(dynamic val) {
      if (val == null || val.toString().trim().isEmpty)
        return CourseCategory.none;
      final str = val.toString().trim().toLowerCase();
      return CourseCategory.values.firstWhere(
        (e) => e.name == str,
        orElse: () => CourseCategory.none,
      );
    }

    CourseScope parseCourseScope(dynamic val) {
      if (val == null || val.toString().trim().isEmpty) return CourseScope.none;
      final str = val.toString().trim().toLowerCase();
      return CourseScope.values.firstWhere(
        (e) => e.name == str,
        orElse: () => CourseScope.none,
      );
    }

    return CourseModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      organization: json['organization'] ?? '',
      date: json['date'] ?? '',
      durationHours: json['durationHours'],
      type: parseCourseType(json['type']),
      courseCategory: parseCourseCategory(json['courseCategory']),
      courseScope: parseCourseScope(json['courseScope']),
      // ✅ قراءة الحقل من قاعدة البيانات
      isIcdl: json['isIcdl'] ?? false,
      certificateUrl: json['certificateUrl'] ?? '',
      certificateFileType: json['certificateFileType'] ?? 'image',
      status: parseVerificationStatus(json['status']),
      rejectionReason: json['rejectionReason'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'organization': organization,
      'date': date,
      'durationHours': durationHours,
      'type': type.name,
      'courseCategory': courseCategory.name,
      'courseScope': courseScope.name,
      // ✅ حفظ الحقل في قاعدة البيانات
      'isIcdl': isIcdl,
      'certificateUrl': certificateUrl,
      'certificateFileType': certificateFileType,
      'status': status.name,
      'rejectionReason': rejectionReason,
    };
  }

  CourseModel copyWith({
    String? id,
    String? title,
    String? organization,
    String? date,
    int? durationHours,
    CourseType? type,
    CourseCategory? courseCategory,
    CourseScope? courseScope,
    bool? isIcdl, // ✅
    String? certificateUrl,
    String? certificateFileType,
    VerificationStatus? status,
    String? rejectionReason,
  }) {
    return CourseModel(
      id: id ?? this.id,
      title: title ?? this.title,
      organization: organization ?? this.organization,
      date: date ?? this.date,
      durationHours: durationHours ?? this.durationHours,
      type: type ?? this.type,
      courseCategory: courseCategory ?? this.courseCategory,
      courseScope: courseScope ?? this.courseScope,
      isIcdl: isIcdl ?? this.isIcdl, // ✅
      certificateUrl: certificateUrl ?? this.certificateUrl,
      certificateFileType: certificateFileType ?? this.certificateFileType,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }
}
