import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:optialeader/feature/employee/data/models/employee_course_model.dart';
import 'package:path/path.dart' as p;


class EmployeeCoursesRepo {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  EmployeeCoursesRepo({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  // ✅ جلب الدورات كـ Stream (للتحديث اللحظي)
  Stream<QuerySnapshot> getCoursesStream(String uid) {
    return _firestore
        .collection('employees')
        .doc(uid)
        .collection('courses')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // ✅ إضافة دورة جديدة مع رفع الملف
  Future<void> addCourse({
    required String uid,
    required EmployeeCourseModel course,
    required File certificateFile,
  }) async {
    try {
      // 1. تحديد نوع الملف ومساره
      final String extension = p.extension(certificateFile.path).toLowerCase();
      final bool isPdf = extension == '.pdf';
      
      // ✅ المسار حسب نوع الملف (images/ أو files/)
      final String folderPath = isPdf 
          ? 'files/employees/$uid/courses' 
          : 'images/employees/$uid/courses';
      
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}$extension';
      final ref = _storage.ref('$folderPath/$fileName');

      // 2. رفع الملف
      await ref.putFile(certificateFile);
      final String fileUrl = await ref.getDownloadURL();

      // 3. تحديث الموديل بالرابط
      course.certificateFileUrl = fileUrl;
      course.certificateFileType = isPdf ? 'pdf' : 'image';

      // 4. حفظ البيانات في فايرستور
      await _firestore
          .collection('employees')
          .doc(uid)
          .collection('courses')
          .add(course.toMap());
    } catch (e) {
      rethrow;
    }
  }

  // ✅ حذف دورة مع حذف الملف من الـ Storage
  Future<void> deleteCourse({
    required String uid,
    required EmployeeCourseModel course,
  }) async {
    try {
      // 1. حذف الملف من الـ Storage لو موجود
      if (course.certificateFileUrl != null && course.certificateFileUrl!.isNotEmpty) {
        try {
          await _storage.refFromURL(course.certificateFileUrl!).delete();
        } catch (_) {
          // لو الملف مش موجود نتجاهل الخطأ ونكمل حذف الداتا
        }
      }

      // 2. حذف الداتا من فايرستور
      await _firestore
          .collection('employees')
          .doc(uid)
          .collection('courses')
          .doc(course.id)
          .delete();
    } catch (e) {
      rethrow;
    }
  }
}