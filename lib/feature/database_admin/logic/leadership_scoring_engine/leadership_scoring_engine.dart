import 'package:optialeader/feature/database_admin/data/models/doctor_profile_model.dart';
import 'package:optialeader/feature/doctor/data/model/academic_activity_model.dart';
import 'package:optialeader/feature/judge/data/model/interview_scoring_model.dart';
import 'package:optialeader/feature/doctor/data/model/conferance_model.dart';
import 'package:optialeader/feature/doctor/data/model/exhibition_venue_model.dart';
import 'package:optialeader/feature/admin/data/model/nomination_score_model.dart';

class LeadershipScoringEngine {
  /// دالة رئيسية لحساب إجمالي درجات الإنجازات
  static Map<String, dynamic> calculateTotalScore(DoctorProfileModel doctor) {
    List<Map<String, dynamic>> allDetails = [];
    double researchPoints = 0.0;
    double conferencePoints = 0.0;
    double exhibitionPoints = 0.0;
    double coursePoints = 0.0;
    double workshopPoints = 0.0;
    double activityPoints = 0.0;

    // 1️⃣ الأبحاث العلمية
    for (var paper in doctor.researchPapers) {
      if (paper.status.name == 'approved') {
        researchPoints += paper.finalPoints;
        allDetails.add({
          'id': paper.id,
          'title': paper.titleAr,
          'type': 'بحث علمي',
          'category': paper.isLocalJournal
              ? 'مجلة محلية'
              : paper.indexingDatabase.name,
          'scope':
              'الترتيب: ${paper.authorOrder} من ${paper.authorsInSameSpecialty} (${(paper.participationPercentage * 100).toInt()}%)',
          'points': paper.finalPoints,
          'breakdown':
              '(${paper.journalPoints.toStringAsFixed(1)} مجلة + ${paper.adminScore.toStringAsFixed(1)} أدمن) × ${paper.participationPercentage} = ${paper.finalPoints.toStringAsFixed(1)}',
          'reportUrl': paper.certifiedReportFileUrl,
        });
      }
    }

    // 2️⃣ المؤتمرات العلمية
    for (var conf in doctor.conferences) {
      if (conf.status.name == 'approved') {
        conferencePoints += conf.totalPoints;
        String nature = conf.isInternational ? 'دولي' : 'محلي';
        String spec = conf.isSpecialized ? 'متخصص' : 'عام';
        String partType = _getParticipationTypeAr(conf.participationType);
        String pubStatus = conf.isPublished ? "منشور" : "غير منشور";

        allDetails.add({
          'title': conf.title,
          'type': '$nature - $spec',
          'category': partType,
          'scope': spec,
          'points': conf.totalPoints,
          'breakdown':
              '$nature - $spec - $pubStatus - $partType = ${conf.totalPoints}',
        });
      }
    }

    // 3️⃣ المعارض الفنية
    for (var exhibition in doctor.exhibitions) {
      if (exhibition.status.name == 'approved') {
        if (exhibition.isPointsOnHold) {
          allDetails.add({
            'title': exhibition.title,
            'type': 'معرض فني (درجة معلقة)',
            'category': _getVenueAr(exhibition.venue),
            'scope': '${exhibition.numberOfWorks} أعمال',
            'points': 0.0,
            'breakdown': 'الدرجة معلقة: المحفل دولي والأعمال أقل من 5',
          });
        } else {
          double points = exhibition.basePoints;
          if (points > 0) exhibitionPoints += points;

          String venueAr = _getVenueAr(exhibition.venue);
          String failReason =
              (exhibition.venue == ExhibitionVenue.internationalAbroad &&
                      exhibition.numberOfWorks < 5)
                  ? ' (رُفض: أقل من 5 أعمال في محفل دولي)'
                  : '';

          allDetails.add({
            'title': exhibition.title,
            'type': 'معرض فني',
            'category': venueAr,
            'scope': '${exhibition.numberOfWorks} أعمال',
            'points': points,
            'breakdown': '$venueAr = $points $failReason',
          });
        }
      }
    }

    // 4️⃣ الدورات التدريبية (خصم 2 إجبارية + 1 ICDL، وحساب الباقي)
    final approvedCourses = doctor.courses
        .where((c) => c.status.name == 'approved')
        .toList();

    int mandatoryUsed = 0;
    int icdlUsed = 0;

    for (var course in approvedCourses) {
      double points = 0.0;
      String reason = '';
      bool isPrerequisiteSkipped = false;

      // 1. خصم أول دورتين إجباريتين (Mandatory)
      if (course.isMandatory && mandatoryUsed < 2) {
        mandatoryUsed++;
        isPrerequisiteSkipped = true;
        reason = 'من الدورات الإجبارية الأساسية (صفر نقاط)';
      } 
      // 2. خصم أول دورة ICDL
      else if (course.isIcdl && icdlUsed < 1) {
        icdlUsed++;
        isPrerequisiteSkipped = true;
        reason = 'دورة ICDL الأساسية (صفر نقاط)';
      }

      // 3. حساب نقاط باقي الدورات (الـ 4 الإجبارية الزيادة، أو الـ ICDL الزيادة، أو العادية)
      if (!isPrerequisiteSkipped) {
        points = course.points; // هنا بترجع النقاط الحقيقية للدورة
        if (points > 0) {
          coursePoints += points;
        }
        String catAr = _getCourseCategoryAr(course.courseCategory);
        String scopeAr = _getCourseScopeAr(course.courseScope);
        reason = '$catAr - $scopeAr';
      }

      allDetails.add({
        'title': course.title,
        'type': 'دورة تدريبية',
        'category': _getCourseCategoryAr(course.courseCategory),
        'scope': _getCourseScopeAr(course.courseScope),
        'points': points,
        'breakdown': reason,
      });
    }
/*
    try {
      final workshops = doctor.workshops; // استبدلها بالمتغير الصحيح إذا كان اسمه مختلفاً
      if (workshops != null && workshops.isNotEmpty) {
        for (var workshop in workshops) {
          if (workshop.status.name == 'approved') {
            double points = workshop.points;
            if (points > 0) {
              workshopPoints += points;
            }
            allDetails.add({
              'title': workshop.title,
              'type': 'ورشة عمل',
              'category': _getCourseCategoryAr(workshop.courseCategory),
              'scope': _getCourseScopeAr(workshop.courseScope),
              'points': points,
              'breakdown': '${_getCourseCategoryAr(workshop.courseCategory)} - ${_getCourseScopeAr(workshop.courseScope)}',
            });
          }
        }
      }
    } catch (e) {
      // في حال لم تكن الخاصية موجودة بعد في الموديل، لن يتعطل التطبيق وسيتجاهل الورش
      print('Workshops property not found or is null: $e');
    }
*/
    // 6️⃣ الأنشطة الأكاديمية
    if (doctor.academicActivities != null) {
      activityPoints = doctor.academicActivities!.totalPoints;
      _addActivityDetails(doctor.academicActivities!, allDetails);
    }

    double totalPoints = researchPoints +
        conferencePoints +
        exhibitionPoints +
        coursePoints +
        workshopPoints +
        activityPoints;

    return {
      'researchPoints': researchPoints,
      'conferencePoints': conferencePoints,
      'exhibitionPoints': exhibitionPoints,
      'coursePoints': coursePoints,
      'workshopPoints': workshopPoints,
      'activityPoints': activityPoints,
      'totalPoints': totalPoints,
      'evaluated_items_details': allDetails,
    };
  }

