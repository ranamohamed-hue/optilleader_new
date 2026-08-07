import 'package:hive_flutter/hive_flutter.dart';
import 'package:optialeader/feature/auth/data/models/user_hive_model.dart';

class HiveService {
  static const String _boxName = 'authBox';
  static const String _userKey = 'cachedUser';
  
  Box? _box;

  Future<void> init() async {
    await Hive.initFlutter();
    
    // ✅ الحل السحري: نمسح الملف القديم من على الجهاز قبل ما نحاول نفتحه
    // ده بيكسر حالة التعليق (Hang) اللي بتحصل مع الملفات التالفة أو المشفرة
    await Hive.deleteBoxFromDisk(_boxName);
    
    // بعدين نفتح الـ Box جديد ونظيف
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
      return UserHiveModel.fromMap(Map<String, dynamic>.from(data));
    }
    return null;
  }

  /// مسح بيانات المستخدم (تسجيل الخروج)
  Future<void> clearUser() async {
    await _box?.delete(_userKey);
  }
}