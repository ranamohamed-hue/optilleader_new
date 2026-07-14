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

  // ✅ دالة ذكية تقرأ البيانات من الفايرستور مهما كان شكل الـ Document (أدمن، دكتور، قاضي)
  factory SearchUserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final String role = data['role'] ?? 'user';
    
    String nameAr = '';
    String nameEn = '';
    String profileImage = '';
    String employeeId = '';
    String email = data['university_email'] ?? '';

    // بنقرأ البيانات حسب الـ Role عشان الفايرستور شكله مختلف لكل نوع
    switch (role) {
      case 'doctor':
        nameAr = data['identity']?['name_ar'] ?? '';
        nameEn = data['identity']?['name_en'] ?? '';
        profileImage = data['identity']?['profile_image_url'] ?? '';
        employeeId = data['identity']?['employee_id'] ?? '';
        email = data['contact']?['university_email'] ?? email;
        break;
      case 'admin':
      case 'judge':
        nameAr = data['profile']?['display_name']?['ar'] ?? '';
        nameEn = data['profile']?['display_name']?['en'] ?? '';
        profileImage = data['profile']?['profile_image'] ?? '';
        employeeId = data['employee_id'] ?? '';
        break;
      case 'database_admin':
        nameAr = data['display_name']?['ar'] ?? '';
        nameEn = data['display_name']?['en'] ?? '';
        profileImage = data['profile']?['profile_image'] ?? '';
        employeeId = data['employee_id'] ?? '';
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