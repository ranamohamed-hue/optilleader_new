import 'package:cloud_firestore/cloud_firestore.dart';

class EmployeeModel {
  final String? uid;
  final String role; 
  final bool isFirstLogin;

  // 1. بيانات الهوية
  final String nameAr;
  final String nameEn;
  final String nationalityAr;
  final String nationalityEn;
  final String nationalId;
  final String employeeId;
  final DateTime? birthDate;
  final String profileImage;

  // 2. البيانات الوظيفية
  final String currentJobAr;
  final String currentJobEn;
  final String universityAr;
  final String universityEn;
  final String facultyAr;
  final String facultyEn;
  final bool? hasAdminExperience; 
  final bool? hasAdminTraining;   
  
  // 3. المؤهلات
  final String degree; 
  final String graduationYear;
  final int yearsOfAdminExperience; 

  // 4. بيانات التواصل
  final String email;
  final String phone;

  // 5. الأهلية والسلوك
  final bool hasCriminalRecord;
  final bool holdsPartyPosition;
  final bool disciplinaryClearance;
  final bool hasExcellentPerformanceReports; 
  final bool isOnVacation;
  final bool isActive;

  // 6. إثباتات الأدمن
  final bool? hasICDL;
  final bool? hasHealthCertificate;

  // 7. بيانات القطاع والإدارة الفرعية
  final String? adminSectorId;
  final String? adminSectorName;
  final String? adminSubDeptId;
  final String? adminSubDeptName;

  // 8. توقيتات النظام
  final DateTime createdAt;
  final DateTime? updatedAt;

