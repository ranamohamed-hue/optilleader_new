import 'package:optialeader/core/services/DateCalculation/date_calculation_model.dart';
import 'package:optialeader/feature/database_admin/data/models/doctor_profile_model.dart';
import  'package:optialeader/feature/doctor/data/model/verefication_status.dart';

class ViceDeanCriteriaCalculator {
  // ==========================================================
  // ثوابت شروط منصب وكيل الكلية
  // ==========================================================

  /// الحد الأقصى لعمر المتقدم
  static const int maxAge = 60;

  /// الحد الأدنى لسنوات الأستاذية
  static const int requiredProfessorYears = 1;

  /// الحد الأقصى لسنوات شغل منصب الوكيل
  static const int maxViceDeanYears = 6;

  /// مدة الدورة الكاملة للوكيل
  static const int viceDeanTermYears = 3;

  /// الحد الأقصى لعدد الدورات
  static const int maxViceDeanTerms = 2;

  // ==========================================================
  // 1. العمر
  // ==========================================================

  /// حساب عمر الطبيب باستخدام DateCalculationModel
  static int calculateAge(DoctorProfileModel doctor) {
    if (doctor.birthDate == null) return 0;

    return DateCalculationModel.forAge(
      doctor.birthDate!,
    ).result;
  }

  /// شرط أن يكون العمر أقل من 60 سنة
  static bool isAgeRequirementMet(DoctorProfileModel doctor) {
    if (doctor.birthDate == null) return false;

    final age = calculateAge(doctor);

    return age < maxAge;
  }

  // ==========================================================
  // 2. سنوات الأستاذية
  // ==========================================================

  /// حساب سنوات الأستاذية.
  ///
  /// المصدر الأساسي هو professorRankDate.
  ///
  /// مثال:
  /// professorRankDate = 2024
  /// currentDate = 2026
  /// النتيجة = سنتان
  static int calculateViceDeanProfessorYears(
    DoctorProfileModel doctor,
  ) {
    if (doctor.professorRankDate == null) {
      return 0;
    }

    return DateCalculationModel.forProfessorRank(
      doctor.professorRankDate!,
    ).result;
  }

  /// شرط أن يكون أستاذًا لمدة سنة على الأقل.
  static bool isProfessorRequirementMet(
    DoctorProfileModel doctor,
  ) {
    return calculateViceDeanProfessorYears(doctor) >=
        requiredProfessorYears;
  }

  // ==========================================================
  // 3. قائم على رأس العمل
  // ==========================================================

  /// الطبيب يعتبر قائمًا على رأس العمل إذا:
  ///
  /// - نشط
  /// - ليس في إجازة
  /// - ليس منتدبًا
  /// - ليس في إجازة بدون مرتب
  static bool isActiveOnDuty(DoctorProfileModel doctor) {
    return doctor.isActive &&
        !doctor.isOnVacation &&
        !(doctor.isOnSecondment ?? false) &&
        !(doctor.isOnUnpaidLeave ?? false);
  }

  // ==========================================================
  // 4. حساب سنوات شغل منصب وكيل
  // ==========================================================

  /// حساب إجمالي سنوات شغل منصب وكيل الكلية
  /// من JobHistory.
  ///
  /// يتم جمع كل الفترات:
  ///
  /// وكيل 2017 -> 2020 = 3 سنوات
  /// وكيل 2021 -> 2024 = 3 سنوات
  ///
  /// الإجمالي = 6 سنوات
  static int calculateViceDeanYears(
    DoctorProfileModel doctor,
  ) {
    int totalYears = 0;

    for (final job in doctor.jobHistory) {
      final jobTitleAr = _normalizeArabic(job.jobTitleAr);
      final jobTitleEn = job.jobTitleEn.toLowerCase();

      final isViceDean =
          jobTitleAr.contains('وكيل') ||
          jobTitleAr.contains('وكيل الكليه') ||
          jobTitleAr.contains('وكيل الكلية') ||
          jobTitleEn.contains('vice dean');

      if (!isViceDean) continue;

      final endDate = job.endDate ?? DateTime.now();

      totalYears += DateCalculationModel.betweenDates(
        start: job.startDate,
        end: endDate,
      ).result;
    }

    return totalYears;
  }

  // ==========================================================
  // 5. شرط ألا يتجاوز 6 سنوات كوكيل
  // ==========================================================

  static bool isViceDeanMaximumYearsMet(
    DoctorProfileModel doctor,
  ) {
    final years = calculateViceDeanYears(doctor);

    return years <= maxViceDeanYears;
  }

