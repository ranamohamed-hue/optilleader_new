import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:optialeader/core/theming/app_color.dart';
import 'package:optialeader/core/theming/app_text_style.dart';
import 'package:optialeader/feature/database_admin/data/models/employee_model.dart';
import 'package:optialeader/feature/database_admin/logic/employee_logic/employee_cubit.dart';
import 'package:optialeader/feature/database_admin/logic/employee_logic/employee_state.dart';
import 'package:optialeader/feature/admin/ui/announces/administrative_roles_data.dart';

class AddEmployeePage extends StatefulWidget {
  final String? existingUid;
  final bool isViewMode;

  const AddEmployeePage({super.key, this.existingUid, this.isViewMode = false});

  @override
  State<AddEmployeePage> createState() => _AddEmployeePageState();
}

class _AddEmployeePageState extends State<AddEmployeePage> {
  final _formKey = GlobalKey<FormState>();

  bool get _isEditing => widget.existingUid != null;
  bool get _isViewing => widget.isViewMode;
  bool get isArabic => context.locale.languageCode == 'ar';
  bool get isDark => Theme.of(context).brightness == Brightness.dark;

  final _nameArController = TextEditingController();
  final _nameEnController = TextEditingController();
  final _nationalityArController = TextEditingController(text: 'مصري');
  final _nationalityEnController = TextEditingController(text: 'Egyptian');
  final _nationalIdController = TextEditingController();
  final _employeeIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _jobArController = TextEditingController();
  final _jobEnController = TextEditingController();
  final _degreeController = TextEditingController(text: 'بكالوريوس');
  final _gradYearController = TextEditingController();
  final _experienceController = TextEditingController(text: '10');

  File? _profileImage;
  String? _existingImageUrl;
  final ImagePicker _picker = ImagePicker();

  bool _hasCriminalRecord = false;
  bool _holdsPartyPosition = false;
  bool _disciplinaryClearance = true;
  bool _hasExcellentReports = false;

  bool _isReadOnly = true;

  // ═══════════════════════════════════════════════════════
  // ✅✅✅ الشروط الجديدة (Booleans)
  // ═══════════════════════════════════════════════════════
  bool _hasAdminExp = false;
  bool _hasICDL = false;
  bool _hasAdminTraining = false;
  bool _hasHealthCert = false;
  bool _hasParticipation = false;

  // ═══════════════════════════════════════════════════════
  // ✅✅✅ روابط المستندات المرفوعة
  // ═══════════════════════════════════════════════════════
  final Map<String, List<String>> _docUrls = {
    'icdl': [],
    'admin_training': [],
    'health': [],
    'admin_experience': [],
    'performance_reports': [],
    'participation': [],
  };

  final Map<String, bool> _isUploading = {
    'icdl': false,
    'admin_training': false,
    'health': false,
    'admin_experience': false,
    'performance_reports': false,
    'participation': false,
  };

  // ═══════════════════════════════════════════════════════
  // ✅✅✅ القطاع والإدارة الفرعية (Dropdowns)
  // ═══════════════════════════════════════════════════════
  String? _selectedSectorId;
  String? _selectedSubDeptId;

