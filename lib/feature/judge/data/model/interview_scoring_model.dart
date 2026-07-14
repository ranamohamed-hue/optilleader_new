/// ✅ محاور تقييم المقابلة (5 محاور = 100 درجة)
enum InterviewSection {
  scientific,         // القسم العلمي (40 درجة)
  leadership,         // التطوير والقيادة (25 درجة)
  studentActivities,  // الأنشطة الطلابية (15 درجة)
  communityActivities,// الأنشطة المجتمعية (10 درجة)
  humanRelations,     // العلاقات الإنسانية (10 درجة)
}

class InterviewScoringModel {
  final DateTime interviewDate;
  final String? interviewLocation;
  final String? interviewTime;
  
  // 1️⃣ القسم العلمي (40 درجة)
  final double scientificScore;
  final String? scientificNotes;
  
  // 2️⃣ التطوير والقيادة (25 درجة)
  final double leadershipScore;
  final String? leadershipNotes;
  
  // 3️⃣ الأنشطة الطلابية (15 درجة)
  final double studentActivitiesScore;
  final String? studentActivitiesNotes;
  
  // 4️⃣ الأنشطة المجتمعية (10 درجة)
  final double communityActivitiesScore;
  final String? communityActivitiesNotes;
  
  // 5️⃣ العلاقات الإنسانية (10 درجة)
  final double humanRelationsScore;
  final String? humanRelationsNotes;
  
  final bool isDraft;

  InterviewScoringModel({
    required this.interviewDate,
    this.interviewLocation,
    this.interviewTime,
    this.scientificScore = 0,
    this.scientificNotes,
    this.leadershipScore = 0,
    this.leadershipNotes,
    this.studentActivitiesScore = 0,
    this.studentActivitiesNotes,
    this.communityActivitiesScore = 0,
    this.communityActivitiesNotes,
    this.humanRelationsScore = 0,
    this.humanRelationsNotes,
    this.isDraft = false,
  });

  /// ✅ الدرجات القصوى لكل محور
  static const Map<InterviewSection, double> maxScores = {
    InterviewSection.scientific: 40.0,
    InterviewSection.leadership: 25.0,
    InterviewSection.studentActivities: 15.0,
    InterviewSection.communityActivities: 10.0,
    InterviewSection.humanRelations: 10.0,
  };

  /// ✅ المجموع الكلي (100 درجة)
  double get totalScore => 
      scientificScore + 
      leadershipScore + 
      studentActivitiesScore + 
      communityActivitiesScore + 
      humanRelationsScore;

  /// ✅ التحقق من صحة الدرجات
  bool get isValid {
    if (scientificScore > 40 || scientificScore < 0) return false;
    if (leadershipScore > 25 || leadershipScore < 0) return false;
    if (studentActivitiesScore > 15 || studentActivitiesScore < 0) return false;
    if (communityActivitiesScore > 10 || communityActivitiesScore < 0) return false;
    if (humanRelationsScore > 10 || humanRelationsScore < 0) return false;
    return true;
  }

  Map<String, dynamic> toMap() {
    return {
      'interviewDate': interviewDate.toIso8601String(),
      'interviewLocation': interviewLocation,
      'interviewTime': interviewTime,
      'scientificScore': scientificScore,
      'scientificNotes': scientificNotes,
      'leadershipScore': leadershipScore,
      'leadershipNotes': leadershipNotes,
      'studentActivitiesScore': studentActivitiesScore,
      'studentActivitiesNotes': studentActivitiesNotes,
      'communityActivitiesScore': communityActivitiesScore,
      'communityActivitiesNotes': communityActivitiesNotes,
      'humanRelationsScore': humanRelationsScore,
      'humanRelationsNotes': humanRelationsNotes,
      'isDraft': isDraft,
      'totalScore': totalScore,
    };
  }

  factory InterviewScoringModel.fromMap(Map<String, dynamic> map) {
    return InterviewScoringModel(
      interviewDate: (map['interviewDate'] != null && map['interviewDate'].toString().isNotEmpty)
          ? DateTime.parse(map['interviewDate'])
          : DateTime.now(),
      interviewLocation: map['interviewLocation'],
      interviewTime: map['interviewTime'],
      scientificScore: (map['scientificScore'] ?? 0).toDouble(),
      scientificNotes: map['scientificNotes'],
      leadershipScore: (map['leadershipScore'] ?? 0).toDouble(),
      leadershipNotes: map['leadershipNotes'],
      studentActivitiesScore: (map['studentActivitiesScore'] ?? 0).toDouble(),
      studentActivitiesNotes: map['studentActivitiesNotes'],
      communityActivitiesScore: (map['communityActivitiesScore'] ?? 0).toDouble(),
      communityActivitiesNotes: map['communityActivitiesNotes'],
      humanRelationsScore: (map['humanRelationsScore'] ?? 0).toDouble(),
      humanRelationsNotes: map['humanRelationsNotes'],
      isDraft: map['isDraft'] ?? false,
    );
  }

  InterviewScoringModel copyWith({
    DateTime? interviewDate,
    String? interviewLocation,
    String? interviewTime,
    double? scientificScore,
    String? scientificNotes,
    double? leadershipScore,
    String? leadershipNotes,
    double? studentActivitiesScore,
    String? studentActivitiesNotes,
    double? communityActivitiesScore,
    String? communityActivitiesNotes,
    double? humanRelationsScore,
    String? humanRelationsNotes,
    bool? isDraft,
  }) {
    return InterviewScoringModel(
      interviewDate: interviewDate ?? this.interviewDate,
      interviewLocation: interviewLocation ?? this.interviewLocation,
      interviewTime: interviewTime ?? this.interviewTime,
      scientificScore: scientificScore ?? this.scientificScore,
      scientificNotes: scientificNotes ?? this.scientificNotes,
      leadershipScore: leadershipScore ?? this.leadershipScore,
      leadershipNotes: leadershipNotes ?? this.leadershipNotes,
      studentActivitiesScore: studentActivitiesScore ?? this.studentActivitiesScore,
      studentActivitiesNotes: studentActivitiesNotes ?? this.studentActivitiesNotes,
      communityActivitiesScore: communityActivitiesScore ?? this.communityActivitiesScore,
      communityActivitiesNotes: communityActivitiesNotes ?? this.communityActivitiesNotes,
      humanRelationsScore: humanRelationsScore ?? this.humanRelationsScore,
      humanRelationsNotes: humanRelationsNotes ?? this.humanRelationsNotes,
      isDraft: isDraft ?? this.isDraft,
    );
  }
  ///  تجميع كل الملاحظات في نص واحد
String get combinedNotes {
  final notesList = <String>[];
  if (scientificNotes != null && scientificNotes!.isNotEmpty) {
    notesList.add('علمي: $scientificNotes');
  }
  if (leadershipNotes != null && leadershipNotes!.isNotEmpty) {
    notesList.add('قيادة: $leadershipNotes');
  }
  if (studentActivitiesNotes != null && studentActivitiesNotes!.isNotEmpty) {
    notesList.add('طلابي: $studentActivitiesNotes');
  }
  if (communityActivitiesNotes != null && communityActivitiesNotes!.isNotEmpty) {
    notesList.add('مجتمعي: $communityActivitiesNotes');
  }
  if (humanRelationsNotes != null && humanRelationsNotes!.isNotEmpty) {
    notesList.add('إنساني: $humanRelationsNotes');
  }
  return notesList.join(' | ');
}
}