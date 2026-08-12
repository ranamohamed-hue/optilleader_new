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

  EmployeeCoursesRepo({
    FirebaseFirestore? firestore,
  }) : _firestore =
            firestore ?? FirebaseFirestore.instance;

  // ============================================================
  // Courses Stream
  // ============================================================

  Stream<QuerySnapshot<Map<String, dynamic>>> getCoursesStream(
    String uid,
  ) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('courses')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // ============================================================
  // Add Course
  // ============================================================

  Future<Either<String, Unit>> addCourse({
    required String uid,
    required EmployeeCourseModel course,
    required File certificateFile,
  }) async {
    try {
      final extension =
          p.extension(certificateFile.path).toLowerCase();

      final bool isPdf = extension == '.pdf';

      Uint8List? fileBytes;

      // ========================================================
      // PDF
      // ========================================================

      if (isPdf) {
        fileBytes = await certificateFile.readAsBytes();
      }

      // ========================================================
      // Images
      // ========================================================

      else {
        fileBytes =
            await FlutterImageCompress.compressWithFile(
          certificateFile.absolute.path,
          minWidth: 1200,
          minHeight: 1200,
          quality: 80,
        );
      }

      if (fileBytes == null || fileBytes.isEmpty) {
        return left('فشل معالجة ملف الشهادة');
      }

      // ========================================================
      // Storage Path
      // ========================================================

      final folderPath =
          'employees/$uid/courses';

      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}$extension';

      final storagePath =
          '$folderPath/$fileName';

      // ========================================================
      // Upload To Supabase
      // ========================================================

      await Supabase.instance.client.storage
          .from('images')
          .uploadBinary(
            storagePath,
            fileBytes,
            fileOptions: const FileOptions(
              upsert: true,
            ),
          );

      // ========================================================
      // Public URL
      // ========================================================

      final fileUrl =
          Supabase.instance.client.storage
              .from('images')
              .getPublicUrl(storagePath);

      // ========================================================
      // Update Model
      // ========================================================

      course.certificateFileUrl = fileUrl;

      course.certificateFileType =
          isPdf ? 'pdf' : 'image';

      // ========================================================
      // Save Firestore
      // ========================================================

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('courses')
          .add(
            course.toMap(),
          );

      return right(unit);
    } catch (e) {
      return left(
        'فشل إضافة الدورة: ${e.toString()}',
      );
    }
  }

  // ============================================================
  // Delete Course
  // ============================================================

  Future<Either<String, Unit>> deleteCourse({
    required String uid,
    required EmployeeCourseModel course,
  }) async {
    try {
      // ========================================================
      // Delete File From Supabase
      // ========================================================

      if (course.certificateFileUrl != null &&
          course.certificateFileUrl!.isNotEmpty) {
        try {
          final uri =
              Uri.parse(course.certificateFileUrl!);

          final segments = uri.pathSegments;

          /*
            Public URL غالبًا يكون:

            .../storage/v1/object/public/images/employees/...

            وبالتالي نحتاج الجزء بعد images
          */

          final imagesIndex =
              segments.indexOf('images');

          if (imagesIndex != -1 &&
              imagesIndex + 1 < segments.length) {
            final filePath = segments
                .sublist(imagesIndex + 1)
                .join('/');

            await Supabase.instance.client.storage
                .from('images')
                .remove([filePath]);
          }
        } catch (_) {
          // لو فشل حذف الملف من Supabase
          // نكمل ونحذف Firestore
        }
      }

      // ========================================================
      // Delete Firestore Document
      // ========================================================

      if (course.id == null ||
          course.id!.isEmpty) {
        return left('معرف الدورة غير موجود');
      }

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('courses')
          .doc(course.id)
          .delete();

      return right(unit);
    } catch (e) {
      return left(
        'فشل حذف الدورة: ${e.toString()}',
      );
    }
  }
}