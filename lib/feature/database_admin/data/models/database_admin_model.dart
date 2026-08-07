class DatabaseAdminProfileModel {
  final String uid;
  final String nameAr;
  final String nameEn;
  final String email;
  final String addressAr;
  final String addressEn;
  final String profileImage;
  final String role;
  final String phone;
  final String nationalId;
  final String employeeId;
  final bool isFirstLogin;

  const DatabaseAdminProfileModel({
    required this.uid,
    required this.nameAr,
    required this.nameEn,
    required this.email,
    required this.addressAr,
    required this.addressEn,
    required this.profileImage,
    this.role = 'database_admin',
    required this.phone,
    required this.nationalId,
    required this.employeeId,
    this.isFirstLogin = true,
  });

  factory DatabaseAdminProfileModel.fromFirestore(
    Map<String, dynamic> json,
    String id,
  ) {
    final profile = json['profile'] as Map<String, dynamic>? ?? {};

    return DatabaseAdminProfileModel(
      uid: id,
      // ✅✅✅ التعديل: يدور على display_name في الجذر أولاً، لو ملقاهوش يدور جوه profile ✅✅✅
      nameAr: json['display_name']?['ar'] ?? profile['display_name']?['ar'] ?? json['name_ar'] ?? '',
      nameEn: json['display_name']?['en'] ?? profile['display_name']?['en'] ?? json['name_en'] ?? '',
      email: json['university_email'] ?? '',
      // ✅ نفس التعديل للعنوان والباقي (عشان متتخنش حاجة)
      addressAr: json['address']?['ar'] ?? profile['address']?['ar'] ?? '',
      addressEn: json['address']?['en'] ?? profile['address']?['en'] ?? '',
      profileImage: profile['profile_image'] ?? '',
      role: json['role'] ?? 'database_admin',
      phone: json['phone'] ?? profile['phone']?['phone1'] ?? '',
      nationalId: json['national_id'] ?? profile['national_id'] ?? '',
      employeeId: json['employee_id'] ?? profile['employee_id'] ?? '',
      isFirstLogin: json['isFirstLogin'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'role': role,
      'university_email': email,
      'isFirstLogin': isFirstLogin,
      'national_id': nationalId,
      'employee_id': employeeId, 
      'profile': {
        'display_name': {'ar': nameAr, 'en': nameEn},
        'phone': {'phone1': phone},
        'address': {'ar': addressAr, 'en': addressEn},
        'profile_image': profileImage,
        'national_id': nationalId,
        'employee_id': employeeId,
      },
    };
  }

  DatabaseAdminProfileModel copyWith({
    String? uid,
    String? nameAr,
    String? nameEn,
    String? email,
    String? addressAr,
    String? addressEn,
    String? profileImage,
    String? role,
    String? phone,
    String? nationalId,
    String? employeeId,
    bool? isFirstLogin,
  }) {
    return DatabaseAdminProfileModel(
      uid: uid ?? this.uid,
      nameAr: nameAr ?? this.nameAr,
      nameEn: nameEn ?? this.nameEn,
      email: email ?? this.email,
      addressAr: addressAr ?? this.addressAr,
      addressEn: addressEn ?? this.addressEn,
      profileImage: profileImage ?? this.profileImage,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      nationalId: nationalId ?? this.nationalId,
      employeeId: employeeId ?? this.employeeId,
      isFirstLogin: isFirstLogin ?? this.isFirstLogin,
    );
  }
}