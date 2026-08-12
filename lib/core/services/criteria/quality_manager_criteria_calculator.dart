import 'package:optialeader/feature/database_admin/data/models/doctor_profile_model.dart';
import 'package:optialeader/feature/doctor/data/model/courses_model.dart';
import 'package:optialeader/feature/doctor/data/model/verefication_status.dart';

/// ==========================================================
/// شروط منصب مدير الجودة
/// ==========================================================
class QualityManagerCriteriaCalculator {
  // ==========================================================
  // 1. الوظيفة الحالية
  // ==========================================================

  /// الوظائف المسموح بها:
  /// - مدرس
  /// - أستاذ مساعد
  /// - أستاذ
  static bool isCurrentAcademicRankRequirementMet(
    DoctorProfileModel doctor,
  ) {
    final jobAr = _normalizeArabic(doctor.currentJobAr);
    final jobEn = doctor.currentJobEn.toLowerCase().trim();

    return jobAr.contains('مدرس') ||
        jobAr.contains('استاذ مساعد') ||
        jobAr.contains('استاذ') ||
        jobEn.contains('lecturer') ||
        jobEn.contains('assistant professor') ||
        jobEn.contains('professor');
  }

  // ==========================================================
  // 2. دورات الجودة
  // ==========================================================

  /// البحث عن دورة جودة معتمدة داخل دورات الدكتور.
  ///
  /// تعتمد على:
  /// - وجود كلمة جودة / quality في اسم الدورة
  /// - وأن تكون الدورة معتمدة.
  static bool hasQualityTraining(
    DoctorProfileModel doctor,
  ) {
    return doctor.courses.any((course) {
      if (course.status != VerificationStatus.approved) {
        return false;
      }

      final titleAr = _normalizeArabic(course.title);
      final titleEn = course.title.toLowerCase().trim();

      return titleAr.contains('جوده') ||
          titleAr.contains('ضمان الجوده') ||
          titleAr.contains('اداره الجوده') ||
          titleEn.contains('quality') ||
          titleEn.contains('quality assurance');
    });
  }

  /// إرجاع أول دورة جودة معتمدة.
  static CourseModel? getQualityTrainingCourse(
    DoctorProfileModel doctor,
  ) {
    for (final course in doctor.courses) {
      if (course.status != VerificationStatus.approved) {
        continue;
      }

      final titleAr = _normalizeArabic(course.title);
      final titleEn = course.title.toLowerCase().trim();

      final isQualityCourse =
          titleAr.contains('جوده') ||
          titleAr.contains('ضمان الجوده') ||
          titleAr.contains('اداره الجوده') ||
          titleEn.contains('quality') ||
          titleEn.contains('quality assurance');

      if (isQualityCourse) {
        return course;
      }
    }

    return null;
  }

  // ==========================================================
  // 3. مهارات التواصل والقيادة
  // ==========================================================

  /// هذا الشرط مفتوح للمراجعة اليدوية.
  static bool isCommunicationAndLeadershipRequirementMet(
    DoctorProfileModel doctor,
  ) {
    return false;
  }

  // ==========================================================
  // 4. ICDL
  // ==========================================================

  /// يتم الاعتماد على getter الموجود في DoctorProfileModel.
  static bool isICDLRequirementMet(
    DoctorProfileModel doctor,
  ) {
    return doctor.hasICDL;
  }

  // ==========================================================
  // 5. إعداد دراسات تقييم ذاتي
  // ==========================================================

  /// هذا الشرط مفتوح للمراجعة اليدوية.
  static bool isSelfAssessmentStudiesRequirementMet(
    DoctorProfileModel doctor,
  ) {
    return false;
  }

  // ==========================================================
  // تفاصيل الشروط
  // ==========================================================

  static String getAcademicRankDetails(
    DoctorProfileModel doctor,
  ) {
    if (doctor.currentJobAr.trim().isEmpty &&
        doctor.currentJobEn.trim().isEmpty) {
      return 'الوظيفة الحالية غير مسجلة';
    }

    return 'الوظيفة الحالية: '
        '${doctor.currentJobAr.isNotEmpty ? doctor.currentJobAr : doctor.currentJobEn}';
  }

  static String getQualityTrainingDetails(
    DoctorProfileModel doctor,
  ) {
    final course = getQualityTrainingCourse(doctor);

    if (course == null) {
      return 'لا توجد دورة جودة معتمدة';
    }

    return 'تم الحصول على دورة جودة معتمدة: ${course.title}';
  }

  static String getCommunicationAndLeadershipDetails(
    DoctorProfileModel doctor,
  ) {
    return 'مهارات التواصل والقيادة تخضع للمراجعة اليدوية وقت التقديم';
  }

  static String getICDLDetails(
    DoctorProfileModel doctor,
  ) {
    return doctor.hasICDL
        ? 'تم التحقق من الحصول على ICDL أو ما يعادلها'
        : 'لا توجد شهادة ICDL معتمدة';
  }

  static String getSelfAssessmentStudiesDetails(
    DoctorProfileModel doctor,
  ) {
    return 'إعداد دراسات التقييم الذاتي يخضع للمراجعة اليدوية وقت التقديم';
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