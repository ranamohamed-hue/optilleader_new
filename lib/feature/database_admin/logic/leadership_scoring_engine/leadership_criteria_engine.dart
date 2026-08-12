import 'package:optialeader/core/services/criteria/dean_criteria_calculator.dart';
import 'package:optialeader/feature/database_admin/data/models/doctor_profile_model.dart';
import 'package:optialeader/feature/database_admin/data/models/employee_model.dart';
import 'package:optialeader/feature/doctor/data/model/verefication_status.dart';
import 'package:optialeader/core/services/criteria/vice_dean_criteria_calculator.dart';
import 'package:optialeader/core/services/criteria/vice_president_criteria_calculator.dart';
import 'package:optialeader/core/services/criteria/university_president_criteria_calculator.dart';
import 'package:optialeader/core/services/criteria/common_criteria_calculator.dart';
import 'package:optialeader/core/services/criteria/head_department_criteria_calculator.dart';
import 'package:optialeader/core/services/criteria/quality_manager_criteria_calculator.dart';
import 'package:optialeader/core/services/criteria/admin_manager_criteria.dart';

class LeadershipCriteriaEngine {
  // ============================================================
  // شروط القيادات الأكاديمية
  // ============================================================

  static List<CriterionStatus> checkMandatoryCriteria({
    required DoctorProfileModel doctor,
    required String targetRole,
    String? sector,
    List<DoctorProfileModel> departmentDoctors = const [],
  }) {
    final List<CriterionStatus> criteria = [];

    // الشروط العامة
    criteria.addAll(_getCommonCriteria(doctor));

    // شروط الوظيفة
    switch (targetRole) {
      case 'university_president':
        criteria.addAll(_getUniversityPresidentCriteria(doctor));
        break;

      case 'vice_president':
        criteria.addAll(_getVicePresidentCriteria(doctor, sector ?? ''));
        break;

      case 'vice_dean':
        criteria.addAll(_getViceDeanCriteria(doctor, sector ?? ''));
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
    }

    return criteria;
  }

  // ============================================================
  // الشروط العامة للدكتور
  // ============================================================

  static List<CriterionStatus> _getCommonCriteria(DoctorProfileModel doctor) {
    return [
      // ========================================================
      // 1. الجنسية المصرية
      // ========================================================
      CriterionStatus(
        titleAr: 'أن يكون مصري الجنسية',
        titleEn: 'Egyptian nationality',
        isMet: CommonCriteriaCalculator.isEgyptian(doctor),
        isAutoChecked: true,
        details: CommonCriteriaCalculator.getNationalityDetails(doctor),
      ),

      // ========================================================
      // 2. عدم وجود حكم بجناية
      // ========================================================
      CriterionStatus(
        titleAr: 'ألا يكون سبق الحكم عليه بعقوبة جناية',
        titleEn: 'No felony convictions',
        isMet: CommonCriteriaCalculator.hasNoCriminalRecord(doctor),
        isAutoChecked: true,
        details: CommonCriteriaCalculator.getCriminalRecordDetails(doctor),
      ),

      // ========================================================
      // 3. عدم وجود جزاء تأديبي
      // ========================================================
      CriterionStatus(
        titleAr: 'ألا يكون قد وقع عليه جزاء تأديبي',
        titleEn: 'Clean disciplinary record',
        isMet: CommonCriteriaCalculator.hasCleanDisciplinaryRecord(doctor),
        isAutoChecked: true,
        details: CommonCriteriaCalculator.getDisciplinaryDetails(doctor),
      ),

      // ========================================================
      // 4. عدم شغل منصب حزبي
      // ========================================================
      CriterionStatus(
        titleAr: 'ألا يكون متولياً لأي منصب حزبي',
        titleEn: 'No political party position',
        isMet: CommonCriteriaCalculator.hasNoPartyPosition(doctor),
        isAutoChecked: true,
        details: CommonCriteriaCalculator.getPartyPositionDetails(doctor),
      ),

      // ========================================================
      // 5. ICDL
      // ========================================================
      CriterionStatus(
        titleAr: 'إجادة التعامل مع الحاسب الآلي ICDL',
        titleEn: 'ICDL or equivalent',
        isMet: CommonCriteriaCalculator.hasICDL(doctor),
        isAutoChecked: true,
        details: CommonCriteriaCalculator.getICDLDetails(doctor),
      ),

      // ========================================================
      // 6. دورتان في القيادة والتأهيل
      // ========================================================
      CriterionStatus(
        titleAr: 'إتمام دورتين تدريبيتين في القيادة والتأهيل',
        titleEn: '2 leadership and qualification courses',
        isMet: CommonCriteriaCalculator.hasRequiredLeadershipCourses(doctor),
        isAutoChecked: true,
        details: CommonCriteriaCalculator.getLeadershipCoursesDetails(doctor),
      ),
    ];
  }