  static NominationScoreModel buildScoreModel(DoctorProfileModel doctor) {
    Map<String, dynamic> scores = calculateTotalScore(doctor);
    return NominationScoreModel(
      researchPoints: scores['researchPoints'],
      conferencePoints: scores['conferencePoints'],
      exhibitionPoints: scores['exhibitionPoints'],
      coursePoints: scores['coursePoints'],
      activityPoints: scores['activityPoints'],
      itemsDetails: List<Map<String, dynamic>>.from(
        scores['evaluated_items_details'],
      ),
    );
  }

  static NominationScoreModel addInterviewScore(
    NominationScoreModel scoreModel,
    InterviewScoringModel interview,
  ) {
    return scoreModel.copyWith(
      interviewScore: interview.totalScore,
      scientificInterviewScore: interview.scientificScore,
      leadershipInterviewScore: interview.leadershipScore,
      studentActivitiesScore: interview.studentActivitiesScore,
      communityActivitiesScore: interview.communityActivitiesScore,
      humanRelationsScore: interview.humanRelationsScore,
    );
  }

  /// حساب المجموع الكلي (الإنجازات + المقابلة)
  static double calculateGrandTotal({
    required DoctorProfileModel doctor,
    required double interviewScore,
  }) {
    return calculateTotalScore(doctor)['totalPoints'] + interviewScore;
  }

