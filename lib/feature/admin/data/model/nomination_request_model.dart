import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:optialeader/feature/admin/data/model/nomination_score_model.dart';

class NominationRequestModel {
  String? id;

  final String doctorId;
  final String doctorName;
  final String? doctorImageUrl;

  final String announcementId;
  final String targetRole;

  // ==========================================================
  // College & Department
  // ==========================================================

  final String? collegeId;
  final String? collegeName;

  final String? departmentId;
  final String? departmentName;

  // ==========================================================
  // Scores
  // ==========================================================

  final NominationScoreModel? scores;

  // ==========================================================
  // Nomination Documents
  // ==========================================================

  /// ملف الإقرار القديم - نحافظ عليه للتوافق
  final String? declarationFileUrl;

  /// شهادة السلامة الصحية
  final String? healthCertificateUrl;

  /// خطة التطوير المقترحة
  final String? developmentPlanUrl;

  /// مستندات أخرى اختيارية
  final String? otherDocumentsUrl;

  // ==========================================================
  // Evaluator Data
  // ==========================================================

  final String? evaluatorId;
  final String? evaluatorName;

  final DateTime? interviewDate;
  final String? interviewLocation;
  final String? interviewTime;

  final double? evaluatorPoints;
  final String? evaluatorNotes;

  // ==========================================================
  // Interview Evaluation
  // ==========================================================

  final Map<String, dynamic>? interviewEvaluation;

  // ==========================================================
  // Status & Rejection
  // ==========================================================

  String status;
  String? rejectionReason;
  String? adminNotes;

  // ==========================================================
  // Timestamps
  // ==========================================================

  final DateTime createdAt;
  DateTime? updatedAt;

  // ==========================================================
  // Status Constants
  // ==========================================================

  static const String statusPendingAdmin =
      'pending_admin';

  static const String statusRejectedByAdmin =
      'rejected_by_admin';

  static const String statusPendingEvaluator =
      'pending_evaluator';

  static const String statusEvaluated =
      'evaluated';

  static const String statusFinalApproved =
      'final_approved';

  static const String statusFinalRejected =
      'final_rejected';

  static const String statusFinalApprovedPendingAnnouncement =
      'final_approved_pending_announcement';

  // ==========================================================
  // Constructor
  // ==========================================================

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

    // الملفات
    this.declarationFileUrl,
    this.healthCertificateUrl,
    this.developmentPlanUrl,
    this.otherDocumentsUrl,

    // المحكم
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

  // ==========================================================
  // From Map
  // ==========================================================

  factory NominationRequestModel.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    DateTime? parseDate(dynamic value) {
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
        try {
          return DateTime.parse(value);
        } catch (_) {
          return null;
        }
      }

