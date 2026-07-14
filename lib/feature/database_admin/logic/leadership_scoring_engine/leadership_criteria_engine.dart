import 'package:optialeader/feature/database_admin/data/models/doctor_profile_model.dart';
import 'package:optialeader/feature/doctor/data/model/verefication_status.dart';

/// ============================================================
///  فحص الشروط الإلزامية للترشح للوظائف القيادية
/// ============================================================
class LeadershipCriteriaEngine {
  /// دالة رئيسية لتقييم الشروط
  static List<CriterionStatus> checkMandatoryCriteria({
    required DoctorProfileModel doctor,
    required String targetRole,
    List<DoctorProfileModel> departmentDoctors = const [],
  }) {
    final List<CriterionStatus> criteria = [];

    // 1. الشروط الأساسية المشتركة
    criteria.addAll(_getCommonCriteria(doctor));

    // 2. الشروط الخاصة بكل وظيفة
    switch (targetRole) {
      case 'dean':
        criteria.addAll(_getDeanCriteria(doctor));
        break;
      case 'vice_dean':
        criteria.addAll(_getViceDeanCriteria(doctor));
        break;
      case 'head_department':
        criteria.addAll(_getHeadDepartmentCriteria(doctor, departmentDoctors));
        break;
      case 'quality_manager':
        criteria.addAll(_getQualityManagerCriteria(doctor));
        break;
      case 'admin_manager':
        criteria.addAll(_getAdminManagerCriteria(doctor));
        break;
    }

    return criteria;
  }

  // ============================================================
  // الشروط المشتركة
  // ============================================================
  static List<CriterionStatus> _getCommonCriteria(DoctorProfileModel doctor) {
    return [
      CriterionStatus(
        titleAr: "أن يكون مصري الجنسية",
        titleEn: "Must be Egyptian",
        isMet: _isEgyptian(doctor), 
        isAutoChecked: true,
      ),
      CriterionStatus(
        titleAr: "ألا يكون سبق الحكم عليه بعقوبة جناية أو مخلة بالشرف",
        titleEn: "No criminal record",
        isMet: !doctor.hasCriminalRecord,
        isAutoChecked: true,
      ),
      CriterionStatus(
        titleAr: "ألا يكون قد وقع عليه جزاء تأديبي (ما لم يكن تم محوه)",
        titleEn: "No disciplinary penalties",
        isMet: doctor.disciplinaryClearance,
        isAutoChecked: true,
      ),
      CriterionStatus(
        titleAr: "ألا يكون متولياً لأي منصب حزبي",
        titleEn: "No party position",
        isMet: !doctor.holdsPartyPosition,
        isAutoChecked: true,
      ),
      CriterionStatus(
        titleAr: "إجادة التعامل مع الحاسب الآلي (ICDL)",
        titleEn: "Computer skills (ICDL)",
        isMet: doctor.hasICDL,
        isAutoChecked: true,
      ),
      CriterionStatus(
        titleAr: "إتمام دورتين تدريبيتين على الأقل في مجالات القيادة",
        titleEn: "At least 2 Leadership Training Courses",
        isMet: _hasRequiredLeadershipCourses(doctor), 
        isAutoChecked: true,
      ),
    ];
  }

  // ============================================================
  // شروط العميد
  // ============================================================
  static List<CriterionStatus> _getDeanCriteria(DoctorProfileModel doctor) {
    final yearsAsProf = _calculateYearsSince(doctor.professorRankDate);

    return [
      CriterionStatus(
        titleAr: "أن يكون في منصب أستاذ لمدة 3 سنوات على الأقل",
        titleEn: "Held Professor position for at least 3 years",
        isMet: _hasProfessorDegree(doctor) && yearsAsProf >= 3, 
        isAutoChecked: true,
        details: yearsAsProf > 0 ? "عدد السنوات: $yearsAsProf سنة" : null,
      ),
      CriterionStatus(
        titleAr: "الحصول على درجة الدكتوراه",
        titleEn: "Holds a PhD",
        isMet: _hasPhdDegree(doctor), 
        isAutoChecked: true,
      ),
      CriterionStatus(
        titleAr: "ألا يكون سبق له شغل الوظيفة لمدتين كاملتين (6 سنوات)",
        titleEn: "Has not served for two full terms",
        isMet: !doctor.previousLeadershipRoles.contains('dean'),
        isAutoChecked: true,
      ),
      CriterionStatus(
        titleAr: "التمتع بالسلامة الصحية والقدرة على العمل لساعات طويلة",
        titleEn: "Good health and ability to work long hours",
        isMet: doctor.hasHealthCertificate ?? false,
        isAutoChecked: true,
      ),
    ];
  }

  // ============================================================
  // شروط وكيل الكلية
  // ============================================================
  static List<CriterionStatus> _getViceDeanCriteria(DoctorProfileModel doctor) {
    return [
      ..._getDeanCriteria(doctor),
      CriterionStatus(
        titleAr: "العضوية في إحدى لجان الجامعة",
        titleEn: "Membership in a University Committee",
        isMet: _hasInternalCommittees(doctor), 
        isAutoChecked: true,
        details: doctor.internalCommittees.isNotEmpty
            ? doctor.internalCommittees.join(' • ')
            : null,
      ),
    ];
  }

