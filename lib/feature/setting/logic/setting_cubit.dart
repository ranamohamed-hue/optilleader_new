import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:optialeader/feature/setting/data/models/user_setting_model.dart';
import 'package:optialeader/feature/setting/data/repo/setting_repo.dart';
import 'package:optialeader/feature/setting/logic/setting_state.dart';

class SettingCubit extends Cubit<SettingState> {
  final SettingsRepo settingsRepo;

  SettingCubit(this.settingsRepo) : super(SettingInitial());

  // جلب بيانات المستخدم
  Future<void> getUserData({
    required String uid,
    required String role,
  }) async {
    emit(SettingLoading());

    final result = await settingsRepo.getUserData(
      uid: uid,
      role: role,
    );

    result.fold(
      (error) => emit(SettingError(error)),
      (user) => emit(SettingFetchSuccess(user)),
    );
  }

  Future<void> updateUserData({
    required UserSettingsModel user,
    required String role,
  }) async {
    emit(SettingLoading(user: user));

    final result = await settingsRepo.updateProfileData(
      user: user,
      role: role,
    );

    result.fold(
      (error) => emit(SettingError(error, user: user)), 
      (_) => emit(SettingUpdateSuccess(user)), 
    );
  }

  //  دالة رفع الصورة الجديدة
  Future<void> uploadProfileImage({
    required String uid,
    required File imageFile,
    required UserSettingsModel currentUser,
    required String role, 
  }) async {
    emit(SettingImageUploading(currentUser));

    final result = await settingsRepo.uploadProfileImage(
      uid: uid,
      imageFile: imageFile,
      role: role, 
    );

    result.fold(
      (error) => emit(SettingError(error, user: currentUser)),
      (newImageUrl) {
        final updatedUser = currentUser.copyWith(profileImage: newImageUrl);
        emit(SettingImageUploadSuccess(updatedUser));
      },
    );
  }
}