import 'package:cloud_firestore/cloud_firestore.dart';

class EmployeeNominationRequestModel {
  String? id;

  // ============================================================
  // بيانات الموظف
  // ============================================================

  final String employeeId;
  final String employeeName;
  final String? employeeImageUrl;
  final String applicantType;
  final String? currentJob;
  final String? sectorName;
  final String? departmentName;

  // ============================================================
  // بيانات الإعلان
  // ============================================================

  final String announcementId;
  final String announcementTitle;
  final String targetRole;

  // ============================================================
  // رؤية الموظف
  // ============================================================

  final String? visionStatement;

  // ============================================================
  // المحكم
  // ============================================================

  final String? evaluatorId;
  final String? evaluatorName;

  // ============================================================
  // بيانات المقابلة
  // ============================================================

  final DateTime? interviewDate;
  final String? interviewLocation;
  final String? interviewTime;

  // ============================================================
  // تقييم المحكم
  // ============================================================

  final double? evaluatorPoints;
  final String? evaluatorNotes;
  final Map<String, dynamic>? interviewEvaluation;

  // ============================================================
  // الحالة
  // ============================================================

  String status;
  String? rejectionReason;
  String? adminNotes;

  // ============================================================
  // التواريخ
  // ============================================================

  final DateTime createdAt;
  DateTime? updatedAt;

  // ============================================================
  // الحالات
  // ============================================================

  static const String statusPendingAdmin = 'pending_admin';

  static const String statusRejectedByAdmin = 'rejected_by_admin';

  static const String statusPendingEvaluator = 'pending_evaluator';

  static const String statusEvaluated = 'evaluated';

  static const String statusFinalApproved = 'final_approved';

  static const String statusFinalRejected = 'final_rejected';

  static const String statusFinalApprovedPendingAnnouncement =
      'final_approved_pending_announcement';

  // ============================================================
  // Constructor
  // ============================================================

  EmployeeNominationRequestModel({
    this.id,

    // Employee
    required this.employeeId,
    required this.employeeName,
    this.employeeImageUrl,
    required this.applicantType,
    this.currentJob,
    this.sectorName,
    this.departmentName,

    // Announcement
    required this.announcementId,
    required this.announcementTitle,
    required this.targetRole,

    // Vision
    this.visionStatement,

    // Evaluator
    this.evaluatorId,
    this.evaluatorName,

    // Interview
    this.interviewDate,
    this.interviewLocation,
    this.interviewTime,

    // Evaluation
    this.evaluatorPoints,
    this.evaluatorNotes,
    this.interviewEvaluation,

    // Status
    required this.status,
    this.rejectionReason,
    this.adminNotes,

    // Dates
    required this.createdAt,
    this.updatedAt,
  });

  // ============================================================
  // From Firestore
  // ============================================================

  factory EmployeeNominationRequestModel.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;

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
      if (value == null) return null;

      if (value is num) {
        return value.toDouble();
      }

      if (value is String) {
        return double.tryParse(value);
      }

