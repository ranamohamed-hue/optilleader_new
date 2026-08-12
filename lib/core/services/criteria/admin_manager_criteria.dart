import 'package:optialeader/feature/database_admin/data/models/employee_model.dart';
import 'package:optialeader/feature/database_admin/logic/leadership_scoring_engine/leadership_criteria_engine.dart';

class AdminManagerCriteriaCalculator {
  static List<CriterionStatus> getCriteria(EmployeeModel employee) {
    return [
      // ========================================================
      // 1. خبرة إدارية موثقة
      // ========================================================
      CriterionStatus(
        titleAr: 'خبرة إدارية موثقة',
        titleEn: 'Documented administrative experience',
        isMet: employee.hasAdminExperience == true,
        isAutoChecked: false,
        details: employee.hasAdminExperience == true
            ? 'توجد خبرة إدارية مسجلة'
            : 'لم يتم تقديم خبرة إدارية',
      ),

      // ========================================================
      // 2. إجادة التعامل مع الحاسب الآلي ICDL
      // ========================================================
      CriterionStatus(
        titleAr: 'إجادة التعامل مع الحاسب الآلي ICDL',
        titleEn: 'ICDL computer skills',
        isMet: employee.hasICDL == true,
        isAutoChecked: true,
        details: employee.hasICDL == true
            ? 'حاصل على شهادة ICDL'
            : 'لا توجد شهادة ICDL',
      ),

      // ========================================================
      // 3. مؤهل جامعي عالٍ - بكالوريوس على الأقل
      // ========================================================
      CriterionStatus(
        titleAr: 'مؤهل جامعي عالٍ',
        titleEn: 'Higher university degree',
        isMet: _hasMinimumUniversityDegree(employee),
        isAutoChecked: true,
        details: 'المؤهل: ${employee.degree}',
      ),

      // ========================================================
      // 4. تقدير امتياز آخر 4 سنوات
      // ========================================================
      CriterionStatus(
        titleAr: 'تقدير امتياز آخر 4 سنوات',
        titleEn: 'Excellent performance during the last 4 years',
        isMet: employee.hasExcellentPerformanceReports,
        isAutoChecked: false,
        details: employee.hasExcellentPerformanceReports
            ? 'تم تقديم تقارير الأداء'
            : 'يتم التحقق منه عند التقديم',
      ),

      // ========================================================
      // 5. خلو السجل من الجزاءات
      // ========================================================
      CriterionStatus(
        titleAr: 'خلو السجل من الجزاءات',
        titleEn: 'Clean disciplinary record',
        isMet: employee.disciplinaryClearance,
        isAutoChecked: true,
        details: employee.disciplinaryClearance
            ? 'السجل خالٍ من الجزاءات'
            : 'يوجد جزاء تأديبي',
      ),

      // ========================================================
      // 6. تطوير العمل الإداري
      // ========================================================
      // يرفع المتقدم التصور/الخطة وقت التقديم
      // ويتم تقييمها يدويًا.
      CriterionStatus(
        titleAr: 'تطوير العمل الإداري',
        titleEn: 'Administrative work development',
        isMet: false,
        isAutoChecked: false,
        details: 'يتم تقديمها وتقييمها يدويًا عند التقديم',
      ),

      // ========================================================
      // 7. دورات إدارة وحل أزمات
      // ========================================================
      CriterionStatus(
        titleAr: 'دورات في الإدارة وحل الأزمات',
        titleEn: 'Management and crisis resolution training',
        isMet: employee.hasAdminTraining == true,
        isAutoChecked: true,
        details: employee.hasAdminTraining == true
            ? 'حاصل على دورات إدارية'
            : 'لا توجد دورات إدارية مسجلة',
      ),
    ];
  }

  // ==========================================================
  // المؤهل الجامعي
  // ==========================================================
  static bool _hasMinimumUniversityDegree(EmployeeModel employee) {
    final degree = employee.degree.trim().toLowerCase();

    if (degree.isEmpty) return false;

    const allowedDegrees = [
      'بكالوريوس',
      'بكالوريوس ',
      'ليسانس',
      'bachelor',
      'bachelor degree',
      'bsc',
      'ba',
      'b.a',
      'b.sc',
    ];

    if (allowedDegrees.contains(degree)) {
      return true;
    }

    // أي مؤهل أعلى من البكالوريوس يعتبر مستوفيًا
    const higherDegrees = [
      'دبلوم',
      'دبلوم عالي',
      'ماجستير',
      'دكتوراه',
      'master',
      'master degree',
      'msc',
      'phd',
      'ph.d',
      'doctorate',
    ];

    if (higherDegrees.any((value) => degree.contains(value))) {
      return true;
    }

    return false;
  }
}