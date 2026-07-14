
enum ActivityAxis {
  teaching,
  research,
  community,
}

enum ProofStatus {
  pending,
  approved,
  rejected,
  notSubmitted,
}

class ActivityCriterion {
  final String key;
  final String titleAr;
  final double maxPoints;
  final String proofRequirement;
  
  bool isSelected;
  String? proofFileUrl;
  String? proofFileType;
  
  ProofStatus proofStatus;
  String? adminNote;

  ActivityCriterion({
    required this.key,
    required this.titleAr,
    required this.maxPoints,
    required this.proofRequirement,
    this.isSelected = false,
    this.proofFileUrl,
    this.proofFileType,
    this.proofStatus = ProofStatus.notSubmitted,
    this.adminNote,
  });

  /// ✅ الدرجة الفعلية
  double get awardedPoints {
    if (isSelected && proofStatus == ProofStatus.approved) {
      return maxPoints;
    }
    return 0.0;
  }

  factory ActivityCriterion.fromJson(Map<String, dynamic> json) {
    return ActivityCriterion(
      key: json['key'] ?? '',
      titleAr: json['titleAr'] ?? '',
      maxPoints: (json['maxPoints'] ?? 0).toDouble(),
      proofRequirement: json['proofRequirement'] ?? '',
      isSelected: json['isSelected'] ?? false,
      proofFileUrl: json['proofFileUrl'],
      proofFileType: json['proofFileType'],
      proofStatus: ProofStatus.values.firstWhere(
        (e) => e.name == json['proofStatus'],
        orElse: () => ProofStatus.notSubmitted,
      ),
      adminNote: json['adminNote'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'titleAr': titleAr,
      'maxPoints': maxPoints,
      'proofRequirement': proofRequirement,
      'isSelected': isSelected,
      'proofFileUrl': proofFileUrl,
      'proofFileType': proofFileType,
      'proofStatus': proofStatus.name,
      'adminNote': adminNote,
    };
  }
}

class AcademicActivityModel {
  final String id;
  final List<ActivityCriterion> teachingCriteria;
  final List<ActivityCriterion> researchCriteria;
  final List<ActivityCriterion> communityCriteria;

  AcademicActivityModel({
    required this.id,
    required this.teachingCriteria,
    required this.researchCriteria,
    required this.communityCriteria,
  });

  /// ✅ درجات كل محور
  double get teachingPoints {
    double sum = teachingCriteria.fold(0.0, (sum, c) => sum + c.awardedPoints);
    return sum > 7.0 ? 7.0 : sum;
  }

  double get researchPoints {
    double sum = researchCriteria.fold(0.0, (sum, c) => sum + c.awardedPoints);
    return sum > 7.0 ? 7.0 : sum;
  }

  double get communityPoints {
    double sum = communityCriteria.fold(0.0, (sum, c) => sum + c.awardedPoints);
    return sum > 6.0 ? 6.0 : sum;
  }

  /// ✅ المجموع الكلي (حد أقصى 20)
  double get totalPoints => teachingPoints + researchPoints + communityPoints;

  /// ✅ هل فيه بنود محتاجة إعادة رفع؟
  bool get hasRejectedProofs {
    return [...teachingCriteria, ...researchCriteria, ...communityCriteria]
        .any((c) => c.proofStatus == ProofStatus.rejected);
  }

