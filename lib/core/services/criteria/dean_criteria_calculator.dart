import 'package:optialeader/core/services/DateCalculation/date_calculation_model.dart';
import 'package:optialeader/feature/database_admin/data/models/doctor_profile_model.dart';

class DeanCriteriaCalculator {
  // ==========================================================
  // شروط منصب العميد
  // ==========================================================

  /// الحد الأدنى لسنوات الأستاذية المطلوبة
  static const int requiredProfessorYears = 3;

  /// الحد الأقصى لسنوات شغل منصب العميد
  static const int maxDeanYears = 8;

  /// مدة الدورة الكاملة للعميد
  static const int deanTermYears = 4;

  /// الحد الأقصى لعدد الدورات الكاملة
  static const int maxDeanTerms = 2;

  // ==========================================================
  // 1. سنوات الأستاذية
  // ==========================================================

  static int calculateDeanProfessorYears(DoctorProfileModel doctor) {
    int totalYears = 0;

    // ✅ التصحيح: jobHistory مش jopHistory
    for (final job in doctor.jobHistory) {
      final jobTitleAr = _normalizeArabic(job.jobTitleAr);
      final jobTitleEn = job.jobTitleEn.toLowerCase();

      final isProfessor =
          jobTitleAr.contains('استاذ') || jobTitleEn.contains('professor');

      if (!isProfessor) continue;

      final endDate = job.endDate ?? DateTime.now();

      totalYears += DateCalculationModel.betweenDates(
        start: job.startDate,
        end: endDate,
      ).result;
    }

    // في حالة عدم وجود سجل أستاذ في JobHistory
    if (totalYears == 0 && doctor.professorRankDate != null) {
      return DateCalculationModel.forProfessorRank(
        doctor.professorRankDate!,
      ).result;
    }

    return totalYears;
  }

  /// التحقق من شرط الأستاذ لمدة 3 سنوات على الأقل.
  static bool isDeanProfessorRequirementMet(DoctorProfileModel doctor) {
    return calculateDeanProfessorYears(doctor) >= requiredProfessorYears;
  }

  // ==========================================================
  // 2. الدكتوراه
  // ==========================================================

  static bool isDeanPhdRequirementMet(DoctorProfileModel doctor) {
    final hasPhdInAcademicHistory = doctor.academicHistory.any((item) {
      final degree = _normalizeArabic((item['degree'] ?? '').toString());

      final type = _normalizeArabic((item['type'] ?? '').toString());

      return degree.contains('دكتوراه') ||
          degree.contains('دكتور') ||
          degree.contains('phd') ||
          degree.contains('ph.d') ||
          degree.contains('doctorate') ||
          type.contains('دكتوراه') ||
          type.contains('phd');
    });

    if (hasPhdInAcademicHistory) {
      return true;
    }

    // الأستاذية تعتبر fallback للدكتوراه
    return doctor.professorRankDate != null;
  }

  static int calculateDeanYears(DoctorProfileModel doctor) {
    int totalYears = 0;

    for (final job in doctor.jobHistory) {
      final jobTitleAr = _normalizeArabic(job.jobTitleAr);
      final jobTitleEn = job.jobTitleEn.toLowerCase();

      final isDean = jobTitleAr.contains('عميد') || jobTitleEn.contains('dean');

      if (!isDean) continue;

      final endDate = job.endDate ?? DateTime.now();

      totalYears += DateCalculationModel.betweenDates(
        start: job.startDate,
        end: endDate,
      ).result;
    }

    // fallback للبيانات القديمة
    if (totalYears == 0 && doctor.yearsAsDean != null) {
      return doctor.yearsAsDean!;
    }

    return totalYears;
  }

  // ==========================================================
  // 4. شرط ألا يتجاوز 8 سنوات كعميد
  // ==========================================================

  static bool isDeanMaximumEightYearsMet(DoctorProfileModel doctor) {
    final years = calculateDeanYears(doctor);

    return years <= maxDeanYears;
  }

  // ==========================================================
  // 5. حساب الدورات الكاملة للعميد
  // ==========================================================

  static int calculateDeanFullTerms(DoctorProfileModel doctor) {
    final years = calculateDeanYears(doctor);

    return years ~/ deanTermYears;
  }

  // ==========================================================
  // 6. شرط ألا يشغل العميد أكثر من دورتين كاملتين
  // ==========================================================

  static bool isDeanMaximumTwoTermsMet(DoctorProfileModel doctor) {
    final terms = calculateDeanFullTerms(doctor);

    return terms <= maxDeanTerms;
  }

  // ==========================================================
  // 7. شرط عدم شغل منصب حزبي
  // ==========================================================

  static bool isDeanPartyPositionRequirementMet(DoctorProfileModel doctor) {
    return !doctor.holdsPartyPosition;
  }

  // ==========================================================
  // 8. شرط السلامة الصحية
  // ==========================================================

  static bool isDeanHealthRequirementMet(DoctorProfileModel doctor) {
    return doctor.hasHealthCertificate;
  }

  // ==========================================================
  // تفاصيل الشروط
  // ==========================================================

  static String getDeanProfessorDetails(DoctorProfileModel doctor) {
    final years = calculateDeanProfessorYears(doctor);

    if (years == 0) {
      return 'لا توجد سنوات أستاذية مسجلة';
    }

    return 'سنوات الأستاذية: $years '
        '(المطلوب $requiredProfessorYears سنوات)';
  }

  static String getDeanPhdDetails(DoctorProfileModel doctor) {
    return isDeanPhdRequirementMet(doctor)
        ? 'تم التحقق من الحصول على الدكتوراه'
        : 'لم يتم التحقق من الحصول على الدكتوراه';
  }

  static String getDeanYearsDetails(DoctorProfileModel doctor) {
    final years = calculateDeanYears(doctor);

    if (years == 0) {
      return 'لم يشغل منصب العميد - مستوفي';
    }

    return 'عدد سنوات العمادة: $years '
        '(الحد الأقصى $maxDeanYears سنوات)';
  }

  static String getDeanTermsDetails(DoctorProfileModel doctor) {
    final years = calculateDeanYears(doctor);
    final terms = calculateDeanFullTerms(doctor);

    if (years == 0) {
      return 'لم يشغل منصب العميد - مستوفي';
    }

    return 'عدد الدورات الكاملة: $terms '
        'من $maxDeanTerms '
        '(إجمالي السنوات: $years)';
  }

  static String getDeanPartyPositionDetails(DoctorProfileModel doctor) {
    return doctor.holdsPartyPosition
        ? 'يشغل منصبًا حزبيًا'
        : 'لا يشغل منصبًا حزبيًا';
  }

  static String getDeanHealthDetails(DoctorProfileModel doctor) {
    return doctor.hasHealthCertificate
        ? 'تم تقديم شهادة السلامة الصحية'
        : 'لم يتم تقديم شهادة السلامة الصحية';
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
