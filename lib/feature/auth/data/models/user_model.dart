import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { admin, user, judge, database_admin,admin_manager }

class UserModel extends Equatable {
  final String uid;
  final String username;
  final String universityEmail;
  final String nationalId;
  final String employeeId;
  final UserRole role;
  final bool isFirstLogin;

  const UserModel({
    required this.uid,
    required this.username,
    required this.universityEmail,
    required this.nationalId,
    required this.employeeId,
    required this.role,
    this.isFirstLogin = true,
  });

  /// Firestore → Model
 factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    // قراءة الاسم سواء كان مسطحاً أو داخل خريطة profile -> display_name
    String resolvedUsername = 'بدون اسم';
    if (data['username'] != null) {
      resolvedUsername = data['username'];
    } else if (data['profile'] != null && data['profile']['display_name'] != null) {
      resolvedUsername = data['profile']['display_name']['ar'] ?? 
                          data['profile']['display_name']['en'] ?? 'بدون اسم';
    }

    return UserModel(
      uid: doc.id,
      username: resolvedUsername,
      universityEmail: data['university_email'] ?? '',
      nationalId: data['national_id'] ?? '',
      employeeId: data['employee_id'] ?? '',
      role: _mapRole(data['role']),
      isFirstLogin: data['isFirstLogin'] ?? true,
    );
  }
  ///  تحويل String → Enum
    /// تحويل String → Enum
   /// تحويل String → Enum
  static UserRole _mapRole(String? role) {
    switch (role) {
      case 'database_admin':
        return UserRole.database_admin;
      case 'admin':
        return UserRole.admin;
      case 'judge':
        return UserRole.judge;
      case 'admin_manager': // ✅ أضف السطر الناقص ده
        return UserRole.admin_manager;
      default:
        return UserRole.user;
    }
  }
  ///  تحويل Enum → String
  String get roleString {
    switch (role) {
      case UserRole.database_admin:
        return 'database_admin';
      case UserRole.admin:
        return 'admin';
      case UserRole.judge:
        return 'judge';
      case UserRole.user:
        return 'user';
        case UserRole.admin_manager:
        return 'admin_manager';
    }
  }

  ///  Model → Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'university_email': universityEmail,
      'national_id': nationalId,
      'employee_id': employeeId,
      'role': roleString,
      'isFirstLogin': isFirstLogin,
    };
  }

  ///  Copy
  UserModel copyWith({
    String? uid,
    String? username,
    String? universityEmail,
    String? nationalId,
    String? employeeId,
    UserRole? role,
    bool? isFirstLogin,
    bool? isRegistered,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      username: username ?? this.username,
      universityEmail: universityEmail ?? this.universityEmail,
      nationalId: nationalId ?? this.nationalId,
      employeeId: employeeId ?? this.employeeId,
      role: role ?? this.role,
      isFirstLogin: isFirstLogin ?? this.isFirstLogin,
    );
  }

  @override
  List<Object?> get props => [
    uid,
    username,
    universityEmail,
    nationalId,
    employeeId,
    role,
    isFirstLogin,
  ];
}
