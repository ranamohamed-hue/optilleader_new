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
    String? sector,
    List<DoctorProfileModel> departmentDoctors = const [],
  }) {
    final List<CriterionStatus> criteria = [];

    // 1. الشروط الأساسية المشتركة
    criteria.addAll(_getCommonCriteria(doctor));

    // 2. الشروط الخاصة بكل وظيفة
    switch (targetRole) {
      case 'university_president':
        criteria.addAll(_getUniversityPresidentCriteria(doctor));
        break;
      case 'vice_president':
        criteria.addAll(_getVicePresidentCriteria(doctor, sector ?? ''));
        break;
      case 'vice_dean':
        criteria.addAll(_getViceDeanSectorCriteria(doctor, sector ?? ''));
        break;
      case 'dean':
        criteria.addAll(_getDeanCriteria(doctor));
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
  // (1) الشروط المشتركة
  // ============================================================
  static List<CriterionStatus> _getCommonCriteria(DoctorProfileModel doctor) {
    return [
      CriterionStatus(
        titleAr: "أن يكون مصري الجنسية",
        titleEn: "Must be of Egyptian Nationality",
        isMet: _isEgyptian(doctor),
        isAutoChecked: true,
      ),
      CriterionStatus(
        titleAr: "ألا يكون سبق الحكم عليه بعقوبة جناية أو مخلة بالشرف أو الأمانة",
        titleEn: "Must not have been convicted of a felony or a crime involving dishonor or breach of trust",
        isMet: !doctor.hasCriminalRecord,
        isAutoChecked: true,
      ),
      CriterionStatus(
        titleAr: "ألا يكون قد وقع عليه جزاء تأديبي (ما لم يكن قد تم محوه قانوناً)",
        titleEn: "Must have a clean disciplinary record (unless legally expunged)",
        isMet: doctor.disciplinaryClearance,
        isAutoChecked: true,
      ),
      CriterionStatus(
        titleAr: "ألا يكون متولياً لأي منصب حزبي وقت الترشح وطوال فترة المنصب",
        titleEn: "Must not hold any political party position during nomination or tenure",
        isMet: !doctor.holdsPartyPosition,
        isAutoChecked: true,
      ),
      CriterionStatus(
        titleAr: "إجادة التعامل مع الحاسب الآلي (ICDL أو ما يعادلها)",
        titleEn: "Proficiency in Computer Skills (ICDL or equivalent)",
        isMet: doctor.hasICDL,
        isAutoChecked: true,
      ),
      CriterionStatus(
        titleAr: "إتمام دورتين تدريبيتين على الأقل في مجالات القيادة والإدارة",
        titleEn: "Completion of at least 2 training courses in Leadership and Management",
        isMet: _hasRequiredLeadershipCourses(doctor),
        isAutoChecked: true,
      ),
    ];
  }

  // ============================================================
  // (2) شروط رئيس الجامعة
  // ============================================================
  static List<CriterionStatus> _getUniversityPresidentCriteria(DoctorProfileModel doctor) {
    final yearsAsProf = _calculateYearsSince(doctor.professorRankDate);
    final yearsOnDuty = _calculateYearsSince(doctor.activeDutySinceDate);

    return [
      CriterionStatus(
        titleAr: "أن يكون من الأساتذة العاملين (تحت سن الستين)",
        titleEn: "Must be a working Professor (Under 60 years of age)",
        isMet: _hasProfessorDegree(doctor) && _isUnder60(doctor),
        isAutoChecked: true,
        details: "العمر: ${_calculateAge(doctor.birthDate)} سنة",
      ),
      CriterionStatus(
        titleAr: "أن يكون قد شغل وظيفة أستاذ لمدة 5 سنوات على الأقل",
        titleEn: "Must have held the rank of Professor for at least 5 years",
        isMet: _hasProfessorDegree(doctor) && yearsAsProf >= 5,
        isAutoChecked: true,
        details: "عدد السنوات: $yearsAsProf سنة",
      ),
      CriterionStatus(
        titleAr: "التواجد على رأس العمل بالجامعة لمدة سنتين متصلتين على الأقل قبل الترشح",
        titleEn: "Must have been actively on duty at the university for at least 2 consecutive years prior to nomination",
        isMet: !_isOnLeaveOrSeconded(doctor) && yearsOnDuty >= 2,
        isAutoChecked: true,
        details: "مدة التواجد الفعلي: $yearsOnDuty سنة",
      ),
      CriterionStatus(
        titleAr: "ألا يكون سبق له شغل المنصب لأكثر من دورة واحدة (4 سنوات)",
        titleEn: "Must not have served in this position for more than one term (4 years)",
        isMet: !_hasExceededTermLimits(doctor, 'university_president', maxTerms: 1),
        isAutoChecked: true,
      ),
      CriterionStatus(
        titleAr: "إتمام الدورة التدريبية الإلزامية المعتمدة من المجلس الأعلى للجامعات",
        titleEn: "Completion of the mandatory training approved by the Supreme Council of Universities",
        isMet: doctor.hasSupremeCouncilTraining ?? false,
        isAutoChecked: true,
      ),
      CriterionStatus(
        titleAr: "تقديم خطة عمل متكاملة لتطوير الجامعة (أكاديمياً وإدارياً ومالياً) ومعتمدة",
        titleEn: "Submission of an approved comprehensive development plan",
        isMet: _hasApprovedWorkPlan(doctor),
        isAutoChecked: false,
        details: _getWorkPlanDetails(doctor),
      ),
    ];
  }

  // ============================================================
  // (3) شروط نائب رئيس الجامعة
  // ============================================================
  static List<CriterionStatus> _getVicePresidentCriteria(DoctorProfileModel doctor, String sector) {
    final yearsAsProf = _calculateYearsSince(doctor.professorRankDate);

    return [
      CriterionStatus(
        titleAr: "أن يكون من الأساتذة العاملين بالجامعة (تحت سن الستين)",
        titleEn: "Must be a working Professor at the university (Under 60)",
        isMet: _hasProfessorDegree(doctor) && _isUnder60(doctor),
        isAutoChecked: true,
      ),
      CriterionStatus(
        titleAr: "أن يكون قد شغل وظيفة أستاذ لمدة 5 سنوات على الأقل",
        titleEn: "Must have held the rank of Professor for at least 5 years",
        isMet: _hasProfessorDegree(doctor) && yearsAsProf >= 5,
        isAutoChecked: true,
        details: "عدد السنوات: $yearsAsProf سنة",
      ),
      CriterionStatus(
        titleAr: "التواجد الفعلي على رأس العمل وقت التقدم",
        titleEn: "Must be actively on duty at the time of application",
        isMet: !_isOnLeaveOrSeconded(doctor),
        isAutoChecked: true,
      ),
      CriterionStatus(
        titleAr: "ألا يكون قد شغل نفس القطاع لأكثر من مرتين متتاليتين",
        titleEn: "Must not have served the same sector for more than two consecutive terms",
        isMet: !_hasExceededSectorTermLimits(doctor, 'vice_president', sector, maxTerms: 2),
        isAutoChecked: true,
      ),
      CriterionStatus(
        titleAr: "إتمام الدورة التدريبية الإلزامية لقيادة القطاعات (المجلس الأعلى)",
        titleEn: "Completion of the mandatory sectoral leadership training",
        isMet: doctor.hasSupremeCouncilTraining ?? false,
        isAutoChecked: true,
      ),
      CriterionStatus(
        titleAr: "تقديم خطة عمل وتصور لتطوير القطاع المستهدف (معتمدة)",
        titleEn: "Submission of an approved development plan for the targeted sector",
        isMet: _hasApprovedWorkPlan(doctor),
        isAutoChecked: false,
      ),
    ];
  }

  // ============================================================
  // (4) شروط وكيل الكلية
  // ============================================================
  static List<CriterionStatus> _getViceDeanSectorCriteria(DoctorProfileModel doctor, String sector) {
    final yearsAsProf = _calculateYearsSince(doctor.professorRankDate);

    return [
      CriterionStatus(
        titleAr: "أن يكون من الأساتذة العاملين بالكلية (تحت سن الستين)",
        titleEn: "Must be a working Professor at the faculty (Under 60)",
        isMet: _hasProfessorDegree(doctor) && _isUnder60(doctor),
        isAutoChecked: true,
      ),
      CriterionStatus(
        titleAr: "أن يكون قد شغل وظيفة أستاذ لمدة سنة واحدة على الأقل",
        titleEn: "Must have held the rank of Professor for at least 1 year",
        isMet: _hasProfessorDegree(doctor) && yearsAsProf >= 1,
        isAutoChecked: true,
        details: "عدد السنوات: $yearsAsProf سنة",
      ),
      CriterionStatus(
        titleAr: "أن يكون قائماً على رأس العمل ومقيداً بقسمه العلمي بصفة فعلية",
        titleEn: "Must be actively on duty and officially assigned to their department",
        isMet: !_isOnLeaveOrSeconded(doctor),
        isAutoChecked: true,
      ),
      CriterionStatus(
        titleAr: "ألا يكون قد شغل المنصب لمدة تزيد عن 6 سنوات متصلة (دورتين)",
        titleEn: "Must not have served for more than 6 consecutive years (two terms)",
        isMet: !_hasExceededTermLimits(doctor, 'vice_dean', maxTerms: 2),
        isAutoChecked: true,
      ),
      CriterionStatus(
        titleAr: "إتمام الدورات الإدارية والقانونية بمركز تنمية قدرات أعضاء هيئة التدريس (FLDC)",
        titleEn: "Completion of administrative training at FLDC",
        isMet: doctor.hasFLDCTraining ?? false,
        isAutoChecked: true,
      ),
      CriterionStatus(
        titleAr: "تقديم تصور ومقترح إداري مصغر لتطوير القطاع المستهدف (معتمد)",
        titleEn: "Submission of an approved mini-administrative proposal",
        isMet: _hasApprovedWorkPlan(doctor),
        isAutoChecked: false,
      ),
    ];
  }

  // ============================================================
  // (5) شروط العميد (تم تصحيح الخطأ هنا)
  // ============================================================
  static List<CriterionStatus> _getDeanCriteria(DoctorProfileModel doctor) {
    final yearsAsProf = _calculateYearsSince(doctor.professorRankDate);

    return [
      CriterionStatus(
        titleAr: "أن يكون في منصب أستاذ لمدة 3 سنوات على الأقل",
        titleEn: "Must have held the rank of Professor for at least 3 years",
        isMet: _hasProfessorDegree(doctor) && yearsAsProf >= 3,
        isAutoChecked: true,
        details: yearsAsProf > 0 ? "عدد السنوات: $yearsAsProf سنة" : null,
      ),
      CriterionStatus(
        titleAr: "الحصول على درجة الدكتوراه",
        titleEn: "Must hold a Ph.D. degree",
        isMet: _hasPhdDegree(doctor),
        isAutoChecked: true,
      ),
      CriterionStatus(
        titleAr: "ألا يكون سبق له شغل الوظيفة لمدتين كاملتين (6 سنوات)",
        titleEn: "Must not have served in this position for two full terms (6 years)",
        // ✅ تم تصحيح الخطأ: استخدمنا الدالة بدلاً من contains التي كانت ترفضه من المرة الأولى
        isMet: !_hasExceededTermLimits(doctor, 'dean', maxTerms: 2),
        isAutoChecked: true,
      ),
      CriterionStatus(
        titleAr: "التمتع بالسلامة الصحية والقدرة على التحمل لساعات العمل الطويلة",
        titleEn: "Must possess good health and ability to endure long working hours",
        isMet: doctor.hasHealthCertificate ?? false,
        isAutoChecked: true,
      ),
    ];
  }

  // ============================================================
  // (6) شروط رئيس القسم
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
        profsInDept.sort((a, b) => a.professorRankDate!.compareTo(b.professorRankDate!));
        final top3Uids = profsInDept.take(3).map((d) => d.uid!).toSet();

        isTop3 = top3Uids.contains(doctor.uid);
        details = isTop3 ? "يقع ضمن أقدم 3 أساتذة بالقسم" : "غير ضمن أقدم 3 أساتذة القسم (عدد الأساتذة: ${profsInDept.length})";
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
        titleEn: "Must be among the top 3 senior Professors in the department",
        isMet: isTop3,
        isAutoChecked: true,
        details: details,
      ),
      CriterionStatus(
        titleAr: "ألا يكون سبق له شغل رئاسة القسم لأكثر من دورة واحدة",
        titleEn: "Must not have served as Department Head for more than one term",
        // هنا يستخدم contains صحيح لأنه دورة واحدة فقط (Max 1)
        isMet: !doctor.previousLeadershipRoles.contains('head_department'),
        isAutoChecked: true,
      ),
      CriterionStatus(
        titleAr: "المشاركة الفعلية في اللجان الداخلية بالجامعة أو الكلية",
        titleEn: "Active participation in internal committees",
        isMet: _hasInternalCommittees(doctor),
        isAutoChecked: true,
      ),
    ];
  }

  // ============================================================
  // (7) شروط مدير وحدة ضمان الجودة
  // ============================================================
  static List<CriterionStatus> _getQualityManagerCriteria(DoctorProfileModel doctor) {
    return [
      CriterionStatus(
        titleAr: "أن يشغل وظيفة (مدرس أو أستاذ مساعد أو أستاذ) وقائماً على رأس عمله",
        titleEn: "Must hold Lecturer, Asst. Prof, or Prof rank, and be actively on duty",
        isMet: _hasQualityManagerRank(doctor) && !_isOnLeaveOrSeconded(doctor),
        isAutoChecked: true,
        details: _getCurrentRankName(doctor),
      ),
      CriterionStatus(
        titleAr: "الحصول على دورات تدريبية معتمدة في مجال الجودة",
        titleEn: "Must hold approved training in Quality",
        isMet: _hasQualityTraining(doctor),
        isAutoChecked: true,
        details: _hasQualityTraining(doctor) ? "✅ يوجد دورات معتمدة" : "⚠️ لم يتم العثور على دورات مطابقة",
      ),
      CriterionStatus(
        titleAr: "أن تكون لديه مهارات التواصل الفعّال وقدرة عالية على قيادة فريق العمل",
        titleEn: "Must possess effective communication and team leadership skills",
        isMet: true,
        isAutoChecked: false,
        details: "يتطلب تقييم الأدمن أو المقابلة الشخصية",
      ),
      CriterionStatus(
        titleAr: "المهارات التقنية اللازمة للتعامل مع أنظمة تكنولوجيا المعلومات",
        titleEn: "Technical skills required for IT systems and digital transformation",
        isMet: doctor.hasICDL,
        isAutoChecked: true,
      ),
      CriterionStatus(
        titleAr: "القدرة على إعداد دراسات التقييم الذاتي والمشاركة الفعالة في الأنشطة",
        titleEn: "Ability to prepare self-assessment studies",
        isMet: true,
        isAutoChecked: false,
        details: "يتطلب تقييم الأدمن بناءً على السيرة الذاتية",
      ),
    ];
  }

  // ============================================================
  // (8) شروط القيادات الإدارية
  // ============================================================
  static List<CriterionStatus> _getAdminManagerCriteria(DoctorProfileModel doctor) {
    return [
      CriterionStatus(
        titleAr: "خبرة موثقة في مجال العمل الإداري بالجامعات",
        titleEn: "Documented experience in university administrative work",
        isMet: doctor.hasAdminExperience ?? false,
        isAutoChecked: false,
        details: "يتطلب مراجعة السيرة الذاتية",
      ),
      CriterionStatus(
        titleAr: "إجادة التعامل المحترف مع برمجيات الحاسب الآلي ونظم التحول الرقمي",
        titleEn: "Professional proficiency in computer software",
        isMet: doctor.hasICDL,
        isAutoChecked: true,
      ),
      CriterionStatus(
        titleAr: "الحصول على مؤهل جامعي عالٍ مناسب لطبيعة الوظيفة",
        titleEn: "Must hold an appropriate higher university degree",
        isMet: true,
        isAutoChecked: true,
        details: "مستوفي (عضو هيئة تدريس)",
      ),
      CriterionStatus(
        titleAr: "تقدير (امتياز) في تقارير تقييم الأداء عن آخر 4 سنوات",
        titleEn: "Excellent rating in performance reports for the last 4 years",
        isMet: doctor.hasExcellentPerformanceReports ?? false,
        isAutoChecked: true,
      ),
      CriterionStatus(
        titleAr: "خلو السجل الوظيفي من أي جزاءات تأديبية",
        titleEn: "Clean disciplinary record",
        isMet: doctor.disciplinaryClearance,
        isAutoChecked: true,
      ),
      CriterionStatus(
        titleAr: "مشاركة إيجابية في تطوير منظومة العمل الإداري خلال آخر 3 سنوات",
        titleEn: "Positive participation in developing admin system over last 3 years",
        isMet: true,
        isAutoChecked: false,
        details: "يتطلب تقديم أوراق ثبوتية للأدمن",
      ),
      CriterionStatus(
        titleAr: "دورات تدريبية متخصصة (إدارة حديثة، حل أزمات، موارد بشرية)",
        titleEn: "Specialized training (Modern Mgmt, Crisis, HR)",
        isMet: _hasAdminTraining(doctor),
        isAutoChecked: true,
        details: _hasAdminTraining(doctor) ? "✅ يوجد دورات مطابقة" : "⚠️ لم يتم العثور على دورات مطابقة",
      ),
    ];
  }

  // ============================================================
  // الدوال المساعدة
  // ============================================================
  static bool _isUnder60(DoctorProfileModel doctor) => _calculateAge(doctor.birthDate) < 60;

  static int _calculateAge(DateTime? birthDate) {
    if (birthDate == null) return 100;
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month || (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  static bool _isOnLeaveOrSeconded(DoctorProfileModel doctor) {
    return (doctor.isOnSecondment ?? false) || (doctor.isOnUnpaidLeave ?? false);
  }

  static bool _hasApprovedWorkPlan(DoctorProfileModel doctor) {
    return doctor.workPlanFileUrl != null && doctor.workPlanStatus == VerificationStatus.approved;
  }

  static String _getWorkPlanDetails(DoctorProfileModel doctor) {
    if (doctor.workPlanFileUrl == null) return "⚠️ لم يتم رفع الخطة";
    switch (doctor.workPlanStatus) {
      case VerificationStatus.approved: return "✅ معتمدة";
      case VerificationStatus.pending: return "⏳ قيد المراجعة";
      case VerificationStatus.rejected: return "❌ مرفوضة";
      default: return "لم يتم التحديد";
    }
  }

  static bool _hasExceededTermLimits(DoctorProfileModel doctor, String role, {int maxTerms = 2}) {
    int count = doctor.previousLeadershipRoles.where((r) => r == role).length;
    return count >= maxTerms;
  }

  static bool _hasExceededSectorTermLimits(DoctorProfileModel doctor, String baseRole, String sector, {int maxTerms = 2}) {
    String sectorRole = '${baseRole}_$sector';
    int count = doctor.previousLeadershipRoles.where((r) => r == sectorRole).length;
    return count >= maxTerms;
  }

  static bool _isEgyptian(DoctorProfileModel doctor) {
    final natAr = _normalizeArabic(doctor.nationalityAr.toLowerCase());
    final natEn = doctor.nationalityEn.toLowerCase();
    return natAr.contains('مصري') || natEn.contains('egyptian');
  }

  static bool _hasRequiredLeadershipCourses(DoctorProfileModel doctor) {
    int count = doctor.courses.where((c) => c.isMandatory && c.status == VerificationStatus.approved).length;
    return count >= 2;
  }

  static bool _hasInternalCommittees(DoctorProfileModel doctor) => doctor.internalCommittees.isNotEmpty;

  static bool _hasProfessorDegree(DoctorProfileModel doctor) {
    return doctor.academicHistory.any((h) {
      if (h['degree'] == null) return false;
      final deg = _normalizeArabic((h['degree'] as String).toLowerCase());
      return deg.contains('استاذ') || deg.contains('بروفيسور') || deg.contains('professor');
    });
  }

  static bool _hasPhdDegree(DoctorProfileModel doctor) {
    return doctor.academicHistory.any((h) {
      if (h['degree'] == null) return false;
      final deg = _normalizeArabic((h['degree'] as String).toLowerCase());
      return deg.contains('دكتوراه') || deg.contains('phd') || deg.contains('دكتور');
    });
  }

  static int _calculateYearsSince(DateTime? startDate) {
    if (startDate == null) return 0;
    final now = DateTime.now();
    int years = now.year - startDate.year;
    if (now.month < startDate.month || (now.month == startDate.month && now.day < startDate.day)) {
      years--;
    }
    return years < 0 ? 0 : years;
  }

  static String _normalizeArabic(String text) {
    return text.replaceAll('أ', 'ا').replaceAll('إ', 'ا').replaceAll('آ', 'ا').replaceAll('ة', 'ه').replaceAll('ى', 'ي');
  }

  static bool _hasQualityManagerRank(DoctorProfileModel doctor) {
    return doctor.academicHistory.any((h) {
      if (h['degree'] == null) return false;
      final deg = _normalizeArabic((h['degree'] as String).toLowerCase());
      return deg.contains('مدرس') || deg.contains('استاذ مساعد') || deg.contains('بروفيسور مساعد') || deg.contains('استاذ') || deg.contains('بروفيسور') || deg.contains('lecturer') || deg.contains('associate professor') || deg.contains('professor');
    });
  }

  static String _getCurrentRankName(DoctorProfileModel doctor) {
    for (var h in doctor.academicHistory) {
      if (h['degree'] != null && (h['type'] == 'promotion' || h['type'] == 'degree')) {
        return h['degree'] as String;
      }
    }
    return "غير محدد";
  }

  static bool _hasQualityTraining(DoctorProfileModel doctor) {
    return doctor.courses.any((course) {
      if (course.status != VerificationStatus.approved) return false;
      final title = _normalizeArabic(course.title.toLowerCase());
      return title.contains('جودة') || title.contains('تخطيط استراتيجي') || title.contains('اعتماد') || title.contains('هيئة قومية') || title.contains('توصيف مقررات') || title.contains('quality') || title.contains('strategic planning') || title.contains('accreditation');
    });
  }

  static bool _hasAdminTraining(DoctorProfileModel doctor) {
    return doctor.courses.any((course) {
      if (course.status != VerificationStatus.approved) return false;
      final title = _normalizeArabic(course.title.toLowerCase());
      return title.contains('ادارة') || title.contains('إدارة') || title.contains('قيادة') || title.contains('موارد بشرية') || title.contains('حل ازمات') || title.contains('تحول رقمي') || title.contains('management') || title.contains('crisis') || title.contains('hr') || title.contains('human resources');
    });
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