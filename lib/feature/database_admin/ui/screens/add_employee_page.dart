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
  bool get isDark => Theme.of(context).brightness == Brightness.dark; // ✅ إضافة الدارك مود

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
  final _sectorIdController = TextEditingController();
  final _sectorNameController = TextEditingController();
  final _subDeptIdController = TextEditingController();
  final _subDeptNameController = TextEditingController();

  File? _profileImage;
  String? _existingImageUrl;
  final ImagePicker _picker = ImagePicker();

  bool _hasCriminalRecord = false;
  bool _holdsPartyPosition = false;
  bool _disciplinaryClearance = true;
  bool _hasExcellentReports = false;

  bool _isReadOnly = true;

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
    _sectorIdController.text = e.adminSectorId ?? '';
    _sectorNameController.text = e.adminSectorName ?? '';
    _subDeptIdController.text = e.adminSubDeptId ?? '';
    _subDeptNameController.text = e.adminSubDeptName ?? '';
    _existingImageUrl = e.profileImage;
    _hasCriminalRecord = e.hasCriminalRecord;
    _holdsPartyPosition = e.holdsPartyPosition;
    _disciplinaryClearance = e.disciplinaryClearance;
    _hasExcellentReports = e.hasExcellentPerformanceReports;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

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
      yearsOfAdminExperience:
          int.tryParse(_experienceController.text.trim()) ?? 0,
      profileImage: _existingImageUrl ?? '',
      hasCriminalRecord: _hasCriminalRecord,
      holdsPartyPosition: _holdsPartyPosition,
      disciplinaryClearance: _disciplinaryClearance,
      hasExcellentPerformanceReports: _hasExcellentReports,
      adminSectorId: _sectorIdController.text.trim().isEmpty
          ? null
          : _sectorIdController.text.trim(),
      adminSectorName: _sectorNameController.text.trim().isEmpty
          ? null
          : _sectorNameController.text.trim(),
      adminSubDeptId: _subDeptIdController.text.trim().isEmpty
          ? null
          : _subDeptIdController.text.trim(),
      adminSubDeptName: _subDeptNameController.text.trim().isEmpty
          ? null
          : _subDeptNameController.text.trim(),
      createdAt: DateTime.now(),
    );

    if (_isEditing) {
      context.read<EmployeeDataCubit>().saveEmployeeData(employee);
      if (_profileImage != null) {
        context.read<EmployeeDataCubit>().uploadAndSetProfileImage(
          widget.existingUid!,
          _profileImage!,
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
    _sectorIdController.dispose();
    _sectorNameController.dispose();
    _subDeptIdController.dispose();
    _subDeptNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocListener<EmployeeDataCubit, EmployeeDataState>(
      listener: (context, state) {
        if (state is EmployeeLoaded &&
            _isEditing &&
            _nameArController.text.isEmpty) {
          _fillFieldsFromModel(state.employee);
        }
        if (state is EmployeeSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isEditing
                    ? 'add_employee.update_success'.tr()
                    : 'add_employee.success_message'.tr(),
              ),
              backgroundColor: Colors.green,
            ),
          );
          context.pop();
        } else if (state is EmployeeError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
                appBar: AppBar(
          title: Text(
            !_isEditing
                ? 'add_employee.title'.tr()       
                : (_isReadOnly
                    ? 'add_employee.view_title'.tr() 
                    : 'add_employee.edit_title'.tr()), 
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
                _buildSectionCard(
                  "add_employee.sections.identity".tr(),
                  Icons.person_pin_rounded,
                  [
                    _buildVerticalDoubleField(
                      "add_employee.fields.name_ar".tr(),
                      _nameArController,
                      "add_employee.fields.name_en".tr(),
                      _nameEnController,
                      Icons.person,
                    ),
                    SizedBox(height: 15.h),
                    _buildVerticalDoubleField(
                      "الجنسية",
                      _nationalityArController,
                      "Nationality",
                      _nationalityEnController,
                      Icons.flag,
                    ),
                    SizedBox(height: 15.h),
                    Row(
                      children: [
                        Expanded(
                          child: _buildField(
                            "add_employee.fields.national_id".tr(),
                            _nationalIdController,
                            Icons.badge,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: _buildField(
                            "add_employee.fields.employee_id".tr(),
                            _employeeIdController,
                            Icons.work_history,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // 2. بيانات التواصل
                _buildSectionCard(
                  "add_employee.sections.contact".tr(),
                  Icons.contact_phone,
                  [
                    _buildField(
                      "add_employee.fields.email".tr(),
                      _emailController,
                      Icons.alternate_email,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    _buildField(
                      "add_employee.fields.phone".tr(),
                      _phoneController,
                      Icons.phone_android,
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),

                // 3. البيانات الوظيفية والقطاع
                _buildSectionCard(
                  "add_employee.sections.job".tr(),
                  Icons.work,
                  [
                    _buildVerticalDoubleField(
                      "add_employee.fields.job_ar".tr(),
                      _jobArController,
                      "add_employee.fields.job_en".tr(),
                      _jobEnController,
                      Icons.work_outline,
                    ),
                    SizedBox(height: 15.h),
                    Text(
                      "add_employee.sections.sector".tr(),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isDark ? Colors.white70 : AppColors.navyLight, // ✅ تعديل اللون
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    _buildField(
                      "add_employee.fields.sector_id".tr(),
                      _sectorIdController,
                      Icons.domain,
                    ),
                    _buildField(
                      "add_employee.fields.sector_name".tr(),
                      _sectorNameController,
                      Icons.business,
                    ),
                    _buildField(
                      "add_employee.fields.sub_dept_id".tr(),
                      _subDeptIdController,
                      Icons.account_tree,
                    ),
                    _buildField(
                      "add_employee.fields.sub_dept_name".tr(),
                      _subDeptNameController,
                      Icons.corporate_fare,
                    ),
                  ],
                ),

                // 4. المؤهلات والخبرة
                _buildSectionCard(
                  "add_employee.sections.qualification".tr(),
                  Icons.school,
                  [
                    _buildField(
                      "add_employee.fields.degree".tr(),
                      _degreeController,
                      Icons.military_tech,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _buildField(
                            "add_employee.fields.grad_year".tr(),
                            _gradYearController,
                            Icons.calendar_today,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: _buildField(
                            "add_employee.fields.experience_years".tr(),
                            _experienceController,
                            Icons.timelapse,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // 5. الأهلية والسلوك
                _buildSectionCard(
                  "add_employee.sections.eligibility".tr(),
                  Icons.verified_user,
                  [
                    _buildSwitch(
                      "add_employee.switches.criminal_record".tr(),
                      _hasCriminalRecord,
                      (v) => setState(() => _hasCriminalRecord = v),
                    ),
                    _buildSwitch(
                      "add_employee.switches.party_position".tr(),
                      _holdsPartyPosition,
                      (v) => setState(() => _holdsPartyPosition = v),
                    ),
                    _buildSwitch(
                      "add_employee.switches.disciplinary_clearance".tr(),
                      !_disciplinaryClearance,
                      (v) => setState(() => _disciplinaryClearance = !v),
                    ),
                    _buildSwitch(
                      "add_employee.switches.excellent_reports".tr(),
                      _hasExcellentReports,
                      (v) => setState(() => _hasExcellentReports = v),
                    ),
                  ],
                ),

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

  // ==========================================
  // ✅ ويدجتات مطابقة لتصميم AddDoctorPage
  // ==========================================

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
            child:
                (_profileImage == null &&
                    (_existingImageUrl == null || _existingImageUrl!.isEmpty))
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
      color: isDark ? const Color(0xFF1E1E2E) : Colors.white, // ✅ لون الكارت
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
                Text(
                  title,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: isDark ? Colors.white : AppColors.navyDark, // ✅ لون العنوان
                  ),
                ),
              ],
            ),
            Divider(height: 30, color: isDark ? Colors.white24 : Colors.grey.shade300), // ✅ لون الفاصل
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController ctrl,
    IconData? icon, {
    bool isEn = false,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: TextFormField(
        controller: ctrl,
        keyboardType: keyboardType,
        enabled: !_isReadOnly,
        textAlign: isEn
            ? TextAlign.left
            : (isArabic ? TextAlign.right : TextAlign.left),
        validator: _isReadOnly
            ? null
            : (v) =>
                  (v == null || v.isEmpty) ? 'validation.required'.tr() : null,
        style: AppTextStyles.bodyMedium.copyWith(
          color: _isReadOnly
              ? (isDark ? Colors.white54 : Colors.grey) // ✅ لون النص إذا كان للقراءة فقط
              : (isDark ? Colors.white : AppColors.navyDark), // ✅ لون النص العادي
        ),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null
              ? Icon(icon, color: isDark ? Colors.white70 : AppColors.navyLight) // ✅ لون الأيقونة
              : null,
          labelStyle: AppTextStyles.bodySmall.copyWith(
            color: isDark ? Colors.white70 : AppColors.navyLight, // ✅ لون التسمية
          ),
          filled: _isReadOnly,
          fillColor: _isReadOnly
              ? (isDark ? Colors.grey.shade800 : Colors.grey.shade200) // ✅ لون الخلفية للقراءة فقط
              : (isDark ? const Color(0xFF2A2A3E) : Colors.white), // ✅ لون الخلفية العادي
          
          // ✅ إضافة البوردرز زي ما الدكتور بالظبط
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(
              color: isDark ? Colors.white24 : Colors.grey.shade300,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: AppColors.darkGold, width: 1.5),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(
              color: isDark ? Colors.white24 : Colors.grey.shade300,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalDoubleField(
    String labelAr,
    TextEditingController ctrlAr,
    String labelEn,
    TextEditingController ctrlEn,
    IconData icon,
  ) {
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
      title: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(
          color: isDark ? Colors.white : AppColors.navyDark, // ✅ لون نص السويتش
        ),
      ),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: isLoading
                ? const CircularProgressIndicator(color: AppColors.darkGold) // ✅ لون اللودر
                : Text(
                    _isEditing
                        ? 'add_employee.update_data'.tr()
                        : 'add_employee.save_data'.tr(),
                    style: TextStyle(
                      color: AppColors.darkGold, // ✅ لون نص الزر
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        );
      },
    );
  }
}