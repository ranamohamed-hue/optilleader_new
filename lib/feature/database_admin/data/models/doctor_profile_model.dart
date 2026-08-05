import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:optialeader/feature/doctor/data/model/conferance_model.dart';
import 'package:optialeader/feature/doctor/data/model/courses_model.dart';
import 'package:optialeader/feature/doctor/data/model/exhibition_venue_model.dart';
import 'package:optialeader/feature/doctor/data/model/research_paper_model.dart';
import 'package:optialeader/feature/doctor/data/model/academic_activity_model.dart';
import 'package:optialeader/feature/doctor/data/model/verefication_status.dart';

class DoctorProfileModel {
  final String? uid;
  final String role;
  final bool isFirstLogin;

  // بيانات الهوية
  final String nameAr;
  final String nameEn;
  final String nationalityAr;
  final String nationalityEn;
  final String currentJobAr;
  final String currentJobEn;
  final String socialStatusAr;
  final String socialStatusEn;
  final String nationalId;
  final String employeeId;
  final DateTime? birthDate;
  final String profileImage;

  final String collageAr;
  final String collageEn;

  // البيانات الأكاديمية والوظيفية
  final String universityAr;
  final String universityEn;
  final String facultyAr;
  final String facultyEn;
  final String departmentAr;
  final String departmentEn;

  // ✅ تاريخ التعيين (لحساب الأقدمية وأقدم 3 بالقسم)
  final DateTime? hiringDate;

  // ✅ تاريخ التواجد الفعلي المستمر (مطلوب لرئيس الجامعة - سنتين)
  final DateTime? activeDutySinceDate;

  // القيادات الأكاديمية
  final DateTime? professorRankDate;
  final List<String> previousLeadershipRoles;
  final bool hasCriminalRecord;
  final bool holdsPartyPosition;

  // بيانات التواصل
  final String email;
  final String phone;
  final String addressAr;
  final String addressEn;
  final String? alternativeEmail;

  // البيانات الأكاديمية (تاريخ الشهادات)
  final List<Map<String, dynamic>> academicHistory;

  // البيانات الجديدة: ملفات الأرشيف
  final List<Map<String, dynamic>> digitalArchive;

  // البيانات الأهلية والإدارية
  final bool disciplinaryClearance;
  final bool hasPermanentPosition;
  final bool isOnVacation;
  
  // ✅ حقول الإعارة والإجازات الجديدة (مطلوبة للقانون الجديد)
  final bool? isOnSecondment;
  final bool? isOnUnpaidLeave;

  final bool isActive;

  // الأبحاث والأنشطة
  final String? cvUrl;
  final List<ResearchPaperModel> researchPapers;

  // ✅ الأنشطة الجديدة
  final List<ConferenceModel> conferences;
  final List<ArtExhibitionModel> exhibitions;
  final List<CourseModel> courses;
  final AcademicActivityModel? academicActivities;

  // ✅ اللجان الداخلية بالجامعة (بأسماء اللجان)
  final List<String> internalCommittees;

  // ✅ حقول الشروط (بيرفعها الأدمن) - تم إزالة hasICDL لأنه بيحسب من الدورات
  final bool? hasHealthCertificate;
  final bool? hasCommitteeMembership;
  final bool? hasSelfEvaluationReport;
  final bool? hasArbitrationPlan;
  final bool? hasAdminExperience;
  final bool? hasExcellentPerformanceReports;
  
  // ✅ isTop3Senior بيحسب من hiringDate مش يدوي
  final bool? isTop3Senior;

  // ✅ حقول التدريب المعتمدة الجديدة (للقانون الجديد)
  final bool? hasSupremeCouncilTraining; // دورة المجلس الأعلى للجامعات
  final bool? hasFLDCTraining; // دورات FLDC

  // ✅ حقول خطة العمل (لرئيس الجامعة ونوابه والوكلاء)
  final String? workPlanFileUrl;
  final VerificationStatus? workPlanStatus;

