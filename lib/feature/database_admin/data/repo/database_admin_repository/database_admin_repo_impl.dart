import 'dart:typed_data'; // ✅ [مهم جداً] عشان نقدر نتعامل مع البايتات بعد الضغط
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // ✅ Supabase
import 'package:flutter_image_compress/flutter_image_compress.dart'; // ✅ مكتبة الضغط
import 'package:optialeader/feature/database_admin/data/models/database_admin_model.dart';
import 'package:optialeader/feature/database_admin/data/repo/database_admin_repository/database_admin_repo.dart';

class DatabaseAdminRepoImpl implements DatabaseAdminRepo {
  final FirebaseFirestore _firestore;
  final SupabaseClient _supabase = Supabase.instance.client; // ✅ تعريف Supabase

  DatabaseAdminRepoImpl(this._firestore);

  @override
  Future<Either<String, DatabaseAdminProfileModel>> getAdminProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        final model = DatabaseAdminProfileModel.fromFirestore(doc.data()!, doc.id);
        return Right(model);
      } else {
        return const Left("ERROR_PROFILE_NOT_FOUND");
      }
    } on FirebaseException catch (e) {
      return Left("ERROR_DB_FIRESTORE: ${e.message ?? ''}");
    } catch (e) {
      return Left("ERROR_UNKNOWN: ${e.toString()}");
    }
  }

  @override
  Future<Either<String, Unit>> updateAdminInfo({
    required String uid,
    required String newPhone,
    required String addressAr,
    required String addressEn,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'profile.phone.phone1': newPhone,
        'profile.address.ar': addressAr,
        'profile.address.en': addressEn,
      });
      return const Right(unit);
    } on FirebaseException catch (e) {
      return Left("ERROR_DB_UPDATE: ${e.message ?? ''}");
    } catch (e) {
      return Left("ERROR_UNKNOWN: ${e.toString()}");
    }
  }

  @override
  Future<Either<String, Unit>> updateProfileImage(String uid, String imageUrl) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'profile.profile_image': imageUrl,
      });
      return const Right(unit);
    } on FirebaseException catch (e) {
      return Left("ERROR_DB_UPDATE: ${e.message ?? ''}");
    } catch (e) {
      return Left("ERROR_UNKNOWN: ${e.toString()}");
    }
  }

  // ✅✅✅ دالة رفع الصورة مع الضغط باستخدام flutter_image_compress ✅✅✅
  @override
  Future<Either<String, String>> uploadImageToSupabase(String uid, String filePath) async {
    try {
      // 1. استخراج الامتداد (jpg, png, etc.)
      final fileExtension = filePath.split('.').last.toLowerCase();

      // 2. ضغط الصورة باستخدام مكتبة flutter_image_compress
      final Uint8List? compressedBytes = await FlutterImageCompress.compressWithFile(
        filePath,
        minHeight: 600,   // أقل ارتفاع
        minWidth: 600,    // أقل عرض
        quality: 85,      // جودة الصورة (85% توازن ممتاز بين الحجم والوضوح)
      );

      // لو المكتبة فشلت في الضغط
      if (compressedBytes == null) {
        return const Left("ERROR_IMAGE_COMPRESS_FAILED");
      }

      // 3. تحديد مسار التخزين في Supabase
      final storagePath = 'db_admin_profiles/$uid/profile.$fileExtension';
      
      // 4. رفع الصورة المضغوطة (كـ Bytes) إلى Supabase
      await _supabase.storage.from('images').uploadBinary(
            storagePath,
            compressedBytes, // ⬅️ هنرفع البايتات اللي ضغطناها
            fileOptions: FileOptions(
              upsert: true, // لو في صورة قديمة يمسحها ويحط الجديدة
              contentType: 'image/$fileExtension',
            ),
          );

      // 5. الحصول على الرابط العام (Public URL) من Supabase
      final imageUrl = _supabase.storage.from('images').getPublicUrl(storagePath);

      return Right(imageUrl);
    } catch (e) {
  debugPrint("🔥 Supabase Upload Error: ${e.toString()}"); // عشان تشوفي الخطأ في الـ Console
  return Left("ERROR_IMAGE_UPLOAD: ${e.toString()}"); // ❌ رجعي الخطأ الحقيقي عشان يظهر في الـ UI
}
  }

  @override
  Future<Map<String, int>> getUserCounts() async {
    try {
      final doctorsQuery = _firestore.collection('users').where('role', isEqualTo: 'doctor');
      final doctorsSnapshot = await doctorsQuery.count().get();
      final int doctorsCount = doctorsSnapshot.count ?? 0; 

      final judgesQuery = _firestore.collection('users').where('role', isEqualTo: 'judge');
      final judgesSnapshot = await judgesQuery.count().get();
      final int judgesCount = judgesSnapshot.count ?? 0;

      final adminsQuery = _firestore.collection('users').where('role', isEqualTo: 'admin');
      final adminsSnapshot = await adminsQuery.count().get();
      final int adminsCount = adminsSnapshot.count ?? 0;

      final employeesQuery = _firestore.collection('users').where('role', isEqualTo: 'admin_manager');
      final employeesSnapshot = await employeesQuery.count().get();
      final int employeesCount = employeesSnapshot.count ?? 0;

      return {
        'doctors': doctorsCount,
        'judges': judgesCount,
        'admins': adminsCount,
        'employees': employeesCount, 
      };
    } catch (e) {
      return {'doctors': 0, 'judges': 0, 'admins': 0, 'employee': 0};
    }
  }
}