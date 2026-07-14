import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:optialeader/feature/database_admin/data/models/doctor_profile_model.dart';
import 'package:optialeader/feature/database_admin/data/repo/doctor_repository/doctor_repo.dart';

class DoctorRepoImpl extends DoctorRepo {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  CollectionReference get _usersCollection =>
      firebaseFirestore.collection('users');

  @override
  Future<Either<String, Unit>> saveDoctorData(DoctorProfileModel doctor) async {
    try {
      await _usersCollection
          .doc(doctor.uid)
          .set(doctor.toMap(), SetOptions(merge: true));
      return right(unit);
    } catch (e) {
      return left(e.toString());
    }
  }

  @override
  Future<Either<String, DoctorProfileModel?>> getDoctorProfile(
    String uid,
  ) async {
    try {
      final doc = await _usersCollection.doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return right(
          DoctorProfileModel.fromJson(
            doc.data() as Map<String, dynamic>,
            doc.id,
          ),
        );
      }
      return right(null);
    } catch (e) {
      return left("فشل جلب بيانات الدكتور: ${e.toString()}");
    }
  }

  @override
  Stream<List<DoctorProfileModel>> watchAllDoctors() {
    return _usersCollection.where('role', isEqualTo: 'doctor').snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) {
        return DoctorProfileModel.fromJson(
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
      await _usersCollection.doc(uid).update({
        'eligibility_data.is_active': isActive,
      });
      return right(unit);
    } catch (e) {
      return left("فشل تحديث حالة الحساب: ${e.toString()}");
    }
  }

  @override
  Future<Either<String, Unit>> updateVacationStatus(
    String uid,
    bool isOnVacation,
  ) async {
    try {
      await _usersCollection.doc(uid).update({
        'eligibility_data.is_on_vacation': isOnVacation,
      });
      return right(unit);
    } catch (e) {
      return left("فشل تحديث حالة الإجازة: ${e.toString()}");
    }
  }

  @override
  Future<Either<String, String>> uploadFile(
    Uint8List fileBytes,
    String storagePath, {
    required String bucketName,
  }) async {
    try {
      await Supabase.instance.client.storage
          .from(bucketName)
          .uploadBinary(
            storagePath,
            fileBytes,
            fileOptions: const FileOptions(upsert: true),
          );

      final String publicUrl = Supabase.instance.client.storage
          .from(bucketName)
          .getPublicUrl(storagePath);

      return right(publicUrl);
    } catch (e) {
      return left("فشل رفع الملف: ${e.toString()}");
    }
  }

  @override
  Future<Either<String, Unit>> updateDoctorImage(
    String uid,
    String imageUrl,
  ) async {
    try {
      await _usersCollection.doc(uid).update({
        'profile.profile_image': imageUrl,
      });
      return right(unit);
    } catch (e) {
      return left("فشل تحديث رابط الصورة: ${e.toString()}");
    }
  }

  @override
  Future<Either<String, Unit>> deleteDoctorAccount(String uid) async {
    try {
      try {
        final List<FileObject> images = await Supabase.instance.client.storage
            .from('images')
            .list(path: 'profiles/$uid');
        if (images.isNotEmpty) {
          final List<String> imagePaths = images
              .map((img) => 'profiles/$uid/${img.name}')
              .toList();
          await Supabase.instance.client.storage
              .from('images')
              .remove(imagePaths);
        }
      } catch (e) {
        print("خطأ في مسح صورة البروفايل: $e");
      }

      try {
        final List<FileObject> archives = await Supabase.instance.client.storage
            .from('files')
            .list(path: 'archives/$uid');
        if (archives.isNotEmpty) {
          final List<String> archivePaths = archives
              .map((arch) => 'archives/$uid/${arch.name}')
              .toList();
          await Supabase.instance.client.storage
              .from('files')
              .remove(archivePaths);
        }
      } catch (e) {
        print("خطأ في مسح ملفات الأرشيف: $e");
      }

      await _usersCollection.doc(uid).delete();

      return right(unit);
    } catch (e) {
      return left("فشل حذف الحساب: ${e.toString()}");
    }
  }

  @override
  Future<Either<String, Unit>> updateDoctorProfileData(
    String uid,
    Map<String, dynamic> updatedFields,
  ) async {
    try {
      await _usersCollection.doc(uid).update(updatedFields);
      return right(unit);
    } catch (e) {
      return left("فشل تحديث بيانات الدكتور: ${e.toString()}");
    }
  }

  @override
  Future<Either<String, List<DoctorProfileModel>>> getAllDoctorsOnce() async {
    try {
      final snapshot = await _usersCollection
          .where('role', isEqualTo: 'doctor')
          .get();
      final doctors = snapshot.docs.map((doc) {
        return DoctorProfileModel.fromJson(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
      return right(doctors);
    } catch (e) {
      return left("فشل جلب الدكاترة: ${e.toString()}");
    }
  }
}