  // ============================================================
  // شروط الموظفين
  // ============================================================

  static List<CriterionStatus> checkEmployeeMandatoryCriteria({
    required EmployeeModel employee,
    required String targetRole,
  }) {
    final List<CriterionStatus> criteria = [];

    // الشروط العامة للموظف
    criteria.addAll(_getEmployeeCommonCriteria(employee));

    // شروط الوظيفة
    switch (targetRole) {
      case 'admin_manager':
        criteria.addAll(_getAdminManagerCriteria(employee));
        break;
    }

    return criteria;
  }

  // ============================================================
  // الشروط العامة للموظف
  // ============================================================

  static List<CriterionStatus> _getEmployeeCommonCriteria(
    EmployeeModel employee,
  ) {
    return [
      // ========================================================
      // 1. الجنسية المصرية
      // ========================================================
      CriterionStatus(
        titleAr: 'أن يكون مصري الجنسية',
        titleEn: 'Egyptian nationality',
        isMet: _isEgyptianEmployee(employee),
        isAutoChecked: true,
        details: _getNationalityDetails(employee),
      ),

      // ========================================================
      // 2. عدم وجود حكم بجناية
      // ========================================================
      CriterionStatus(
        titleAr: 'ألا يكون سبق الحكم عليه بعقوبة جناية',
        titleEn: 'No felony convictions',
        isMet: !employee.hasCriminalRecord,
        isAutoChecked: true,
        details: employee.hasCriminalRecord
            ? 'يوجد حكم جنائي مسجل'
            : 'لا يوجد حكم جنائي مسجل',
      ),

      // ========================================================
      // 3. عدم وجود جزاء تأديبي
      // ========================================================
      CriterionStatus(
        titleAr: 'ألا يكون قد وقع عليه جزاء تأديبي',
        titleEn: 'Clean disciplinary record',
        isMet: employee.disciplinaryClearance,
        isAutoChecked: true,
        details: employee.disciplinaryClearance
            ? 'السجل خالٍ من الجزاءات التأديبية'
            : 'يوجد جزاء تأديبي مسجل',
      ),

      // ========================================================
      // 4. عدم شغل منصب حزبي
      // ========================================================
      CriterionStatus(
        titleAr: 'ألا يكون متولياً لأي منصب حزبي',
        titleEn: 'No political party position',
        isMet: !employee.holdsPartyPosition,
        isAutoChecked: true,
        details: employee.holdsPartyPosition
            ? 'يشغل منصبًا حزبيًا'
            : 'لا يشغل أي منصب حزبي',
      ),

      // ========================================================
      // 5. ICDL
      // ========================================================
      CriterionStatus(
        titleAr: 'إجادة التعامل مع الحاسب الآلي ICDL',
        titleEn: 'ICDL or equivalent',
        isMet: employee.hasICDL == true,
        isAutoChecked: true,
        details: employee.hasICDL == true
            ? 'حاصل على شهادة ICDL'
            : 'لا توجد شهادة ICDL',
      ),

      // ========================================================
      // 6. دورتان في القيادة والتأهيل
      // ========================================================
      CriterionStatus(
        titleAr: 'إتمام دورتين تدريبيتين في القيادة والتأهيل',
        titleEn: '2 leadership and qualification courses',
        isMet: employee.hasAdminTraining == true,
        isAutoChecked: true,
        details: employee.hasAdminTraining == true
            ? 'مستوفٍ للدورات التدريبية المطلوبة'
            : 'لم يتم تسجيل الدورات التدريبية المطلوبة',
      ),
    ];
  }

  // ============================================================
  // التحقق من الجنسية للموظف
  // ============================================================

