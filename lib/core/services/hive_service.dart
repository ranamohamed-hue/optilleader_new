import 'package:hive_flutter/hive_flutter.dart';
import 'package:optialeader/feature/auth/data/models/user_hive_model.dart';
class HiveService {
  static const String _boxName = 'authBox';
  static const String _userKey = 'cachedUser';
  
  Box? _box;

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
  }

  /// حفظ بيانات المستخدم
  Future<void> saveUser(UserHiveModel userHiveModel) async {
    await _box?.put(_userKey, userHiveModel.toMap());
  }

  ///  جلب بيانات المستخدم
  UserHiveModel? getUser() {
    final data = _box?.get(_userKey);
    if (data != null) {
      // بنحول الـ dynamic اللي جاي من الـ Hive لـ Map ونبنى بيه الموديل
      return UserHiveModel.fromMap(Map<String, dynamic>.from(data));
    }
    return null;
  }

  ///مسح بيانات المستخدم (تسجيل الخروج)
  Future<void> clearUser() async {
    await _box?.delete(_userKey);
  }
}