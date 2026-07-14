import 'package:dartz/dartz.dart';
import 'package:optialeader/feature/admin/data/model/announcement_model.dart';

abstract class IAnnouncementRepository {
  Future<Either<String, String>> addAnnouncement(
    AnnouncementModel announcement,
  );

  Stream<List<AnnouncementModel>> getAnnouncements();

  Future<Either<String, Unit>> updateAnnouncement(
    AnnouncementModel announcement,
  );

  Future<Either<String, Unit>> deleteAnnouncement(String id, String? imageUrl);

  Future<Either<String, String>> uploadAnnouncementImage(String filePath);

  Future<void> deleteAnnouncementImage(String imageUrl);

  // ✅✅✅ الدالة الجديدة اللي كانت ناقصة (لازم تضاف هنا)
  Future<Either<String, Unit>> autoCloseExpiredAnnouncements(
    List<AnnouncementModel> announcements,
  );
}