  DoctorProfileModel({
    this.uid,
    this.role = 'doctor',
    this.isFirstLogin = true,
    required this.nameAr,
    required this.nameEn,
    required this.nationalityAr,
    required this.nationalityEn,
    required this.currentJobAr,
    required this.currentJobEn,
    required this.socialStatusAr,
    required this.socialStatusEn,
    required this.nationalId,
    required this.employeeId,
    this.birthDate,
    required this.profileImage,
    this.universityAr = '',
    this.universityEn = '',
    this.facultyAr = '',
    this.facultyEn = '',
    this.departmentAr = '',
    this.departmentEn = '',
    this.collageAr = '',
    this.collageEn = '',
    this.hiringDate, // ✅ قديم
    this.activeDutySinceDate, // ✅ جديد
    this.professorRankDate,
    this.previousLeadershipRoles = const [],
    this.hasCriminalRecord = false,
    this.holdsPartyPosition = false,
    required this.email,
    required this.phone,
    required this.addressAr,
    required this.addressEn,
    this.alternativeEmail,
    required this.academicHistory,
    required this.digitalArchive,
    required this.disciplinaryClearance,
    required this.hasPermanentPosition,
    required this.isOnVacation,
    this.isOnSecondment, // ✅ جديد
    this.isOnUnpaidLeave, // ✅ جديد
    this.isActive = true,
    this.cvUrl = "",
    this.researchPapers = const [],
    this.conferences = const [],
    this.exhibitions = const [],
    this.courses = const [],
    this.academicActivities,
    this.internalCommittees = const [], 
    this.hasHealthCertificate,
    this.hasCommitteeMembership,
    this.hasSelfEvaluationReport,
    this.hasArbitrationPlan,
    this.hasAdminExperience,
    this.hasExcellentPerformanceReports,
    this.isTop3Senior,
    this.hasSupremeCouncilTraining, // ✅ جديد
    this.hasFLDCTraining, // ✅ جديد
    this.workPlanFileUrl, // ✅ جديد
    this.workPlanStatus, // ✅ جديد
  });

