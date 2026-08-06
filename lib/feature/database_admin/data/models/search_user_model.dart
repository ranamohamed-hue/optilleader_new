import 'package:cloud_firestore/cloud_firestore.dart';

class SearchUserModel {
  final String uid;
  final String nameAr;
  final String nameEn;
  final String profileImage;
  final String employeeId;
  final String role;
  final String email;

  SearchUserModel({
    required this.uid,
    required this.nameAr,
    required this.nameEn,
    required this.profileImage,
    required this.employeeId,
    required this.role,
    required this.email,
  });

  factory SearchUserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final String role = data['role'] ?? 'user';
    
    // ✅ قيم افتراضية
    String nameAr = '';
    String nameEn = '';
    String profileImage = '';
    String employeeId = data['employee_id'] ?? '';
    String email = data['university_email'] ?? '';

    // ✅ التعديل: جميع الأدوار بتقرأ من نفس المسار الصحيح
    switch (role) {
      case 'doctor':
        nameAr = data['profile']?['display_name']?['ar'] ?? '';
        nameEn = data['profile']?['display_name']?['en'] ?? '';
        profileImage = data['profile']?['profile_image'] ?? '';
        break;
      case 'admin':
      case 'judge':
        nameAr = data['profile']?['display_name']?['ar'] ?? '';
        nameEn = data['profile']?['display_name']?['en'] ?? '';
        profileImage = data['profile']?['profile_image'] ?? '';
        break;
      case 'database_admin':
        nameAr = data['profile']?['display_name']?['ar'] ?? data['display_name']?['ar'] ?? '';
        nameEn = data['profile']?['display_name']?['en'] ?? data['display_name']?['en'] ?? '';
        profileImage = data['profile']?['profile_image'] ?? '';
        break;
    }

    return SearchUserModel(
      uid: doc.id,
      nameAr: nameAr,
      nameEn: nameEn,
      profileImage: profileImage,
      employeeId: employeeId,
      role: role,
      email: email,
    );
  }
}