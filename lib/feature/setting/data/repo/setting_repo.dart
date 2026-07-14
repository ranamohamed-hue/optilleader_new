import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:optialeader/feature/setting/data/models/user_setting_model.dart';

abstract class SettingsRepo {
  Future<Either<String, UserSettingsModel>> getUserData({
    required String uid,
    required String role, 
  });
  Future<Either<String,Unit>> updateProfileData({
    required UserSettingsModel user,
    required String role,
  });
 Future<Either<String, String>> uploadProfileImage({
    required String uid,
    required File imageFile,
        required String role, 

  });
}