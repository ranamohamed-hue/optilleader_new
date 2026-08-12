import 'package:cloud_firestore/cloud_firestore.dart';

class JobHistory {
  final String jobTitleAr;
  final String jobTitleEn;

  final DateTime startDate;
  final DateTime? endDate;

  final String placeAr;
  final String placeEn;

  JobHistory({
    required this.jobTitleAr,
    required this.jobTitleEn,
    required this.startDate,
    this.endDate,
    required this.placeAr,
    required this.placeEn,
  });

  factory JobHistory.fromJson(Map<String, dynamic> json) {
    DateTime parseStartDate(dynamic value) {
      if (value == null) {
        return DateTime.now();
      }

      if (value is Timestamp) {
        return value.toDate();
      }

      if (value is DateTime) {
        return value;
      }

      if (value is String) {
        return DateTime.tryParse(value) ?? DateTime.now();
      }

      return DateTime.now();
    }

    DateTime? parseEndDate(dynamic value) {
      if (value == null) {
        return null;
      }

      if (value is Timestamp) {
        return value.toDate();
      }

      if (value is DateTime) {
        return value;
      }

      if (value is String) {
        return DateTime.tryParse(value);
      }

      return null;
    }

    return JobHistory(
      jobTitleAr: json['job_title_ar'] ?? '',
      jobTitleEn: json['job_title_en'] ?? '',

      startDate: parseStartDate(
        json['start_date'],
      ),

      endDate: parseEndDate(
        json['end_date'],
      ),

      placeAr: json['place_ar'] ?? '',
      placeEn: json['place_en'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'job_title_ar': jobTitleAr,
      'job_title_en': jobTitleEn,

      'start_date': Timestamp.fromDate(startDate),

      'end_date': endDate != null
          ? Timestamp.fromDate(endDate!)
          : null,

      'place_ar': placeAr,
      'place_en': placeEn,
    };
  }

  Duration get duration {
    final end = endDate ?? DateTime.now();

    return end.difference(startDate);
  }
}