  EmployeeModel({
    this.uid,
    this.role = 'admin_manager',
    this.isFirstLogin = true,
    required this.nameAr,
    required this.nameEn,
    required this.nationalityAr,
    required this.nationalityEn,
    required this.nationalId,
    required this.employeeId,
    this.birthDate,
    required this.profileImage,
    required this.currentJobAr,
    required this.currentJobEn,
    this.universityAr = '',
    this.universityEn = '',
    this.facultyAr = '',
    this.facultyEn = '',
    this.hasAdminExperience,
    this.hasAdminTraining,
    required this.degree,
    required this.graduationYear,
    this.yearsOfAdminExperience = 0,
    required this.email,
    required this.phone,
    this.hasCriminalRecord = false,
    this.holdsPartyPosition = false,
    this.disciplinaryClearance = true,
    this.hasExcellentPerformanceReports = false,
    this.isOnVacation = false,
    this.isActive = true,
    this.hasICDL,
    this.hasHealthCertificate,
    this.adminSectorId,
    this.adminSectorName,
    this.adminSubDeptId,
    this.adminSubDeptName,
    required this.createdAt,
    this.updatedAt,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json, String id) {
    DateTime? parseDate(dynamic dateField) {
      if (dateField == null) return null;
      if (dateField is Timestamp) return dateField.toDate();
      return DateTime.tryParse(dateField.toString());
    }

    final profile = json['profile'] as Map<String, dynamic>? ?? {};
    final adminProofs = json['admin_proofs'] as Map<String, dynamic>? ?? {};
    final adminData = json['admin_data'] as Map<String, dynamic>? ?? {};

    return EmployeeModel(
      uid: id,
      role: json['role'] ?? 'admin_manager',
      isFirstLogin: json['isFirstLogin'] ?? true,
      nameAr: profile['display_name']?['ar'] ?? '',
      nameEn: profile['display_name']?['en'] ?? '',
      nationalityAr: profile['nationality_ar'] ?? '',
      nationalityEn: profile['nationality_en'] ?? '',
      nationalId: json['national_id'] ?? '',
      employeeId: json['employee_id'] ?? '',
      birthDate: parseDate(profile['birth_date']),
      profileImage: profile['profile_image'] ?? '',
      currentJobAr: profile['current_job_ar'] ?? '',
      currentJobEn: profile['current_job_en'] ?? '',
      universityAr: profile['university_ar'] ?? '',
      universityEn: profile['university_en'] ?? '',
      facultyAr: profile['faculty_ar'] ?? '',
      facultyEn: profile['faculty_en'] ?? '',
      hasAdminExperience: adminProofs['has_admin_experience'],
      hasAdminTraining: adminProofs['has_admin_training'],
      degree: adminData['degree'] ?? '',
      graduationYear: adminData['graduation_year'] ?? '',
      yearsOfAdminExperience: adminData['years_of_experience'] ?? 0,
      email: json['university_email'] ?? '',
      phone: profile['phone']?['phone1'] ?? '',
      hasCriminalRecord: json['security_data']?['has_criminal_record'] ?? false,
      holdsPartyPosition: json['security_data']?['holds_party_position'] ?? false,
      disciplinaryClearance: json['eligibility_data']?['disciplinary_clearance'] ?? true,
      hasExcellentPerformanceReports: json['eligibility_data']?['has_excellent_performance'] ?? false,
      isOnVacation: json['eligibility_data']?['is_on_vacation'] ?? false,
      isActive: json['is_active'] ?? true,
      hasICDL: adminProofs['has_icdl'],
      hasHealthCertificate: adminProofs['has_health_certificate'],
      adminSectorId: adminData['sector_id'],
      adminSectorName: adminData['sector_name'],
      adminSubDeptId: adminData['sub_dept_id'],
      adminSubDeptName: adminData['sub_dept_name'],
      createdAt: parseDate(json['created_at']) ?? DateTime.now(),
      updatedAt: parseDate(json['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid ?? '',
      'role': role,
      'isFirstLogin': isFirstLogin,
      'university_email': email,
      'national_id': nationalId,
      'employee_id': employeeId,
      'is_active': isActive,
      'profile': {
        'display_name': {'ar': nameAr, 'en': nameEn},
        'phone': {'phone1': phone},
        'profile_image': profileImage,
        'nationality_ar': nationalityAr,
        'nationality_en': nationalityEn,
        'current_job_ar': currentJobAr,
        'current_job_en': currentJobEn,
        'university_ar': universityAr,
        'university_en': universityEn,
        'faculty_ar': facultyAr,
        'faculty_en': facultyEn,
        'birth_date': birthDate != null ? Timestamp.fromDate(birthDate!) : null,
      },
      'admin_data': {
        'degree': degree,
        'graduation_year': graduationYear,
        'years_of_experience': yearsOfAdminExperience,
        'sector_id': adminSectorId,
        'sector_name': adminSectorName,
        'sub_dept_id': adminSubDeptId,
        'sub_dept_name': adminSubDeptName,
      },
      'eligibility_data': {
        'disciplinary_clearance': disciplinaryClearance,
        'has_excellent_performance': hasExcellentPerformanceReports,
        'is_on_vacation': isOnVacation,
        'is_active': isActive,
      },
      'security_data': {
        'has_criminal_record': hasCriminalRecord,
        'holds_party_position': holdsPartyPosition,
      },
      'admin_proofs': {
        'has_icdl': hasICDL,
        'has_health_certificate': hasHealthCertificate,
        'has_admin_experience': hasAdminExperience,
        'has_admin_training': hasAdminTraining,
      },
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  EmployeeModel copyWith({
    String? uid,
    String? role,
    bool? isFirstLogin,
    String? nameAr,
    String? nameEn,
    String? nationalityAr,
    String? nationalityEn,
    String? nationalId,
    String? employeeId,
    DateTime? birthDate,
    String? profileImage,
    String? currentJobAr,
    String? currentJobEn,
    String? universityAr,
    String? universityEn,
    String? facultyAr,
    String? facultyEn,
    bool? hasAdminExperience,
    bool? hasAdminTraining,
    String? degree,
    String? graduationYear,
    int? yearsOfAdminExperience,
    String? email,
    String? phone,
    bool? hasCriminalRecord,
    bool? holdsPartyPosition,
    bool? disciplinaryClearance,
    bool? hasExcellentPerformanceReports,
    bool? isOnVacation,
    bool? isActive,
    bool? hasICDL,
    bool? hasHealthCertificate,
    String? adminSectorId,
    String? adminSectorName,
    String? adminSubDeptId,
    String? adminSubDeptName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EmployeeModel(
      uid: uid ?? this.uid,
      role: role ?? this.role,
      isFirstLogin: isFirstLogin ?? this.isFirstLogin,
      nameAr: nameAr ?? this.nameAr,
      nameEn: nameEn ?? this.nameEn,
      nationalityAr: nationalityAr ?? this.nationalityAr,
      nationalityEn: nationalityEn ?? this.nationalityEn,
      nationalId: nationalId ?? this.nationalId,
      employeeId: employeeId ?? this.employeeId,
      birthDate: birthDate ?? this.birthDate,
      profileImage: profileImage ?? this.profileImage,
      currentJobAr: currentJobAr ?? this.currentJobAr,
      currentJobEn: currentJobEn ?? this.currentJobEn,
      universityAr: universityAr ?? this.universityAr,
      universityEn: universityEn ?? this.universityEn,
      facultyAr: facultyAr ?? this.facultyAr,
      facultyEn: facultyEn ?? this.facultyEn,
      hasAdminExperience: hasAdminExperience ?? this.hasAdminExperience,
      hasAdminTraining: hasAdminTraining ?? this.hasAdminTraining,
      degree: degree ?? this.degree,
      graduationYear: graduationYear ?? this.graduationYear,
      yearsOfAdminExperience: yearsOfAdminExperience ?? this.yearsOfAdminExperience,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      hasCriminalRecord: hasCriminalRecord ?? this.hasCriminalRecord,
      holdsPartyPosition: holdsPartyPosition ?? this.holdsPartyPosition,
      disciplinaryClearance: disciplinaryClearance ?? this.disciplinaryClearance,
      hasExcellentPerformanceReports: hasExcellentPerformanceReports ?? this.hasExcellentPerformanceReports,
      isOnVacation: isOnVacation ?? this.isOnVacation,
      isActive: isActive ?? this.isActive,
      hasICDL: hasICDL ?? this.hasICDL,
      hasHealthCertificate: hasHealthCertificate ?? this.hasHealthCertificate,
      adminSectorId: adminSectorId ?? this.adminSectorId,
      adminSectorName: adminSectorName ?? this.adminSectorName,
      adminSubDeptId: adminSubDeptId ?? this.adminSubDeptId,
      adminSubDeptName: adminSubDeptName ?? this.adminSubDeptName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}