  static bool _isEgyptianEmployee(EmployeeModel employee) {
    final nationality = _norm(
      employee.nationalityAr.isNotEmpty
          ? employee.nationalityAr
          : employee.nationalityEn,
    ).toLowerCase();

    return nationality == 'مصر' ||
        nationality == 'مصري' ||
        nationality == 'egyptian' ||
        nationality.contains('مصر') ||
        nationality.contains('egypt');
  }

  static String _getNationalityDetails(EmployeeModel employee) {
    final nationality = employee.nationalityAr.isNotEmpty
        ? employee.nationalityAr
        : employee.nationalityEn;

    if (nationality.trim().isEmpty) {
      return 'لم يتم تسجيل الجنسية';
    }

    return _isEgyptianEmployee(employee)
        ? 'الجنسية: $nationality'
        : 'الجنسية ليست مصرية: $nationality';
  }

  // ============================================================
  // رئيس الجامعة
  // ============================================================

  static List<CriterionStatus> _getUniversityPresidentCriteria(
    DoctorProfileModel doctor,
  ) {
    return [
      // ========================================================
      // 1. أستاذ عامل تحت سن الستين
      // ========================================================
      CriterionStatus(
        titleAr: 'أستاذ عامل تحت سن الستين',
        titleEn: 'Active Professor under 60',
        isMet:
            UniversityPresidentCriteriaCalculator.isActiveProfessor(doctor) &&
            UniversityPresidentCriteriaCalculator.isAgeRequirementMet(doctor),
        isAutoChecked: true,
        details:
            '${UniversityPresidentCriteriaCalculator.getAgeDetails(doctor)} - '
            '${UniversityPresidentCriteriaCalculator.getActiveProfessorDetails(doctor)}',
      ),

      // ========================================================
      // 2. أستاذ لمدة 5 سنوات على الأقل
      // ========================================================
      CriterionStatus(
        titleAr: 'أستاذ لمدة 5 سنوات على الأقل',
        titleEn: 'Professor for at least 5 years',
        isMet: UniversityPresidentCriteriaCalculator.isProfessorRequirementMet(
          doctor,
        ),
        isAutoChecked: true,
        details: UniversityPresidentCriteriaCalculator.getProfessorDetails(
          doctor,
        ),
      ),

      // ========================================================
      // 3. التواجد على رأس العمل لمدة سنتين متصلتين
      // ========================================================
      CriterionStatus(
        titleAr: 'التواجد على رأس العمل لمدة سنتين متصلتين',
        titleEn: 'Active duty for 2 years',
        isMet: UniversityPresidentCriteriaCalculator.isActiveDutyRequirementMet(
          doctor,
        ),
        isAutoChecked: true,
        details: UniversityPresidentCriteriaCalculator.getActiveDutyDetails(
          doctor,
        ),
      ),

      // ========================================================
      // 4. ألا يشغل منصب رئيس الجامعة لأكثر من دورة واحدة
      // ========================================================
      CriterionStatus(
        titleAr: 'ألا يشغل منصب رئيس الجامعة لأكثر من دورة واحدة',
        titleEn: 'Maximum one term as University President',
        isMet:
            UniversityPresidentCriteriaCalculator.isPresidentTermRequirementMet(
              doctor,
            ),
        isAutoChecked: true,
        details: UniversityPresidentCriteriaCalculator.getPresidentTermsDetails(
          doctor,
        ),
      ),

      // ========================================================
      // 5. دورة المجلس الأعلى للجامعات
      // ========================================================
      CriterionStatus(
        titleAr: 'إتمام دورة المجلس الأعلى للجامعات',
        titleEn: 'Supreme Council of Universities training',
        isMet: UniversityPresidentCriteriaCalculator.hasSupremeCouncilTraining(
          doctor,
        ),
        isAutoChecked: true,
        details:
            UniversityPresidentCriteriaCalculator.getSupremeCouncilTrainingDetails(
              doctor,
            ),
      ),

      // ========================================================
      // 6. خطة العمل
      // ========================================================
      CriterionStatus(
        titleAr: 'تقديم خطة عمل معتمدة',
        titleEn: 'Approved work plan',
        isMet: false,
        isAutoChecked: false,
        details: UniversityPresidentCriteriaCalculator.getWorkPlanDetails(
          doctor,
        ),
      ),
    ];
  }

