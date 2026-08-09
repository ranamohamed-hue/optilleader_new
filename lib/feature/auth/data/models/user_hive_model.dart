import 'package:optialeader/feature/auth/data/models/user_model.dart';

class UserHiveModel {
  final String uid;
  final String username;
  final String universityEmail;
  final String nationalId;
  final String employeeId;
  final String role;
  final bool isFirstLogin;

  UserHiveModel({
    required this.uid,
    required this.username,
    required this.universityEmail,
    required this.nationalId,
    required this.employeeId,
    required this.role,
    required this.isFirstLogin,
  });

  ///  تحويل من UserModel (بتاع التطبيق) لـ UserHiveModel
  factory UserHiveModel.fromUserModel(UserModel user) {
    return UserHiveModel(
      uid: user.uid,
      username: user.username,
      universityEmail: user.universityEmail,
      nationalId: user.nationalId,
      employeeId: user.employeeId,
      role: user.roleString, // بنستخدم الدالة اللي عملناها في UserModel
      isFirstLogin: user.isFirstLogin,
    );
  }

  /// تحويل من UserHiveModel لـ UserModel (عشان التطبيق يشتغل بـ Enum بتاع الـ Role)
  UserModel toUserModel() {
    return UserModel(
      uid: uid,
      username: username,
      universityEmail: universityEmail,
      nationalId: nationalId,
      employeeId: employeeId,
      role: _mapRole(role), // بنحول الـ String لـ Enum تاني
      isFirstLogin: isFirstLogin,
    );
  }

  /// تحويل من UserHiveModel لـ Map (عشان الـ Hive يحفظه)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'universityEmail': universityEmail,
      'nationalId': nationalId,
      'employeeId': employeeId,
      'role': role,
      'isFirstLogin': isFirstLogin,
    };
  }

  /// تحويل من Map (اللي جاي من الـ Hive) لـ UserHiveModel
  factory UserHiveModel.fromMap(Map<String, dynamic> map) {
    return UserHiveModel(
      uid: map['uid'] ?? '',
      username: map['username'] ?? '',
      universityEmail: map['universityEmail'] ?? '',
      nationalId: map['nationalId'] ?? '',
      employeeId: map['employeeId'] ?? '',
      role: map['role'] ?? 'user',
      isFirstLogin: map['isFirstLogin'] ?? true,
    );
  }

  // دالة مساعدة لتحويل الـ String لـ Enum
  static UserRole _mapRole(String? role) {
    switch (role) {
      case 'database_admin':
        return UserRole.database_admin;
      case 'admin':
        return UserRole.admin;
      case 'judge':
        return UserRole.judge;
        case 'employee':
        return UserRole.admin_manager;
      default:
        return UserRole.user;
    }
  }
}