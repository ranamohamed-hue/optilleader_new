import 'dart:io'; // ✅ [مهم] لاستخدام File
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:optialeader/feature/database_admin/data/repo/database_admin_repository/database_admin_repo.dart';
import 'package:optialeader/feature/database_admin/logic/database_admin_data/database_admin_state.dart';

class DatabseAdminCubit extends Cubit<DatabaseAdminState> {
  final DatabaseAdminRepo _databaseAdminRepo;
  DatabseAdminCubit(this._databaseAdminRepo) : super(DatabaseAdminInitial());

  Future<void> getProfile(String uid) async {
    emit(DatabaseAdminLoading());

    final result = await _databaseAdminRepo.getAdminProfile(uid);

    result.fold(
      (error) {
        emit(DatabaseAdminError(error));
      },
      (profile) async {
        final counts = await _databaseAdminRepo.getUserCounts();
        
        emit(DatabaseAdminSuccess(
          profile,
          doctorsCount: counts['doctors'] ?? 0,
          judgesCount: counts['judges'] ?? 0,
          adminsCount: counts['admins'] ?? 0,
          employeesCount:counts['employees']??0,
        ));
      },
    );
  }

  Future<void> updateInfo({
    required String uid,
    required String phone,
    required String addrAr,
    required String addrEn,
  }) async {
    emit(DatabaseAdminLoading());
    final result = await _databaseAdminRepo.updateAdminInfo(
      uid: uid,
      newPhone: phone,
      addressAr: addrAr,
      addressEn: addrEn,
    );
    result.fold(
      (error) => emit(DatabaseAdminError(error)),
      (_) {
        emit(DatabaseAdminUpdateSuccess());
        getProfile(uid);
      },
    );
  }

  // ✅ [تعديل] دالة تحديث الرابط في الفايرستور فقط (يتم استدعاؤها من الدالة اللي تحت)
  Future<void> updateImage({
    required String uid,
    required String imageUrl,
  }) async {
    final result = await _databaseAdminRepo.updateProfileImage(uid, imageUrl);

    result.fold(
      (error) => emit(DatabaseAdminError(error)),
      (_) {
        emit(DatabaseAdminUpdateSuccess());
        getProfile(uid); // تحديث البيانات في الشاشة
      },
    );
  }

  // ✅ [إضافة] دالة رفع الصورة لـ Supabase ثم تحديث الفايرستور
  Future<void> updateProfileImageWithFile(String uid, File imageFile) async {
    emit(DatabaseAdminLoading()); 

    // 1. رفع الصورة إلى Supabase (نمرر المسار)
    final uploadResult = await _databaseAdminRepo.uploadImageToSupabase(uid, imageFile.path);

    uploadResult.fold(
      (uploadError) {
        emit(DatabaseAdminError(uploadError));
      },
      (imageUrl) async {
        // 2. حفظ الرابط في Firebase Firestore باستخدام دالة updateImage الأصلية
        await updateImage(uid: uid, imageUrl: imageUrl);
      },
    );
  }
}