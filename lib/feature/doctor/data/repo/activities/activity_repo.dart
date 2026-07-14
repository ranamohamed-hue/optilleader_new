import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:optialeader/feature/doctor/data/model/conferance_model.dart';

import 'package:optialeader/feature/doctor/data/model/courses_model.dart';
import 'package:optialeader/feature/doctor/data/model/exhibition_venue_model.dart';
import 'package:optialeader/feature/doctor/data/model/verefication_status.dart';

abstract class ActivitiesRepo {
  // ==== المؤتمرات ====
  Future<Either<String, Unit>> addConference(String doctorUid, ConferenceModel conference, {File? certFile});
  Future<Either<String, Unit>> deleteConference(String doctorUid, String confId);
  Future<Either<String, Unit>> updateConferenceStatus(String doctorUid, String confId, VerificationStatus status, {String? rejectionReason});

  // ==== الدورات ====
  Future<Either<String, Unit>> addCourse(String doctorUid, CourseModel course, {File? certFile});
  Future<Either<String, Unit>> deleteCourse(String doctorUid, String courseId);
  Future<Either<String, Unit>> updateCourseStatus(String doctorUid, String courseId, VerificationStatus status, {String? rejectionReason});

  // ==== المعارض ====
  Future<Either<String, Unit>> addExhibition(String doctorUid, ArtExhibitionModel exhibition, {File? proofFile});
  Future<Either<String, Unit>> deleteExhibition(String doctorUid, String exhId);
  Future<Either<String, Unit>> updateExhibitionStatus(String doctorUid, String exhId, VerificationStatus status, {String? rejectionReason});

  // ==== الأنشطة الأكاديمية (الـ 20 درجة) ====
  Future<Either<String, Unit>> saveAcademicActivities(String doctorUid, Map<String, dynamic> activitiesMap);
  Future<Either<String, Unit>> updateAcademicActivityCriterion(String doctorUid, String criterionKey, bool isApproved, {String? adminNote});
}