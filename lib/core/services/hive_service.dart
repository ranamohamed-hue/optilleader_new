import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:optialeader/feature/auth/data/models/user_hive_model.dart';
class HiveService {
  static const String _boxName = 'authBox';
  static const String _userKey = 'cachedUser';

  Box? _box;

  Future<void> init() async {
    await Hive.initFlutter();

    if (Hive.isBoxOpen(_boxName)) {
      _box = Hive.box(_boxName);
    } else {
      _box = await Hive.openBox(_boxName);
    }
  }

  Future<void> saveUser(UserHiveModel userHiveModel) async {
    await _box?.put(_userKey, userHiveModel.toMap());
  }

  UserHiveModel? getUser() {
    try {
      final data = _box?.get(_userKey);

      if (data != null) {
        return UserHiveModel.fromMap(
          Map<String, dynamic>.from(data),
        );
      }
    } catch (e) {
      debugPrint('خطأ في قراءة بيانات المستخدم من Hive: $e');
      clearUser();
    }

    return null;
  }

  Future<void> clearUser() async {
    await _box?.delete(_userKey);
  }
}