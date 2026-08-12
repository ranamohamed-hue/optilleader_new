import 'package:optialeader/core/services/DateCalculation/date_calculation_model.dart';
import 'package:optialeader/feature/database_admin/data/models/doctor_profile_model.dart';
import 'package:optialeader/feature/doctor/data/model/courses_model.dart';
import 'package:optialeader/feature/doctor/data/model/verefication_status.dart';

/// ==========================================================
/// شروط منصب نائب رئيس الجامعة
/// ==========================================================
class VicePresidentCriteriaCalculator {
  // ==========================================================
  // الثوابت
  // ==========================================================

  /// الحد الأقصى للعمر
  static const int maxAge = 60;

  /// الحد الأدنى لسنوات الأستاذية
  static const int requiredProfessorYears = 5;

  /// الحد الأقصى لشغل وظيفة نائب رئيس الجامعة
  static const int maxVicePresidentYears = 2;

  // ==========================================================
  // 1. السن
  // ==========================================================

  /// حساب عمر الدكتور من تاريخ الميلاد.
  static int calculateAge(DoctorProfileModel doctor) {
    if (doctor.birthDate == null) {
      return 0;
    }

    return DateCalculationModel.forAge(
      doctor.birthDate!,
    ).result;
  }

  /// التحقق من أن العمر أقل من 60 سنة.
  static bool isAgeRequirementMet(
    DoctorProfileModel doctor,
  ) {
    final age = calculateAge(doctor);

    return age > 0 && age < maxAge;
  }

  // ==========================================================
  // 2. سنوات الأستاذية
  // ==========================================================

  /// حساب سنوات الأستاذية من تاريخ الأستاذية.
  static int calculateProfessorYears(
    DoctorProfileModel doctor,
  ) {
    if (doctor.professorRankDate == null) {
      return 0;
    }

    return DateCalculationModel.forProfessorRank(
      doctor.professorRankDate!,
    ).result;
  }

  /// التحقق من أن الدكتور أستاذ لمدة 5 سنوات على الأقل.
  static bool isProfessorRequirementMet(
    DoctorProfileModel doctor,
  ) {
    final years = calculateProfessorYears(doctor);

    return years >= requiredProfessorYears;
  }

  // ==========================================================
  // 3. التواجد الفعلي على رأس العمل
  // ==========================================================

  /// الدكتور يعتبر قائمًا على رأس العمل
  /// إذا كان حسابه نشطًا.
  static bool isActivelyOnDuty(
    DoctorProfileModel doctor,
  ) {
    return doctor.isActive;
  }

  // ==========================================================
  // 4. سنوات شغل وظيفة نائب رئيس الجامعة
  // ==========================================================

  /// حساب إجمالي السنوات التي شغل فيها الدكتور
  /// وظيفة نائب رئيس الجامعة.
  ///
  /// يتم التعرف على الوظيفة من اسم الوظيفة
  /// الموجود في JobHistory.
  static int calculateVicePresidentYears(
    DoctorProfileModel doctor,
  ) {
    int totalYears = 0;

    for (final job in doctor.jobHistory) {
      final titleAr = _normalizeArabic(job.jobTitleAr);
      final titleEn = job.jobTitleEn.toLowerCase().trim();

      final isVicePresident =
          titleAr.contains('نائب رئيس الجامعه') ||
          titleAr.contains('نائب رئيس') ||
          titleEn.contains('vice president');

      if (!isVicePresident) {
        continue;
      }

      final endDate = job.endDate ?? DateTime.now();

      totalYears += DateCalculationModel.betweenDates(
        start: job.startDate,
        end: endDate,
      ).result;
    }

    return totalYears;
  }

  /// التحقق من ألا يكون قد شغل وظيفة نائب رئيس الجامعة
  /// لمدة سنتين أو أكثر.
  ///
  /// أقل من سنتين = مستوفي
  /// سنتين أو أكثر = غير مستوفي
  static bool isVicePresidentYearsRequirementMet(
    DoctorProfileModel doctor,
  ) {
    final years = calculateVicePresidentYears(doctor);

    return years < maxVicePresidentYears;
  }

  // ==========================================================
  // 5. دورة القيادات
  // ==========================================================

