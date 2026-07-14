import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:optialeader/feature/database_admin/data/models/admin_profile_model.dart';
import 'package:optialeader/feature/database_admin/data/repo/admin_repository/admin_repo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminRepoImpl extends AdminRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SupabaseClient _supabase = Supabase.instance.client;

  CollectionReference get _usersCollection => _firestore.collection('users');

  @override
  Future<Either<String, Unit>> saveAdminData(AdminProfileModel admin) async {
    try {
      await _usersCollection
          .doc(admin.uid)
          .set(admin.toMap(), SetOptions(merge: true));
      return right(unit);
    } catch (e) {
      return left("ERROR_ADMIN_SAVE");
    }
  }

  @override
  Future<Either<String, AdminProfileModel>> getAdminProfile(String uid) async {
    try {
      final doc = await _usersCollection.doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return right(
          AdminProfileModel.fromJson(
            doc.data() as Map<String, dynamic>,
            doc.id,
          ),
        );
      }
      return left("ERROR_ADMIN_NOT_FOUND");
    } catch (e) {
      return left("ERROR_DB_FETCH");
    }
  }

  @override
  Stream<List<AdminProfileModel>> watchAllAdmins() {
    return _usersCollection.where('role', isEqualTo: 'admin').snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) {
        return AdminProfileModel.fromJson(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    });
  }

  @override
  Future<Either<String, Unit>> updateAccountStatus(
    String uid,
    bool isActive,
  ) async {
    try {
      await _usersCollection.doc(uid).update({'is_active': isActive});
      return right(unit);
    } catch (e) {
      return left("ERROR_ADMIN_STATUS_UPDATE");
    }
  }

  @override
  Future<Either<String, Unit>> updateAdminImage(String uid, String imageUrl) async {
    try {
      await _usersCollection.doc(uid).update({
        'profile.profile_image': imageUrl,
      });
      return right(unit);
    } catch (e) {
      return left("ERROR_ADMIN_IMAGE_UPDATE");
    }
  }

  @override
  Future<Either<String, String>> uploadImageToSupabase(String uid, String filePath) async {
    try {
      final fileExtension = filePath.split('.').last.toLowerCase();

      final Uint8List? compressedBytes = await FlutterImageCompress.compressWithFile(
        filePath,
        minHeight: 600,
        minWidth: 600,
        quality: 85,
      );

      if (compressedBytes == null) {
        return left("ERROR_IMAGE_COMPRESS_FAILED");
      }

      final storagePath = 'admin_profiles/$uid/profile.$fileExtension';
      
      await _supabase.storage.from('images').uploadBinary(
            storagePath,
            compressedBytes,
            fileOptions: FileOptions(
              upsert: true,
              contentType: 'image/$fileExtension',
            ),
          );

      final imageUrl = _supabase.storage.from('images').getPublicUrl(storagePath);

      return right(imageUrl);
    } catch (e) {
      return left("ERROR_IMAGE_UPLOAD_SUPABASE");
    }
  }

  @override
  Future<Either<String, Unit>> deleteAdminAccount(String uid) async {
    try {
      final doc = await _usersCollection.doc(uid).get();
      
      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        
        final String? imageUrl = data['profile']?['profile_image'];

        // 2. حذف الصورة من Supabase إذا وجدت
        if (imageUrl != null && imageUrl.contains('supabase.co')) {
          try {
          
            final uri = Uri.parse(imageUrl);
            final pathSegments = uri.pathSegments;
            
            final bucketIndex = pathSegments.indexOf('images');
            if (bucketIndex != -1 && bucketIndex + 1 < pathSegments.length) {
              final storagePath = pathSegments.sublist(bucketIndex + 1).join('/');
              
              // حذف الملف من Supabase
              await _supabase.storage.from('images').remove([storagePath]);
            }
          } catch (storageError) {
            print('Failed to delete image from Supabase: $storageError');
          }
        }
      }

      // 3. حذف المستند (البروفايل) من Firebase Firestore
      await _usersCollection.doc(uid).delete();

      return right(unit);
    } catch (e) {
      return left("ERROR_ADMIN_DELETE");
    }
  }

  @override
  Future<Map<String, int>> getAdminDashboardCounts() async {
    try {
      int newRequestsCount = 0;
      int underReviewCount = 0;

      final newRequestsQuery = _firestore
          .collection('requests')
          .where('status', isEqualTo: 'new');
      final newRequestsSnapshot = await newRequestsQuery.count().get();
      newRequestsCount = newRequestsSnapshot.count ?? 0;

      final underReviewQuery = _firestore
          .collection('requests')
          .where('status', isEqualTo: 'under_review');
      final underReviewSnapshot = await underReviewQuery.count().get();
      underReviewCount = underReviewSnapshot.count ?? 0;

      return {
        'newRequests': newRequestsCount,
        'underReview': underReviewCount,
      };
    } catch (e) {
      return {'newRequests': 0, 'underReview': 0};
    }
  }
}