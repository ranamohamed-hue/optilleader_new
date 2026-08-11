import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:optialeader/feature/employee/data/models/employee_course_model.dart';

class EmployeeCoursesRepo {
  final FirebaseFirestore _firestore;

  EmployeeCoursesRepo({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<QuerySnapshot> getCoursesStream(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('courses')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<Either<String, Unit>> addCourse({
    required String uid,
    required EmployeeCourseModel course,
    required File certificateFile,
  }) async {
    try {
      final String extension = p.extension(certificateFile.path).toLowerCase();
      final bool isPdf = extension == '.pdf';

      // ✅ معالجة ذكية: ضغط الصور فقط، وقراءة الـ PDF كما هو
      Uint8List? fileBytes;
      if (isPdf) {
        fileBytes = await certificateFile.readAsBytes();
      } else {
        fileBytes = await FlutterImageCompress.compressWithFile(
          certificateFile.absolute.path,
          minWidth: 1200,
          minHeight: 1200,
          quality: 80,
        );
      }

      if (fileBytes == null) {
        return left("فشل معالجة الملف");
      }

      // تحديد مسار التخزين
      final String folderPath = 'employees/$uid/courses';
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}$extension';
      final String storagePath = '$folderPath/$fileName';

      // رفع الملف على Supabase
      await Supabase.instance.client.storage
          .from('images') // تأكد أن الـ Bucket اسمه 'images'
          .uploadBinary(
            storagePath,
            fileBytes,
            fileOptions: const FileOptions(upsert: true),
          );

      final String fileUrl = Supabase.instance.client.storage
          .from('images')
          .getPublicUrl(storagePath);

      // تحديث الموديل وحفظه
      course.certificateFileUrl = fileUrl;
      course.certificateFileType = isPdf ? 'pdf' : 'image';

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('courses')
          .add(course.toMap());

      return right(unit);
    } catch (e) {
      return left("فشل إضافة الدورة: ${e.toString()}");
    }
  }

  Future<Either<String, Unit>> deleteCourse({
    required String uid,
    required EmployeeCourseModel course,
  }) async {
    try {
      if (course.certificateFileUrl != null && course.certificateFileUrl!.isNotEmpty) {
        try {
          final uri = Uri.parse(course.certificateFileUrl!);
          final pathSegments = uri.pathSegments;
          if (pathSegments.length > 2) {
            final filePath = pathSegments.sublist(2).join('/');
            await Supabase.instance.client.storage.from('images').remove([filePath]);
          }
        } catch (_) {}
      }

      await _firestore.collection('users').doc(uid).collection('courses').doc(course.id).delete();
      return right(unit);
    } catch (e) {
      return left("فشل حذف الدورة: ${e.toString()}");
    }
  }
}