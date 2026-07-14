import 'dart:io';
import 'dart:typed_data'; 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart'; 
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:optialeader/feature/setting/data/models/user_setting_model.dart';
import 'package:optialeader/feature/setting/data/repo/setting_repo.dart';

class SettingRepoImpl implements SettingsRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SupabaseClient _supabase = Supabase.instance.client;

  CollectionReference get _usersCollection => _firestore.collection('users');

  @override
  Future<Either<String, UserSettingsModel>> getUserData({
    required String uid,
    required String role,
  }) async {
    try {
      final doc = await _usersCollection.doc(uid).get();

      if (doc.exists && doc.data() != null) {
        return right(
          UserSettingsModel.fromFirestore(
            doc.data() as Map<String, dynamic>,
            uid,
          ),
        );
      } else {
        return left("ERROR_USER_NOT_FOUND");
      }
    } on FirebaseException {
      return left("ERROR_DB_CONNECTION");
    } catch (e) {
      return left("ERROR_UNKNOWN");
    }
  }

  @override
  Future<Either<String, Unit>> updateProfileData({
    required UserSettingsModel user,
    required String role,
  }) async {
    try {
      await _usersCollection.doc(user.uid).update(user.toUpdateMap());
      return right(unit);
    } on FirebaseException {
      return left("ERROR_DB_UPDATE");
    } catch (e) {
      return left("ERROR_UNKNOWN");
    }
  }

  @override
  Future<Either<String, String>> uploadProfileImage({
    required String uid,
    required File imageFile,
    required String role,
  }) async {
    try {
      // 1 استخراج الامتداد (jpg, png)
      final filePath = imageFile.path;
      final fileExtension = filePath.split('.').last.toLowerCase();

      // 2 ضغط الصورة (بنفس طريقة باقي التطبيق)
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

      // 3 تحديد مسار التخزين في Supabase
      final storagePath = 'profiles/$uid/profile.$fileExtension';

      // 4 رفع الصورة المضغوطة (كـ Bytes) - الـ Bucket اسمه images
      await _supabase.storage
          .from('images')
          .uploadBinary(
            storagePath,
            compressedBytes,
            fileOptions: FileOptions(
              upsert: true, // لو في صورة قديمة يمسحها ويحط الجديدة
              contentType: 'image/$fileExtension',
            ),
          );

      // 5 الحصول على الرابط العام (Public URL)
      final imageUrl = _supabase.storage
          .from('images')
          .getPublicUrl(storagePath);

      // 6 تحديث رابط الصورة في الفايرستور (جدول users)
      await _usersCollection.doc(uid).update({
        'profile.profile_image': imageUrl,
      });

      return right(imageUrl);
    } on StorageException catch (e) {
      print(' Supabase Error: ${e.message}');
      return left("ERROR_DB_UPDATE");
    } on FirebaseException catch (e) {
      print(' Firestore Error: ${e.message}');
      return left("ERROR_DB_UPDATE");
    } catch (e) {
      print(' Unknown Error: $e');
      return left("ERROR_UNKNOWN");
    }
  }
}
