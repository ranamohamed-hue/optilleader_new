import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:optialeader/feature/admin/data/model/nomination_score_model.dart';

class NominationRequestModel {
  String? id;
  final String doctorId;
  final String doctorName;
  final String? doctorImageUrl;
  final String announcementId;
  final String targetRole;

  // College & Department Info
  final String? collegeId;
  final String? collegeName;
  final String? departmentId;
  final String? departmentName;

  // ✅ الدرجات الشاملة (الإنجازات + المقابلة)
  final NominationScoreModel? scores;

  // Files
  final String? declarationFileUrl;

  // Evaluator Data
  final String? evaluatorId;
  final String? evaluatorName;
  final DateTime? interviewDate;
  final String? interviewLocation;
  final String? interviewTime;
  final double? evaluatorPoints;
  final String? evaluatorNotes;

  // Interview Evaluation
  final Map<String, dynamic>? interviewEvaluation;

  // Status & Rejection
  String status;
  String? rejectionReason;
  String? adminNotes;

  // Timestamps
  final DateTime createdAt;
  DateTime? updatedAt;

  // Constants
  static const String statusPendingAdmin = 'pending_admin';
  static const String statusRejectedByAdmin = 'rejected_by_admin';
  static const String statusPendingEvaluator = 'pending_evaluator';
  static const String statusEvaluated = 'evaluated';
  static const String statusFinalApproved = 'final_approved';
  static const String statusFinalRejected = 'final_rejected';
  static const String statusFinalApprovedPendingAnnouncement =
      'final_approved_pending_announcement';

  NominationRequestModel({
    this.id,
    required this.doctorId,
    required this.doctorName,
    this.doctorImageUrl,
    required this.announcementId,
    required this.targetRole,
    this.collegeId,
    this.collegeName,
    this.departmentId,
    this.departmentName,
    this.scores,
    this.declarationFileUrl,
    this.evaluatorId,
    this.evaluatorName,
    this.interviewDate,
    this.interviewLocation,
    this.interviewTime,
    this.evaluatorPoints,
    this.evaluatorNotes,
    this.interviewEvaluation,
    required this.status,
    this.rejectionReason,
    this.adminNotes,
    required this.createdAt,
    this.updatedAt,
  });

  factory NominationRequestModel.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (_) {
          return null;
        }
      }
      return null;
    }

    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    return NominationRequestModel(
      id: documentId,
      doctorId: map['doctorId'] ?? '',
      doctorName: map['doctorName'] ?? '',
      doctorImageUrl: map['doctorImageUrl'],
      announcementId: map['announcementId'] ?? '',
      targetRole: map['targetRole'] ?? '',
      collegeId: map['collegeId'],
      collegeName: map['collegeName'],
      departmentId: map['departmentId'],
      departmentName: map['departmentName'],
      // ✅ تحميل موديل الدرجات
      scores: map['scores'] is Map
          ? NominationScoreModel.fromMap(map['scores'] as Map<String, dynamic>)
          : null,
      declarationFileUrl: map['declarationFileUrl'],
      evaluatorId: map['evaluatorId'],
      evaluatorName: map['evaluatorName'],
      interviewDate: parseDate(map['interviewDate']),
      interviewLocation: map['interviewLocation'],
      interviewTime: map['interviewTime'],
      evaluatorPoints: parseDouble(map['evaluatorPoints']),
      evaluatorNotes: map['evaluatorNotes'],
      interviewEvaluation: map['interviewEvaluation'] is Map
          ? Map<String, dynamic>.from(map['interviewEvaluation'] as Map)
          : null,
      status: map['status'] ?? statusPendingAdmin,
      rejectionReason: map['rejectionReason'],
      adminNotes: map['adminNotes'],
      createdAt: parseDate(map['createdAt']) ?? DateTime.now(),
      updatedAt: parseDate(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'doctorId': doctorId,
      'doctorName': doctorName,
      'doctorImageUrl': doctorImageUrl,
      'announcementId': announcementId,
      'targetRole': targetRole,
      'collegeId': collegeId,
      'collegeName': collegeName,
      'departmentId': departmentId,
      'departmentName': departmentName,
      // ✅ حفظ موديل الدرجات
      'scores': scores?.toMap(),
      'declarationFileUrl': declarationFileUrl,
      'evaluatorId': evaluatorId,
      'evaluatorName': evaluatorName,
      'interviewDate': interviewDate != null
          ? Timestamp.fromDate(interviewDate!)
          : null,
      'interviewLocation': interviewLocation,
      'interviewTime': interviewTime,
      'evaluatorPoints': evaluatorPoints,
      'evaluatorNotes': evaluatorNotes,
      'interviewEvaluation': interviewEvaluation,
      'status': status,
      'rejectionReason': rejectionReason,
      'adminNotes': adminNotes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  NominationRequestModel copyWith({
    String? id,
    String? doctorId,
    String? doctorName,
    String? doctorImageUrl,
    String? announcementId,
    String? targetRole,
    String? collegeId,
    String? collegeName,
    String? departmentId,
    String? departmentName,
    NominationScoreModel? scores,
    String? declarationFileUrl,
    String? evaluatorId,
    String? evaluatorName,
    DateTime? interviewDate,
    String? interviewLocation,
    String? interviewTime,
    double? evaluatorPoints,
    String? evaluatorNotes,
    Map<String, dynamic>? interviewEvaluation,
    String? status,
    String? rejectionReason,
    String? adminNotes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NominationRequestModel(
      id: id ?? this.id,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      doctorImageUrl: doctorImageUrl ?? this.doctorImageUrl,
      announcementId: announcementId ?? this.announcementId,
      targetRole: targetRole ?? this.targetRole,
      collegeId: collegeId ?? this.collegeId,
      collegeName: collegeName ?? this.collegeName,
      departmentId: departmentId ?? this.departmentId,
      departmentName: departmentName ?? this.departmentName,
      // ✅ نسخ موديل الدرجات
      scores: scores ?? this.scores,
      declarationFileUrl: declarationFileUrl ?? this.declarationFileUrl,
      evaluatorId: evaluatorId ?? this.evaluatorId,
      evaluatorName: evaluatorName ?? this.evaluatorName,
      interviewDate: interviewDate ?? this.interviewDate,
      interviewLocation: interviewLocation ?? this.interviewLocation,
      interviewTime: interviewTime ?? this.interviewTime,
      evaluatorPoints: evaluatorPoints ?? this.evaluatorPoints,
      evaluatorNotes: evaluatorNotes ?? this.evaluatorNotes,
      interviewEvaluation: interviewEvaluation ?? this.interviewEvaluation,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      adminNotes: adminNotes ?? this.adminNotes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}