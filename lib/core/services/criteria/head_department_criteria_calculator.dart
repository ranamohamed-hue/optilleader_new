import 'package:optialeader/core/services/DateCalculation/date_calculation_model.dart';
import 'package:optialeader/feature/database_admin/data/models/doctor_profile_model.dart';

/// ==========================================================
/// شروط منصب رئيس القسم
/// ==========================================================
class HeadDepartmentCriteriaCalculator {
  // ==========================================================
  // الثوابت
  // ==========================================================

  /// مدة الدورة الواحدة لرئيس القسم
  static const int departmentHeadTermYears = 4;

  /// الحد الأقصى لعدد الدورات
  static const int maxDepartmentHeadTerms = 1;

  /// عدد الأساتذة المطلوب اختيارهم
  static const int topSeniorCount = 3;

  // ==========================================================
  // 1. أقدم 3 أساتذة
  // ==========================================================

  /// الحصول على أقدم 3 أساتذة:
  ///
  /// - من نفس الكلية
  /// - من نفس القسم
  /// - حاصلين على الأستاذية
  /// - يتم الترتيب حسب تاريخ الأستاذية
  static List<String> getTop3SeniorProfessors({
    required List<DoctorProfileModel> doctors,
    required String facultyAr,
    required String departmentAr,
  }) {
    final targetFaculty = _normalizeArabic(facultyAr);
    final targetDepartment = _normalizeArabic(departmentAr);

    if (targetFaculty.isEmpty || targetDepartment.isEmpty) {
      return [];
    }

    // نفس الكلية + نفس القسم + حاصل على الأستاذية
    final professors = doctors.where((doctor) {
      return _normalizeArabic(doctor.facultyAr) == targetFaculty &&
          _normalizeArabic(doctor.departmentAr) == targetDepartment &&
          doctor.professorRankDate != null &&
          doctor.uid != null;
    }).toList();

    if (professors.isEmpty) {
      return [];
    }

    // الأقدم في الأستاذية أولاً
    professors.sort((a, b) {
      return a.professorRankDate!.compareTo(
        b.professorRankDate!,
      );
    });

    // أول 3 فقط
    return professors
        .take(topSeniorCount)
        .map((doctor) => doctor.uid!)
        .toList();
  }

  /// التحقق هل الدكتور ضمن أقدم 3 أساتذة
  static bool isTop3SeniorProfessor({
    required DoctorProfileModel doctor,
    required List<DoctorProfileModel> doctors,
    required String facultyAr,
    required String departmentAr,
  }) {
    if (doctor.uid == null) {
      return false;
    }

    final top3 = getTop3SeniorProfessors(
      doctors: doctors,
      facultyAr: facultyAr,
      departmentAr: departmentAr,
    );

    return top3.contains(doctor.uid);
  }

  // ==========================================================
  // 2. سنوات شغل رئيس القسم
  // ==========================================================

  /// حساب عدد السنوات التي شغل فيها الدكتور
  /// منصب رئيس القسم من الـ JobHistory.
  ///
  /// لا نعتمد على yearsAsDean أو أي قيمة محفوظة.
  static int calculateDepartmentHeadYears(
    DoctorProfileModel doctor,
  ) {
    int totalYears = 0;

    for (final job in doctor.jobHistory) {
      final titleAr = _normalizeArabic(job.jobTitleAr);
      final titleEn = job.jobTitleEn.toLowerCase().trim();

      final isDepartmentHead =
          titleAr.contains('رئيس قسم') ||
          titleAr.contains('رئيس القسم') ||
          titleEn.contains('head of department') ||
          titleEn.contains('head department') ||
          titleEn.contains('department head');

      if (!isDepartmentHead) {
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

  // ==========================================================
  // 3. حساب عدد الدورات
  // ==========================================================

  /// الدورة الواحدة = 4 سنوات.
  ///
  /// مثال:
  /// 0 - 3 سنوات = 0 دورة كاملة
  /// 4 - 7 سنوات = دورة واحدة
  /// 8 سنوات أو أكثر = دورتان
  static int calculateDepartmentHeadTerms(
    DoctorProfileModel doctor,
  ) {
    final years = calculateDepartmentHeadYears(doctor);

    return years ~/ departmentHeadTermYears;
  }

  // ==========================================================
  // 4. شرط عدم تجاوز دورة واحدة
  // ==========================================================

  static bool isDepartmentHeadTermRequirementMet(
    DoctorProfileModel doctor,
  ) {
    final terms = calculateDepartmentHeadTerms(doctor);

    return terms <= maxDepartmentHeadTerms;
  }

  // ==========================================================
  // 5. المشاركة في اللجان الداخلية
  // ==========================================================

  /// المشاركة في اللجان الداخلية يتم أخذها
  /// من internalCommittees الموجودة في DoctorProfileModel.
  static bool hasInternalCommittees(
    DoctorProfileModel doctor,
  ) {
    return doctor.internalCommittees.isNotEmpty;
  }

  // ==========================================================
  // تفاصيل الشروط
  // ==========================================================

  static String getTop3Details({
    required DoctorProfileModel doctor,
    required List<DoctorProfileModel> doctors,
    required String facultyAr,
    required String departmentAr,
  }) {
    final isTop3 = isTop3SeniorProfessor(
      doctor: doctor,
      doctors: doctors,
      facultyAr: facultyAr,
      departmentAr: departmentAr,
    );

    if (isTop3) {
      return 'الدكتور ضمن أقدم 3 أساتذة في نفس الكلية والقسم';
    }

    return 'الدكتور ليس ضمن أقدم 3 أساتذة في نفس الكلية والقسم';
  }

  static String getDepartmentHeadYearsDetails(
    DoctorProfileModel doctor,
  ) {
    final years = calculateDepartmentHeadYears(doctor);

    if (years == 0) {
      return 'لم يشغل منصب رئيس القسم - مستوفي';
    }

    return 'مدة شغل رئاسة القسم: $years سنوات '
        '(الدورة الواحدة $departmentHeadTermYears سنوات)';
  }

  static String getDepartmentHeadTermsDetails(
    DoctorProfileModel doctor,
  ) {
    final years = calculateDepartmentHeadYears(doctor);
    final terms = calculateDepartmentHeadTerms(doctor);

    if (years == 0) {
      return 'لم يشغل منصب رئيس القسم - مستوفي';
    }

    return 'عدد الدورات الكاملة: $terms '
        'من $maxDepartmentHeadTerms '
        '(إجمالي السنوات: $years)';
  }

  static String getInternalCommitteesDetails(
    DoctorProfileModel doctor,
  ) {
    if (doctor.internalCommittees.isEmpty) {
      return 'لا توجد مشاركة في اللجان الداخلية';
    }

    return 'توجد مشاركة في اللجان الداخلية '
        '(${doctor.internalCommittees.length} لجنة)';
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