  factory DoctorProfileModel.fromJson(Map<String, dynamic> json, String id) {
    DateTime? parseDate(dynamic dateField) {
      if (dateField == null) return null;
      if (dateField is Timestamp) return dateField.toDate();
      return DateTime.tryParse(dateField.toString());
    }

    // ✅ دالة مساعدة لتحويل String إلى Enum بأمان
    VerificationStatus? parseStatus(String? statusString) {
      if (statusString == null) return null;
      return VerificationStatus.values.firstWhere(
        (e) => e.name == statusString,
        orElse: () => VerificationStatus.pending,
      );
    }

    List<ResearchPaperModel> parseResearchPapers(List<dynamic>? list) {
      if (list == null) return [];
      return list
          .map((item) =>
              ResearchPaperModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    List<ConferenceModel> parseConferences(List<dynamic>? list) {
      if (list == null) return [];
      return list
          .map((item) =>
              ConferenceModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    List<ArtExhibitionModel> parseExhibitions(List<dynamic>? list) {
      if (list == null) return [];
      return list
          .map((item) =>
              ArtExhibitionModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    List<CourseModel> parseCourses(List<dynamic>? list) {
      if (list == null) return [];
      return list
          .map((item) =>
              CourseModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    final profile = json['profile'] as Map<String, dynamic>? ?? {};
    final scientificWork =
        json['scientific_work'] as Map<String, dynamic>? ?? {};
    final adminProofs = json['admin_proofs'] as Map<String, dynamic>? ?? {};
    final leadershipData =
        json['leadership_data'] as Map<String, dynamic>? ?? {};

    List<Map<String, dynamic>> historyList = [];
    final historyData = json['academic_profile']?['history'];
    if (historyData != null && historyData is List) {
      for (var item in historyData) {
        if (item is Map<String, dynamic>) {
          historyList.add({
            'degree': item['degree'] ?? '',
            'major': item['major'] ?? '',
            'date': parseDate(item['date']),
            'place': item['place'] ?? '',
            'type': item['type'] ?? 'degree',
          });
        }
      }
    }

    List<Map<String, dynamic>> archiveList = [];
    if (json['digital_archive'] != null && json['digital_archive'] is List) {
      for (var item in json['digital_archive']) {
        if (item is Map<String, dynamic>) {
          archiveList.add({
            'title': item['title'] ?? '',
            'description': item['description'] ?? '',
            'category': item['category'] ?? '',
            'file_url': item['file_url'] ?? '',
            'uploaded_at': item['uploaded_at'] ?? '',
          });
        }
      }
    }

    return DoctorProfileModel(
      uid: id,
      role: json['role'] ?? 'doctor',
      isFirstLogin: json['isFirstLogin'] ?? true,
      nameAr: profile['display_name']?['ar'] ?? '',
      nameEn: profile['display_name']?['en'] ?? '',
      nationalityAr: profile['nationality_ar'] ?? '',
      nationalityEn: profile['nationality_en'] ?? '',
      currentJobAr:
          profile['current_job_ar'] ?? json['jop']?['title']?['ar'] ?? '',
      currentJobEn:
          profile['current_job_en'] ?? json['jop']?['title']?['en'] ?? '',
      socialStatusAr: profile['social_status_ar'] ?? '',
      socialStatusEn: profile['social_status_en'] ?? '',
      nationalId: json['national_id'] ?? '',
      employeeId: json['employee_id'] ?? '',
      birthDate: parseDate(profile['birth_date']),
      profileImage: profile['profile_image'] ?? '',
      universityAr: profile['university_ar'] ??
          json['academic_profile']?['university_ar'] ??
          '',
      universityEn: profile['university_en'] ??
          json['academic_profile']?['university_en'] ??
          '',
      facultyAr:
          profile['faculty_ar'] ?? json['academic_profile']?['faculty_ar'] ?? '',
      facultyEn:
          profile['faculty_en'] ?? json['academic_profile']?['faculty_en'] ?? '',
      departmentAr: profile['department_ar'] ??
          json['academic_profile']?['department_ar'] ??
          '',
      departmentEn: profile['department_en'] ??
          json['academic_profile']?['department_en'] ??
          '',
      collageAr: profile['collage_ar'] ?? '',
      collageEn: profile['collage_en'] ?? '',

      hiringDate: parseDate(
          profile['hiring_date'] ?? json['academic_profile']?['hiring_date']),
      
      // ✅ قراءة التواجد الفعلي
      activeDutySinceDate: parseDate(json['academic_profile']?['active_duty_since_date']),

      professorRankDate:
          parseDate(json['academic_profile']?['professor_rank_date']),
      previousLeadershipRoles:
          List<String>.from(leadershipData['previous_roles'] ?? []),

      internalCommittees:
          List<String>.from(leadershipData['internal_committees'] ?? []),

      hasCriminalRecord: json['security_data']?['has_criminal_record'] ?? false,
      holdsPartyPosition:
          json['security_data']?['holds_party_position'] ?? false,
      email: json['university_email'] ?? '',
      phone: profile['phone']?['phone1'] ?? '',
      addressAr: profile['address']?['ar'] ?? '',
      addressEn: profile['address']?['en'] ?? '',
      alternativeEmail: json['alternative_email'] ?? '',
      academicHistory: historyList,
      digitalArchive: archiveList,
      disciplinaryClearance:
          json['eligibility_data']?['disciplinary_clearance'] ?? true,
      hasPermanentPosition:
          json['eligibility_data']?['has_permanent_position'] ?? true,
      isOnVacation: json['eligibility_data']?['is_on_vacation'] ?? false,
      
      // ✅ قراءة الإعارة والإجازات
      isOnSecondment: json['eligibility_data']?['is_on_secondment'] ?? false,
      isOnUnpaidLeave: json['eligibility_data']?['is_on_unpaid_leave'] ?? false,

      isActive: json['is_active'] ?? json['eligibility_data']?['is_active'] ?? true,
      cvUrl: json['academic_profile']?['cv_url'],

      researchPapers: parseResearchPapers(scientificWork['research_papers']),
      conferences: parseConferences(scientificWork['conferences']),
      exhibitions: parseExhibitions(scientificWork['exhibitions']),
      courses: parseCourses(scientificWork['courses']),
      academicActivities: scientificWork['academic_activities'] != null
          ? AcademicActivityModel.fromJson(
              Map<String, dynamic>.from(scientificWork['academic_activities']))
          : null,

      hasHealthCertificate: adminProofs['has_health_certificate'],
      hasCommitteeMembership: adminProofs['has_committee_membership'],
      hasSelfEvaluationReport: adminProofs['has_self_evaluation_report'],
      hasArbitrationPlan: adminProofs['has_arbitration_plan'],
      hasAdminExperience: adminProofs['has_admin_experience'],
      hasExcellentPerformanceReports:
          adminProofs['has_excellent_performance_reports'],
      isTop3Senior: adminProofs['is_top3_senior'],
      
      // ✅ قراءة التدريب المعتمد وخطة العمل
      hasSupremeCouncilTraining: adminProofs['has_supreme_council_training'] ?? false,
      hasFLDCTraining: adminProofs['has_fldc_training'] ?? false,
      workPlanFileUrl: leadershipData['work_plan_file_url'],
      workPlanStatus: parseStatus(leadershipData['work_plan_status']),
    );
  }

  Map<String, dynamic> toMap() {
    List<Map<String, dynamic>> historyMap =
        academicHistory.map((historyItem) {
      return {
        'degree': historyItem['degree'],
        'major': historyItem['major'],
        'date': historyItem['date'] != null
            ? Timestamp.fromDate(historyItem['date'] as DateTime)
            : null,
        'place': historyItem['place'],
        'type': historyItem['type'],
      };
    }).toList();

    List<Map<String, dynamic>> archiveMap = digitalArchive.map((item) {
      return {
        'title': item['title'],
        'description': item['description'],
        'category': item['category'],
        'file_url': item['file_url'],
        'uploaded_at': item['uploaded_at'],
      };
    }).toList();

    return {
      'role': role,
      'isFirstLogin': isFirstLogin,
      'university_email': email,
      'alternative_email': alternativeEmail ?? "",
      'national_id': nationalId,
      'employee_id': employeeId,
      'is_active': isActive,
      'profile': {
        'display_name': {'ar': nameAr, 'en': nameEn},
        'phone': {'phone1': phone},
        'address': {'ar': addressAr, 'en': addressEn},
        'profile_image': profileImage,
        'nationality_ar': nationalityAr,
        'nationality_en': nationalityEn,
        'current_job_ar': currentJobAr,
        'current_job_en': currentJobEn,
        'social_status_ar': socialStatusAr,
        'social_status_en': socialStatusEn,
        'birth_date':
            birthDate != null ? Timestamp.fromDate(birthDate!) : null,
        'university_ar': universityAr,
        'university_en': universityEn,
        'faculty_ar': facultyAr,
        'faculty_en': facultyEn,
        'department_ar': departmentAr,
        'department_en': departmentEn,
        'collage_ar': collageAr,
        'collage_en': collageEn,
        'hiring_date':
            hiringDate != null ? Timestamp.fromDate(hiringDate!) : null,
      },
      'academic_profile': {
        'history': historyMap,
        'cv_url': cvUrl,
        'professor_rank_date': professorRankDate != null
            ? Timestamp.fromDate(professorRankDate!)
            : null,
        // ✅ حفظ التواجد الفعلي
        'active_duty_since_date': activeDutySinceDate != null
            ? Timestamp.fromDate(activeDutySinceDate!)
            : null,
      },
      'eligibility_data': {
        'is_on_vacation': isOnVacation,
        'has_permanent_position': hasPermanentPosition,
        'disciplinary_clearance': disciplinaryClearance,
        'is_active': isActive,
        // ✅ حفظ الإعارة والإجازات
        'is_on_secondment': isOnSecondment ?? false,
        'is_on_unpaid_leave': isOnUnpaidLeave ?? false,
      },
      'leadership_data': {
        'previous_roles': previousLeadershipRoles,
        'internal_committees': internalCommittees,
        // ✅ حفظ خطة العمل
        'work_plan_file_url': workPlanFileUrl,
        'work_plan_status': workPlanStatus?.name, // حفظ اسم الـ Enum كـ String
      },
      'security_data': {
        'has_criminal_record': hasCriminalRecord,
        'holds_party_position': holdsPartyPosition,
      },
      'digital_archive': archiveMap,
      'scientific_work': {
        'research_papers': researchPapers.map((x) => x.toMap()).toList(),
        'conferences': conferences.map((x) => x.toMap()).toList(),
        'exhibitions': exhibitions.map((x) => x.toMap()).toList(),
        'courses': courses.map((x) => x.toMap()).toList(),
        'academic_activities': academicActivities?.toJson(),
      },
      'admin_proofs': {
        'has_health_certificate': hasHealthCertificate,
        'has_committee_membership': hasCommitteeMembership,
        'has_self_evaluation_report': hasSelfEvaluationReport,
        'has_arbitration_plan': hasArbitrationPlan,
        'has_admin_experience': hasAdminExperience,
        'has_excellent_performance_reports': hasExcellentPerformanceReports,
        'is_top3_senior': isTop3Senior,
        // ✅ حفظ التدريب المعتمد
        'has_supreme_council_training': hasSupremeCouncilTraining ?? false,
        'has_fldc_training': hasFLDCTraining ?? false,
      },
    };
  }

  DoctorProfileModel copyWith({
    String? uid,
    String? role,
    bool? isFirstLogin,
    String? nameAr,
    String? nameEn,
    String? nationalityAr,
    String? nationalityEn,
    String? currentJobAr,
    String? currentJobEn,
    String? socialStatusAr,
    String? socialStatusEn,
    String? nationalId,
    String? employeeId,
    DateTime? birthDate,
    String? profileImage,
    String? universityAr,
    String? universityEn,
    String? facultyAr,
    String? facultyEn,
    String? departmentAr,
    String? departmentEn,
    DateTime? hiringDate,
    DateTime? activeDutySinceDate, // ✅ جديد
    DateTime? professorRankDate,
    List<String>? previousLeadershipRoles,
    List<String>? internalCommittees,
    bool? hasCriminalRecord,
    bool? holdsPartyPosition,
    String? email,
    String? phone,
    String? addressAr,
    String? addressEn,
    String? alternativeEmail,
    List<Map<String, dynamic>>? academicHistory,
    bool? disciplinaryClearance,
    bool? hasPermanentPosition,
    bool? isOnVacation,
    bool? isOnSecondment, // ✅ جديد
    bool? isOnUnpaidLeave, // ✅ جديد
    bool? isActive,
    String? cvUrl,
    List<ResearchPaperModel>? researchPapers,
    List<ConferenceModel>? conferences,
    List<ArtExhibitionModel>? exhibitions,
    List<CourseModel>? courses,
    AcademicActivityModel? academicActivities,
    List<Map<String, dynamic>>? digitalArchive,
    bool? hasHealthCertificate,
    bool? hasCommitteeMembership,
    bool? hasSelfEvaluationReport,
    bool? hasArbitrationPlan,
    bool? hasAdminExperience,
    bool? hasExcellentPerformanceReports,
    bool? isTop3Senior,
    bool? hasSupremeCouncilTraining, // ✅ جديد
    bool? hasFLDCTraining, // ✅ جديد
    String? workPlanFileUrl, // ✅ جديد
    VerificationStatus? workPlanStatus, // ✅ جديد
    String? collageAr,
    String? collageEn,
  }) {
    return DoctorProfileModel(
      uid: uid ?? this.uid,
      role: role ?? this.role,
      isFirstLogin: isFirstLogin ?? this.isFirstLogin,
      nameAr: nameAr ?? this.nameAr,
      nameEn: nameEn ?? this.nameEn,
      nationalityAr: nationalityAr ?? this.nationalityAr,
      nationalityEn: nationalityEn ?? this.nationalityEn,
      currentJobAr: currentJobAr ?? this.currentJobAr,
      currentJobEn: currentJobEn ?? this.currentJobEn,
      socialStatusAr: socialStatusAr ?? this.socialStatusAr,
      socialStatusEn: socialStatusEn ?? this.socialStatusEn,
      nationalId: nationalId ?? this.nationalId,
      employeeId: employeeId ?? this.employeeId,
      birthDate: birthDate ?? this.birthDate,
      profileImage: profileImage ?? this.profileImage,
      universityAr: universityAr ?? this.universityAr,
      universityEn: universityEn ?? this.universityEn,
      facultyAr: facultyAr ?? this.facultyAr,
      facultyEn: facultyEn ?? this.facultyEn,
      departmentAr: departmentAr ?? this.departmentAr,
      departmentEn: departmentEn ?? this.departmentEn,
      collageAr: collageAr ?? this.collageAr,
      collageEn: collageEn ?? this.collageEn,
      hiringDate: hiringDate ?? this.hiringDate,
      activeDutySinceDate: activeDutySinceDate ?? this.activeDutySinceDate, // ✅
      professorRankDate: professorRankDate ?? this.professorRankDate,
      previousLeadershipRoles:
          previousLeadershipRoles ?? this.previousLeadershipRoles,
      internalCommittees: internalCommittees ?? this.internalCommittees,
      hasCriminalRecord: hasCriminalRecord ?? this.hasCriminalRecord,
      holdsPartyPosition: holdsPartyPosition ?? this.holdsPartyPosition,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      addressAr: addressAr ?? this.addressAr,
      addressEn: addressEn ?? this.addressEn,
      alternativeEmail: alternativeEmail ?? this.alternativeEmail,
      academicHistory: academicHistory ?? this.academicHistory,
      digitalArchive: digitalArchive ?? this.digitalArchive,
      disciplinaryClearance: disciplinaryClearance ?? this.disciplinaryClearance,
      hasPermanentPosition: hasPermanentPosition ?? this.hasPermanentPosition,
      isOnVacation: isOnVacation ?? this.isOnVacation,
      isOnSecondment: isOnSecondment ?? this.isOnSecondment, // ✅
      isOnUnpaidLeave: isOnUnpaidLeave ?? this.isOnUnpaidLeave, // ✅
      isActive: isActive ?? this.isActive,
      cvUrl: cvUrl ?? this.cvUrl,
      researchPapers: researchPapers ?? this.researchPapers,
      conferences: conferences ?? this.conferences,
      exhibitions: exhibitions ?? this.exhibitions,
      courses: courses ?? this.courses,
      academicActivities: academicActivities ?? this.academicActivities,
      hasHealthCertificate: hasHealthCertificate ?? this.hasHealthCertificate,
      hasCommitteeMembership:
          hasCommitteeMembership ?? this.hasCommitteeMembership,
      hasSelfEvaluationReport:
          hasSelfEvaluationReport ?? this.hasSelfEvaluationReport,
      hasArbitrationPlan: hasArbitrationPlan ?? this.hasArbitrationPlan,
      hasAdminExperience: hasAdminExperience ?? this.hasAdminExperience,
      hasExcellentPerformanceReports:
          hasExcellentPerformanceReports ?? this.hasExcellentPerformanceReports,
      isTop3Senior: isTop3Senior ?? this.isTop3Senior,
      hasSupremeCouncilTraining: hasSupremeCouncilTraining ?? this.hasSupremeCouncilTraining, // ✅
      hasFLDCTraining: hasFLDCTraining ?? this.hasFLDCTraining, // ✅
      workPlanFileUrl: workPlanFileUrl ?? this.workPlanFileUrl, // ✅
      workPlanStatus: workPlanStatus ?? this.workPlanStatus, // ✅
    );
  }

  // ==========================================================
  // ✅ Getters الجديدة: ICDL من الدورات + الأقدمية
  // ==========================================================

  /// ✅ التحقق من ICDL عن طريق الدورات المعتمدة (مش حقل يدوي)
  bool get hasICDL {
    return courses.any((course) {
      if (course.status != VerificationStatus.approved) return false;
      final title = _normalizeArabic(course.title.toLowerCase());
      return title.contains('icdl') ||
          title.contains('الشهادة الدولية لقيادة الحاسب') ||
          title.contains('شهادة icdl') ||
          title.contains('international computer driving license');
    });
  }

  /// ✅ عدد سنوات الخدمة منذ التعيين
  int get yearsSinceHiring {
    if (hiringDate == null) return 0;
    final now = DateTime.now();
    int years = now.year - hiringDate!.year;
    if (now.month < hiringDate!.month ||
        (now.month == hiringDate!.month && now.day < hiringDate!.day)) {
      years--;
    }
    return years;
  }

  // ==========================================================
  // Getters الإحصائيات
  // ==========================================================

  int get totalAchievements =>
      researchPapers.length +
      conferences.length +
      exhibitions.length +
      courses.length;

  int get totalApprovedAchievements {
    final approvedResearch =
        researchPapers.where((p) => p.status == VerificationStatus.approved).length;
    final approvedConferences = conferences
        .where((c) => c.status == VerificationStatus.approved)
        .length;
    final approvedExhibitions = exhibitions
        .where((e) => e.status == VerificationStatus.approved)
        .length;
    final approvedCourses =
        courses.where((c) => c.status == VerificationStatus.approved).length;
    return approvedResearch +
        approvedConferences +
        approvedExhibitions +
        approvedCourses;
  }

  int get totalPendingAchievements {
    final pendingResearch =
        researchPapers.where((p) => p.status == VerificationStatus.pending).length;
    final pendingConferences = conferences
        .where((c) => c.status == VerificationStatus.pending)
        .length;
    final pendingExhibitions = exhibitions
        .where((e) => e.status == VerificationStatus.pending)
        .length;
    final pendingCourses =
        courses.where((c) => c.status == VerificationStatus.pending).length;
    return pendingResearch +
        pendingConferences +
        pendingExhibitions +
        pendingCourses;
  }

  int get totalConferences => conferences.length;
  int get totalExhibitions => exhibitions.length;
  int get totalCourses => courses.where((c) => !c.isMandatory).length;
  int get totalMandatoryCourses =>
      courses.where((c) => c.isMandatory).length;

  int get totalApprovedResearch => researchPapers
      .where((p) => p.status == VerificationStatus.approved)
      .length;

  int get yearsAsProfessor {
    if (professorRankDate == null) return 0;
    final now = DateTime.now();
    int years = now.year - professorRankDate!.year;
    if (now.month < professorRankDate!.month ||
        (now.month == professorRankDate!.month &&
            now.day < professorRankDate!.day)) {
      years--;
    }
    return years;
  }

  /// ✅ دالة مساعدة لتنظيف النصوص العربية
  static String _normalizeArabic(String text) {
    return text
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي');
  }

  // ==========================================================
  // ✅ حساب أقدم 3 دكاترة بالقسم (ستاتيك - محتاجة لست الدكاترة)
  // ==========================================================

  /// تحديد أقدم 3 دكاترة في قسم معين بناءً على تاريخ التعيين
  /// ترجع لست بأسماء الـ uid بتاعهم
  static List<String> getTop3SeniorInDepartment({
    required List<DoctorProfileModel> doctors,
    required String departmentAr,
  }) {
    // فلترة دكاترة القسم اللي عندهم تاريخ تعيين
    final filtered = doctors.where((d) {
      return d.departmentAr == departmentAr && d.hiringDate != null;
    }).toList();

    // ترتيب تنازلي حسب الأقدمية (الأقدم أول واحد)
    filtered.sort((a, b) {
      final dateA = a.hiringDate!;
      final dateB = b.hiringDate!;
      // الأقدم = التاريخ الأصغر = ييجي الأول
      return dateA.compareTo(dateB);
    });

    // أخد أول 3
    return filtered.take(3).map((d) => d.uid!).toList();
  }

  /// تحديث حقل isTop3Senior لكل الدكاترة في قسم معين
  /// (بتستدعيها من الأدمن أو Cloud Function)
  static Map<String, bool> calculateTop3SeniorMap({
    required List<DoctorProfileModel> doctors,
    required String departmentAr,
  }) {
    final top3Uids = getTop3SeniorInDepartment(
      doctors: doctors,
      departmentAr: departmentAr,
    );

    final Map<String, bool> result = {};
    for (var doctor in doctors) {
      if (doctor.departmentAr == departmentAr) {
        result[doctor.uid!] = top3Uids.contains(doctor.uid);
      }
    }
    return result;
  }
}