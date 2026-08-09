import 'package:optialeader/feature/database_admin/data/models/doctor_profile_model.dart';
import 'package:optialeader/feature/doctor/data/model/verefication_status.dart';
/// محرك فحص شروط الترشح للوظائف القيادية
/// ============================================================
class LeadershipCriteriaEngine {
  /// الدالة الرئيسية لتقييم الشروط
  static List<CriterionStatus> checkMandatoryCriteria({
    required DoctorProfileModel doctor,
    required String targetRole,
    String? sector,
    List<DoctorProfileModel> departmentDoctors = const [],
  }) {
    final List<CriterionStatus> criteria = [];

    // 1. الشروط الأساسية المشتركة
    criteria.addAll(_getCommonCriteria(doctor));

    // 2. الشروط الخاصة بالوظيفة
    switch (targetRole) {
      case 'university_president':
        criteria.addAll(_getUniversityPresidentCriteria(doctor));
        break;

      case 'vice_president':
        criteria.addAll(
          _getVicePresidentCriteria(doctor, sector ?? ''),
        );
        break;

      case 'vice_dean':
        criteria.addAll(
          _getViceDeanCriteria(doctor, sector ?? ''),
        );
        break;

      case 'dean':
        criteria.addAll(_getDeanCriteria(doctor));
        break;

      case 'head_department':
        criteria.addAll(
          _getHeadDepartmentCriteria(
            doctor,
            departmentDoctors,
          ),
        );
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

  static List<CriterionStatus> _getCommonCriteria(
    DoctorProfileModel doctor,
  ) {
    return [
      CriterionStatus(
        titleAr: 'أن يكون مصري الجنسية',
        titleEn: 'Must be of Egyptian nationality',
        isMet: _isEgyptian(doctor),
        isAutoChecked: true,
      ),

      CriterionStatus(
        titleAr:
            'ألا يكون سبق الحكم عليه بعقوبة جناية أو مخلة بالشرف أو الأمانة',
        titleEn:
            'Must not have been convicted of a felony or a crime involving dishonor or breach of trust',
        isMet: !doctor.hasCriminalRecord,
        isAutoChecked: true,
      ),

      CriterionStatus(
        titleAr:
            'ألا يكون قد وقع عليه جزاء تأديبي ما لم يكن قد تم محوه قانوناً',
        titleEn:
            'Must have a clean disciplinary record unless legally expunged',
        isMet: doctor.disciplinaryClearance,
        isAutoChecked: true,
      ),

      CriterionStatus(
        titleAr:
            'ألا يكون متولياً لأي منصب حزبي وقت الترشح وطوال فترة المنصب',
        titleEn:
            'Must not hold any political party position during nomination or tenure',
        isMet: !doctor.holdsPartyPosition,
        isAutoChecked: true,
      ),

      CriterionStatus(
        titleAr: 'إجادة التعامل مع الحاسب الآلي ICDL أو ما يعادلها',
        titleEn:
            'Proficiency in computer skills (ICDL or equivalent)',
        isMet: doctor.hasICDL,
        isAutoChecked: true,
      ),

      CriterionStatus(
        titleAr:
            'إتمام دورتين تدريبيتين على الأقل في مجالات القيادة والإدارة',
        titleEn:
            'Completion of at least 2 training courses in leadership and management',
        isMet: _hasRequiredLeadershipCourses(doctor),
        isAutoChecked: true,
      ),
    ];
  }

  // ============================================================
  // (2) رئيس الجامعة
  // ============================================================

  static List<CriterionStatus> _getUniversityPresidentCriteria(
    DoctorProfileModel doctor,
  ) {
    final yearsAsProf =
        _calculateYearsSince(doctor.professorRankDate);

    final yearsOnDuty =
        _calculateYearsSince(doctor.activeDutySinceDate);

    return [
      CriterionStatus(
        titleAr:
            'أن يكون من الأساتذة العاملين تحت سن الستين',
        titleEn:
            'Must be a working Professor under 60 years of age',
        isMet:
            _hasProfessorDegree(doctor) &&
            _isUnder60(doctor),
        isAutoChecked: true,
        details:
            'العمر: ${_calculateAge(doctor.birthDate)} سنة',
      ),

      CriterionStatus(
        titleAr:
            'أن يكون قد شغل وظيفة أستاذ لمدة 5 سنوات على الأقل',
        titleEn:
            'Must have held the rank of Professor for at least 5 years',
        isMet:
            _hasProfessorDegree(doctor) &&
            yearsAsProf >= 5,
        isAutoChecked: true,
        details:
            'عدد السنوات: $yearsAsProf سنة',
      ),

      CriterionStatus(
        titleAr:
            'التواجد على رأس العمل بالجامعة لمدة سنتين متصلتين على الأقل قبل الترشح',
        titleEn:
            'Must have been actively on duty at the university for at least 2 consecutive years',
        isMet:
            !_isOnLeaveOrSeconded(doctor) &&
            yearsOnDuty >= 2,
        isAutoChecked: true,
        details:
            'مدة التواجد الفعلي: $yearsOnDuty سنة',
      ),

      CriterionStatus(
        titleAr:
            'ألا يكون سبق له شغل المنصب لأكثر من دورة واحدة',
        titleEn:
            'Must not have served in this position for more than one term',
        isMet: !_hasExceededTermLimits(
          doctor,
          'university_president',
          maxTerms: 1,
        ),
        isAutoChecked: true,
      ),

      CriterionStatus(
        titleAr:
            'إتمام الدورة التدريبية الإلزامية المعتمدة من المجلس الأعلى للجامعات',
        titleEn:
            'Completion of the mandatory training approved by the Supreme Council of Universities',
        isMet:
            doctor.hasSupremeCouncilTraining ?? false,
        isAutoChecked: true,
      ),

      CriterionStatus(
        titleAr:
            'تقديم خطة عمل متكاملة لتطوير الجامعة ومعتمدة',
        titleEn:
            'Submission of an approved comprehensive development plan',
        isMet: _hasApprovedWorkPlan(doctor),
        isAutoChecked: false,
        details: _getWorkPlanDetails(doctor),
      ),
    ];
  }

  // ============================================================
  // (3) نائب رئيس الجامعة
  // ============================================================

  static List<CriterionStatus> _getVicePresidentCriteria(
    DoctorProfileModel doctor,
    String sector,
  ) {
    final yearsAsProf =
        _calculateYearsSince(doctor.professorRankDate);

    return [
      CriterionStatus(
        titleAr:
            'أن يكون من الأساتذة العاملين بالجامعة تحت سن الستين',
        titleEn:
            'Must be a working Professor at the university under 60',
        isMet:
            _hasProfessorDegree(doctor) &&
            _isUnder60(doctor),
        isAutoChecked: true,
      ),

      CriterionStatus(
        titleAr:
            'أن يكون قد شغل وظيفة أستاذ لمدة 5 سنوات على الأقل',
        titleEn:
            'Must have held the rank of Professor for at least 5 years',
        isMet:
            _hasProfessorDegree(doctor) &&
            yearsAsProf >= 5,
        isAutoChecked: true,
        details:
            'عدد السنوات: $yearsAsProf سنة',
      ),

      CriterionStatus(
        titleAr:
            'التواجد الفعلي على رأس العمل وقت التقدم',
        titleEn:
            'Must be actively on duty at the time of application',
        isMet: !_isOnLeaveOrSeconded(doctor),
        isAutoChecked: true,
      ),

      CriterionStatus(
        titleAr:
            'ألا يكون قد شغل نفس القطاع لأكثر من مرتين متتاليتين',
        titleEn:
            'Must not have served the same sector for more than two consecutive terms',
        isMet: !_hasExceededSectorTermLimits(
          doctor,
          'vice_president',
          sector,
          maxTerms: 2,
        ),
        isAutoChecked: true,
      ),

      CriterionStatus(
        titleAr:
            'إتمام الدورة التدريبية الإلزامية لقيادة القطاعات',
        titleEn:
            'Completion of the mandatory sectoral leadership training',
        isMet:
            doctor.hasSupremeCouncilTraining ?? false,
        isAutoChecked: true,
      ),

      CriterionStatus(
        titleAr:
            'تقديم خطة عمل وتصور لتطوير القطاع المستهدف',
        titleEn:
            'Submission of an approved development plan for the targeted sector',
        isMet: _hasApprovedWorkPlan(doctor),
        isAutoChecked: false,
        details: _getWorkPlanDetails(doctor),
      ),
    ];
  }

  // ============================================================
  // (4) وكيل الكلية
  // ============================================================

  static List<CriterionStatus> _getViceDeanCriteria(
    DoctorProfileModel doctor,
    String sector,
  ) {
    final yearsAsProf =
        _calculateYearsSince(doctor.professorRankDate);

    return [
      CriterionStatus(
        titleAr:
            'أن يكون من الأساتذة العاملين بالكلية تحت سن الستين',
        titleEn:
            'Must be a working Professor at the faculty under 60',
        isMet:
            _hasProfessorDegree(doctor) &&
            _isUnder60(doctor),
        isAutoChecked: true,
      ),

      CriterionStatus(
        titleAr:
            'أن يكون قد شغل وظيفة أستاذ لمدة سنة واحدة على الأقل',
        titleEn:
            'Must have held the rank of Professor for at least 1 year',
        isMet:
            _hasProfessorDegree(doctor) &&
            yearsAsProf >= 1,
        isAutoChecked: true,
        details:
            'عدد السنوات: $yearsAsProf سنة',
      ),

      CriterionStatus(
        titleAr:
            'أن يكون قائماً على رأس العمل ومقيداً بقسمه العلمي بصفة فعلية',
        titleEn:
            'Must be actively on duty and officially assigned to their department',
        isMet: !_isOnLeaveOrSeconded(doctor),
        isAutoChecked: true,
      ),

      CriterionStatus(
        titleAr:
            'ألا يكون قد شغل المنصب لمدة تزيد عن 6 سنوات متصلة',
        titleEn:
            'Must not have served for more than 6 consecutive years',
        isMet: !_hasExceededTermLimits(
          doctor,
          'vice_dean',
          maxTerms: 2,
        ),
        isAutoChecked: true,
      ),

      CriterionStatus(
        titleAr:
            'إتمام الدورات الإدارية والقانونية بمركز تنمية قدرات أعضاء هيئة التدريس FLDC',
        titleEn:
            'Completion of administrative training at FLDC',
        isMet: doctor.hasFLDCTraining ?? false,
        isAutoChecked: true,
      ),

      CriterionStatus(
        titleAr:
            'تقديم تصور ومقترح إداري مصغر لتطوير القطاع المستهدف',
        titleEn:
            'Submission of an approved mini-administrative proposal',
        isMet: _hasApprovedWorkPlan(doctor),
        isAutoChecked: false,
        details: _getWorkPlanDetails(doctor),
      ),
    ];
  }

  // ============================================================
  // (5) العميد
  // ============================================================

  static List<CriterionStatus> _getDeanCriteria(
    DoctorProfileModel doctor,
  ) {
    final yearsAsProf =
        _calculateYearsSince(doctor.professorRankDate);

    return [
      CriterionStatus(
        titleAr:
            'أن يكون في منصب أستاذ لمدة 3 سنوات على الأقل',
        titleEn:
            'Must have held the rank of Professor for at least 3 years',
        isMet:
            _hasProfessorDegree(doctor) &&
            yearsAsProf >= 3,
        isAutoChecked: true,
        details:
            'عدد السنوات: $yearsAsProf سنة',
      ),

      CriterionStatus(
        titleAr: 'الحصول على درجة الدكتوراه',
        titleEn: 'Must hold a Ph.D. degree',
        isMet: _hasPhdDegree(doctor),
        isAutoChecked: true,
      ),

      CriterionStatus(
        titleAr:
            'ألا يكون سبق له شغل الوظيفة لمدتين كاملتين',
        titleEn:
            'Must not have served in this position for two full terms',
        isMet: !_hasExceededTermLimits(
          doctor,
          'dean',
          maxTerms: 2,
        ),
        isAutoChecked: true,
      ),

      CriterionStatus(
        titleAr:
            'التمتع بالسلامة الصحية والقدرة على التحمل لساعات العمل الطويلة',
        titleEn:
            'Must possess good health and ability to endure long working hours',
        isMet:
            doctor.hasHealthCertificate ?? false,
        isAutoChecked: true,
      ),
    ];
  }

  // ============================================================
  // (6) رئيس القسم
  // ============================================================

  static List<CriterionStatus> _getHeadDepartmentCriteria(
    DoctorProfileModel doctor,
    List<DoctorProfileModel> departmentDoctors,
  ) {
    bool isTop3 = false;
    String? details;

    if (departmentDoctors.isNotEmpty) {
      final top3Uids =
          DoctorProfileModel.getTop3SeniorInDepartment(
        doctors: departmentDoctors,
        departmentAr: doctor.departmentAr,
      );

      isTop3 =
          doctor.uid != null &&
          top3Uids.contains(doctor.uid);

      details = isTop3
          ? 'يقع ضمن أقدم 3 أساتذة بالقسم حسب تاريخ الحصول على درجة الأستاذ'
          : 'غير ضمن أقدم 3 أساتذة بالقسم';
    } else {
      isTop3 = doctor.isTop3Senior ?? false;
      details =
          'لم يتم توفير قائمة الدكاترة، يعتمد على البيانات المسجلة';
    }

    return [
      CriterionStatus(
        titleAr:
            'أن يكون ضمن أقدم 3 أساتذة بالقسم',
        titleEn:
            'Must be among the top 3 senior Professors in the department',
        isMet: isTop3,
        isAutoChecked: true,
        details: details,
      ),

      CriterionStatus(
        titleAr:
            'ألا يكون سبق له شغل رئاسة القسم لأكثر من دورة واحدة',
        titleEn:
            'Must not have served as Department Head for more than one term',
        isMet: !_hasExceededTermLimits(
          doctor,
          'head_department',
          maxTerms: 1,
        ),
        isAutoChecked: true,
      ),

      CriterionStatus(
        titleAr:
            'المشاركة الفعلية في اللجان الداخلية بالجامعة أو الكلية',
        titleEn:
            'Active participation in internal committees',
        isMet: _hasInternalCommittees(doctor),
        isAutoChecked: true,
      ),
    ];
  }

  // ============================================================
  // (7) مدير وحدة ضمان الجودة
  // ============================================================

  static List<CriterionStatus> _getQualityManagerCriteria(
    DoctorProfileModel doctor,
  ) {
    final qualityTraining =
        _hasQualityTraining(doctor);

    return [
      CriterionStatus(
        titleAr:
            'أن يشغل وظيفة مدرس أو أستاذ مساعد أو أستاذ وقائماً على رأس عمله',
        titleEn:
            'Must hold Lecturer, Assistant Professor, or Professor rank and be actively on duty',
        isMet:
            _hasQualityManagerRank(doctor) &&
            !_isOnLeaveOrSeconded(doctor),
        isAutoChecked: true,
        details: _getCurrentRankName(doctor),
      ),

      CriterionStatus(
        titleAr:
            'الحصول على دورات تدريبية معتمدة في مجال الجودة',
        titleEn:
            'Must hold approved training in Quality',
        isMet: qualityTraining,
        isAutoChecked: true,
        details: qualityTraining
            ? 'يوجد دورات معتمدة'
            : 'لم يتم العثور على دورات مطابقة',
      ),

      CriterionStatus(
        titleAr:
            'امتلاك مهارات التواصل الفعال والقدرة على قيادة فريق العمل',
        titleEn:
            'Must possess effective communication and team leadership skills',
        isMet: true,
        isAutoChecked: false,
        details:
            'يتطلب تقييم الأدمن أو المقابلة الشخصية',
      ),

      CriterionStatus(
        titleAr:
            'المهارات التقنية اللازمة للتعامل مع أنظمة تكنولوجيا المعلومات',
        titleEn:
            'Technical skills required for IT systems and digital transformation',
        isMet: doctor.hasICDL,
        isAutoChecked: true,
      ),

      CriterionStatus(
        titleAr:
            'القدرة على إعداد دراسات التقييم الذاتي والمشاركة الفعالة في الأنشطة',
        titleEn:
            'Ability to prepare self-assessment studies',
        isMet: true,
        isAutoChecked: false,
        details:
            'يتطلب تقييم الأدمن بناءً على السيرة الذاتية',
      ),
    ];
  }

  // ============================================================
  // (8) القيادات الإدارية
  // ============================================================

  static List<CriterionStatus> _getAdminManagerCriteria(
    DoctorProfileModel doctor,
  ) {
    final adminTraining =
        _hasAdminTraining(doctor);

    return [
      CriterionStatus(
        titleAr:
            'خبرة موثقة في مجال العمل الإداري بالجامعات',
        titleEn:
            'Documented experience in university administrative work',
        isMet:
            doctor.hasAdminExperience ?? false,
        isAutoChecked: false,
        details: 'يتطلب مراجعة السيرة الذاتية',
      ),

      CriterionStatus(
        titleAr:
            'إجادة التعامل المحترف مع برمجيات الحاسب الآلي ونظم التحول الرقمي',
        titleEn:
            'Professional proficiency in computer software',
        isMet: doctor.hasICDL,
        isAutoChecked: true,
      ),

      CriterionStatus(
        titleAr:
            'الحصول على مؤهل جامعي عالٍ مناسب لطبيعة الوظيفة',
        titleEn:
            'Must hold an appropriate higher university degree',
        isMet: true,
        isAutoChecked: true,
        details: 'مستوفي - عضو هيئة تدريس',
      ),

      CriterionStatus(
        titleAr:
            'تقدير امتياز في تقارير تقييم الأداء عن آخر 4 سنوات',
        titleEn:
            'Excellent rating in performance reports for the last 4 years',
        isMet:
            doctor.hasExcellentPerformanceReports ?? false,
        isAutoChecked: true,
      ),

      CriterionStatus(
        titleAr:
            'خلو السجل الوظيفي من أي جزاءات تأديبية',
        titleEn:
            'Clean disciplinary record',
        isMet: doctor.disciplinaryClearance,
        isAutoChecked: true,
      ),

      CriterionStatus(
        titleAr:
            'مشاركة إيجابية في تطوير منظومة العمل الإداري خلال آخر 3 سنوات',
        titleEn:
            'Positive participation in developing the administrative system over the last 3 years',
        isMet: true,
        isAutoChecked: false,
        details:
            'يتطلب تقديم أوراق ثبوتية للأدمن',
      ),

      CriterionStatus(
        titleAr:
            'دورات تدريبية متخصصة في الإدارة الحديثة وحل الأزمات والموارد البشرية',
        titleEn:
            'Specialized training in modern management, crisis management, and HR',
        isMet: adminTraining,
        isAutoChecked: true,
        details: adminTraining
            ? 'يوجد دورات مطابقة'
            : 'لم يتم العثور على دورات مطابقة',
      ),
    ];
  }

  // ============================================================
  // الدوال المساعدة
  // ============================================================

  static bool _isUnder60(
    DoctorProfileModel doctor,
  ) {
    return _calculateAge(doctor.birthDate) < 60;
  }

  static int _calculateAge(DateTime? birthDate) {
    if (birthDate == null) return 100;

    final today = DateTime.now();

    int age = today.year - birthDate.year;

    if (today.month < birthDate.month ||
        (today.month == birthDate.month &&
            today.day < birthDate.day)) {
      age--;
    }

    return age;
  }

  static bool _isOnLeaveOrSeconded(
    DoctorProfileModel doctor,
  ) {
    return (doctor.isOnSecondment ?? false) ||
        (doctor.isOnUnpaidLeave ?? false) ||
        doctor.isOnVacation;
  }

  static bool _hasApprovedWorkPlan(
    DoctorProfileModel doctor,
  ) {
    return doctor.workPlanFileUrl != null &&
        doctor.workPlanFileUrl!.trim().isNotEmpty &&
        doctor.workPlanStatus ==
            VerificationStatus.approved;
  }

  static String _getWorkPlanDetails(
    DoctorProfileModel doctor,
  ) {
    if (doctor.workPlanFileUrl == null ||
        doctor.workPlanFileUrl!.trim().isEmpty) {
      return 'لم يتم رفع الخطة';
    }

    switch (doctor.workPlanStatus) {
      case VerificationStatus.approved:
        return 'معتمدة';

      case VerificationStatus.pending:
        return 'قيد المراجعة';

      case VerificationStatus.rejected:
        return 'مرفوضة';

      default:
        return 'لم يتم التحديد';
    }
  }

  static bool _hasExceededTermLimits(
    DoctorProfileModel doctor,
    String role, {
    int maxTerms = 2,
  }) {
    final count = doctor.previousLeadershipRoles
        .where(
          (r) =>
              r.toString().trim().toLowerCase() ==
              role.trim().toLowerCase(),
        )
        .length;

    return count >= maxTerms;
  }

  static bool _hasExceededSectorTermLimits(
    DoctorProfileModel doctor,
    String baseRole,
    String sector, {
    int maxTerms = 2,
  }) {
    final sectorRole =
        '${baseRole}_$sector'.trim().toLowerCase();

    final count = doctor.previousLeadershipRoles
        .where(
          (r) =>
              r.toString().trim().toLowerCase() ==
              sectorRole,
        )
        .length;

    return count >= maxTerms;
  }

  static bool _isEgyptian(
    DoctorProfileModel doctor,
  ) {
    final natAr =
        _normalizeArabic(
          doctor.nationalityAr.toLowerCase(),
        );

    final natEn =
        doctor.nationalityEn.toLowerCase().trim();

    return natAr.contains('مصري') ||
        natAr.contains('مصر') ||
        natEn.contains('egyptian') ||
        natEn == 'egypt';
  }

  static bool _hasRequiredLeadershipCourses(
    DoctorProfileModel doctor,
  ) {
    final count = doctor.courses
        .where(
          (course) =>
              course.isMandatory &&
              course.status ==
                  VerificationStatus.approved,
        )
        .length;

    return count >= 2;
  }

  static bool _hasInternalCommittees(
    DoctorProfileModel doctor,
  ) {
    return doctor.internalCommittees.isNotEmpty;
  }

  static bool _hasProfessorDegree(
    DoctorProfileModel doctor,
  ) {
    return doctor.academicHistory.any((h) {
      final degree =
          (h['degree'] ?? '').toString();

      final normalized =
          _normalizeArabic(degree.toLowerCase());

      return normalized == 'استاذ' ||
          normalized == 'بروفيسور' ||
          normalized == 'professor';
    });
  }

  static bool _hasPhdDegree(
    DoctorProfileModel doctor,
  ) {
    return doctor.academicHistory.any((h) {
      final degree =
          (h['degree'] ?? '').toString();

      final normalized =
          _normalizeArabic(degree.toLowerCase());

      return normalized.contains('دكتوراه') ||
          normalized.contains('phd') ||
          normalized.contains('doctor of philosophy');
    });
  }

  static int _calculateYearsSince(
    DateTime? startDate,
  ) {
    if (startDate == null) return 0;

    final now = DateTime.now();

    int years =
        now.year - startDate.year;

    if (now.month < startDate.month ||
        (now.month == startDate.month &&
            now.day < startDate.day)) {
      years--;
    }

    return years < 0 ? 0 : years;
  }

  static String _normalizeArabic(
    String text,
  ) {
    return text
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي')
        .replaceAll('ؤ', 'و')
        .replaceAll('ئ', 'ي')
        .replaceAll('ـ', '')
        .trim();
  }

  static bool _hasQualityManagerRank(
    DoctorProfileModel doctor,
  ) {
    return doctor.academicHistory.any((h) {
      final degree =
          (h['degree'] ?? '').toString();

      final normalized =
          _normalizeArabic(degree.toLowerCase());

      return normalized == 'مدرس' ||
          normalized == 'lecturer' ||
          normalized == 'استاذ مساعد' ||
          normalized == 'بروفيسور مساعد' ||
          normalized == 'associate professor' ||
          normalized == 'استاذ' ||
          normalized == 'بروفيسور' ||
          normalized == 'professor';
    });
  }

  static String _getCurrentRankName(
    DoctorProfileModel doctor,
  ) {
    for (final h in doctor.academicHistory) {
      final type =
          (h['type'] ?? '').toString();

      if (h['degree'] != null &&
          (type == 'promotion' ||
              type == 'degree')) {
        return h['degree'].toString();
      }
    }

    return 'غير محدد';
  }

  static bool _hasQualityTraining(
    DoctorProfileModel doctor,
  ) {
    return doctor.courses.any((course) {
      if (course.status !=
          VerificationStatus.approved) {
        return false;
      }

      final title =
          _normalizeArabic(
            course.title.toLowerCase(),
          );

      return title.contains('جوده') ||
          title.contains('تخطيط استراتيجي') ||
          title.contains('اعتماد') ||
          title.contains('هيئه قوميه') ||
          title.contains('توصيف مقررات') ||
          title.contains('quality') ||
          title.contains('strategic planning') ||
          title.contains('accreditation');
    });
  }

  static bool _hasAdminTraining(
    DoctorProfileModel doctor,
  ) {
    return doctor.courses.any((course) {
      if (course.status !=
          VerificationStatus.approved) {
        return false;
      }

      final title =
          _normalizeArabic(
            course.title.toLowerCase(),
          );

      return title.contains('اداره') ||
          title.contains('قياده') ||
          title.contains('موارد بشريه') ||
          title.contains('حل ازمات') ||
          title.contains('تحول رقمي') ||
          title.contains('management') ||
          title.contains('leadership') ||
          title.contains('crisis') ||
          title == 'hr' ||
          title.contains('human resources');
    });
  }
}

/// ============================================================
/// موديل حالة الشرط
/// ============================================================

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