  // ============================================================
  // نائب رئيس الجامعة
  // ============================================================

  static List<CriterionStatus> _getVicePresidentCriteria(
    DoctorProfileModel doctor,
    String sector,
  ) {
    final hasLeadershipTraining =
        VicePresidentCriteriaCalculator.hasSectorLeadershipTraining(doctor);

    return [
      // ========================================================
      // 1. السن أقل من 60 سنة
      // ========================================================
      CriterionStatus(
        titleAr: 'أساتذة تحت سن الستين',
        titleEn: 'Professor under 60',
        isMet: VicePresidentCriteriaCalculator.isAgeRequirementMet(doctor),
        isAutoChecked: true,
        details: VicePresidentCriteriaCalculator.getAgeDetails(doctor),
      ),

      // ========================================================
      // 2. أستاذ لمدة 5 سنوات
      // ========================================================
      CriterionStatus(
        titleAr: 'أستاذ لمدة 5 سنوات',
        titleEn: 'Professor for 5 years',
        isMet: VicePresidentCriteriaCalculator.isProfessorRequirementMet(
          doctor,
        ),
        isAutoChecked: true,
        details: VicePresidentCriteriaCalculator.getProfessorDetails(doctor),
      ),

      // ========================================================
      // 3. التواجد الفعلي على رأس العمل
      // ========================================================
      CriterionStatus(
        titleAr: 'التواجد الفعلي على رأس العمل',
        titleEn: 'Actively on duty',
        isMet: VicePresidentCriteriaCalculator.isActivelyOnDuty(doctor),
        isAutoChecked: true,
        details: VicePresidentCriteriaCalculator.getActiveDutyDetails(doctor),
      ),

      // ========================================================
      // 4. مدة شغل نائب رئيس الجامعة أقل من سنتين
      // ========================================================
      CriterionStatus(
        titleAr: 'ألا يشغل وظيفة نائب رئيس الجامعة لمدة سنتين أو أكثر',
        titleEn: 'Less than 2 years as Vice President',
        isMet:
            VicePresidentCriteriaCalculator.isVicePresidentYearsRequirementMet(
              doctor,
            ),
        isAutoChecked: true,
        details: VicePresidentCriteriaCalculator.getVicePresidentYearsDetails(
          doctor,
        ),
      ),

      // ========================================================
      // 5. دورة قيادة القطاعات
      // ========================================================
      CriterionStatus(
        titleAr: 'الدورة التدريبية لقيادة القطاعات',
        titleEn: 'Sectoral leadership training',
        isMet: hasLeadershipTraining,
        isAutoChecked: true,
        details: VicePresidentCriteriaCalculator.getLeadershipTrainingDetails(
          doctor,
        ),
      ),

      // ========================================================
      // 6. خطة عمل لتطوير القطاع
      // ========================================================
      CriterionStatus(
        titleAr: 'خطة عمل لتطوير القطاع',
        titleEn: 'Sector development plan',
        isMet: false,
        isAutoChecked: false,
        details: VicePresidentCriteriaCalculator.getSectorPlanDetails(doctor),
      ),
    ];
  }

  // ============================================================
  // نائب العميد
  // ============================================================

