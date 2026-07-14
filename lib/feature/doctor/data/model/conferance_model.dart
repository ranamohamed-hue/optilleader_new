import 'package:optialeader/feature/doctor/data/model/verefication_status.dart';

/// تصنيف نوع المشاركة في المؤتمر
enum ParticipationType { 
  paperPresentation,
  abstractPresentation,
  attendanceOnly
}

class ConferenceModel {
  final String id;
  final String title;
  
  final bool isInternational;
  final bool isSpecialized;
  final bool isPublished;
  final ParticipationType participationType;
  
  final String certificateUrl;
  final String? proceedingsUrl;
  
  final VerificationStatus status;
  final String? rejectionReason;

  ConferenceModel({
    required this.id,
    required this.title,
    required this.isInternational,
    required this.isSpecialized,
    required this.isPublished,
    required this.participationType,
    required this.certificateUrl,
    this.proceedingsUrl,
    this.status = VerificationStatus.pending,
    this.rejectionReason,
  });

  /// ✅ الحساب حسب الجدول الرسمي
  double get totalPoints {
    if (participationType == ParticipationType.paperPresentation && isPublished) {
      if (isInternational && isSpecialized) return 6.5;
      if (isInternational && !isSpecialized) return 5.0;
      if (!isInternational && isSpecialized) return 4.0;
      if (!isInternational && !isSpecialized) return 2.0;
    }
    
    if (participationType == ParticipationType.abstractPresentation) {
      if (isInternational && isSpecialized) return 4.5;
      if (isInternational && !isSpecialized) return 4.0;
      if (!isInternational && isSpecialized) return 2.5;
      if (!isInternational && !isSpecialized) return 1.0;
    }
    
    return 0.0;
  }

  factory ConferenceModel.fromJson(Map<String, dynamic> json) {
    return ConferenceModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      isInternational: json['isInternational'] ?? false,
      isSpecialized: json['isSpecialized'] ?? true,
      isPublished: json['isPublished'] ?? false,
      participationType: ParticipationType.values.firstWhere(
        (e) => e.name == json['participationType'],
        orElse: () => ParticipationType.attendanceOnly,
      ),
      certificateUrl: json['certificateUrl'] ?? '',
      proceedingsUrl: json['proceedingsUrl'],
      status: parseVerificationStatus(json['status']),
      rejectionReason: json['rejectionReason'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isInternational': isInternational,
      'isSpecialized': isSpecialized,
      'isPublished': isPublished,
      'participationType': participationType.name,
      'certificateUrl': certificateUrl,
      'proceedingsUrl': proceedingsUrl,
      'status': status.name,
      'rejectionReason': rejectionReason,
    };
  }

  ConferenceModel copyWith({
    String? id,
    String? title,
    bool? isInternational,
    bool? isSpecialized,
    bool? isPublished,
    ParticipationType? participationType,
    String? certificateUrl,
    String? proceedingsUrl,
    VerificationStatus? status,
    String? rejectionReason,
  }) {
    return ConferenceModel(
      id: id ?? this.id,
      title: title ?? this.title,
      isInternational: isInternational ?? this.isInternational,
      isSpecialized: isSpecialized ?? this.isSpecialized,
      isPublished: isPublished ?? this.isPublished,
      participationType: participationType ?? this.participationType,
      certificateUrl: certificateUrl ?? this.certificateUrl,
      proceedingsUrl: proceedingsUrl ?? this.proceedingsUrl,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }
}