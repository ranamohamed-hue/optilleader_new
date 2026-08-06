import 'package:optialeader/feature/doctor/data/model/verefication_status.dart';

// ====== الـ Enums ======
enum JournalScope { specialized, nonSpecialized }

enum JournalLevel { international, local }

enum IndexingDatabase { scopus, webOfScience, local, other }

/*T enumFromString<T>(Iterable<T> values, String? value) {
  return values.firstWhere(
    (type) => type.toString().split('.').last == value,
    orElse: () => values.first,
  );
}*/
// =========================

class ResearchPaperModel {
  final String id;

  // 1. البيانات الأساسية
  final String titleAr;
  final String titleEn;
  final String journalName;
  final String issn;
  final String impactFactor;
  final int publicationYear;
  final int authorOrder;
  final int totalAuthors;
  final String? doi;
  final int authorsInSameSpecialty;
  final bool isTopTierJournal;
  final bool sameSpecialization;
  // 2. تصنيف المجلة
  final JournalScope journalScope;
  final JournalLevel journalLevel;
  final IndexingDatabase indexingDatabase;
  final String journalUrl;
  //3.في حالة كانت مجلة محلية
  final bool peerReviewed;
  final bool knownEditorialBoard;
  final bool regularPublication;
  final bool indexedDatabase;
  final bool specializedJournal;
  final bool electronicPublishing;
  final bool externalReviewers;
  final bool externalAuthors;

  // 3. الحقول الجديدة لحساب نقاط المجلة
  final String? quartile;
  final bool isLocalJournal;
  final Map<String, bool>? localJournalCriteria;

  // 4. التقرير المعتمد
  final String? certifiedReportNumber;
  final String? certifiedReportFileUrl;

  // 5. درجة الأدمن
  final double adminScore;
  //

  // 6. الإثباتات
  final String paperFileUrl;
  final String paperFileType;
  final String? indexingProofUrl;
  final String? indexingProofType;

  // 7. حالة الاعتماد
  final VerificationStatus status;
  final String? rejectionReason;

  ResearchPaperModel({
    this.authorOrder = 1,
    this.sameSpecialization = true,
    required this.id,
    required this.titleAr,
    required this.titleEn,
    required this.journalName,
    required this.issn,
    required this.impactFactor,
    required this.publicationYear,
    required this.totalAuthors,
    this.doi,
    this.authorsInSameSpecialty = 1,
    this.isTopTierJournal = false,
    required this.journalScope,
    required this.journalLevel,
    required this.indexingDatabase,
    required this.journalUrl,
    this.quartile,
    this.isLocalJournal = false,
    this.localJournalCriteria,
    this.certifiedReportNumber,
    this.certifiedReportFileUrl,
    this.adminScore = 0.0,
    required this.paperFileUrl,
    this.paperFileType = 'image',
    this.indexingProofUrl,
    this.indexingProofType,
    this.status = VerificationStatus.pending,
    this.rejectionReason,
    this.peerReviewed = false,
    this.knownEditorialBoard = false,
    this.regularPublication = false,
    this.indexedDatabase = false,
    this.specializedJournal = false,
    this.electronicPublishing = false,
    this.externalReviewers = false,
    this.externalAuthors = false,
  });

  // =============================================================
  // ============== الحسابات الآلية (Getters) ====================
  // =============================================================

  ///  1. نسبة المشاركة (مادة 22)
 double get participationPercentage {
  final bool firstOrLast =
      authorOrder == 1 || authorOrder == totalAuthors;
    final int count = authorsInSameSpecialty;
  final bool isWosQ1 =
      indexingDatabase == IndexingDatabase.webOfScience &&
      (quartile ?? '').toUpperCase() == 'Q1';

  // ==========================
  // Web Of Science Q1 (10 درجات)
  // ==========================
  if (isWosQ1) {
    if (count <= 4) {
      return 1.0;
    }

    if (count == 5 || count == 6) {
      return firstOrLast ? 1.0 : 0.8;
    }

    return firstOrLast ? 1.0 : 0.6;
  }

  // ==========================
  // باقي المجلات
  // ==========================

  if (count == 1) {
    return 1.0;
  }
if (totalAuthors == 2) {
  return 1.0;
}
  if (count == 2) {
    return 0.8;
  }

  if (count == 3) {
    return firstOrLast ? 1.0 : 0.7;
  }

  if (count == 4) {
    return firstOrLast ? 1.0 : 0.55;
  }

  if (count == 5) {
    return firstOrLast ? 1.0 : 0.4;
  }

  // 6 فأكثر
  return firstOrLast ? 1.0 : 0.25;
}
  /// ✅ 2. نقاط المجلة الدولية
  double get _internationalJournalPoints {
    final q = (quartile ?? '').toUpperCase();

    switch (indexingDatabase) {
      case IndexingDatabase.webOfScience:
        switch (q) {
          case 'Q1':
            return 10.0;

          case 'Q2':
            return 9.5;

          case 'Q3':
            return 8.5;

          case 'Q4':
            return 8;

          default:
            return 0.0;
        }

      case IndexingDatabase.scopus:
        switch (q) {
          case 'Q1':
            return 9.0;

          case 'Q2':
            return 8.5;

          case 'Q3':
            return 8.0;

          case 'Q4':
            return 7.5;

          default:
            return 0.0;
        }

      default:
        return 0.0;
    }
  }