  // ==========================================================
  // 6. حساب الدورات الكاملة
  // ==========================================================

  /// كل دورة = 3 سنوات.
  ///
  /// 3 سنوات = دورة واحدة
  /// 6 سنوات = دورتان
  /// 9 سنوات = 3 دورات
  static int calculateViceDeanFullTerms(
    DoctorProfileModel doctor,
  ) {
    final years = calculateViceDeanYears(doctor);

    return years ~/ viceDeanTermYears;
  }

  // ==========================================================
  // 7. شرط ألا يتجاوز دورتين كاملتين
  // ==========================================================

  static bool isViceDeanMaximumTwoTermsMet(
    DoctorProfileModel doctor,
  ) {
    final terms = calculateViceDeanFullTerms(doctor);

    return terms <= maxViceDeanTerms;
  }

  // ==========================================================
  // 8. التحقق من دورة FLDC
  // ==========================================================

  /// البحث عن دورة FLDC معتمدة.
  ///
  /// نعتمد على doctor.courses لأن CourseModel
  /// موجود بالفعل داخل DoctorProfileModel.
  static bool hasApprovedFLDC(
    DoctorProfileModel doctor,
  ) {
    return doctor.courses.any((course) {
      if (course.status != VerificationStatus.approved) {
        return false;
      }

      final title = _normalizeArabic(
        course.title.toLowerCase(),
      );

      return title.contains('fldc') ||
          title.contains('fl dc') ||
          title.contains('ال fldc') ||
          title.contains('دورة fldc') ||
          title.contains('القيادات') ||
          title.contains('تنميه القيادات') ||
          title.contains('دورة القيادة الاستراتيجية');
    });
  }

  /// شرط الحصول على دورة FLDC
  static bool isFLDCRequirementMet(
    DoctorProfileModel doctor,
  ) {
    return hasApprovedFLDC(doctor);
  }

  // ==========================================================
  // 9. تفاصيل الشروط
  // ==========================================================

  static String getAgeDetails(
    DoctorProfileModel doctor,
  ) {
    if (doctor.birthDate == null) {
      return 'تاريخ الميلاد غير مسجل';
    }

    final age = calculateAge(doctor);

    return 'العمر: $age سنة (يجب أن يكون أقل من $maxAge)';
  }

  static String getProfessorDetails(
    DoctorProfileModel doctor,
  ) {
    final years = calculateViceDeanProfessorYears(doctor);

    return 'سنوات الأستاذية: $years '
        '(المطلوب $requiredProfessorYears سنة)';
  }

  static String getActiveDutyDetails(
    DoctorProfileModel doctor,
  ) {
    if (isActiveOnDuty(doctor)) {
      return 'قائم على رأس العمل';
    }

    final reasons = <String>[];

    if (!doctor.isActive) {
      reasons.add('غير نشط');
    }

    if (doctor.isOnVacation) {
      reasons.add('في إجازة');
    }

    if (doctor.isOnSecondment ?? false) {
      reasons.add('منتدب');
    }

    if (doctor.isOnUnpaidLeave ?? false) {
      reasons.add('إجازة بدون مرتب');
    }

    return 'غير قائم على رأس العمل: ${reasons.join('، ')}';
  }

  static String getViceDeanYearsDetails(
    DoctorProfileModel doctor,
  ) {
    final years = calculateViceDeanYears(doctor);

    if (years == 0) {
      return 'لم يشغل منصب وكيل - مستوفي';
    }

    return 'عدد سنوات شغل منصب الوكيل: $years '
        '(الحد الأقصى $maxViceDeanYears سنوات)';
  }

  static String getViceDeanTermsDetails(
    DoctorProfileModel doctor,
  ) {
    final years = calculateViceDeanYears(doctor);
    final terms = calculateViceDeanFullTerms(doctor);

    if (years == 0) {
      return 'لم يشغل منصب الوكيل - مستوفي';
    }

    return 'عدد الدورات الكاملة: $terms '
        'من $maxViceDeanTerms '
        '(إجمالي السنوات: $years)';
  }

  static String getFLDCDetails(
    DoctorProfileModel doctor,
  ) {
    return hasApprovedFLDC(doctor)
        ? 'تم الحصول على دورة FLDC معتمدة'
        : 'لم يتم الحصول على دورة FLDC معتمدة';
  }

  // ==========================================================
  // Helper
  // ==========================================================

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
        .trim();
  }
}