      return null;
    }

    return EmployeeNominationRequestModel(
      id: documentId,

      // ========================================================
      // Employee
      // ========================================================

      employeeId: map['employeeId'] ?? '',
      employeeName: map['employeeName'] ?? '',
      employeeImageUrl: map['employeeImageUrl'],

      // مهم للفصل بين الموظف والدكتور
      applicantType: map['applicantType'] ?? 'employee',

      currentJob: map['currentJob'],
      sectorName: map['sectorName'],
      departmentName: map['departmentName'],

      // ========================================================
      // Announcement
      // ========================================================

      announcementId: map['announcementId'] ?? '',
      announcementTitle: map['announcementTitle'] ?? '',
      targetRole: map['targetRole'] ?? '',

      // ========================================================
      // Vision
      // ========================================================

      visionStatement: map['visionStatement'],

      // ========================================================
      // Evaluator
      // ========================================================

      evaluatorId: map['evaluatorId'],
      evaluatorName: map['evaluatorName'],

      // ========================================================
      // Interview
      // ========================================================

      interviewDate: parseDate(map['interviewDate']),
      interviewLocation: map['interviewLocation'],
      interviewTime: map['interviewTime'],

      // ========================================================
      // Evaluation
      // ========================================================

      evaluatorPoints: parseDouble(
        map['evaluatorPoints'],
      ),

      evaluatorNotes: map['evaluatorNotes'],

      interviewEvaluation:
          map['interviewEvaluation'] is Map
              ? Map<String, dynamic>.from(
                  map['interviewEvaluation'] as Map,
                )
              : null,

      // ========================================================
      // Status
      // ========================================================

      status: map['status'] ?? statusPendingAdmin,

      rejectionReason: map['rejectionReason'],

      adminNotes: map['adminNotes'],

      // ========================================================
      // Dates
      // ========================================================

      createdAt:
          parseDate(map['createdAt']) ?? DateTime.now(),

      updatedAt: parseDate(map['updatedAt']),
    );
  }

  // ============================================================
  // To Firestore
  // ============================================================

  Map<String, dynamic> toMap() {
    return {
      // ========================================================
      // Employee
      // ========================================================

      'employeeId': employeeId,
      'employeeName': employeeName,
      'employeeImageUrl': employeeImageUrl,

      // مهم جدًا
      'applicantType': applicantType,

      'currentJob': currentJob,
      'sectorName': sectorName,
      'departmentName': departmentName,

      // ========================================================
      // Announcement
      // ========================================================

      'announcementId': announcementId,
      'announcementTitle': announcementTitle,
      'targetRole': targetRole,

      // ========================================================
      // Vision
      // ========================================================

      'visionStatement': visionStatement,

      // ========================================================
      // Evaluator
      // ========================================================

      'evaluatorId': evaluatorId,
      'evaluatorName': evaluatorName,

      // ========================================================
      // Interview
      // ========================================================

      'interviewDate': interviewDate != null
          ? Timestamp.fromDate(interviewDate!)
          : null,

      'interviewLocation': interviewLocation,
      'interviewTime': interviewTime,

      // ========================================================
      // Evaluation
      // ========================================================

      'evaluatorPoints': evaluatorPoints,
      'evaluatorNotes': evaluatorNotes,
      'interviewEvaluation': interviewEvaluation,

      // ========================================================
      // Status
      // ========================================================

      'status': status,
      'rejectionReason': rejectionReason,
      'adminNotes': adminNotes,

      // ========================================================
      // Dates
      // ========================================================

      'createdAt': Timestamp.fromDate(createdAt),

      'updatedAt': updatedAt != null
          ? Timestamp.fromDate(updatedAt!)
          : null,
    };
  }

  // ============================================================
  // Copy With
  // ============================================================

  EmployeeNominationRequestModel copyWith({
    String? id,

    // Employee
    String? employeeId,
    String? employeeName,
    String? employeeImageUrl,
    String? applicantType,
    String? currentJob,
    String? sectorName,
    String? departmentName,

    // Announcement
    String? announcementId,
    String? announcementTitle,
    String? targetRole,

    // Vision
    String? visionStatement,

    // Evaluator
    String? evaluatorId,
    String? evaluatorName,

    // Interview
    DateTime? interviewDate,
    String? interviewLocation,
    String? interviewTime,

    // Evaluation
    double? evaluatorPoints,
    String? evaluatorNotes,
    Map<String, dynamic>? interviewEvaluation,

    // Status
    String? status,
    String? rejectionReason,
    String? adminNotes,

    // Dates
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EmployeeNominationRequestModel(
      id: id ?? this.id,

      // ========================================================
      // Employee
      // ========================================================

      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      employeeImageUrl:
          employeeImageUrl ?? this.employeeImageUrl,

      applicantType:
          applicantType ?? this.applicantType,

      currentJob: currentJob ?? this.currentJob,
      sectorName: sectorName ?? this.sectorName,
      departmentName:
          departmentName ?? this.departmentName,

      // ========================================================
      // Announcement
      // ========================================================

      announcementId:
          announcementId ?? this.announcementId,

      announcementTitle:
          announcementTitle ?? this.announcementTitle,

      targetRole:
          targetRole ?? this.targetRole,

      // ========================================================
      // Vision
      // ========================================================

      visionStatement:
          visionStatement ?? this.visionStatement,

      // ========================================================
      // Evaluator
      // ========================================================

      evaluatorId:
          evaluatorId ?? this.evaluatorId,

      evaluatorName:
          evaluatorName ?? this.evaluatorName,

      // ========================================================
      // Interview
      // ========================================================

      interviewDate:
          interviewDate ?? this.interviewDate,

      interviewLocation:
          interviewLocation ?? this.interviewLocation,

      interviewTime:
          interviewTime ?? this.interviewTime,

      // ========================================================
      // Evaluation
      // ========================================================

      evaluatorPoints:
          evaluatorPoints ?? this.evaluatorPoints,

      evaluatorNotes:
          evaluatorNotes ?? this.evaluatorNotes,

      interviewEvaluation:
          interviewEvaluation ??
              this.interviewEvaluation,

      // ========================================================
      // Status
      // ========================================================

      status: status ?? this.status,

      rejectionReason:
          rejectionReason ?? this.rejectionReason,

      adminNotes:
          adminNotes ?? this.adminNotes,

      // ========================================================
      // Dates
      // ========================================================

      createdAt:
          createdAt ?? this.createdAt,

      updatedAt:
          updatedAt ?? this.updatedAt,
    );
  }
}