  static List<CriterionStatus> _getViceDeanCriteria(
    DoctorProfileModel doctor,
    String sector,
  ) {
    return [
      CriterionStatus(
        titleAr: 'أساتذة بالكلية تحت سن الستين',
        titleEn: 'Faculty Prof under 60',
        isMet: ViceDeanCriteriaCalculator.isAgeRequirementMet(doctor),
        isAutoChecked: true,
        details: ViceDeanCriteriaCalculator.getAgeDetails(doctor),
      ),

      CriterionStatus(
        titleAr: 'أستاذ لمدة سنة على الأقل',
        titleEn: 'Professor for 1 year',
        isMet: ViceDeanCriteriaCalculator.isProfessorRequirementMet(doctor),
        isAutoChecked: true,
        details: ViceDeanCriteriaCalculator.getProfessorDetails(doctor),
      ),

      CriterionStatus(
        titleAr: 'قائماً على رأس العمل',
        titleEn: 'Actively on duty',
        isMet: ViceDeanCriteriaCalculator.isActiveOnDuty(doctor),
        isAutoChecked: true,
        details: ViceDeanCriteriaCalculator.getActiveDutyDetails(doctor),
      ),

      CriterionStatus(
        titleAr: 'ألا يشغل المنصب لأكثر من 6 سنوات',
        titleEn: 'Max 6 years as Vice Dean',
        isMet: ViceDeanCriteriaCalculator.isViceDeanMaximumYearsMet(doctor),
        isAutoChecked: true,
        details: ViceDeanCriteriaCalculator.getViceDeanYearsDetails(doctor),
      ),

      CriterionStatus(
        titleAr: 'ألا يشغل المنصب لأكثر من دورتين كاملتين',
        titleEn: 'Maximum two full terms',
        isMet: ViceDeanCriteriaCalculator.isViceDeanMaximumTwoTermsMet(doctor),
        isAutoChecked: true,
        details: ViceDeanCriteriaCalculator.getViceDeanTermsDetails(doctor),
      ),

      CriterionStatus(
        titleAr: 'دورات FLDC',
        titleEn: 'FLDC training',
        isMet: ViceDeanCriteriaCalculator.isFLDCRequirementMet(doctor),
        isAutoChecked: true,
        details: ViceDeanCriteriaCalculator.getFLDCDetails(doctor),
      ),

      CriterionStatus(
        titleAr: 'مقترح إداري مصغر',
        titleEn: 'Mini proposal',
        isMet: _hasApprovedWorkPlan(doctor),
        isAutoChecked: false,
        details: _getWorkPlanDetails(doctor),
      ),
    ];
  }

  // ============================================================
  // العميد
  // ============================================================

  static List<CriterionStatus> _getDeanCriteria(DoctorProfileModel doctor) {
    return [
      CriterionStatus(
        titleAr: 'أستاذ لمدة 3 سنوات على الأقل',
        titleEn: 'Professor for at least 3 years',
        isMet: DeanCriteriaCalculator.isDeanProfessorRequirementMet(doctor),
        isAutoChecked: true,
        details: DeanCriteriaCalculator.getDeanProfessorDetails(doctor),
      ),

      CriterionStatus(
        titleAr: 'الحصول على درجة الدكتوراه',
        titleEn: 'Hold a Ph.D.',
        isMet: DeanCriteriaCalculator.isDeanPhdRequirementMet(doctor),
        isAutoChecked: true,
        details: DeanCriteriaCalculator.getDeanPhdDetails(doctor),
      ),

      CriterionStatus(
        titleAr: 'ألا يشغل العميد لأكثر من 8 سنوات',
        titleEn: 'Maximum 8 years as Dean',
        isMet: DeanCriteriaCalculator.isDeanMaximumEightYearsMet(doctor),
        isAutoChecked: true,
        details: DeanCriteriaCalculator.getDeanYearsDetails(doctor),
      ),

      CriterionStatus(
        titleAr: 'ألا يشغل الوظيفة لمدتين كاملتين',
        titleEn: 'Maximum two full terms',
        isMet: DeanCriteriaCalculator.isDeanMaximumTwoTermsMet(doctor),
        isAutoChecked: true,
        details: DeanCriteriaCalculator.getDeanTermsDetails(doctor),
      ),

      CriterionStatus(
        titleAr: 'ألا يشغل منصبًا حزبيًا',
        titleEn: 'Must not hold a party position',
        isMet: DeanCriteriaCalculator.isDeanPartyPositionRequirementMet(doctor),
        isAutoChecked: true,
        details: DeanCriteriaCalculator.getDeanPartyPositionDetails(doctor),
      ),

      CriterionStatus(
        titleAr: 'السلامة الصحية والتحمل',
        titleEn: 'Good health',
        isMet: DeanCriteriaCalculator.isDeanHealthRequirementMet(doctor),
        isAutoChecked: true,
        details: DeanCriteriaCalculator.getDeanHealthDetails(doctor),
      ),
    ];
  }

  // ============================================================
  // رئيس القسم
  // ============================================================

