import 'package:optialeader/feature/setting/data/models/user_setting_model.dart';

abstract class SettingState {}

class SettingInitial extends SettingState {}

class SettingLoading extends SettingState {
  final UserSettingsModel? user;
  SettingLoading({this.user});
}

class SettingFetchSuccess extends SettingState {
  final UserSettingsModel user;
  SettingFetchSuccess(this.user);
}

class SettingImageUploadSuccess extends SettingState {
  final UserSettingsModel user;
  SettingImageUploadSuccess(this.user);
}

class SettingUpdateSuccess extends SettingState {
  final UserSettingsModel user;
  SettingUpdateSuccess(this.user);
}

class SettingImageUploading extends SettingState {
  final UserSettingsModel user;
  SettingImageUploading(this.user);
}

class SettingError extends SettingState {
  final String message;
  final UserSettingsModel? user;
  SettingError(this.message, {this.user});
}
