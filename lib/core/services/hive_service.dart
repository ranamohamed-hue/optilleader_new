import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:optialeader/feature/auth/data/models/user_hive_model.dart';

class HiveService {
  static const String _boxName = 'authBox';
  static const String _userKey = 'cachedUser';
  Box? _box;

  Future<void> init() async {
    await Hive.initFlutter();
    debugPrint('✅ Hive Engine جاهز');
  }

  Future<void> _openBoxSafely() async {
    if (_box != null && _box!.isOpen) return;
    try {
      if (Hive.isBoxOpen(_boxName)) {
        _box = Hive.box(_boxName);
      } else {
        _box = await Hive.openBox(_boxName);
      }
    } catch (e) {
      debugPrint('❌ فشل فتح الـ Box، سيتم حذفه: $e');
      try { await Hive.deleteBoxFromDisk(_boxName); } catch (_) {}
      _box = null;
    }
  }

  Future<UserHiveModel?> getUser() async {
    try {
      await _openBoxSafely();
      if (_box != null && _box!.isOpen) {
        final data = _box!.get(_userKey);
        if (data != null) return UserHiveModel.fromMap(Map<String, dynamic>.from(data));
      }
    } catch (e) {
      debugPrint('❌ خطأ في القراءة: $e');
    }
    return null;
  }

  Future<void> saveUser(UserHiveModel userHiveModel) async {
    try {
      await _openBoxSafely();
      if (_box != null && _box!.isOpen) {
        await _box!.put(_userKey, userHiveModel.toMap());
      }
    } catch (e) {
      debugPrint('❌ خطأ في الحفظ: $e');
    }
  }

  Future<void> clearUser() async {
    if (_box != null && _box!.isOpen) {
      await _box!.delete(_userKey);
    }
  }
}