  /// تحديد هل الدورة هي دورة القيادات المطلوبة
  /// لمنصب نائب رئيس الجامعة.
  ///
  /// مهم:
  /// لا يكفي أن تكون الدورة إدارية.
  /// يجب أن تكون دورة القيادات نفسها.
  static bool _isLeadershipCourse(
    CourseModel course,
  ) {
    final title = _normalizeArabic(course.title);

    return title.contains('fldc') ||
        title.contains('fl dc') ||
        title.contains('دورة fldc') ||
        title.contains('تنميه القيادات') ||
        title.contains('تنمية قأهيل القيادات') ||
        title.contains('دوره القيادات') ||
        title.contains('دورة القيادات') ||
        title.contains('القيادات');
  }

  /// التحقق من وجود دورة القيادات المطلوبة
  /// بشرط أن تكون معتمدة من الأدمن.
  static bool hasSectorLeadershipTraining(
    DoctorProfileModel doctor,
  ) {
    return doctor.courses.any(
      (course) =>
          _isLeadershipCourse(course) &&
          course.status == VerificationStatus.approved,
    );
  }

  /// الحصول على دورة القيادات المعتمدة.
  static CourseModel? getSectorLeadershipCourse(
    DoctorProfileModel doctor,
  ) {
    for (final course in doctor.courses) {
      final isLeadershipCourse =
          _isLeadershipCourse(course) &&
          course.status == VerificationStatus.approved;

      if (isLeadershipCourse) {
        return course;
      }
    }

    return null;
  }

  // ==========================================================
  // 6. خطة عمل لتطوير القطاع
  // ==========================================================

  /// خطة تطوير القطاع لا يتم التحقق منها تلقائيًا.
  ///
  /// يتم رفعها وقت التقديم
  /// وتخضع للمراجعة اليدوية.
  static bool isSectorPlanRequirementMet(
    DoctorProfileModel doctor,
  ) {
    return false;
  }

  // ==========================================================
  // تفاصيل الشروط
  // ==========================================================

  static String getAgeDetails(
    DoctorProfileModel doctor,
  ) {
    if (doctor.birthDate == null) {
      return 'تاريخ الميلاد غير مسجل';
    }

    final age = calculateAge(doctor);

    return 'العمر: $age سنة '
        '(المطلوب أقل من $maxAge سنة)';
  }

  static String getProfessorDetails(
    DoctorProfileModel doctor,
  ) {
    final years = calculateProfessorYears(doctor);

    if (years == 0) {
      return 'لا توجد سنوات أستاذية مسجلة';
    }

    return 'سنوات الأستاذية: $years '
        '(المطلوب $requiredProfessorYears سنوات)';
  }

  static String getActiveDutyDetails(
    DoctorProfileModel doctor,
  ) {
    return doctor.isActive
        ? 'الدكتور قائم على رأس العمل ونشط حاليًا'
        : 'الدكتور غير نشط حاليًا';
  }

  static String getVicePresidentYearsDetails(
    DoctorProfileModel doctor,
  ) {
    final years = calculateVicePresidentYears(doctor);

    if (years == 0) {
      return 'لم يشغل وظيفة نائب رئيس الجامعة - مستوفي';
    }

    return 'إجمالي مدة شغل وظيفة نائب رئيس الجامعة: $years '
        '(الحد الأقصى أقل من $maxVicePresidentYears سنوات)';
  }

  static String getLeadershipTrainingDetails(
    DoctorProfileModel doctor,
  ) {
    final course = getSectorLeadershipCourse(doctor);

    if (course == null) {
      return 'لا توجد دورة قيادات معتمدة من الأدمن';
    }

    return 'تم الحصول على دورة القيادات المعتمدة: ${course.title}';
  }

  static String getSectorPlanDetails(
    DoctorProfileModel doctor,
  ) {
    return 'خطة تطوير القطاع تُرفع وقت التقديم '
        'وتخضع للمراجعة اليدوية';
  }

  // ==========================================================
  // Helper
  // ==========================================================

  /// توحيد النص العربي والإنجليزي
  /// لتجنب اختلافات الكتابة.
  static String _normalizeArabic(String text) {
    return text
        .toLowerCase()
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي')
        .replaceAll('ؤ', 'و')
        .replaceAll('ئ', 'ي')
        .replaceAll('ـ', '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}