/// ✅ المحاور الجديدة لتقييم المقابلة (5 محاور = 100 درجة)
enum InterviewSection {
  emotionalBalance,      // الاتزان الانفعالي (20 درجة)
  strategicThinking,     // الفكر الاستراتيجي (25 درجة)
  participatoryLeadership,// القيادة التشاركية (20 درجة)
  legalAwareness,        // الوعي القانوني (20 درجة)
  communityInteraction,  // التفاعل المجتمعي (15 درجة)
}

/// موديل مساعد للمعايير الفرعية داخل كل محور
class RubricCriterion {
  final String titleAr;
  final double maxScore;
  double givenScore;

  RubricCriterion({required this.titleAr, required this.maxScore, this.givenScore = 0.0});

  Map<String, dynamic> toMap() => {'titleAr': titleAr, 'maxScore': maxScore, 'givenScore': givenScore};
  factory RubricCriterion.fromMap(Map<String, dynamic> map) => RubricCriterion(
    titleAr: map['titleAr'] ?? '',
    maxScore: (map['maxScore'] ?? 0).toDouble(),
    givenScore: (map['givenScore'] ?? 0).toDouble(),
  );
}

/// ✅ موديل تقييم المقابلة الشخصية (المحدّث)
class InterviewScoringModel {
  final DateTime interviewDate;
  final String? interviewLocation;
  final String? interviewTime;
  
  // 1️⃣ المحور الأول: سمة الاتزان الانفعالي (20 درجة)
  final List<RubricCriterion> emotionalBalanceCriteria;
  final String? emotionalBalanceNotes;
  
  // 2️⃣ المحور الثاني: الفكر الاستراتيجي (25 درجة)
  final List<RubricCriterion> strategicThinkingCriteria;
  final String? strategicThinkingNotes;
  
  // 3️⃣ المحور الثالث: القيادة التشاركية (20 درجة)
  final List<RubricCriterion> participatoryLeadershipCriteria;
  final String? participatoryLeadershipNotes;
  
  // 4️⃣ المحور الرابع: الوعي القانوني (20 درجة)
  final List<RubricCriterion> legalAwarenessCriteria;
  final String? legalAwarenessNotes;
  
  // 5️⃣ المحور الخامس: التفاعل المجتمعي (15 درجة)
  final List<RubricCriterion> communityInteractionCriteria;
  final String? communityInteractionNotes;
  
  final bool isDraft;

  InterviewScoringModel({
    required this.interviewDate,
    this.interviewLocation,
    this.interviewTime,
    List<RubricCriterion>? emotionalBalanceCriteria,
    this.emotionalBalanceNotes,
    List<RubricCriterion>? strategicThinkingCriteria,
    this.strategicThinkingNotes,
    List<RubricCriterion>? participatoryLeadershipCriteria,
    this.participatoryLeadershipNotes,
    List<RubricCriterion>? legalAwarenessCriteria,
    this.legalAwarenessNotes,
    List<RubricCriterion>? communityInteractionCriteria,
    this.communityInteractionNotes,
    this.isDraft = false,
  }) : emotionalBalanceCriteria = emotionalBalanceCriteria ?? _getDefaultEmotionalCriteria(),
       strategicThinkingCriteria = strategicThinkingCriteria ?? _getDefaultStrategicCriteria(),
       participatoryLeadershipCriteria = participatoryLeadershipCriteria ?? _getDefaultLeadershipCriteria(),
       legalAwarenessCriteria = legalAwarenessCriteria ?? _getDefaultLegalCriteria(),
       communityInteractionCriteria = communityInteractionCriteria ?? _getDefaultCommunityCriteria();

  // ============================================================
  // الدوال الافتراضية لإنشاء المعايير الفرعية (الاستبيان الفاضي)
  // ============================================================
  static List<RubricCriterion> _getDefaultEmotionalCriteria() => [
    RubricCriterion(titleAr: "الثبات الانفعالي والهدوء تحت الضغط", maxScore: 5),
    RubricCriterion(titleAr: "مهارات التحدث بوضوح وقوة الحجة", maxScore: 5),
    RubricCriterion(titleAr: "الجاهزية والحضور الذهني السريع", maxScore: 5),
    RubricCriterion(titleAr: "التعبير الإيجابي بلغة الجسد والتواصل البصري", maxScore: 5),
  ];