  static List<CriterionStatus> _getHeadDepartmentCriteria(
    DoctorProfileModel doctor,
    List<DoctorProfileModel> departmentDoctors,
  ) {
    final isTop3 = HeadDepartmentCriteriaCalculator.isTop3SeniorProfessor(
      doctor: doctor,
      doctors: departmentDoctors,
      facultyAr: doctor.facultyAr,
      departmentAr: doctor.departmentAr,
    );

    return [
      // ========================================================
      // 1. أقدم 3 أساتذة في نفس الكلية والقسم
      // ========================================================
      CriterionStatus(
        titleAr: 'ضمن أقدم 3 أساتذة في نفس الكلية والقسم',
        titleEn: 'Among the top 3 senior professors',
        isMet: isTop3,
        isAutoChecked: true,
        details: HeadDepartmentCriteriaCalculator.getTop3Details(
          doctor: doctor,
          doctors: departmentDoctors,
          facultyAr: doctor.facultyAr,
          departmentAr: doctor.departmentAr,
        ),
      ),

      // ========================================================
      // 2. ألا يشغل رئاسة القسم لأكثر من دورة
      // ========================================================
      CriterionStatus(
        titleAr: 'ألا يشغل رئاسة القسم لأكثر من دورة',
        titleEn: 'Maximum one term as Head of Department',
        isMet:
            HeadDepartmentCriteriaCalculator.isDepartmentHeadTermRequirementMet(
              doctor,
            ),
        isAutoChecked: true,
        details: HeadDepartmentCriteriaCalculator.getDepartmentHeadTermsDetails(
          doctor,
        ),
      ),

      // ========================================================
      // 3. المشاركة في اللجان الداخلية
      // ========================================================
      CriterionStatus(
        titleAr: 'المشاركة في اللجان الداخلية',
        titleEn: 'Participation in internal committees',
        isMet: HeadDepartmentCriteriaCalculator.hasInternalCommittees(doctor),
        isAutoChecked: true,
        details: HeadDepartmentCriteriaCalculator.getInternalCommitteesDetails(
          doctor,
        ),
      ),
    ];
  }

  // ============================================================
  // مدير الجودة
  // ============================================================

  static List<CriterionStatus> _getQualityManagerCriteria(
    DoctorProfileModel doctor,
  ) {
    return [
      // ========================================================
      // 1. مدرس / أستاذ مساعد / أستاذ على رأس العمل
      // ========================================================
      CriterionStatus(
        titleAr: 'مدرس/أستاذ مساعد/أستاذ على رأس العمل',
        titleEn: 'Lecturer/Assistant Professor/Professor',
        isMet:
            QualityManagerCriteriaCalculator.isCurrentAcademicRankRequirementMet(
              doctor,
            ),
        isAutoChecked: true,
        details: QualityManagerCriteriaCalculator.getAcademicRankDetails(
          doctor,
        ),
      ),

      // ========================================================
      // 2. دورات معتمدة في الجودة
      // ========================================================
      CriterionStatus(
        titleAr: 'دورات معتمدة في الجودة',
        titleEn: 'Quality training',
        isMet: QualityManagerCriteriaCalculator.hasQualityTraining(doctor),
        isAutoChecked: true,
        details: QualityManagerCriteriaCalculator.getQualityTrainingDetails(
          doctor,
        ),
      ),

      // ========================================================
      // 3. مهارات التواصل والقيادة
      // ========================================================
      CriterionStatus(
        titleAr: 'مهارات تواصل وقيادة',
        titleEn: 'Communication and leadership skills',
        isMet: false,
        isAutoChecked: false,
        details:
            QualityManagerCriteriaCalculator.getCommunicationAndLeadershipDetails(
              doctor,
            ),
      ),

      // ========================================================
      // 4. ICDL
      // ========================================================
      CriterionStatus(
        titleAr: 'مهارات تقنية ICDL',
        titleEn: 'IT skills',
        isMet: QualityManagerCriteriaCalculator.isICDLRequirementMet(doctor),
        isAutoChecked: true,
        details: QualityManagerCriteriaCalculator.getICDLDetails(doctor),
      ),

      // ========================================================
      // 5. إعداد دراسات تقييم ذاتي
      // ========================================================
      CriterionStatus(
        titleAr: 'إعداد دراسات تقييم ذاتي',
        titleEn: 'Assessment studies',
        isMet: false,
        isAutoChecked: false,
        details:
            QualityManagerCriteriaCalculator.getSelfAssessmentStudiesDetails(
              doctor,
            ),
      ),
    ];
  }