  /// ✅ 3. نقاط المجلة المحلية (بحد أقصى 7)
  double get localJournalPoints {
    double score = 0;

    if (peerReviewed) score += 1;
    if (knownEditorialBoard) score += 1;
    if (regularPublication) score += 1;
    if (indexedDatabase) score += 1;
    if (specializedJournal) score += 1;
    if (electronicPublishing) score += 1;
    if (externalReviewers) score += 0.5;
    if (externalAuthors) score += 0.5;

    return score;
  }

  /// ✅ 4. إجمالي نقاط المجلة
  double get journalPoints {
    if (isLocalJournal) return localJournalPoints;

    final db = indexingDatabase.name.toLowerCase();
    if (db == 'webofscience' || db == 'wos' || db == 'scopus') {
      return _internationalJournalPoints;
    }

    return 0.0;
  }

  /// ✅ 5. المجموع النهائي للبحث (درجة المجلة + درجة الأدمن) × نسبة المشاركة
  double get finalPoints {
    return (adminScore + journalPoints) * participationPercentage;
  }

  /// ✅ هل البحث محتاج تقييم الأدمن؟
  bool get needsAdminReview => adminScore == 0.0;

  // =============================================================
  // ================ JSON Methods ===============================
  // =============================================================

  factory ResearchPaperModel.fromJson(Map<String, dynamic> json) {
    return ResearchPaperModel(
      id: json['id'] ?? '',
      titleAr: json['titleAr'] ?? '',
      titleEn: json['titleEn'] ?? '',
      journalName: json['journalName'] ?? '',
      issn: json['issn'] ?? '',
      impactFactor: json['impactFactor'] ?? '',
      publicationYear: json['publicationYear'] ?? 0,
      authorOrder: json['authorOrder'] ?? 0,
      totalAuthors: json['totalAuthors'] ?? 0,
      doi: json['doi'],
      authorsInSameSpecialty: json['authors_in_same_specialty'] ?? 1,
      isTopTierJournal: json['is_top_tier_journal'] ?? false,
      journalScope: enumFromString(JournalScope.values, json['journalScope']),
      journalLevel: enumFromString(JournalLevel.values, json['journalLevel']),
      indexingDatabase: enumFromString(
        IndexingDatabase.values,
        json['indexingDatabase'],
      ),
      journalUrl: json['journalUrl'] ?? '',
      quartile: json['quartile'],
      isLocalJournal: json['isLocalJournal'] ?? false,
      localJournalCriteria: json['localJournalCriteria'] != null
          ? Map<String, bool>.from(json['localJournalCriteria'])
          : null,
      certifiedReportNumber: json['certifiedReportNumber'],
      certifiedReportFileUrl: json['certifiedReportFileUrl'],
      adminScore: (json['adminScore'] ?? 0).toDouble(),
      paperFileUrl: json['paperFileUrl'] ?? '',
      paperFileType: json['paperFileType'] ?? 'image',
      indexingProofUrl: json['indexingProofUrl'],
      indexingProofType: json['indexingProofType'],
      status: parseVerificationStatus(json['status']),
      rejectionReason: json['rejectionReason'],
      peerReviewed: json['peerReviewed'] ?? false,
      knownEditorialBoard: json['knownEditorialBoard'] ?? false,
      regularPublication: json['regularPublication'] ?? false,
      indexedDatabase: json['indexedDatabase'] ?? false,
      specializedJournal: json['specializedJournal'] ?? false,
      electronicPublishing: json['electronicPublishing'] ?? false,
      externalReviewers: json['externalReviewers'] ?? false,
      externalAuthors: json['externalAuthors'] ?? false,

      sameSpecialization: json['sameSpecialization'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'peerReviewed': peerReviewed,
      'knownEditorialBoard': knownEditorialBoard,
      'regularPublication': regularPublication,
      'indexedDatabase': indexedDatabase,
      'specializedJournal': specializedJournal,
      'electronicPublishing': electronicPublishing,
      'externalReviewers': externalReviewers,
      'externalAuthors': externalAuthors,

      'sameSpecialization': sameSpecialization,
      'id': id,
      'titleAr': titleAr,
      'titleEn': titleEn,
      'journalName': journalName,
      'issn': issn,
      'impactFactor': impactFactor,
      'publicationYear': publicationYear,
      'authorOrder': authorOrder,
      'totalAuthors': totalAuthors,
      'doi': doi,
      'authors_in_same_specialty': authorsInSameSpecialty,
      'is_top_tier_journal': isTopTierJournal,
      'journalScope': journalScope.name,
      'journalLevel': journalLevel.name,
      'indexingDatabase': indexingDatabase.name,
      'journalUrl': journalUrl,
      'quartile': quartile,
      'isLocalJournal': isLocalJournal,
      'localJournalCriteria': localJournalCriteria,
      'certifiedReportNumber': certifiedReportNumber,
      'certifiedReportFileUrl': certifiedReportFileUrl,
      'adminScore': adminScore,
      'paperFileUrl': paperFileUrl,
      'paperFileType': paperFileType,
      'indexingProofUrl': indexingProofUrl,
      'indexingProofType': indexingProofType,
      'status': status.name,
      'rejectionReason': rejectionReason,
    };
  }

  ResearchPaperModel copyWith({
    bool? peerReviewed,
    bool? knownEditorialBoard,
    bool? regularPublication,
    bool? indexedDatabase,
    bool? specializedJournal,
    bool? electronicPublishing,
    bool? externalReviewers,
    bool? externalAuthors,

    bool? sameSpecialization,
    String? id,
    String? titleAr,
    String? titleEn,
    String? journalName,
    String? issn,
    String? impactFactor,
    int? publicationYear,
    int? authorOrder,
    int? totalAuthors,
    String? doi,
    int? authorsInSameSpecialty,
    bool? isTopTierJournal,
    JournalScope? journalScope,
    JournalLevel? journalLevel,
    IndexingDatabase? indexingDatabase,
    String? journalUrl,
    String? quartile,
    bool? isLocalJournal,
    Map<String, bool>? localJournalCriteria,
    String? certifiedReportNumber,
    String? certifiedReportFileUrl,
    double? adminScore,
    String? paperFileUrl,
    String? paperFileType,
    String? indexingProofUrl,
    String? indexingProofType,
    VerificationStatus? status,
    String? rejectionReason,
  }) {
    return ResearchPaperModel(
      id: id ?? this.id,
      titleAr: titleAr ?? this.titleAr,
      titleEn: titleEn ?? this.titleEn,
      journalName: journalName ?? this.journalName,
      issn: issn ?? this.issn,
      impactFactor: impactFactor ?? this.impactFactor,
      publicationYear: publicationYear ?? this.publicationYear,
      authorOrder: authorOrder ?? this.authorOrder,
      totalAuthors: totalAuthors ?? this.totalAuthors,
      doi: doi ?? this.doi,
      authorsInSameSpecialty:
          authorsInSameSpecialty ?? this.authorsInSameSpecialty,
      isTopTierJournal: isTopTierJournal ?? this.isTopTierJournal,
      journalScope: journalScope ?? this.journalScope,
      journalLevel: journalLevel ?? this.journalLevel,
      indexingDatabase: indexingDatabase ?? this.indexingDatabase,
      journalUrl: journalUrl ?? this.journalUrl,
      quartile: quartile ?? this.quartile,
      isLocalJournal: isLocalJournal ?? this.isLocalJournal,
      localJournalCriteria: localJournalCriteria ?? this.localJournalCriteria,
      certifiedReportNumber:
          certifiedReportNumber ?? this.certifiedReportNumber,
      certifiedReportFileUrl:
          certifiedReportFileUrl ?? this.certifiedReportFileUrl,
      adminScore: adminScore ?? this.adminScore,
      paperFileUrl: paperFileUrl ?? this.paperFileUrl,
      paperFileType: paperFileType ?? this.paperFileType,
      indexingProofUrl: indexingProofUrl ?? this.indexingProofUrl,
      indexingProofType: indexingProofType ?? this.indexingProofType,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      peerReviewed: peerReviewed ?? this.peerReviewed,
      knownEditorialBoard: knownEditorialBoard ?? this.knownEditorialBoard,
      regularPublication: regularPublication ?? this.regularPublication,
      indexedDatabase: indexedDatabase ?? this.indexedDatabase,
      specializedJournal: specializedJournal ?? this.specializedJournal,
      electronicPublishing: electronicPublishing ?? this.electronicPublishing,
      externalReviewers: externalReviewers ?? this.externalReviewers,
      externalAuthors: externalAuthors ?? this.externalAuthors,
      sameSpecialization: sameSpecialization ?? this.sameSpecialization,
    );
  }
}
