import 'package:dartz/dartz.dart';
import 'package:optialeader/feature/database_admin/data/models/judge_profile_model.dart';

abstract class JudgeRepo {
  Future<Either<String, Unit>> saveJudgeData(JudgeProfileModel judge);

  Future<Either<String, JudgeProfileModel?>> getJudgeProfile(String uid);
  Stream<List<JudgeProfileModel>> watchAllJudges();

  Future<Either<String, Unit>> updateJudgeStatus(String uid, bool isActive);

  Future<Either<String, Unit>> updateJudgeImage(String uid, String imageUrl);
  Future<Either<String, String>> uploadImageToSupabase(String uid, String filePath);

  Future<Either<String, Unit>> deleteJudgeAccount(String uid);
    // ✅ دالة جلب عدد المتقدمين لإعلان معين
  Future<Either<String, int>> getAnnouncementApplicantsCount(String announcementId);
}