  /// ✅ إنشاء قائمة فارغة بالمعايير
  factory AcademicActivityModel.createEmpty(String id) {
    return AcademicActivityModel(
      id: id,
      teachingCriteria: [
        ActivityCriterion(key: 'teaching_courses', titleAr: 'المقررات الدراسية', maxPoints: 2.5, proofRequirement: 'بيان معتمد من مجلس القسم'),
        ActivityCriterion(key: 'teaching_dev', titleAr: 'تطوير المقررات', maxPoints: 1.5, proofRequirement: 'صورة رقمية للمقرر على الإنترنت'),
        ActivityCriterion(key: 'teaching_results', titleAr: 'نتائج الطلاب', maxPoints: 2.0, proofRequirement: 'تقرير من وكيل الكلية المختص'),
        ActivityCriterion(key: 'teaching_exams', titleAr: 'أعمال الامتحانات والكنترول', maxPoints: 2.0, proofRequirement: 'تقرير من وكيل الكلية أو رئيس الكنترول'),
        ActivityCriterion(key: 'teaching_books', titleAr: 'الكتب والمؤلفات', maxPoints: 2.0, proofRequirement: 'رقم الإيداع بدار الكتب'),
      ],
      researchCriteria: [
        ActivityCriterion(key: 'res_citations', titleAr: 'عدد الاستشهادات (Citations)', maxPoints: 2.0, proofRequirement: 'صورة من موقع Scopus'),
        ActivityCriterion(key: 'res_supervision', titleAr: 'الإشراف العلمي', maxPoints: 2.0, proofRequirement: 'بيان معتمد من وكيل الكلية'),
        ActivityCriterion(key: 'res_courses', titleAr: 'الدورات وورش العمل', maxPoints: 1.0, proofRequirement: 'بيان معتمد من الكلية'),
        ActivityCriterion(key: 'res_conferences', titleAr: 'المؤتمرات العلمية', maxPoints: 1.0, proofRequirement: 'بيان معتمد من الكلية'),
        ActivityCriterion(key: 'res_projects', titleAr: 'المشروعات البحثية', maxPoints: 1.0, proofRequirement: 'بيان من الجهة الممولة'),
        ActivityCriterion(key: 'res_patents', titleAr: 'براءات الاختراع', maxPoints: 1.0, proofRequirement: 'بيان من الجهة المانحة'),
        ActivityCriterion(key: 'res_dept_support', titleAr: 'رفع شأن القسم', maxPoints: 2.0, proofRequirement: 'رأي القسم العلمي'),
      ],
      communityCriteria: [
        ActivityCriterion(key: 'com_regulations', titleAr: 'تطوير اللوائح', maxPoints: 2.0, proofRequirement: 'بيان من الكلية أو الجهة المشارك معها'),
        ActivityCriterion(key: 'com_committees', titleAr: 'الوحدات الخدمية واللجان', maxPoints: 1.0, proofRequirement: 'بيان من الكلية أو الجهة المشارك معها'),
        ActivityCriterion(key: 'com_quality', titleAr: 'وحدة ضمان الجودة', maxPoints: 1.5, proofRequirement: 'بيان من وحدة ضمان الجودة'),
        ActivityCriterion(key: 'com_caravans', titleAr: 'القوافل التنموية/محو الأمية', maxPoints: 1.5, proofRequirement: 'بيان معتمد من الكلية'),
        ActivityCriterion(key: 'com_student', titleAr: 'الأنشطة الطلابية', maxPoints: 1.0, proofRequirement: 'بيان معتمد من الكلية'),
        ActivityCriterion(key: 'com_associations', titleAr: 'الجمعيات والروابط العلمية', maxPoints: 1.5, proofRequirement: 'بيان من الجهة المشتركة فيها'),
        ActivityCriterion(key: 'com_awards', titleAr: 'الجوائز العلمية', maxPoints: 1.5, proofRequirement: 'شهادة أو بيان من الجهة المانحة'),
      ],
    );
  }

  factory AcademicActivityModel.fromJson(Map<String, dynamic> json) {
    List<ActivityCriterion> parseList(String key) {
      final list = json[key] as List<dynamic>? ?? [];
      return list.map((e) => ActivityCriterion.fromJson(e as Map<String, dynamic>)).toList();
    }

    return AcademicActivityModel(
      id: json['id'] ?? '',
      teachingCriteria: parseList('teachingCriteria'),
      researchCriteria: parseList('researchCriteria'),
      communityCriteria: parseList('communityCriteria'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'teachingCriteria': teachingCriteria.map((e) => e.toJson()).toList(),
      'researchCriteria': researchCriteria.map((e) => e.toJson()).toList(),
      'communityCriteria': communityCriteria.map((e) => e.toJson()).toList(),
    };
  }
}