import 'package:optialeader/feature/database_admin/data/models/employee_model.dart';
import 'package:optialeader/feature/database_admin/logic/leadership_scoring_engine/leadership_criteria_engine.dart';

class AdminManagerCriteriaCalculator {
 static List<CriterionStatus> getCriteria(EmployeeModel employee) {
  return [
    // ========================================================
    // 1. خبرة إدارية موثقة ← ملف مطلوب رفعه
    // ========================================================
    CriterionStatus(
      titleAr: 'خبرة إدارية موثقة',
      titleEn: 'Documented administrative experience',
      isMet: employee.hasAdminExperience == true,
      isAutoChecked: false,
      needsDocument: true,
      documentType: 'admin_experience',
      details: 'يجب رفع مستند يثبت الخبرة الإدارية',
    ),

    // ========================================================
    // 2. ICDL ← ملف مطلوب رفعه
    // ========================================================
    CriterionStatus(
      titleAr: 'إجادة التعامل مع الحاسب الآلي ICDL',
      titleEn: 'ICDL computer skills',
      isMet: employee.hasICDL == true,
      isAutoChecked: false,
      needsDocument: true,
      documentType: 'icdl_certificate',
      details: 'يجب رفع شهادة ICDL أو ما يعادلها',
    ),

    // ========================================================
    // 3. مؤهل جامعي عالٍ ← ملف مطلوب رفعه
    // ========================================================
    CriterionStatus(
      titleAr: 'مؤهل جامعي عالٍ',
      titleEn: 'Higher university degree',
      isMet: _hasMinimumUniversityDegree(employee),
      isAutoChecked: false,
      needsDocument: true,
      documentType: 'university_degree',
      details: 'يجب رفع صورة المؤهل الجامعي',
    ),

    // ========================================================
    // 4. تقدير امتياز آخر 4 سنوات ← ملف مطلوب رفعه
    // ========================================================
    CriterionStatus(
      titleAr: 'تقدير امتياز آخر 4 سنوات',
      titleEn: 'Excellent performance during the last 4 years',
      isMet: employee.hasExcellentPerformanceReports,
      isAutoChecked: false,
      needsDocument: true,
      documentType: 'performance_reports',
      details: 'يجب رفع تقارير تقييم الأداء عن آخر 4 سنوات',
    ),

    // ========================================================
    // 5. خلو السجل من الجزاءات ← ملف مطلوب رفعه
    // ========================================================
    CriterionStatus(
      titleAr: 'خلو السجل من الجزاءات',
      titleEn: 'Clean disciplinary record',
      isMet: employee.disciplinaryClearance,
      isAutoChecked: false,
      needsDocument: true,
      documentType: 'clearance_record',
      details: 'يجب رفع مستند خلو السجل من الجزاءات',
    ),

    // ========================================================
    // 6. تطوير العمل الإداري ← ملف مطلوب رفعه
    // ========================================================
    CriterionStatus(
      titleAr: 'تطوير العمل الإداري',
      titleEn: 'Administrative work development',
      isMet: false,
      isAutoChecked: false,
      needsDocument: true,
      documentType: 'admin_development_plan',
      details: 'يجب رفع تصور أو خطة لتطوير العمل الإداري',
    ),

    // ========================================================
    // 7. دورات إدارة وحل أزمات ← الشرط الوحيد المانع للترشح ⛔
    // ========================================================
    CriterionStatus(
      titleAr: 'دورات في الإدارة وحل الأزمات',
      titleEn: 'Management and crisis resolution training',
      isMet: employee.hasAdminTraining == true,
      isAutoChecked: true,
      needsDocument: false,
      details: employee.hasAdminTraining == true
          ? 'حاصل على دورات إدارية مطابقة'
          : 'يجب الحصول على دورات في الإدارة وحل الأزمات للترشح',
    ),
  ];
}
  //=========================================================
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