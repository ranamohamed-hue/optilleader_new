import 'package:optialeader/core/services/DateCalculation/date_calculation_model.dart';
import 'package:optialeader/feature/database_admin/data/models/doctor_profile_model.dart';
import 'package:optialeader/feature/doctor/data/model/courses_model.dart';

/// ==========================================================
/// شروط منصب رئيس الجامعة
/// ==========================================================
class UniversityPresidentCriteriaCalculator {
  // ==========================================================
  // الثوابت
  // ==========================================================

  /// الحد الأقصى للعمر
  static const int maxAge = 60;

  /// الحد الأدنى لسنوات الأستاذية
  static const int requiredProfessorYears = 5;

  /// الحد الأدنى للتواجد على رأس العمل
  static const int requiredActiveDutyYears = 2;

  /// مدة الدورة الواحدة لرئيس الجامعة
  static const int presidentTermYears = 5;

  /// الحد الأقصى لعدد الدورات
  static const int maxPresidentTerms = 1;

  // ==========================================================
  // 1. السن
  // ==========================================================

  /// حساب العمر من تاريخ الميلاد.
  static int calculateAge(
    DoctorProfileModel doctor,
  ) {
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
  // 3. أستاذ عامل وحسابه نشط
  // ==========================================================

  /// الدكتور يعتبر أستاذًا عاملًا إذا:
  /// 1. لديه تاريخ أستاذية.
  /// 2. حسابه نشط.
  static bool isActiveProfessor(
    DoctorProfileModel doctor,
  ) {
    return doctor.professorRankDate != null &&
        doctor.isActive;
  }

  // ==========================================================
  // 4. التواجد على رأس العمل لمدة سنتين
  // ==========================================================

  /// حساب سنوات التواجد على رأس العمل
  /// من تاريخ activeDutySinceDate.
  static int calculateActiveDutyYears(
    DoctorProfileModel doctor,
  ) {
    if (doctor.activeDutySinceDate == null) {
      return 0;
    }

    return DateCalculationModel.forHiring(
      doctor.activeDutySinceDate!,
    ).result;
  }

  /// التحقق من:
  /// - الحساب نشط
  /// - على رأس العمل لمدة سنتين على الأقل.
  static bool isActiveDutyRequirementMet(
    DoctorProfileModel doctor,
  ) {
    final years = calculateActiveDutyYears(doctor);

    return doctor.isActive &&
        years >= requiredActiveDutyYears;
  }

  // ==========================================================
  // 5. سنوات شغل منصب رئيس الجامعة
  // ==========================================================

  /// حساب إجمالي سنوات شغل منصب رئيس الجامعة.
  ///
  /// يتم البحث في JobHistory عن اسم الوظيفة فقط.
  ///
  /// لا يتم الاعتماد على القطاع.
  static int calculateUniversityPresidentYears(
    DoctorProfileModel doctor,
  ) {
    int totalYears = 0;

    for (final job in doctor.jobHistory) {
      final titleAr = _normalizeArabic(
        job.jobTitleAr,
      );

      final titleEn = job.jobTitleEn
          .toLowerCase()
          .trim();

      final isUniversityPresident =
          titleAr.contains('رئيس جامعه') ||
          titleAr.contains('رئيس جامعة') ||
          titleEn.contains('university president');

      if (!isUniversityPresident) {
        continue;
      }

      final endDate =
          job.endDate ?? DateTime.now();

      totalYears +=
          DateCalculationModel.betweenDates(
        start: job.startDate,
        end: endDate,
      ).result;
    }

    return totalYears;
  }

  // ==========================================================
  // 6. حساب عدد الدورات
  // ==========================================================

  /// كل 5 سنوات = دورة واحدة.
  ///
  /// 0 - 4 سنوات = 0 دورة كاملة
  /// 5 - 9 سنوات = دورة واحدة
  /// 10 - 14 سنة = دورتان
  static int calculatePresidentFullTerms(
    DoctorProfileModel doctor,
  ) {
    final years =
        calculateUniversityPresidentYears(
      doctor,
    );

    return years ~/ presidentTermYears;
  }

  /// التحقق من ألا يتجاوز دورة واحدة.
  static bool isPresidentTermRequirementMet(
    DoctorProfileModel doctor,
  ) {
    final terms =
        calculatePresidentFullTerms(
      doctor,
    );

    return terms <= maxPresidentTerms;
  }

  // ==========================================================
  // 7. دورة المجلس الأعلى للجامعات
  // ==========================================================

  /// التحقق من وجود دورة المجلس الأعلى للجامعات
  /// ضمن الدورات المعتمدة.
  ///
  /// يتم الاعتماد على:
  /// courseCategory == administrative
  /// status == approved
  static bool hasSupremeCouncilTraining(
    DoctorProfileModel doctor,
  ) {
    return doctor.courses.any(
      (course) =>
          course.courseCategory ==
              CourseCategory.administrative &&
          course.status.name == 'approved',
    );
  }

  /// إرجاع دورة المجلس الأعلى للجامعات.
  static CourseModel? getSupremeCouncilCourse(
    DoctorProfileModel doctor,
  ) {
    for (final course in doctor.courses) {
      final isSupremeCouncilCourse =
          course.courseCategory ==
              CourseCategory.administrative &&
          course.status.name == 'approved';

      if (isSupremeCouncilCourse) {
        return course;
      }
    }

    return null;
  }

  // ==========================================================
  // 8. خطة العمل
  // ==========================================================

  /// خطة العمل يتم تقديمها وقت التقديم
  /// وتخضع للمراجعة اليدوية.
  static bool isWorkPlanRequirementMet(
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
    final years =
        calculateProfessorYears(doctor);

    if (years == 0) {
      return 'لا توجد سنوات أستاذية مسجلة';
    }

    return 'سنوات الأستاذية: $years '
        '(المطلوب $requiredProfessorYears سنوات)';
  }

  static String getActiveProfessorDetails(
    DoctorProfileModel doctor,
  ) {
    if (!doctor.isActive) {
      return 'الحساب غير نشط';
    }

    if (doctor.professorRankDate == null) {
      return 'لا يوجد تاريخ أستاذية';
    }

    return 'أستاذ وحسابه نشط حاليًا';
  }

  static String getActiveDutyDetails(
    DoctorProfileModel doctor,
  ) {
    final years =
        calculateActiveDutyYears(doctor);

    if (!doctor.isActive) {
      return 'الدكتور غير نشط حاليًا';
    }

    return 'مدة التواجد على رأس العمل: $years '
        '(المطلوب $requiredActiveDutyYears سنوات)';
  }

  static String getPresidentTermsDetails(
    DoctorProfileModel doctor,
  ) {
    final years =
        calculateUniversityPresidentYears(
      doctor,
    );

    final terms =
        calculatePresidentFullTerms(
      doctor,
    );

    if (years == 0) {
      return 'لم يشغل منصب رئيس الجامعة - مستوفي';
    }

    return 'مدة شغل منصب رئيس الجامعة: $years سنوات '
        '، عدد الدورات الكاملة: $terms '
        'من $maxPresidentTerms';
  }

  static String getSupremeCouncilTrainingDetails(
    DoctorProfileModel doctor,
  ) {
    final course =
        getSupremeCouncilCourse(doctor);

    if (course == null) {
      return 'لا توجد دورة معتمدة للمجلس الأعلى للجامعات';
    }

    return 'تم الحصول على الدورة: ${course.title}';
  }

  static String getWorkPlanDetails(
    DoctorProfileModel doctor,
  ) {
    return 'خطة العمل تُرفع وقت التقديم '
        'وتخضع للمراجعة اليدوية';
  }

  // ==========================================================
  // Helper
  // ==========================================================

  static String _normalizeArabic(
    String text,
  ) {
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
        .trim();
  }
}