  // ============================================================
  // دوال مساعدة لترجمة النصوص
  // ============================================================

  static String _getParticipationTypeAr(ParticipationType type) {
    switch (type) {
      case ParticipationType.paperPresentation:
        return 'بحث كامل محكم';
      case ParticipationType.abstractPresentation:
        return 'ملخص بحث محكم';
      case ParticipationType.attendanceOnly:
        return 'حضور فقط';
    }
  }

  static String _getVenueAr(ExhibitionVenue venue) {
    switch (venue) {
      case ExhibitionVenue.internationalAbroad:
        return 'محفل دولي (خارج مصر)';
      case ExhibitionVenue.internationalEgypt:
        return 'محفل دولي (داخل مصر)';
      case ExhibitionVenue.artFaculties:
        return 'قاعات الكليات الفنية';
      case ExhibitionVenue.fineArtsSector:
        return 'قاعات قطاع الفنون التشكيلية';
      case ExhibitionVenue.foreignCulturalCenters:
        return 'قاعات المراكز الثقافية الأجنبية';
      case ExhibitionVenue.artSyndicates:
        return 'قاعات النقابات الفنية';
      case ExhibitionVenue.culturePalaces:
        return 'قاعات هيئة قصور الثقافة';
      case ExhibitionVenue.ateliersCairoAlex:
        return 'قاعات أتيليه القاهرة والإسكندرية';
      case ExhibitionVenue.privateGalleries:
        return 'قاعات المعرض الخاص';
    }
  }

  static String _getCourseCategoryAr(dynamic category) {
    String name = category.toString().split('.').last;
    switch (name) {
      case 'administrative':
        return 'إدارية';
      case 'specialized':
        return 'متخصصة';
      case 'general':
        return 'عامة';
      default:
        return 'غير محدد';
    }
  }

  static String _getCourseScopeAr(dynamic scope) {
    String name = scope.toString().split('.').last;
    switch (name) {
      case 'international':
        return 'دولي';
      case 'local':
        return 'محلي';
      default:
        return 'غير محدد';
    }
  }

  static void _addActivityDetails(
    AcademicActivityModel activities,
    List<Map<String, dynamic>> details,
  ) {
    for (var c in activities.teachingCriteria) {
      if (c.proofStatus.name == 'approved' && c.awardedPoints > 0) {
        details.add({
          'title': c.titleAr,
          'type': 'نشاط تدريسي',
          'category': 'تدريسية',
          'scope': c.proofRequirement,
          'points': c.awardedPoints,
        });
      }
    }
    for (var c in activities.researchCriteria) {
      if (c.proofStatus.name == 'approved' && c.awardedPoints > 0) {
        details.add({
          'title': c.titleAr,
          'type': 'نشاط بحثي',
          'category': 'بحثية',
          'scope': c.proofRequirement,
          'points': c.awardedPoints,
        });
      }
    }
    for (var c in activities.communityCriteria) {
      if (c.proofStatus.name == 'approved' && c.awardedPoints > 0) {
        details.add({
          'title': c.titleAr,
          'type': 'نشاط مجتمعي',
          'category': 'جامعية ومجتمعية',
          'scope': c.proofRequirement,
          'points': c.awardedPoints,
        });
      }
    }
  }
}