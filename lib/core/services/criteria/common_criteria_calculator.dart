import 'package:optialeader/feature/database_admin/data/models/doctor_profile_model.dart';
import 'package:optialeader/feature/doctor/data/model/courses_model.dart';
import 'package:optialeader/feature/doctor/data/model/verefication_status.dart';
import 'package:optialeader/feature/doctor/logic/activities/mandatory_leadership_data.dart';

/// ==========================================================
/// الشروط العامة المشتركة لجميع المناصب
/// ==========================================================
class CommonCriteriaCalculator {
  // ==========================================================
  // الثوابت
  // ==========================================================

  /// الحد الأدنى لعدد الدورات القيادية المطلوبة
  static const int requiredLeadershipCourses = 2;

  // ==========================================================
  // 1. الجنسية المصرية
  // ==========================================================

  static bool isEgyptian(DoctorProfileModel doctor) {
    final nationalityAr = doctor.nationalityAr.trim().toLowerCase();
    final nationalityEn = doctor.nationalityEn.trim().toLowerCase();

    return nationalityAr == 'مصر' ||
        nationalityAr == 'مصرى' ||
        nationalityAr == 'مصرية' ||
        nationalityEn == 'egypt' ||
        nationalityEn == 'egyptian';
  }

  // ==========================================================
  // 2. عدم وجود حكم بجناية
  // ==========================================================

  static bool hasNoCriminalRecord(
    DoctorProfileModel doctor,
  ) {
    return !doctor.hasCriminalRecord;
  }

  // ==========================================================
  // 3. عدم وجود جزاء تأديبي
  // ==========================================================

  static bool hasCleanDisciplinaryRecord(
    DoctorProfileModel doctor,
  ) {
    return doctor.disciplinaryClearance;
  }

  // ==========================================================
  // 4. عدم شغل منصب حزبي
  // ==========================================================

  static bool hasNoPartyPosition(
    DoctorProfileModel doctor,
  ) {
    return !doctor.holdsPartyPosition;
  }

  // ==========================================================
  // 5. ICDL
  // ==========================================================

  static bool hasICDL(
    DoctorProfileModel doctor,
  ) {
    return doctor.hasICDL;
  }

  // ==========================================================
  // 6. الدورات القيادية المحددة في النظام
  // ==========================================================

  /// مفاتيح الدورات القيادية السبعة المحددة بالنظام.
  static Set<String> get mandatoryLeadershipKeys {
    return MandatoryLeadershipData.courses
        .map((course) => course['key']!)
        .toSet();
  }

  /// يرجع الدورات القيادية المطلوبة فقط والمُعتمدة من الأدمن.
  ///
  /// لكي تُحسب الدورة:
  /// 1. تكون واحدة من الدورات السبعة المحددة مسبقًا.
  /// 2. تكون Approved.
  ///
  /// لا نعتمد على CourseCategory هنا،
  /// لأن الدورات الإلزامية في CourseModel قد تكون
  /// CourseCategory.none.
  static List<CourseModel> getApprovedLeadershipCourses(
    DoctorProfileModel doctor,
  ) {
    final mandatoryKeys = mandatoryLeadershipKeys;

    return doctor.courses.where((course) {
      final isRequiredCourse =
          course.mandatoryKey != null &&
          mandatoryKeys.contains(course.mandatoryKey);

      final isApproved =
          course.status == VerificationStatus.approved;

      return isRequiredCourse && isApproved;
    }).toList();
  }

  /// عدد الدورات القيادية المحددة والمعتمدة.
  static int calculateLeadershipCoursesCount(
    DoctorProfileModel doctor,
  ) {
    return getApprovedLeadershipCourses(doctor).length;
  }

  /// التحقق من وجود دورتين على الأقل من الدورات المحددة
  /// والمعتمدة من الأدمن.
  static bool hasRequiredLeadershipCourses(
    DoctorProfileModel doctor,
  ) {
    return calculateLeadershipCoursesCount(doctor) >=
        requiredLeadershipCourses;
  }

  // ==========================================================
  // 7. السلامة الصحية
  // ==========================================================

  /// السلامة الصحية لا تدخل هنا.
  ///
  /// لأنها تعتمد على تقرير طبي مرتبط بطلب ترشح معين
  /// ويمكن أن تتغير من طلب لآخر.
  ///
  /// لذلك يتم فحصها داخل بيانات طلب الترشح نفسه.

  // ==========================================================
  // تفاصيل الشروط
  // ==========================================================

  static String getNationalityDetails(
    DoctorProfileModel doctor,
  ) {
    return isEgyptian(doctor)
        ? 'الجنسية مصرية'
        : 'الجنسية ليست مصرية';
  }

  static String getCriminalRecordDetails(
    DoctorProfileModel doctor,
  ) {
    return hasNoCriminalRecord(doctor)
        ? 'لا توجد أحكام بجناية'
        : 'يوجد حكم بجناية';
  }

  static String getDisciplinaryDetails(
    DoctorProfileModel doctor,
  ) {
    return hasCleanDisciplinaryRecord(doctor)
        ? 'لا توجد جزاءات تأديبية'
        : 'يوجد جزاء تأديبي';
  }

  static String getPartyPositionDetails(
    DoctorProfileModel doctor,
  ) {
    return hasNoPartyPosition(doctor)
        ? 'لا يشغل منصبًا حزبيًا'
        : 'يشغل منصبًا حزبيًا';
  }

  static String getICDLDetails(
    DoctorProfileModel doctor,
  ) {
    return hasICDL(doctor)
        ? 'تم إثبات إجادة التعامل مع الحاسب الآلي ICDL'
        : 'لم يتم إثبات الحصول على ICDL';
  }

  static String getLeadershipCoursesDetails(
    DoctorProfileModel doctor,
  ) {
    final count =
        calculateLeadershipCoursesCount(doctor);

    if (count == 0) {
      return 'لا توجد دورات قيادية معتمدة من الدورات المحددة';
    }

    return 'عدد الدورات القيادية المحددة والمعتمدة: $count '
        '(المطلوب $requiredLeadershipCourses)';
  }
}