  // ============================================================
  // مدير الإدارة
  // ============================================================

  static List<CriterionStatus> _getAdminManagerCriteria(
    EmployeeModel employee,
  ) {
    return AdminManagerCriteriaCalculator.getCriteria(employee);
  }

  // ============================================================
  // حساب عدد الدورات من JobHistory
  // ============================================================

  static int _getTermsCountFromHistory(
    DoctorProfileModel doctor,
    String keywordAr,
  ) {
    if (doctor.jobHistory.isEmpty) {
      return 0;
    }

    final roleJobs = doctor.jobHistory
        .where((job) => job.jobTitleAr.contains(keywordAr))
        .toList();

    if (roleJobs.isEmpty) {
      return 0;
    }

    roleJobs.sort((a, b) => a.startDate.compareTo(b.startDate));

    int terms = 1;

    for (int i = 1; i < roleJobs.length; i++) {
      final prevEnd = roleJobs[i - 1].endDate ?? DateTime.now();

      if (roleJobs[i].startDate.difference(prevEnd).inDays > 180) {
        terms++;
      }
    }

    return terms;
  }

  // ============================================================
  // التحقق من تجاوز عدد الدورات
  // ============================================================

  static bool _checkTermsExceeded(
    DoctorProfileModel doctor,
    String keywordAr,
    String roleCode, {
    int maxTerms = 2,
  }) {
    if (doctor.jobHistory.isNotEmpty) {
      final historyTerms = _getTermsCountFromHistory(doctor, keywordAr);

      if (historyTerms >= maxTerms) {
        return true;
      }
    }

    final count = doctor.previousLeadershipRoles
        .where((r) => r.trim().toLowerCase() == roleCode.trim().toLowerCase())
        .length;

    return count >= maxTerms;
  }

  // ============================================================
  // تفاصيل الدورات السابقة
  // ============================================================

  static String _getTermsDetails(
    DoctorProfileModel doctor,
    String keywordAr,
    String roleCode,
  ) {
    if (doctor.jobHistory.isNotEmpty) {
      final terms = _getTermsCountFromHistory(doctor, keywordAr);

      final years = doctor.calculateYearsInPosition(keywordAr);

      if (years > 0) {
        return 'السجل الوظيفي: $years سنة ($terms دورة)';
      }
    }

    final count = doctor.previousLeadershipRoles
        .where((r) => r.trim().toLowerCase() == roleCode.trim().toLowerCase())
        .length;

    return count > 0 ? 'مُسجل كدورات: $count' : 'لا توجد دورات سابقة';
  }

  // ============================================================
  // خطة العمل
  // ============================================================

  static bool _hasApprovedWorkPlan(DoctorProfileModel doctor) {
    return doctor.workPlanFileUrl != null &&
        doctor.workPlanFileUrl!.trim().isNotEmpty &&
        doctor.workPlanStatus == VerificationStatus.approved;
  }

  static String _getWorkPlanDetails(DoctorProfileModel doctor) {
    if (doctor.workPlanFileUrl == null ||
        doctor.workPlanFileUrl!.trim().isEmpty) {
      return 'لم يتم رفع الخطة';
    }

    return doctor.workPlanStatus == VerificationStatus.approved
        ? 'معتمدة'
        : doctor.workPlanStatus == VerificationStatus.pending
        ? 'قيد المراجعة'
        : 'مرفوضة';
  }

  // ============================================================
  // Normalize Arabic text
  // ============================================================

  static String _norm(String text) {
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
}

// ============================================================
// Criterion Status
// ============================================================

class CriterionStatus {
  final String titleAr;
  final String titleEn;
  final bool isMet;
  final bool isAutoChecked;
  final String? details;

  final bool needsDocument;
  final String? documentType;
  final List<String> uploadedDocs;

  CriterionStatus({
    required this.titleAr,
    required this.titleEn,
    required this.isMet,
    this.isAutoChecked = true,
    this.details,
    this.needsDocument = false,
    this.documentType,
    this.uploadedDocs = const [],
  });
}
