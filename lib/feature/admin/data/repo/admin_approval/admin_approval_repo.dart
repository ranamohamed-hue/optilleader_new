import 'package:dartz/dartz.dart';
import 'package:optialeader/feature/database_admin/data/models/doctor_profile_model.dart';

abstract class AdminApprovalRepo {
  /// جلب الدكاترة اللي عندهم طلبات معلقة
  Future<Either<String, List<DoctorProfileModel>>> getPendingRequests();

  // ====== الأبحاث ======
  Future<Either<String, Unit>> approveResearch(String doctorUid, String paperId, String paperTitle);
  Future<Either<String, Unit>> rejectResearch(String doctorUid, String paperId, String paperTitle, String reason);

  // ====== المؤتمرات ======
  Future<Either<String, Unit>> approveConference(String doctorUid, String confId, String confTitle);
  Future<Either<String, Unit>> rejectConference(String doctorUid, String confId, String confTitle, String reason);

  // ====== المعارض ======
  Future<Either<String, Unit>> approveExhibition(String doctorUid, String exhId, String exhTitle);
  Future<Either<String, Unit>> rejectExhibition(String doctorUid, String exhId, String exhTitle, String reason);

  // ====== الدورات ======
  Future<Either<String, Unit>> approveCourse(String doctorUid, String courseId, String courseTitle);
  Future<Either<String, Unit>> rejectCourse(String doctorUid, String courseId, String courseTitle, String reason);

  // ====== الأنشطة الأكاديمية (تحديث بند معين) ======
  Future<Either<String, Unit>> updateActivityCriterionStatus({
    required String doctorUid,
    required String criterionKey,
    required bool isApproved,
    String? adminNote,
  });
}