/// ✅ موديل الدرجات الكاملة (بنخزنها مع طلب الترشح)
class NominationScoreModel {
  // 1️⃣ درجات الإنجازات (محسوبة آلية من البيانات)
  final double researchPoints;       // الأبحاث
  final double conferencePoints;     // المؤتمرات
  final double exhibitionPoints;     // المعارض
  final double coursePoints;         // الدورات
  final double activityPoints;       // الأنشطة (20 درجة)

  // 2️⃣ درجة المقابلة (بيديها المحكم)
  final double? interviewScore;
  final double? scientificInterviewScore;       // 40
  final double? leadershipInterviewScore;       // 25
  final double? studentActivitiesScore;         // 15
  final double? communityActivitiesScore;       // 10
  final double? humanRelationsScore;            // 10

  // 3️⃣ التفاصيل (كل بند ودرجته)
  final List<Map<String, dynamic>> itemsDetails;

  NominationScoreModel({
    this.researchPoints = 0.0,
    this.conferencePoints = 0.0,
    this.exhibitionPoints = 0.0,
    this.coursePoints = 0.0,
    this.activityPoints = 0.0,
    this.interviewScore,
    this.scientificInterviewScore,
    this.leadershipInterviewScore,
    this.studentActivitiesScore,
    this.communityActivitiesScore,
    this.humanRelationsScore,
    this.itemsDetails = const [],
  });

  /// ✅ إجمالي درجات الإنجازات
  double get achievementsTotal =>
      researchPoints + conferencePoints + exhibitionPoints + coursePoints + activityPoints;

  /// ✅ إجمالي درجة المقابلة
  double get totalInterviewScore =>
      (scientificInterviewScore ?? 0) +
      (leadershipInterviewScore ?? 0) +
      (studentActivitiesScore ?? 0) +
      (communityActivitiesScore ?? 0) +
      (humanRelationsScore ?? 0);

  /// ✅ المجموع الكلي النهائي
  double get grandTotal => achievementsTotal + totalInterviewScore;

  // =============================================================
  // ===================== JSON Methods ==========================
  // =============================================================

  factory NominationScoreModel.fromMap(Map<String, dynamic> map) {
    return NominationScoreModel(
      researchPoints: (map['researchPoints'] ?? 0).toDouble(),
      conferencePoints: (map['conferencePoints'] ?? 0).toDouble(),
      exhibitionPoints: (map['exhibitionPoints'] ?? 0).toDouble(),
      coursePoints: (map['coursePoints'] ?? 0).toDouble(),
      activityPoints: (map['activityPoints'] ?? 0).toDouble(),
      interviewScore: map['interviewScore']?.toDouble(),
      scientificInterviewScore: map['scientificInterviewScore']?.toDouble(),
      leadershipInterviewScore: map['leadershipInterviewScore']?.toDouble(),
      studentActivitiesScore: map['studentActivitiesScore']?.toDouble(),
      communityActivitiesScore: map['communityActivitiesScore']?.toDouble(),
      humanRelationsScore: map['humanRelationsScore']?.toDouble(),
      itemsDetails: List<Map<String, dynamic>>.from(
        (map['itemsDetails'] ?? []) as List,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'researchPoints': researchPoints,
      'conferencePoints': conferencePoints,
      'exhibitionPoints': exhibitionPoints,
      'coursePoints': coursePoints,
      'activityPoints': activityPoints,
      'interviewScore': interviewScore,
      'scientificInterviewScore': scientificInterviewScore,
      'leadershipInterviewScore': leadershipInterviewScore,
      'studentActivitiesScore': studentActivitiesScore,
      'communityActivitiesScore': communityActivitiesScore,
      'humanRelationsScore': humanRelationsScore,
      'itemsDetails': itemsDetails,
    };
  }

  NominationScoreModel copyWith({
    double? researchPoints,
    double? conferencePoints,
    double? exhibitionPoints,
    double? coursePoints,
    double? activityPoints,
    double? interviewScore,
    double? scientificInterviewScore,
    double? leadershipInterviewScore,
    double? studentActivitiesScore,
    double? communityActivitiesScore,
    double? humanRelationsScore,
    List<Map<String, dynamic>>? itemsDetails,
  }) {
    return NominationScoreModel(
      researchPoints: researchPoints ?? this.researchPoints,
      conferencePoints: conferencePoints ?? this.conferencePoints,
      exhibitionPoints: exhibitionPoints ?? this.exhibitionPoints,
      coursePoints: coursePoints ?? this.coursePoints,
      activityPoints: activityPoints ?? this.activityPoints,
      interviewScore: interviewScore ?? this.interviewScore,
      scientificInterviewScore: scientificInterviewScore ?? this.scientificInterviewScore,
      leadershipInterviewScore: leadershipInterviewScore ?? this.leadershipInterviewScore,
      studentActivitiesScore: studentActivitiesScore ?? this.studentActivitiesScore,
      communityActivitiesScore: communityActivitiesScore ?? this.communityActivitiesScore,
      humanRelationsScore: humanRelationsScore ?? this.humanRelationsScore,
      itemsDetails: itemsDetails ?? this.itemsDetails,
    );
  }
}