      return null;
    }

    double? parseDouble(dynamic value) {
      if (value == null) {
        return null;
      }

      if (value is num) {
        return value.toDouble();
      }

      if (value is String) {
        return double.tryParse(value);
      }

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

      // ======================================================
      // Scores
      // ======================================================

      scores: map['scores'] is Map
          ? NominationScoreModel.fromMap(
              Map<String, dynamic>.from(
                map['scores'] as Map,
              ),
            )
          : null,

      // ======================================================
      // Files
      // ======================================================

      declarationFileUrl:
          map['declarationFileUrl'],

      healthCertificateUrl:
          map['healthCertificateUrl'],

      developmentPlanUrl:
          map['developmentPlanUrl'],

      otherDocumentsUrl:
          map['otherDocumentsUrl'],

      // ======================================================
      // Evaluator
      // ======================================================

      evaluatorId:
          map['evaluatorId'],

      evaluatorName:
          map['evaluatorName'],

      interviewDate:
          parseDate(map['interviewDate']),

      interviewLocation:
          map['interviewLocation'],

      interviewTime:
          map['interviewTime'],

      evaluatorPoints:
          parseDouble(map['evaluatorPoints']),

      evaluatorNotes:
          map['evaluatorNotes'],

      // ======================================================
      // Interview Evaluation
      // ======================================================

      interviewEvaluation:
          map['interviewEvaluation'] is Map
              ? Map<String, dynamic>.from(
                  map['interviewEvaluation'] as Map,
                )
              : null,

      // ======================================================
      // Status
      // ======================================================

      status:
          map['status'] ??
          statusPendingAdmin,

      rejectionReason:
          map['rejectionReason'],

      adminNotes:
          map['adminNotes'],

      // ======================================================
      // Dates
      // ======================================================

      createdAt:
          parseDate(map['createdAt']) ??
          DateTime.now(),

      updatedAt:
          parseDate(map['updatedAt']),
    );
  }

  // ==========================================================
  // To Map
  // ==========================================================

  Map<String, dynamic> toMap() {
    return {
      // ======================================================
      // Doctor
      // ======================================================

      'doctorId': doctorId,
      'doctorName': doctorName,
      'doctorImageUrl': doctorImageUrl,

      // ======================================================
      // Announcement
      // ======================================================

      'announcementId': announcementId,
      'targetRole': targetRole,

      // ======================================================
      // College
      // ======================================================

      'collegeId': collegeId,
      'collegeName': collegeName,

      // ======================================================
      // Department
      // ======================================================

      'departmentId': departmentId,
      'departmentName': departmentName,

      // ======================================================
      // Scores
      // ======================================================

      'scores': scores?.toMap(),

      // ======================================================
      // Documents
      // ======================================================

      'declarationFileUrl':
          declarationFileUrl,

      'healthCertificateUrl':
          healthCertificateUrl,

      'developmentPlanUrl':
          developmentPlanUrl,

      'otherDocumentsUrl':
          otherDocumentsUrl,

      // ======================================================
      // Evaluator
      // ======================================================

      'evaluatorId':
          evaluatorId,

      'evaluatorName':
          evaluatorName,

      'interviewDate':
          interviewDate != null
              ? Timestamp.fromDate(interviewDate!)
              : null,

      'interviewLocation':
          interviewLocation,

      'interviewTime':
          interviewTime,

      'evaluatorPoints':
          evaluatorPoints,

      'evaluatorNotes':
          evaluatorNotes,

      // ======================================================
      // Interview
      // ======================================================

      'interviewEvaluation':
          interviewEvaluation,

      // ======================================================
      // Status
      // ======================================================

      'status':
          status,

      'rejectionReason':
          rejectionReason,

      'adminNotes':
          adminNotes,

      // ======================================================
      // Dates
      // ======================================================

      'createdAt':
          Timestamp.fromDate(createdAt),

      'updatedAt':
          updatedAt != null
              ? Timestamp.fromDate(updatedAt!)
              : null,
    };
  }

  // ==========================================================
  // Copy With
  // ==========================================================

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

    // الملفات
    String? declarationFileUrl,
    String? healthCertificateUrl,
    String? developmentPlanUrl,
    String? otherDocumentsUrl,

    // المحكم
    String? evaluatorId,
    String? evaluatorName,

    DateTime? interviewDate,
    String? interviewLocation,
    String? interviewTime,

    double? evaluatorPoints,
    String? evaluatorNotes,

    // التقييم
    Map<String, dynamic>? interviewEvaluation,

    // الحالة
    String? status,
    String? rejectionReason,
    String? adminNotes,

    // التواريخ
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NominationRequestModel(
      id: id ?? this.id,

      doctorId:
          doctorId ?? this.doctorId,

      doctorName:
          doctorName ?? this.doctorName,

      doctorImageUrl:
          doctorImageUrl ?? this.doctorImageUrl,

      announcementId:
          announcementId ?? this.announcementId,

      targetRole:
          targetRole ?? this.targetRole,

      collegeId:
          collegeId ?? this.collegeId,

      collegeName:
          collegeName ?? this.collegeName,

      departmentId:
          departmentId ?? this.departmentId,

      departmentName:
          departmentName ?? this.departmentName,

      scores:
          scores ?? this.scores,

      // ======================================================
      // الملفات
      // ======================================================

      declarationFileUrl:
          declarationFileUrl ??
          this.declarationFileUrl,

      healthCertificateUrl:
          healthCertificateUrl ??
          this.healthCertificateUrl,

      developmentPlanUrl:
          developmentPlanUrl ??
          this.developmentPlanUrl,

      otherDocumentsUrl:
          otherDocumentsUrl ??
          this.otherDocumentsUrl,

      // ======================================================
      // المحكم
      // ======================================================

      evaluatorId:
          evaluatorId ??
          this.evaluatorId,

      evaluatorName:
          evaluatorName ??
          this.evaluatorName,

      interviewDate:
          interviewDate ??
          this.interviewDate,

      interviewLocation:
          interviewLocation ??
          this.interviewLocation,

      interviewTime:
          interviewTime ??
          this.interviewTime,

      evaluatorPoints:
          evaluatorPoints ??
          this.evaluatorPoints,

      evaluatorNotes:
          evaluatorNotes ??
          this.evaluatorNotes,

      // ======================================================
      // Interview
      // ======================================================

      interviewEvaluation:
          interviewEvaluation ??
          this.interviewEvaluation,

      // ======================================================
      // Status
      // ======================================================

      status:
          status ??
          this.status,

      rejectionReason:
          rejectionReason ??
          this.rejectionReason,

      adminNotes:
          adminNotes ??
          this.adminNotes,

      // ======================================================
      // Dates
      // ======================================================

      createdAt:
          createdAt ??
          this.createdAt,

      updatedAt:
          updatedAt ??
          this.updatedAt,
    );
  }
}