  // ============================================================
  // شروط رئيس القسم
  // ============================================================
  static List<CriterionStatus> _getHeadDepartmentCriteria(
    DoctorProfileModel doctor,
    List<DoctorProfileModel> departmentDoctors,
  ) {
    bool isTop3 = false;
    String? details;

    if (departmentDoctors.isNotEmpty) {
      final profsInDept = departmentDoctors.where((d) {
        return d.departmentAr == doctor.departmentAr &&
            d.professorRankDate != null &&
            d.uid != null;
      }).toList();

      if (profsInDept.isNotEmpty) {
        profsInDept.sort(
          (a, b) => a.professorRankDate!.compareTo(b.professorRankDate!),
        );

        final top3Uids = profsInDept.take(3).map((d) => d.uid!).toSet();

        isTop3 = top3Uids.contains(doctor.uid);
        details = isTop3
            ? "يقع ضمن أقدم 3 أساتذة بالقسم"
            : "غير ضمن أقدم 3 أساتذة القسم (عدد الأساتذة: ${profsInDept.length})";
      } else {
        details = "لا يوجد بيانات أستاذية كافية لقسمك للتحقق التلقائي";
      }
    } else {
      isTop3 = doctor.isTop3Senior ?? false; 
      details = "لم يتم التحقق التلقائي (يعتمد على الإدخال اليدوي للأدمن)";
    }

    return [
      CriterionStatus(
        titleAr: "أن يكون ضمن أقدم 3 أساتذة بالقسم",
        titleEn: "Top 3 Senior Professors",
        isMet: isTop3,
        isAutoChecked: true,
        details: details,
      ),
      CriterionStatus(
        titleAr: "ألا يكون سبق له شغل رئاسة القسم أكثر من مرة",
        titleEn: "Max 1 previous Head appointment",
        isMet: !doctor.previousLeadershipRoles.contains('head_department'),
        isAutoChecked: true,
      ),
      CriterionStatus(
        titleAr: "المشاركة في اللجان الداخلية بالجامعة",
        titleEn: "Participation in internal university committees",
        isMet: _hasInternalCommittees(doctor),
        isAutoChecked: true,
      ),
    ];
  }

  // ============================================================
  // شروط مدير الجودة و القيادات الإدارية
  // ============================================================
  static List<CriterionStatus> _getQualityManagerCriteria(DoctorProfileModel doctor) {
    return [
      CriterionStatus(
        titleAr: "المشاركة في اللجان الداخلية بالجامعة",
        titleEn: "Participation in internal university committees",
        isMet: _hasInternalCommittees(doctor),
        isAutoChecked: true,
      ),
      // أضف باقي شروط مدير الجودة هنا إن لزم
    ];
  }

  static List<CriterionStatus> _getAdminManagerCriteria(DoctorProfileModel doctor) {
    return [
      CriterionStatus(
        titleAr: "المشاركة في اللجان الداخلية بالجامعة",
        titleEn: "Participation in internal university committees",
        isMet: _hasInternalCommittees(doctor),
        isAutoChecked: true,
      ),
      // أضف باقي شروط مدير الإدارة هنا إن لزم
    ];
  }


  ///  التحقق من الجنسية المصرية (من حقل nationalityAr أو nationalityEn)
  static bool _isEgyptian(DoctorProfileModel doctor) {
    final natAr = _normalizeArabic(doctor.nationalityAr.toLowerCase());
    final natEn = doctor.nationalityEn.toLowerCase();
    return natAr.contains('مصري') || natEn.contains('egyptian');
  }

  ///  التحقق من الدورات القيادية الإجبارية (الـ 2 دورات)
  static bool _hasRequiredLeadershipCourses(DoctorProfileModel doctor) {
    int count = 0;
    for (var course in doctor.courses) {
      // نحسب فقط الدورات المعتمدة والمصنفة كإجبارية (قيادية)
      if (course.isMandatory && course.status == VerificationStatus.approved) {
        count++;
      }
    }
    return count >= 2;
  }

  ///  التحقق من اللجان الداخلية (القائمة مش فاضية)
  static bool _hasInternalCommittees(DoctorProfileModel doctor) {
    return doctor.internalCommittees.isNotEmpty;
  }

  ///  التحقق من درجة الأستاذية (من السجل الأكاديمي)
  static bool _hasProfessorDegree(DoctorProfileModel doctor) {
    return doctor.academicHistory.any((h) {
      if (h['degree'] == null) return false;
      final deg = _normalizeArabic((h['degree'] as String).toLowerCase());
      return deg.contains('استاذ') || deg.contains('بروفيسور') || deg.contains('professor');
    });
  }

  ///  التحقق من درجة الدكتوراه (من السجل الأكاديمي)
  static bool _hasPhdDegree(DoctorProfileModel doctor) {
    return doctor.academicHistory.any((h) {
      if (h['degree'] == null) return false;
      final deg = _normalizeArabic((h['degree'] as String).toLowerCase());
      return deg.contains('دكتوراه') || deg.contains('phd') || deg.contains('دكتور');
    });
  }

  ///  حساب عدد السنوات منذ تاريخ معين (لحساب سنوات الأستاذية)
  static int _calculateYearsSince(DateTime? startDate) {
    if (startDate == null) return 0;
    final now = DateTime.now();
    int years = now.year - startDate.year;
    if (now.month < startDate.month || 
        (now.month == startDate.month && now.day < startDate.day)) {
      years--;
    }
    return years < 0 ? 0 : years;
  }

  ///  دالة تنظيف النصوص العربية عشان المقارنة تكون دقيقة
  static String _normalizeArabic(String text) {
    return text
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي');
  }
}

/// موديل حالة الشرط
class CriterionStatus {
  final String titleAr;
  final String titleEn;
  final bool isMet;
  final bool isAutoChecked;
  final String? details;

  CriterionStatus({
    required this.titleAr,
    required this.titleEn,
    required this.isMet,
    this.isAutoChecked = true,
    this.details,
  });
}