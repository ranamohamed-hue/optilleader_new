import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:optialeader/feature/admin/data/model/announcement_model.dart';
import 'package:optialeader/feature/admin/data/repo/announcement_repos/announcement_repo.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  print('🔥 GET ANNOUNCEMENTS CALLED');
  print('👤 Firebase User: ${_firestore.app.options.projectId}');
  print('🔐 Authenticated: ${FirebaseAuth.instance.currentUser != null}');
  print('🆔 UID: ${FirebaseAuth.instance.currentUser?.uid}');

  return _collection.snapshots().map((snapshot) {
    print(
      '🔥 FIRESTORE SNAPSHOT: ${snapshot.docs.length} documents',
    );

    final announcements = <AnnouncementModel>[];

    for (final doc in snapshot.docs) {
      try {
        final data =
            Map<String, dynamic>.from(doc.data() as Map);

        print('📄 ANNOUNCEMENT ${doc.id}: $data');

        final announcement =
            AnnouncementModel.fromMap(data, doc.id);

        announcements.add(announcement);
      } catch (e, stack) {
        print('❌ ERROR PARSING ${doc.id}');
        print(e);
        print(stack);
      }
    }

    announcements.sort(
      (a, b) => b.createdAt.compareTo(a.createdAt),
    );

    print(
      '✅ FINAL ANNOUNCEMENTS: ${announcements.length}',
    );

    return announcements;
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
    print('📸 [UPLOAD] START');
    print('📸 [UPLOAD] filePath: $filePath');

    final file = File(filePath);

    if (!await file.exists()) {
      print('❌ [UPLOAD] الملف غير موجود');
      return const Left('ERROR_IMAGE_FILE_NOT_FOUND');
    }

    final Uint8List bytes = await file.readAsBytes();

    print('📸 [UPLOAD] حجم الصورة: ${bytes.length} bytes');

    if (bytes.isEmpty) {
      return const Left('ERROR_IMAGE_EMPTY');
    }

    final storagePath =
        'announcements/${DateTime.now().millisecondsSinceEpoch}.jpg';

    print('📤 [UPLOAD] جاري الرفع إلى Supabase...');
    print('📤 [UPLOAD] path: $storagePath');

    await _supabase.storage
        .from('images')
        .uploadBinary(
          storagePath,
          bytes,
          fileOptions: const FileOptions(
            upsert: true,
            contentType: 'image/jpeg',
          ),
        );

    print('✅ [UPLOAD] تم رفع الصورة');

    final imageUrl = _supabase.storage
        .from('images')
        .getPublicUrl(storagePath);

    print('🔗 [UPLOAD] URL: $imageUrl');

    return Right(imageUrl);
  } catch (e, stackTrace) {
    print('❌ [UPLOAD] ERROR: $e');
    print('❌ [UPLOAD] STACK: $stackTrace');

    return Left(
      'ERROR_IMAGE_UPLOAD_SUPABASE: $e',
    );
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