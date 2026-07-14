import 'package:optialeader/feature/doctor/data/model/verefication_status.dart';

// ✅ تم توسيع الـ Enum ليتطابق مع أصناف الجدول الرسمي بالضبط
enum ExhibitionVenue {
  // 8 درجات
  internationalAbroad,
  
  // 7 درجات
  internationalEgypt,
  
  // 6.5 درجات (القاعات المعتمدة)
  artFaculties,         
  fineArtsSector,        
  foreignCulturalCenters,
  artSyndicates,         
  
  // 5 درجات (القاعات العامة)
  culturePalaces,        // قاعات هيئة قصور الثقافة بوزارة الثقافة
  ateliersCairoAlex,     // قاعات اتيليه القاهرة والإسكندرية بوزارة الثقافة
  privateGalleries,      // قاعات المعرض الخاص داخل أو خارج مصر
}

class ArtExhibitionModel {
  final String id;
  final String title;
  final ExhibitionVenue venue; 
  final int numberOfWorks;
  
  final bool isInternationalType; // محتفظين بيه للـ Backward Compatibility
  
  final String proofFileUrl; 
  final String proofFileType; 
  final String? researcherNotes; 

  final VerificationStatus status;
  final String? rejectionReason;

  ArtExhibitionModel({
    required this.id,
    required this.title,
    required this.venue,
    required this.numberOfWorks,
    this.isInternationalType = false,
    required this.proofFileUrl,
    required this.proofFileType,
    this.researcherNotes,
    this.status = VerificationStatus.pending,
    this.rejectionReason,
  });

bool get isPointsOnHold {
  return venue == ExhibitionVenue.internationalAbroad &&
         numberOfWorks > 0 &&
         numberOfWorks < 5;
}

  /// ✅ حساب النقاط الأساسية (مطابق للجدول الرسمي مع الخيارات الجديدة)
  double get basePoints {
    if (isPointsOnHold) return 0.0;

    switch (venue) {
      case ExhibitionVenue.internationalAbroad:
        return numberOfWorks >= 5 ? 8.0 : 0.0;
        
      case ExhibitionVenue.internationalEgypt:
        return 7.0;
        
      // المجموعة دي كلها بتعطي 6.5 درجة
      case ExhibitionVenue.artFaculties:
      case ExhibitionVenue.fineArtsSector:
      case ExhibitionVenue.foreignCulturalCenters:
      case ExhibitionVenue.artSyndicates:
        return 6.5;
        
      // المجموعة دي كلها بتعطي 5 درجات
      case ExhibitionVenue.culturePalaces:
      case ExhibitionVenue.ateliersCairoAlex:
      case ExhibitionVenue.privateGalleries:
        return 5.0;
    }
  }

  factory ArtExhibitionModel.fromJson(Map<String, dynamic> json) {
    return ArtExhibitionModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      venue: ExhibitionVenue.values.firstWhere(
        (e) => e.name == json['venue'],
        orElse: () => ExhibitionVenue.privateGalleries, // قيمة افتراضية آمنة
      ),
      numberOfWorks: json['numberOfWorks'] ?? 1,
      isInternationalType: json['isInternationalType'] ?? false,
      proofFileUrl: json['proofFileUrl'] ?? '',
      proofFileType: json['proofFileType'] ?? 'image',
      researcherNotes: json['researcherNotes'],
      status: parseVerificationStatus(json['status']),
      rejectionReason: json['rejectionReason'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'venue': venue.name,
      'numberOfWorks': numberOfWorks,
      'isInternationalType': isInternationalType,
      'proofFileUrl': proofFileUrl,
      'proofFileType': proofFileType,
      'researcherNotes': researcherNotes,
      'status': status.name,
      'rejectionReason': rejectionReason,
    };
  }

  ArtExhibitionModel copyWith({
    String? id,
    String? title,
    ExhibitionVenue? venue,
    int? numberOfWorks,
    bool? isInternationalType,
    String? proofFileUrl,
    String? proofFileType,
    String? researcherNotes,
    VerificationStatus? status,
    String? rejectionReason,
  }) {
    return ArtExhibitionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      venue: venue ?? this.venue,
      numberOfWorks: numberOfWorks ?? this.numberOfWorks,
      isInternationalType: isInternationalType ?? this.isInternationalType,
      proofFileUrl: proofFileUrl ?? this.proofFileUrl,
      proofFileType: proofFileType ?? this.proofFileType,
      researcherNotes: researcherNotes ?? this.researcherNotes,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }
}