  static List<RubricCriterion> _getDefaultStrategicCriteria() => [
    RubricCriterion(titleAr: "عمق الرؤية وفهم المشكلات وطرح حلول مبتكرة", maxScore: 10),
    RubricCriterion(titleAr: "مهارة العرض الشفهي وتنظيم الأفكار بشكل منطقي", maxScore: 10),
    RubricCriterion(titleAr: "مواءمة مقترح التطوير مع التحول الرقمي", maxScore: 5),
  ];

  static List<RubricCriterion> _getDefaultLeadershipCriteria() => [
    RubricCriterion(titleAr: "حل النزاعات بأساليب دبلوماسية وعلمية", maxScore: 10),
    RubricCriterion(titleAr: "الإيمان بالتفويض وإشراك مجالس الأقسام (العمل الجماعي)", maxScore: 10),
  ];

  static List<RubricCriterion> _getDefaultLegalCriteria() => [
    RubricCriterion(titleAr: "الإحاطة بنصوص اللوائح وحقوق وواجبات كل فئة", maxScore: 10),
    RubricCriterion(titleAr: "اتخاذ قرارات حاسمة وصحيحة قانونياً لمواجهة البيروقراطية", maxScore: 10),
  ];

  static List<RubricCriterion> _getDefaultCommunityCriteria() => [
    RubricCriterion(titleAr: "تسويق خدمات الكلية وربط الأبحاث بسوق العمل", maxScore: 10),
    RubricCriterion(titleAr: "بناء شراكات مستدامة مع مؤسسات محلية أو دولية", maxScore: 5),
  ];

  /// ✅ الدرجات القصوى لكل محور
  static const Map<InterviewSection, double> maxScores = {
    InterviewSection.emotionalBalance: 20.0,
    InterviewSection.strategicThinking: 25.0,
    InterviewSection.participatoryLeadership: 20.0,
    InterviewSection.legalAwareness: 20.0,
    InterviewSection.communityInteraction: 15.0,
  };

  // ============================================================
  // حسابات الدرجات
  // ============================================================
  
  /// حساب درجة محور معين
  double _getAxisScore(List<RubricCriterion> criteria) {
    return criteria.fold(0.0, (sum, item) => sum + item.givenScore);
  }

  double get emotionalBalanceScore => _getAxisScore(emotionalBalanceCriteria);
  double get strategicThinkingScore => _getAxisScore(strategicThinkingCriteria);
  double get participatoryLeadershipScore => _getAxisScore(participatoryLeadershipCriteria);
  double get legalAwarenessScore => _getAxisScore(legalAwarenessCriteria);
  double get communityInteractionScore => _getAxisScore(communityInteractionCriteria);

  /// ✅ المجموع الكلي (100 درجة)
  double get totalScore => 
      emotionalBalanceScore + 
      strategicThinkingScore + 
      participatoryLeadershipScore + 
      legalAwarenessScore + 
      communityInteractionScore;

  /// ✅ التحقق من صحة الدرجات (ألا تتجاوز الحد الأقصى لكل معيار)
  bool get isValid {
    for (var axis in [emotionalBalanceCriteria, strategicThinkingCriteria, participatoryLeadershipCriteria, legalAwarenessCriteria, communityInteractionCriteria]) {
      for (var crit in axis) {
        if (crit.givenScore < 0 || crit.givenScore > crit.maxScore) return false;
      }
    }
    return true;
  }

