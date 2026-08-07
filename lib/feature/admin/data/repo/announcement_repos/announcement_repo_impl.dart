import 'dart:io';
import 'dart:typed_data';
import 'dart:isolate';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:optialeader/feature/admin/data/model/announcement_model.dart';
import 'package:optialeader/feature/admin/data/repo/announcement_repos/announcement_repo.dart';

class AnnouncementRepositoryImpl implements IAnnouncementRepository {
  final FirebaseFirestore _firestore;
  final SupabaseClient _supabase = Supabase.instance.client;

  AnnouncementRepositoryImpl(this._firestore);

  CollectionReference get _collection => _firestore.collection('announcements');

  @override
  Future<Either<String, String>> addAnnouncement(
    AnnouncementModel announcement,
  ) async {
    try {
      final docRef = await _collection.add(announcement.toMap());
      return Right(docRef.id);
    } catch (e) {
      return const Left("ERROR_ADD_ANNOUNCEMENT");
    }
  }

  @override
  Stream<List<AnnouncementModel>> getAnnouncements() {
    return _collection.orderBy('createdAt', descending: true).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) {
        return AnnouncementModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    });
  }

  @override
  Future<Either<String, Unit>> updateAnnouncement(
    AnnouncementModel announcement,
  ) async {
    try {
      if (announcement.id != null) {
        await _collection.doc(announcement.id).update(announcement.toMap());
        return const Right(unit);
      }
      return const Left("ERROR_ANNOUNCEMENT_NO_ID");
    } catch (e) {
      return const Left("ERROR_UPDATE_ANNOUNCEMENT");
    }
  }

  @override
  Future<Either<String, Unit>> deleteAnnouncement(
    String id,
    String? imageUrl,
  ) async {
    try {
      if (imageUrl != null && imageUrl.contains('supabase.co')) {
        try {
          final uri = Uri.parse(imageUrl);
          final pathSegments = uri.pathSegments;
          final bucketIndex = pathSegments.indexOf('images');
          if (bucketIndex != -1 && bucketIndex + 1 < pathSegments.length) {
            final storagePath = pathSegments.sublist(bucketIndex + 1).join('/');
            await _supabase.storage.from('images').remove([storagePath]);
          }
        } catch (storageError) {
          print('Failed to delete announcement image from Supabase: $storageError');
        }
      }
      await _collection.doc(id).delete();
      return const Right(unit);
    } catch (e) {
      return const Left("ERROR_DELETE_ANNOUNCEMENT");
    }
  }

  // ✅✅✅ الحل: قراءة الملف سريعاً، ثم ضغطه في Isolate منفصل عشان متجمدش الشاشة ✅✅✅
  @override
  Future<Either<String, String>> uploadAnnouncementImage(
    String filePath,
  ) async {
    try {
      // 1. قراءة الملف كـ bytes (دي عملية I/O عادية وسريعة)
      final File imageFile = File(filePath);
      final Uint8List originalBytes = await imageFile.readAsBytes();

      // 2. ضغط الصورة في Isolate منفصل (الواجهة هتستمر في الشغل بشكل طبيعي)
      final Uint8List? compressedBytes = await Isolate.run(() => _compressImageInIsolate(originalBytes));
      
      if (compressedBytes == null) {
        return const Left("ERROR_IMAGE_COMPRESS_FAILED");
      }

      // 3. رفع الصورة المضغوطة على Supabase
      final storagePath = 'announcements/${DateTime.now().millisecondsSinceEpoch}.jpg';
      await _supabase.storage
          .from('images')
          .uploadBinary(
            storagePath,
            compressedBytes,
            fileOptions: const FileOptions(
              upsert: true,
              contentType: 'image/jpeg',
            ),
          );
      
      final imageUrl = _supabase.storage.from('images').getPublicUrl(storagePath);
      return Right(imageUrl);
    } catch (e) {
      return Left("ERROR_IMAGE_UPLOAD_SUPABASE: ${e.toString()}");
    }
  }

  // ✅ دالة منفصلة تتعامل مع الـ Isolate بشكل آمن
  static Future<Uint8List?> _compressImageInIsolate(Uint8List bytes) async {
    try {
      final result = await FlutterImageCompress.compressWithList(
        bytes,
        minHeight: 800,
        minWidth: 800,
        quality: 85,
      );
      return result;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> deleteAnnouncementImage(String imageUrl) async {
    if (imageUrl.contains('supabase.co')) {
      try {
        final uri = Uri.parse(imageUrl);
        final pathSegments = uri.pathSegments;
        final bucketIndex = pathSegments.indexOf('images');
        if (bucketIndex != -1 && bucketIndex + 1 < pathSegments.length) {
          final storagePath = pathSegments.sublist(bucketIndex + 1).join('/');
          await _supabase.storage.from('images').remove([storagePath]);
        }
      } catch (e) {
        print('Failed to delete old image: $e');
      }
    }
  }

  @override
  Future<Either<String, Unit>> autoCloseExpiredAnnouncements(
    List<AnnouncementModel> announcements,
  ) async {
    try {
      final now = DateTime.now();
      final batch = _firestore.batch();
      bool hasUpdates = false;

      for (final ann in announcements) {
        if (ann.status == 'Active' && ann.deadline.isBefore(now)) {
          batch.update(_collection.doc(ann.id), {'status': 'Closed'});
          hasUpdates = true;
        }
      }

      if (hasUpdates) {
        await batch.commit();
      }
      return const Right(unit);
    } catch (e) {
      return const Left("ERROR_AUTO_CLOSE");
    }
  }
}