import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:optialeader/feature/database_admin/data/models/judge_profile_model.dart';
import 'package:optialeader/feature/database_admin/data/repo/judge_repository/judge_repo.dart';

class JudgeRepoImpl extends JudgeRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SupabaseClient _supabase = Supabase.instance.client;

  CollectionReference get _usersCollection => _firestore.collection('users');

  @override
  Future<Either<String, Unit>> saveJudgeData(JudgeProfileModel judge) async {
    try {
      await _usersCollection
          .doc(judge.uid)
          .set(judge.toMap(), SetOptions(merge: true));
      return right(unit);
    } catch (e) {
      return left("ERROR_JUDGE_SAVE");
    }
  }

  @override
  Future<Either<String, JudgeProfileModel?>> getJudgeProfile(String uid) async {
    try {
      final doc = await _usersCollection.doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return right(
          JudgeProfileModel.fromJson(
            doc.data() as Map<String, dynamic>,
            doc.id,
          ),
        );
      }
      return right(null);
    } catch (e) {
      return left("ERROR_JUDGE_FETCH");
    }
  }

  @override
  Stream<List<JudgeProfileModel>> watchAllJudges() {
    return _usersCollection.where('role', isEqualTo: 'judge').snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) {
        return JudgeProfileModel.fromJson(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    });
  }

  @override
  Future<Either<String, Unit>> updateJudgeStatus(
    String uid,
    bool isActive,
  ) async {
    try {
      await _usersCollection.doc(uid).update({'is_active': isActive});
      return right(unit);
    } catch (e) {
      return left("ERROR_JUDGE_STATUS_UPDATE");
    }
  }

  @override
  Future<Either<String, Unit>> updateJudgeImage(
    String uid,
    String imageUrl,
  ) async {
    try {
      await _usersCollection.doc(uid).update({
        'profile.profile_image': imageUrl,
      });
      return right(unit);
    } catch (e) {
      return left("ERROR_JUDGE_IMAGE_UPDATE");
    }
  }

  @override
  Future<Either<String, String>> uploadImageToSupabase(
    String uid,
    String filePath,
  ) async {
    try {
      final fileExtension = filePath.split('.').last.toLowerCase();

      final Uint8List? compressedBytes =
          await FlutterImageCompress.compressWithFile(
            filePath,
            minHeight: 600,
            minWidth: 600,
            quality: 85,
          );

      if (compressedBytes == null) {
        return left("ERROR_IMAGE_COMPRESS_FAILED");
      }

      final storagePath = 'judge_profiles/$uid/profile.$fileExtension';

      await _supabase.storage
          .from('images')
          .uploadBinary(
            storagePath,
            compressedBytes,
            fileOptions: FileOptions(
              upsert: true,
              contentType: 'image/$fileExtension',
            ),
          );

      final imageUrl = _supabase.storage
          .from('images')
          .getPublicUrl(storagePath);
      return right(imageUrl);
    } catch (e) {
      return left("ERROR_IMAGE_UPLOAD_SUPABASE");
    }
  }

  @override
  Future<Either<String, Unit>> deleteJudgeAccount(String uid) async {
    try {
      final doc = await _usersCollection.doc(uid).get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        final String? imageUrl = data['profile']?['profile_image'];

        if (imageUrl != null && imageUrl.contains('supabase.co')) {
          try {
            final uri = Uri.parse(imageUrl);
            final pathSegments = uri.pathSegments;
            final bucketIndex = pathSegments.indexOf('images');

            if (bucketIndex != -1 && bucketIndex + 1 < pathSegments.length) {
              final storagePath = pathSegments
                  .sublist(bucketIndex + 1)
                  .join('/');
              await _supabase.storage.from('images').remove([storagePath]);
            }
          } catch (storageError) {
            print('Failed to delete judge image from Supabase: $storageError');
          }
        }
      }

      await _usersCollection.doc(uid).delete();
      return right(unit);
    } catch (e) {
      return left("ERROR_JUDGE_DELETE");
    }
  }
}