  // ============================================================
  // التحويل لـ Map والعكس (للتخزين في Firebase)
  // ============================================================
  Map<String, dynamic> toMap() {
    return {
      'interviewDate': interviewDate.toIso8601String(),
      'interviewLocation': interviewLocation,
      'interviewTime': interviewTime,
      'emotionalBalanceCriteria': emotionalBalanceCriteria.map((c) => c.toMap()).toList(),
      'emotionalBalanceNotes': emotionalBalanceNotes,
      'strategicThinkingCriteria': strategicThinkingCriteria.map((c) => c.toMap()).toList(),
      'strategicThinkingNotes': strategicThinkingNotes,
      'participatoryLeadershipCriteria': participatoryLeadershipCriteria.map((c) => c.toMap()).toList(),
      'participatoryLeadershipNotes': participatoryLeadershipNotes,
      'legalAwarenessCriteria': legalAwarenessCriteria.map((c) => c.toMap()).toList(),
      'legalAwarenessNotes': legalAwarenessNotes,
      'communityInteractionCriteria': communityInteractionCriteria.map((c) => c.toMap()).toList(),
      'communityInteractionNotes': communityInteractionNotes,
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
      emotionalBalanceCriteria: (map['emotionalBalanceCriteria'] as List?)?.map((c) => RubricCriterion.fromMap(c)).toList(),
      emotionalBalanceNotes: map['emotionalBalanceNotes'],
      strategicThinkingCriteria: (map['strategicThinkingCriteria'] as List?)?.map((c) => RubricCriterion.fromMap(c)).toList(),
      strategicThinkingNotes: map['strategicThinkingNotes'],
      participatoryLeadershipCriteria: (map['participatoryLeadershipCriteria'] as List?)?.map((c) => RubricCriterion.fromMap(c)).toList(),
      participatoryLeadershipNotes: map['participatoryLeadershipNotes'],
      legalAwarenessCriteria: (map['legalAwarenessCriteria'] as List?)?.map((c) => RubricCriterion.fromMap(c)).toList(),
      legalAwarenessNotes: map['legalAwarenessNotes'],
      communityInteractionCriteria: (map['communityInteractionCriteria'] as List?)?.map((c) => RubricCriterion.fromMap(c)).toList(),
      communityInteractionNotes: map['communityInteractionNotes'],
      isDraft: map['isDraft'] ?? false,
    );
  }

  InterviewScoringModel copyWith({
    DateTime? interviewDate,
    String? interviewLocation,
    String? interviewTime,
    List<RubricCriterion>? emotionalBalanceCriteria,
    String? emotionalBalanceNotes,
    List<RubricCriterion>? strategicThinkingCriteria,
    String? strategicThinkingNotes,
    List<RubricCriterion>? participatoryLeadershipCriteria,
    String? participatoryLeadershipNotes,
    List<RubricCriterion>? legalAwarenessCriteria,
    String? legalAwarenessNotes,
    List<RubricCriterion>? communityInteractionCriteria,
    String? communityInteractionNotes,
    bool? isDraft,
  }) {
    return InterviewScoringModel(
      interviewDate: interviewDate ?? this.interviewDate,
      interviewLocation: interviewLocation ?? this.interviewLocation,
      interviewTime: interviewTime ?? this.interviewTime,
      emotionalBalanceCriteria: emotionalBalanceCriteria ?? this.emotionalBalanceCriteria,
      emotionalBalanceNotes: emotionalBalanceNotes ?? this.emotionalBalanceNotes,
      strategicThinkingCriteria: strategicThinkingCriteria ?? this.strategicThinkingCriteria,
      strategicThinkingNotes: strategicThinkingNotes ?? this.strategicThinkingNotes,
      participatoryLeadershipCriteria: participatoryLeadershipCriteria ?? this.participatoryLeadershipCriteria,
      participatoryLeadershipNotes: participatoryLeadershipNotes ?? this.participatoryLeadershipNotes,
      legalAwarenessCriteria: legalAwarenessCriteria ?? this.legalAwarenessCriteria,
      legalAwarenessNotes: legalAwarenessNotes ?? this.legalAwarenessNotes,
      communityInteractionCriteria: communityInteractionCriteria ?? this.communityInteractionCriteria,
      communityInteractionNotes: communityInteractionNotes ?? this.communityInteractionNotes,
      isDraft: isDraft ?? this.isDraft,
    );
  }

  ///  تجميع كل الملاحظات في نص واحد
  String get combinedNotes {
    final notesList = <String>[];
    if (emotionalBalanceNotes != null && emotionalBalanceNotes!.isNotEmpty) notesList.add('اتزان انفعالي: $emotionalBalanceNotes');
    if (strategicThinkingNotes != null && strategicThinkingNotes!.isNotEmpty) notesList.add('فكر استراتيجي: $strategicThinkingNotes');
    if (participatoryLeadershipNotes != null && participatoryLeadershipNotes!.isNotEmpty) notesList.add('قيادة تشاركية: $participatoryLeadershipNotes');
    if (legalAwarenessNotes != null && legalAwarenessNotes!.isNotEmpty) notesList.add('وعي قانوني: $legalAwarenessNotes');
    if (communityInteractionNotes != null && communityInteractionNotes!.isNotEmpty) notesList.add('تفاعل مجتمعي: $communityInteractionNotes');
    return notesList.join(' | ');
  }
}