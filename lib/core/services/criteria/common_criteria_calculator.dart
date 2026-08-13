import 'package:optialeader/feature/database_admin/data/models/doctor_profile_model.dart';
import 'package:optialeader/feature/doctor/data/model/courses_model.dart';
import 'package:optialeader/feature/doctor/data/model/verefication_status.dart';
import 'package:optialeader/feature/doctor/logic/activities/mandatory_leadership_data.dart';

class CommonCriteriaCalculator {
  // ==========================================================
  // الثوابت
  // ==========================================================

  /// المطلوب دورتان مختلفتان من الدورات القيادية السبعة
  static const int requiredLeadershipCourses = 2;

  // ==========================================================
  // 1. الجنسية
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
  // 2. السجل الجنائي
  // ==========================================================

  static bool hasNoCriminalRecord(DoctorProfileModel doctor) {
    return !doctor.hasCriminalRecord;
  }

  // ==========================================================
  // 3. السجل التأديبي
  // ==========================================================

  static bool hasCleanDisciplinaryRecord(DoctorProfileModel doctor) {
    return doctor.disciplinaryClearance;
  }

  // ==========================================================
  // 4. المنصب الحزبي
  // ==========================================================

  static bool hasNoPartyPosition(DoctorProfileModel doctor) {
    return !doctor.holdsPartyPosition;
  }

  // ==========================================================
  // 5. ICDL
  // ==========================================================

  static bool hasICDL(DoctorProfileModel doctor) {
    return doctor.hasICDL;
  }

  // ==========================================================
  // 6. الدورات القيادية السبعة المحددة
  // ==========================================================

  /// جميع مفاتيح الدورات القيادية المحددة في النظام.
  static Set<String> get mandatoryLeadershipKeys {
    return MandatoryLeadershipData.courses
        .map((course) => course['key']!)
        .toSet();
  }

  // ==========================================================
  // تحديد مفتاح الدورة
  // ==========================================================

  /// لا نعتمد على اسم الدورة.
  ///
  /// الدورة تدخل في شرط الدورتين فقط إذا:
  /// 1. لديها mandatoryKey
  /// 2. المفتاح موجود ضمن الدورات السبعة المحددة
  static String? _resolveMandatoryKey(CourseModel course) {
    if (course.mandatoryKey == null) {
      return null;
    }

    if (mandatoryLeadershipKeys.contains(course.mandatoryKey)) {
      return course.mandatoryKey;
    }

    return null;
  }

  // ==========================================================
  // الدورات القيادية المعتمدة
  // ==========================================================

  /// إرجاع الدورات القيادية المحددة التي:
  /// - من الدورات السبعة
  /// - معتمدة من الأدمن
  static List<CourseModel> getApprovedLeadershipCourses(
    DoctorProfileModel doctor,
  ) {
    return doctor.courses.where((course) {
      if (course.status != VerificationStatus.approved) {
        return false;
      }

      final key = _resolveMandatoryKey(course);

      return key != null;
    }).toList();
  }

  // ==========================================================
  // مفاتيح الدورات المختلفة فقط
  // ==========================================================

  /// مهم:
  /// نفس الدورة لو موجودة مرتين لا تُحسب مرتين.
  static Set<String> getApprovedLeadershipCourseKeys(
    DoctorProfileModel doctor,
  ) {
    final approvedKeys = <String>{};

    for (final course in doctor.courses) {
      if (course.status != VerificationStatus.approved) {
        continue;
      }

      final key = _resolveMandatoryKey(course);

      if (key != null) {
        approvedKeys.add(key);
      }
    }

    return approvedKeys;
  }

  // ==========================================================
  // عدد الدورات المختلفة
  // ==========================================================

  static int calculateLeadershipCoursesCount(
    DoctorProfileModel doctor,
  ) {
    return getApprovedLeadershipCourseKeys(doctor).length;
  }

  // ==========================================================
  // الشرط الحقيقي
  // ==========================================================

  /// يجب أن يكون لدى الدكتور دورتان مختلفتان على الأقل
  /// من الدورات السبعة المحددة، وكلتاهما معتمدتان من الأدمن.
  static bool hasRequiredLeadershipCourses(
    DoctorProfileModel doctor,
  ) {
    return calculateLeadershipCoursesCount(doctor) >=
        requiredLeadershipCourses;
  }

  // ==========================================================
  // تفاصيل الشرط
  // ==========================================================

  static String getLeadershipCoursesDetails(
    DoctorProfileModel doctor,
  ) {
    final approvedKeys =
        getApprovedLeadershipCourseKeys(doctor);

    final count = approvedKeys.length;

    if (count == 0) {
      return 'لا توجد دورات قيادية محددة ومعتمدة من الأدمن';
    }

    if (count == 1) {
      return 'تم اعتماد دورة قيادية واحدة فقط '
          '(المطلوب دورتان مختلفتان)';
    }

    return 'تم اعتماد $count دورات قيادية مختلفة '
        '(المطلوب $requiredLeadershipCourses)';
  }

  // ==========================================================
  // تفاصيل باقي الشروط
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
}