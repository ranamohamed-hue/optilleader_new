import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:optialeader/feature/doctor/data/model/conferance_model.dart';
import 'package:optialeader/feature/doctor/data/model/courses_model.dart';
import 'package:optialeader/feature/doctor/data/model/exhibition_venue_model.dart';
import 'package:optialeader/feature/doctor/data/repo/activities/activity_repo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:optialeader/core/helper/file_halper.dart';

import 'package:optialeader/feature/doctor/data/model/verefication_status.dart';

class ActivitiesRepoImpl extends ActivitiesRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SupabaseClient _supabase = Supabase.instance.client;

  CollectionReference get _users => _firestore.collection('users');

  // ✅ دالة مساعدة لرفع الملفات على Supabase
  Future<String?> _uploadFile(File? file, String doctorUid, String folderName) async {
    if (file == null) return null;
    
    final fileType = FileHelper.getFileType(file);
    final extension = FileHelper.getExtension(file);
    final storagePath = '$folderName/$doctorUid/${DateTime.now().millisecondsSinceEpoch}.$extension';
    final fileBytes = await file.readAsBytes();
    
    await _supabase.storage.from('files').uploadBinary(storagePath, fileBytes, fileOptions: const FileOptions(upsert: true));
    return _supabase.storage.from('files').getPublicUrl(storagePath);
  }

  // ✅ دالة عامة لإضافة أي عنصر لـ Array في Firestore
  Future<Either<String, Unit>> _addItem(String doctorUid, String arrayPath, Map<String, dynamic> itemMap) async {
    try {
      await _users.doc(doctorUid).update({
        'scientific_work.$arrayPath': FieldValue.arrayUnion([itemMap])
      });
      return right(unit);
    } catch (e) {
      return left(e.toString());
    }
  }

  // ✅ دالة عامة لحذف أي عنصر من الـ Array
  Future<Either<String, Unit>> _deleteItem(String doctorUid, String arrayPath, String itemId, String? fileUrlField) async {
    try {
      final docRef = _users.doc(doctorUid);
      final docSnap = await docRef.get();
      if (!docSnap.exists) return left("User not found");

      final data = docSnap.data() as Map<String, dynamic>;
      final scientificWork = data['scientific_work'] as Map<String, dynamic>? ?? {};
      final list = scientificWork[arrayPath] as List<dynamic>? ?? [];

      Map<String, dynamic>? itemToDelete;
      for (var item in list) {
        if (item['id'] == itemId) {
          itemToDelete = item as Map<String, dynamic>;
          break;
        }
      }

      if (itemToDelete != null) {
        // مسح الملف من Supabase لو موجود
        if (fileUrlField != null && itemToDelete[fileUrlField] != null) {
          try {
            final uri = Uri.parse(itemToDelete[fileUrlField]);
            final filePath = uri.pathSegments.sublist(uri.pathSegments.indexOf('files') + 1).join('/');
            await _supabase.storage.from('files').remove([filePath]);
          } catch (_) {}
        }
        
        await docRef.update({
          'scientific_work.$arrayPath': FieldValue.arrayRemove([itemToDelete])
        });
      }
      return right(unit);
    } catch (e) {
      return left(e.toString());
    }
  }

  // ✅ دالة عامة لتحديث حالة أي عنصر (موافقة/رفض)
  Future<Either<String, Unit>> _updateStatus(String doctorUid, String arrayPath, String itemId, VerificationStatus status, {String? rejectionReason}) async {
    try {
      final docRef = _users.doc(doctorUid);
      final docSnap = await docRef.get();
      if (!docSnap.exists) return left("User not found");

      final data = docSnap.data() as Map<String, dynamic>;
      final scientificWork = data['scientific_work'] as Map<String, dynamic>? ?? {};
      final list = scientificWork[arrayPath] as List<dynamic>? ?? [];

      for (int i = 0; i < list.length; i++) {
        if (list[i]['id'] == itemId) {
          list[i]['status'] = status.name;
          if (rejectionReason != null) {
            list[i]['rejectionReason'] = rejectionReason;
          } else {
            list[i].remove('rejectionReason');
          }
          break;
        }
      }

      await docRef.update({'scientific_work.$arrayPath': list});
      return right(unit);
    } catch (e) {
      return left(e.toString());
    }
  }

  // ============================================================
  // ============== تنفيذ دوال المؤتمرات ========================
  // ============================================================
  @override
  Future<Either<String, Unit>> addConference(String doctorUid, ConferenceModel conference, {File? certFile}) async {
    try {
      String? url = await _uploadFile(certFile, doctorUid, 'conferences');
      ConferenceModel finalConf = conference.copyWith(certificateUrl: url ?? '');
      return _addItem(doctorUid, 'conferences', finalConf.toMap());
    } catch (e) {
      return left(e.toString());
    }
  }

  @override
  Future<Either<String, Unit>> deleteConference(String doctorUid, String confId) => _deleteItem(doctorUid, 'conferences', confId, 'certificateUrl');

  @override
  Future<Either<String, Unit>> updateConferenceStatus(String doctorUid, String confId, VerificationStatus status, {String? rejectionReason}) => _updateStatus(doctorUid, 'conferences', confId, status, rejectionReason: rejectionReason);

  // ============================================================
  // ============== تنفيذ دوال الدورات ==========================
  // ============================================================
  @override
  Future<Either<String, Unit>> addCourse(String doctorUid, CourseModel course, {File? certFile}) async {
    try {
      String? url = await _uploadFile(certFile, doctorUid, 'courses');
      CourseModel finalCourse = course.copyWith(certificateUrl: url ?? '');
      return _addItem(doctorUid, 'courses', finalCourse.toMap());
    } catch (e) {
      return left(e.toString());
    }
  }

  @override
  Future<Either<String, Unit>> deleteCourse(String doctorUid, String courseId) => _deleteItem(doctorUid, 'courses', courseId, 'certificateUrl');

  @override
  Future<Either<String, Unit>> updateCourseStatus(String doctorUid, String courseId, VerificationStatus status, {String? rejectionReason}) => _updateStatus(doctorUid, 'courses', courseId, status, rejectionReason: rejectionReason);

  // ============================================================
  // ============== تنفيذ دوال المعارض ==========================
  // ============================================================
  @override
  Future<Either<String, Unit>> addExhibition(String doctorUid, ArtExhibitionModel exhibition, {File? proofFile}) async {
    try {
      String? url = await _uploadFile(proofFile, doctorUid, 'exhibitions');
      ArtExhibitionModel finalExh = exhibition.copyWith(proofFileUrl: url ?? '');
      return _addItem(doctorUid, 'exhibitions', finalExh.toMap());
    } catch (e) {
      return left(e.toString());
    }
  }

  @override
  Future<Either<String, Unit>> deleteExhibition(String doctorUid, String exhId) => _deleteItem(doctorUid, 'exhibitions', exhId, 'proofFileUrl');

  @override
  Future<Either<String, Unit>> updateExhibitionStatus(String doctorUid, String exhId, VerificationStatus status, {String? rejectionReason}) => _updateStatus(doctorUid, 'exhibitions', exhId, status, rejectionReason: rejectionReason);

  // ============================================================
  // ============== تنفيذ دوال الأنشطة الأكاديمية ===============
  // ============================================================
  @override
  Future<Either<String, Unit>> saveAcademicActivities(String doctorUid, Map<String, dynamic> activitiesMap) async {
    try {
      await _users.doc(doctorUid).update({
        'scientific_work.academic_activities': activitiesMap
      });
      return right(unit);
    } catch (e) {
      return left(e.toString());
    }
  }

  @override
  Future<Either<String, Unit>> updateAcademicActivityCriterion(String doctorUid, String criterionKey, bool isApproved, {String? adminNote}) async {
    try {
      final docRef = _users.doc(doctorUid);
      final docSnap = await docRef.get();
      if (!docSnap.exists) return left("User not found");

      final data = docSnap.data() as Map<String, dynamic>;
      final scientificWork = data['scientific_work'] as Map<String, dynamic>? ?? {};
      final activities = scientificWork['academic_activities'] as Map<String, dynamic>? ?? {};

      // تحديث الـ 3 محاور
      for (var axis in ['teachingCriteria', 'researchCriteria', 'communityCriteria']) {
        final list = activities[axis] as List<dynamic>? ?? [];
        for (int i = 0; i < list.length; i++) {
          if (list[i]['key'] == criterionKey) {
            list[i]['proofStatus'] = isApproved ? 'approved' : 'rejected';
            if (adminNote != null) list[i]['adminNote'] = adminNote;
            break;
          }
        }
        activities[axis] = list;
      }

      await docRef.update({'scientific_work.academic_activities': activities});
      return right(unit);
    } catch (e) {
      return left(e.toString());
    }
  }
}