  @override
  void initState() {
    super.initState();
    _isReadOnly = widget.isViewMode;
    if (_isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<EmployeeDataCubit>().getEmployeeProfile(
          widget.existingUid!,
        );
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (pickedFile != null) {
      if (_isEditing && widget.existingUid != null) {
        context.read<EmployeeDataCubit>().uploadAndSetProfileImage(
          widget.existingUid!,
          File(pickedFile.path),
        );
      } else {
        setState(() {
          _profileImage = File(pickedFile.path);
          _existingImageUrl = '';
        });
      }
    }
  }

  // ═══════════════════════════════════════════════════════
  // ✅ رفع مستند ثبوتي
  // ═══════════════════════════════════════════════════════
  Future<void> _pickAndUploadDocument(String docType) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (pickedFile == null) return;

      final file = File(pickedFile.path);
      final uid = widget.existingUid ?? 'temp';

      setState(() => _isUploading[docType] = true);

      final result = await context
          .read<EmployeeDataCubit>()
          .uploadProofDocument(file: file, uid: uid, docType: docType);

      if (!mounted) return;
      setState(() => _isUploading[docType] = false);

      result.fold(
        (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error), backgroundColor: AppColors.error),
          );
        },
        (url) {
          setState(() => _docUrls[docType]!.add(url));
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploading[docType] = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
      );
    }
  }

  void _removeDocument(String docType, int index) {
    setState(() => _docUrls[docType]!.removeAt(index));
  }

  void _fillFieldsFromModel(EmployeeModel e) {
    _nameArController.text = e.nameAr;
    _nameEnController.text = e.nameEn;
    _nationalityArController.text = e.nationalityAr;
    _nationalityEnController.text = e.nationalityEn;
    _nationalIdController.text = e.nationalId;
    _employeeIdController.text = e.employeeId;
    _emailController.text = e.email;
    _phoneController.text = e.phone;
    _jobArController.text = e.currentJobAr;
    _jobEnController.text = e.currentJobEn;
    _degreeController.text = e.degree;
    _gradYearController.text = e.graduationYear;
    _experienceController.text = e.yearsOfAdminExperience.toString();
    _existingImageUrl = e.profileImage;
    _hasCriminalRecord = e.hasCriminalRecord;
    _holdsPartyPosition = e.holdsPartyPosition;
    _disciplinaryClearance = e.disciplinaryClearance;
    _hasExcellentReports = e.hasExcellentPerformanceReports;

    // ✅ الشروط الجديدة
    _hasAdminExp = e.hasAdminExperience ?? false;
    _hasICDL = e.hasICDL ?? false;
    _hasAdminTraining = e.hasAdminTraining ?? false;
    _hasHealthCert = e.hasHealthCertificate ?? false;
    _hasParticipation = e.hasParticipationProof ?? false;

    // ✅ المستندات
    _docUrls['icdl'] = e.icdlCertificateUrl != null ? [e.icdlCertificateUrl!] : [];
    _docUrls['admin_training'] = List.from(e.adminTrainingCertUrls);
    _docUrls['health'] = e.healthCertificateUrl != null ? [e.healthCertificateUrl!] : [];
    _docUrls['admin_experience'] = List.from(e.adminExperienceDocUrls);
    _docUrls['performance_reports'] = List.from(e.performanceReportUrls);
    _docUrls['participation'] = List.from(e.participationDocUrls);

    // ✅ القطاع والإدارة الفرعية
    _selectedSectorId = e.adminSectorId;
    _selectedSubDeptId = e.adminSubDeptId;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    // ✅ أسماء القطاع والإدارة من الـ Data
    final sectorName = _selectedSectorId != null
        ? AdministrativeRolesData.getDepartmentNameById(_selectedSectorId!, isArabic: isArabic)
        : null;
    final subDeptName = (_selectedSectorId != null && _selectedSubDeptId != null)
        ? AdministrativeRolesData.getSubDepartmentNameById(
            departmentId: _selectedSectorId!,
            subDepartmentId: _selectedSubDeptId!,
            isArabic: isArabic,
          )
        : null;

    final employee = EmployeeModel(
      uid: _isEditing ? widget.existingUid! : '',
      nameAr: _nameArController.text.trim(),
      nameEn: _nameEnController.text.trim(),
      nationalityAr: _nationalityArController.text.trim(),
      nationalityEn: _nationalityEnController.text.trim(),
      nationalId: _nationalIdController.text.trim(),
      employeeId: _employeeIdController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      currentJobAr: _jobArController.text.trim(),
      currentJobEn: _jobEnController.text.trim(),
      degree: _degreeController.text.trim(),
      graduationYear: _gradYearController.text.trim(),
      yearsOfAdminExperience: int.tryParse(_experienceController.text.trim()) ?? 0,
      profileImage: _existingImageUrl ?? '',
      hasCriminalRecord: _hasCriminalRecord,
      holdsPartyPosition: _holdsPartyPosition,
      disciplinaryClearance: _disciplinaryClearance,
      hasExcellentPerformanceReports: _hasExcellentReports,
      // ✅ الشروط الجديدة
      hasAdminExperience: _hasAdminExp,
      hasICDL: _hasICDL,
      hasAdminTraining: _hasAdminTraining,
      hasHealthCertificate: _hasHealthCert,
      hasParticipationProof: _hasParticipation,
      // ✅ القطاع والإدارة
      adminSectorId: _selectedSectorId,
      adminSectorName: sectorName,
      adminSubDeptId: _selectedSubDeptId,
      adminSubDeptName: subDeptName,
      // ✅ روابط المستندات
      icdlCertificateUrl: _docUrls['icdl']!.isNotEmpty ? _docUrls['icdl']!.last : null,
      adminTrainingCertUrls: _docUrls['admin_training']!,
      healthCertificateUrl: _docUrls['health']!.isNotEmpty ? _docUrls['health']!.last : null,
      adminExperienceDocUrls: _docUrls['admin_experience']!,
      performanceReportUrls: _docUrls['performance_reports']!,
      participationDocUrls: _docUrls['participation']!,
      createdAt: DateTime.now(),
    );

    if (_isEditing) {
      context.read<EmployeeDataCubit>().saveEmployeeData(employee);
      if (_profileImage != null) {
        context.read<EmployeeDataCubit>().uploadAndSetProfileImage(
          widget.existingUid!, _profileImage!,
        );
      }
    } else {
      context.read<EmployeeDataCubit>().createNewEmployee(
        employee,
        profileImageFile: _profileImage,
      );
    }
  }

  @override
  void dispose() {
    _nameArController.dispose();
    _nameEnController.dispose();
    _nationalityArController.dispose();
    _nationalityEnController.dispose();
    _nationalIdController.dispose();
    _employeeIdController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _jobArController.dispose();
    _jobEnController.dispose();
    _degreeController.dispose();
    _gradYearController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocListener<EmployeeDataCubit, EmployeeDataState>(
      listener: (context, state) {
        if (state is EmployeeLoaded && _isEditing && _nameArController.text.isEmpty) {
          _fillFieldsFromModel(state.employee);
        }
        if (state is EmployeeSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isEditing ? 'add_employee.update_success'.tr() : 'add_employee.success_message'.tr()),
              backgroundColor: Colors.green,
            ),
          );
          context.pop();
        } else if (state is EmployeeError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error), backgroundColor: AppColors.error),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            !_isEditing
                ? 'add_employee.title'.tr()
                : (_isReadOnly ? 'add_employee.view_title'.tr() : 'add_employee.edit_title'.tr()),
            style: theme.appBarTheme.titleTextStyle,
          ),
          actions: [
            if (widget.existingUid != null)
              IconButton(
                icon: Icon(_isReadOnly ? Icons.edit : Icons.lock_open),
                onPressed: () => setState(() => _isReadOnly = !_isReadOnly),
              ),
          ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          physics: const BouncingScrollPhysics(),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildProfileImage(),
                SizedBox(height: 20.h),

                // 1. بيانات الهوية
                _buildSectionCard("add_employee.sections.identity".tr(), Icons.person_pin_rounded, [
                  _buildVerticalDoubleField("add_employee.fields.name_ar".tr(), _nameArController, "add_employee.fields.name_en".tr(), _nameEnController, Icons.person),
                  SizedBox(height: 15.h),
                  _buildVerticalDoubleField("الجنسية", _nationalityArController, "Nationality", _nationalityEnController, Icons.flag),
                  SizedBox(height: 15.h),
                  Row(
                    children: [
                      Expanded(child: _buildField("add_employee.fields.national_id".tr(), _nationalIdController, Icons.badge, keyboardType: TextInputType.number)),
                      SizedBox(width: 10.w),
                      Expanded(child: _buildField("add_employee.fields.employee_id".tr(), _employeeIdController, Icons.work_history, keyboardType: TextInputType.number)),
                    ],
                  ),
                ]),

                // 2. بيانات التواصل
                _buildSectionCard("add_employee.sections.contact".tr(), Icons.contact_phone, [
                  _buildField("add_employee.fields.email".tr(), _emailController, Icons.alternate_email, keyboardType: TextInputType.emailAddress),
                  _buildField("add_employee.fields.phone".tr(), _phoneController, Icons.phone_android, keyboardType: TextInputType.phone),
                ]),

                // 3. البيانات الوظيفية والقطاع (بها DropDowns)
                _buildSectionCard("add_employee.sections.job".tr(), Icons.work, [
                  _buildVerticalDoubleField("add_employee.fields.job_ar".tr(), _jobArController, "add_employee.fields.job_en".tr(), _jobEnController, Icons.work_outline),
                  SizedBox(height: 15.h),
                  Text("add_employee.sections.sector".tr(), style: AppTextStyles.bodyMedium.copyWith(color: isDark ? Colors.white70 : AppColors.navyLight, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10.h),
                  _buildSectorDropdown(),
                  SizedBox(height: 12.h),
                  _buildSubDeptDropdown(),
                ]),

                // 4. المؤهلات والخبرة
                _buildSectionCard("add_employee.sections.qualification".tr(), Icons.school, [
                  _buildField("add_employee.fields.degree".tr(), _degreeController, Icons.military_tech),
                  Row(
                    children: [
                      Expanded(child: _buildField("add_employee.fields.grad_year".tr(), _gradYearController, Icons.calendar_today, keyboardType: TextInputType.number)),
                      SizedBox(width: 10.w),
                      Expanded(child: _buildField("add_employee.fields.experience_years".tr(), _experienceController, Icons.timelapse, keyboardType: TextInputType.number)),
                    ],
                  ),
                ]),

                // ✅✅✅ 5. الشروط الأهلية والمستندات الثبوتية ✅✅✅
                _buildSectionCard("add_employee.sections.eligibility_docs".tr(), Icons.verified_user, [
                  _buildDocUploadCard(
                    title: 'add_employee.cond.admin_exp'.tr(),
                    desc: 'يرفق: السيرة الذاتية + خطابات الخبرة',
                    isEnabled: _hasAdminExp,
                    onToggle: (v) => setState(() => _hasAdminExp = v),
                    docType: 'admin_experience',
                    allowMultiple: true,
                  ),
                  SizedBox(height: 10.h),
                  _buildDocUploadCard(
                    title: 'add_employee.cond.icdl'.tr(),
                    desc: 'يرفق: صورة شهادة ICDL',
                    isEnabled: _hasICDL,
                    onToggle: (v) => setState(() => _hasICDL = v),
                    docType: 'icdl',
                    allowMultiple: false,
                  ),
                  SizedBox(height: 10.h),
                  _buildDocUploadCard(
                    title: 'add_employee.cond.perf'.tr(),
                    desc: 'يرفق: صور تقارير الأداء السنوية',
                    isEnabled: _hasExcellentReports,
                    onToggle: (v) => setState(() => _hasExcellentReports = v),
                    docType: 'performance_reports',
                    allowMultiple: true,
                  ),
                  SizedBox(height: 10.h),
                  _buildDocUploadCard(
                    title: 'add_employee.cond.participation'.tr(),
                    desc: 'يرفق: شهادات المشاركة أو خطابات تكليف',
                    isEnabled: _hasParticipation,
                    onToggle: (v) => setState(() => _hasParticipation = v),
                    docType: 'participation',
                    allowMultiple: true,
                  ),
                  SizedBox(height: 10.h),
                  _buildDocUploadCard(
                    title: 'add_employee.cond.training'.tr(),
                    desc: 'يرفع: شهادات الدورات التدريبية',
                    isEnabled: _hasAdminTraining,
                    onToggle: (v) => setState(() => _hasAdminTraining = v),
                    docType: 'admin_training',
                    allowMultiple: true,
                  ),
                  SizedBox(height: 10.h),
                  _buildDocUploadCard(
                    title: 'add_employee.cond.health'.tr(),
                    desc: 'يرفق: صورة الشهادة الصحية',
                    isEnabled: _hasHealthCert,
                    onToggle: (v) => setState(() => _hasHealthCert = v),
                    docType: 'health',
                    allowMultiple: false,
                  ),
                ]),

                // 6. الأهلية والسلوك (تلقائية بدون مستندات)
                _buildSectionCard("add_employee.sections.eligibility".tr(), Icons.gavel, [
                  _buildSwitch("add_employee.switches.criminal_record".tr(), _hasCriminalRecord, (v) => setState(() => _hasCriminalRecord = v)),
                  _buildSwitch("add_employee.switches.party_position".tr(), _holdsPartyPosition, (v) => setState(() => _holdsPartyPosition = v)),
                  _buildSwitch("add_employee.switches.disciplinary_clearance".tr(), !_disciplinaryClearance, (v) => setState(() => _disciplinaryClearance = !v)),
                ]),

                SizedBox(height: 30.h),
                if (!_isReadOnly) _buildSaveButton(),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
   // ═══════════════════════════════════════════════════════
  // ✅✅✅ Dropdown القطاع (محمي من الخطأ)
  // ═══════════════════════════════════════════════════════
  Widget _buildSectorDropdown() {
    // ✅ نتأكد إن القيمة موجودة فعلاً في القائمة عشان مفيش Assertion Error
    final validIds = AdministrativeRolesData.departments.map((d) => d.id).toSet();
    final safeValue = validIds.contains(_selectedSectorId) ? _selectedSectorId : null;

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: DropdownButtonFormField<String>(
        value: safeValue, // ✅ استخدمنا safeValue بدل _selectedSectorId مباشرة
        isExpanded: true,
        decoration: _dropdownDecoration("add_employee.fields.sector_name".tr(), Icons.business),
        items: AdministrativeRolesData.departments.map((dept) {
          return DropdownMenuItem(
            value: dept.id,
            child: Text(
              isArabic ? dept.nameAr : dept.nameEn,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? Colors.white : AppColors.navyDark,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: _isReadOnly
            ? null
            : (val) {
                setState(() {
                  _selectedSectorId = val;
                  _selectedSubDeptId = null; 
                });
              },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // ✅✅✅ Dropdown الإدارة الفرعية (محمي من الخطأ)
  // ═══════════════════════════════════════════════════════
  Widget _buildSubDeptDropdown() {
    final subs = _selectedSectorId != null
        ? AdministrativeRolesData.getSubDepartmentsByDepartmentId(_selectedSectorId!)
        : <AdminSubDepartmentData>[];

    // ✅ نفس الحماية للإدارة الفرعية
    final validSubIds = subs.map((s) => s.id).toSet();
    final safeSubValue = validSubIds.contains(_selectedSubDeptId) ? _selectedSubDeptId : null;

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: DropdownButtonFormField<String>(
        value: safeSubValue, // ✅ استخدمنا safeSubValue
        isExpanded: true,
        hint: Text(
          'add_employee.fields.sub_dept_name'.tr(),
          style: AppTextStyles.bodySmall.copyWith(color: isDark ? Colors.white54 : AppColors.navyLight),
        ),
        decoration: _dropdownDecoration("add_employee.fields.sub_dept_name".tr(), Icons.corporate_fare),
        items: subs.map((sub) {
          return DropdownMenuItem(
            value: sub.id,
            child: Text(
              isArabic ? sub.nameAr : sub.nameEn,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? Colors.white : AppColors.navyDark,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: _isReadOnly || _selectedSectorId == null
            ? null
            : (val) => setState(() => _selectedSubDeptId = val),
      ),
    );
  }
  /// ✅ دالة تصميم الـ Dropdown موحدة
  InputDecoration _dropdownDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: isDark ? Colors.white70 : AppColors.navyLight, size: 20.sp),
      labelStyle: AppTextStyles.bodySmall.copyWith(color: isDark ? Colors.white70 : AppColors.navyLight),
      filled: true,
      fillColor: _isReadOnly
          ? (isDark ? Colors.grey.shade800 : Colors.grey.shade200)
          : (isDark ? const Color(0xFF2A2A3E) : Colors.white),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: AppColors.darkGold, width: 1.5),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // ✅✅✅ كارت رفع المستندات (مطابق لستايل الصفحة)
  // ═══════════════════════════════════════════════════════
  Widget _buildDocUploadCard({
    required String title,
    required String desc,
    required bool isEnabled,
    required ValueChanged<bool> onToggle,
    required String docType,
    required bool allowMultiple,
  }) {
    final urls = _docUrls[docType]!;
    final uploading = _isUploading[docType]!;

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252538) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isEnabled ? AppColors.darkGold.withOpacity(0.5) : (isDark ? Colors.white24 : Colors.grey.shade300),
          width: isEnabled ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان + السويتش
          Row(
            children: [
              Expanded(
                child: Text(title, style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark ? Colors.white : AppColors.navyDark,
                  fontWeight: FontWeight.w600,
                )),
              ),
              Switch(
                value: isEnabled,
                onChanged: _isReadOnly ? null : onToggle,
                activeColor: AppColors.darkGold,
                inactiveThumbColor: isDark ? Colors.white54 : Colors.grey.shade400,
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(desc, style: AppTextStyles.bodySmall.copyWith(color: isDark ? Colors.white54 : AppColors.navyLight)),

          // منطقة الرفع والمعاينة
          if (isEnabled) ...[
            SizedBox(height: 10.h),
            if (allowMultiple || urls.isEmpty)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: uploading || _isReadOnly ? null : () => _pickAndUploadDocument(docType),
                  icon: uploading
                      ? SizedBox(width: 16.sp, height: 16.sp, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.darkGold))
                      : Icon(Icons.upload_file_outlined, size: 18.sp, color: AppColors.darkGold),
                  label: Text(
                    uploading ? 'جاري الرفع...' : 'رفع مستند',
                    style: AppTextStyles.bodySmall.copyWith(color: uploading ? (isDark ? Colors.white54 : Colors.grey) : AppColors.darkGold),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.darkGold.withOpacity(0.4)),
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                  ),
                ),
            ),
            if (urls.isNotEmpty) ...[
              SizedBox(height: 10.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: urls.asMap().entries.map((entry) {
                  return _buildDocThumbnail(
                    url: entry.value,
                    onRemove: _isReadOnly ? () {} : () => _removeDocument(docType, entry.key),
                    canRemove: !_isReadOnly,
                  );
                }).toList(),
              ),
            ],
          ],
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // ✅ صورة مصغرة للمستند
  // ═══════════════════════════════════════════════════════
  Widget _buildDocThumbnail({required String url, required VoidCallback onRemove, required bool canRemove}) {
    return Stack(
      children: [
        Container(
          width: 70.w,
          height: 70.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: AppColors.darkGold.withOpacity(0.3)),
            color: isDark ? const Color(0xFF2A2A3E) : Colors.grey.shade100,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(9.r),
            child: CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              placeholder: (_, __) => Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.darkGold)),
              errorWidget: (_, __, ___) => Icon(Icons.broken_image_outlined, color: isDark ? Colors.white54 : Colors.grey, size: 24.sp),
            ),
          ),
        ),
        if (canRemove)
          Positioned(
            top: -4.h,
            right: -4.w,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(color: AppColors.error, shape: BoxShape.circle, border: Border.all(color: isDark ? const Color(0xFF1E1E2E) : Colors.white, width: 2)),
                child: Icon(Icons.close, size: 10.sp, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════
  // ويدجتات الأصلية (بدون تعديل)
  // ═══════════════════════════════════════════════════════

  Widget _buildProfileImage() {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 50.r,
            backgroundColor: AppColors.navyLight.withOpacity(0.2),
            backgroundImage: _profileImage != null
                ? FileImage(_profileImage!) as ImageProvider
                : (_existingImageUrl != null && _existingImageUrl!.isNotEmpty
                    ? CachedNetworkImageProvider(_existingImageUrl!)
                    : null),
            child: (_profileImage == null && (_existingImageUrl == null || _existingImageUrl!.isEmpty))
                ? Icon(Icons.person, size: 50.sp, color: AppColors.navyLight)
                : null,
          ),
          if (!_isReadOnly)
            Positioned(
              bottom: 0,
              right: 0,
              child: CircleAvatar(
                radius: 18.r,
                backgroundColor: AppColors.darkGold,
                child: IconButton(
                  icon: Icon(Icons.camera_alt, size: 18.r, color: Colors.white),
                  onPressed: _pickImage,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, IconData icon, List<Widget> children) {
    return Card(
      color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
      margin: EdgeInsets.only(bottom: 20.h),
      child: Padding(
        padding: EdgeInsets.all(18.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.darkGold, size: 22.sp),
                SizedBox(width: 10.w),
                Text(title, style: AppTextStyles.titleMedium.copyWith(color: isDark ? Colors.white : AppColors.navyDark)),
              ],
            ),
            Divider(height: 30, color: isDark ? Colors.white24 : Colors.grey.shade300),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, IconData? icon, {bool isEn = false, TextInputType? keyboardType}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: TextFormField(
        controller: ctrl,
        keyboardType: keyboardType,
        enabled: !_isReadOnly,
        textAlign: isEn ? TextAlign.left : (isArabic ? TextAlign.right : TextAlign.left),
        validator: _isReadOnly ? null : (v) => (v == null || v.isEmpty) ? 'validation.required'.tr() : null,
        style: AppTextStyles.bodyMedium.copyWith(
          color: _isReadOnly ? (isDark ? Colors.white54 : Colors.grey) : (isDark ? Colors.white : AppColors.navyDark),
        ),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon, color: isDark ? Colors.white70 : AppColors.navyLight) : null,
          labelStyle: AppTextStyles.bodySmall.copyWith(color: isDark ? Colors.white70 : AppColors.navyLight),
          filled: true,
          fillColor: _isReadOnly
              ? (isDark ? Colors.grey.shade800 : Colors.grey.shade200)
              : (isDark ? const Color(0xFF2A2A3E) : Colors.white),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: AppColors.darkGold, width: 1.5)),
          disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300)),
        ),
      ),
    );
  }

  Widget _buildVerticalDoubleField(String labelAr, TextEditingController ctrlAr, String labelEn, TextEditingController ctrlEn, IconData icon) {
    return Column(
      children: [
        _buildField(labelAr, ctrlAr, icon),
        SizedBox(height: 8.h),
        _buildField(labelEn, ctrlEn, null, isEn: true),
      ],
    );
  }

  Widget _buildSwitch(String title, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title, style: AppTextStyles.bodyMedium.copyWith(color: isDark ? Colors.white : AppColors.navyDark)),
      value: value,
      onChanged: _isReadOnly ? null : onChanged,
      contentPadding: EdgeInsets.zero,
      activeColor: AppColors.darkGold,
    );
  }

  Widget _buildSaveButton() {
    
    return BlocBuilder<EmployeeDataCubit, EmployeeDataState>(
      builder: (context, state) {
        bool isLoading = state is EmployeeLoading;
        return SizedBox(
          width: double.infinity,
          height: 50.h,
          child: ElevatedButton(
            onPressed: isLoading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.navyDark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
            child: isLoading
                ? const CircularProgressIndicator(color: AppColors.darkGold)
                : Text(
                    _isEditing ? 'add_employee.update_data'.tr() : 'add_employee.save_data'.tr(),
                    style: TextStyle(color: AppColors.darkGold, fontSize: 16.sp, fontWeight: FontWeight.bold),
                  ),
          ),
        );
      },
    );
  }
}