class JudgeProfileModel {
  final String uid;
  final String email;
  final String nameAr;
  final String nameEn;
  final String jopAr;
  final String jopEn;
  final String phone;
  final String addressAr;
  final String addressEn;
  final String profileImage;
  final bool isActive;
  final String role;
  final bool isFirstLogin;
  final String nationalId;   
  final String employeeId;   

  const JudgeProfileModel({
    required this.uid,
    required this.email,
    required this.nameAr,
    required this.nameEn,
    required this.jopAr,
    required this.jopEn,
    required this.phone,
    required this.addressAr,
    required this.addressEn,
    required this.profileImage,
    this.nationalId = '',    
    this.employeeId = '',   
    this.isActive = true,
    this.role = 'judge',
    this.isFirstLogin = true, 
  });

  factory JudgeProfileModel.fromJson(Map<String, dynamic> json, String id) {
    return JudgeProfileModel(
      uid: id,
      email: json['university_email'] ?? '',
      role: json['role'] ?? 'judge',
      isFirstLogin: json['isFirstLogin'] ?? true,
      nationalId: json['national_id'] ?? '',    
      employeeId: json['employee_id'] ?? '',    
      nameAr: json['profile']?['display_name']?['ar'] ?? '',
      nameEn: json['profile']?['display_name']?['en'] ?? '',
      jopAr: json['jop']?['title']?['ar'] ?? '',
      jopEn: json['jop']?['title']?['en'] ?? '',
      phone: json['profile']?['phone']?['phone1'] ?? '',
      addressAr: json['profile']?['address']?['ar'] ?? '',
      addressEn: json['profile']?['address']?['en'] ?? '',
      profileImage: json['profile']?['profile_image'] ?? '',
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'university_email': email,
      'role': role,
      'isFirstLogin': isFirstLogin,
      'national_id': nationalId,    
      'employee_id': employeeId,    
      'profile': {
        'display_name': {'ar': nameAr, 'en': nameEn},
        'phone': {'phone1': phone},
        'address': {'ar': addressAr, 'en': addressEn},
        'profile_image': profileImage,
      },
      'jop': {
        'title': {'ar': jopAr, 'en': jopEn},
      },
      'is_active': isActive,
    };
  }

  JudgeProfileModel copyWith({
    String? uid,
    String? email,
    String? nameAr,
    String? nameEn,
    String? jopAr,
    String? jopEn,
    String? phone,
    String? addressAr,
    String? addressEn,
    String? profileImage,
    String? nationalId,    
    String? employeeId,    
    bool? isActive,
    String? role,
    bool? isFirstLogin, 
  }) {
    return JudgeProfileModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      nameAr: nameAr ?? this.nameAr,
      nameEn: nameEn ?? this.nameEn,
      jopAr: jopAr ?? this.jopAr,
      jopEn: jopEn ?? this.jopEn,
      phone: phone ?? this.phone,
      addressAr: addressAr ?? this.addressAr,
      addressEn: addressEn ?? this.addressEn,
      profileImage: profileImage ?? this.profileImage,
      nationalId: nationalId ?? this.nationalId,    
      employeeId: employeeId ?? this.employeeId,    
      isActive: isActive ?? this.isActive,
      role: role ?? this.role,
      isFirstLogin: isFirstLogin ?? this.isFirstLogin, 
    );
  }
}