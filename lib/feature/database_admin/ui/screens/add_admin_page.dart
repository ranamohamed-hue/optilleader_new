import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:optialeader/core/theming/app_color.dart';
import 'package:optialeader/core/theming/app_text_style.dart';
import 'package:optialeader/feature/database_admin/data/models/admin_profile_model.dart';
import 'package:optialeader/feature/database_admin/logic/admin_data/admin_data_cubit.dart';
import 'package:optialeader/feature/database_admin/logic/admin_data/admin_data_state.dart';
import 'dart:ui' as ui;

class AddAdminPage extends StatefulWidget {
  final String? existingUid;
  final bool isViewMode;

  const AddAdminPage({super.key, this.existingUid, this.isViewMode = false});

  @override
  State<AddAdminPage> createState() => _AddAdminPageState();
}

class _AddAdminPageState extends State<AddAdminPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _nameArController = TextEditingController();
  final _nameEnController = TextEditingController();
  final _phoneController = TextEditingController();
  final _jobTitleArController = TextEditingController();
  final _jobTitleEnController = TextEditingController();
  final _addressArController = TextEditingController();
  final _addressEnController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _employeeIdController = TextEditingController();

  bool get isArabic => context.locale.languageCode == 'ar';
  bool get isEditing => widget.existingUid != null;
  bool get isDark => Theme.of(context).brightness == Brightness.dark;

  bool _isReadOnly = true;
  String _currentImageUrl = '';
  bool _isSubmitting = false;
  bool _isProfileLoaded = false;
  @override
  @override
  void initState() {
    super.initState();

    debugPrint('🔥 AddAdminPage initState');
    debugPrint('🔥 existingUid = ${widget.existingUid}');
    debugPrint('🔥 isViewMode = ${widget.isViewMode}');

    _isReadOnly = widget.isViewMode;

    if (isEditing) {
      context.read<AdminDataCubit>().getAdminProfile(widget.existingUid!);
    } else {
      _isProfileLoaded = true;
    }
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.r),
        ),
        backgroundColor: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: AppColors.error,
              size: 28.sp,
            ),
            SizedBox(width: 10.w),
            Text(
              "add_admin.confirm_delete_title".tr(),
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.navyDark,
              ),
            ),
          ],
        ),
        content: Text(
          "add_admin.confirm_delete_msg".tr(),
          style: AppTextStyles.bodyMedium.copyWith(
            color: isDark ? Colors.white70 : AppColors.navyDark,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              "add_admin.cancel".tr(),
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.navyLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AdminDataCubit>().deleteAdmin(widget.existingUid!);
            },
            child: Text(
              "add_admin.confirm".tr(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameArController.dispose();
    _nameEnController.dispose();
    _phoneController.dispose();
    _jobTitleArController.dispose();
    _jobTitleEnController.dispose();
    _addressArController.dispose();
    _addressEnController.dispose();
    _nationalIdController.dispose();
    _employeeIdController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (pickedFile != null && widget.existingUid != null) {
      context.read<AdminDataCubit>().updateAdminProfileImage(
        widget.existingUid!,
        File(pickedFile.path),
      );
    }
  }

  void _populateFields(AdminProfileModel admin) {
    debugPrint('========== POPULATE ADMIN ==========');
    debugPrint('nameAr: ${admin.nameAr}');
    debugPrint('nameEn: ${admin.nameEn}');
    debugPrint('email: ${admin.email}');
    debugPrint('phone: ${admin.phone}');
    debugPrint('jobAr: ${admin.jopAr}');
    debugPrint('jobEn: ${admin.jopEn}');
    debugPrint('addressAr: ${admin.addressAr}');
    debugPrint('addressEn: ${admin.addressEn}');
    debugPrint('nationalId: ${admin.nationalId}');
    debugPrint('employeeId: ${admin.employeeId}');
    debugPrint('image: ${admin.profileImage}');

    _nameArController.text = admin.nameAr;
    _nameEnController.text = admin.nameEn;
    _emailController.text = admin.email;
    _phoneController.text = admin.phone;
    _jobTitleArController.text = admin.jopAr;
    _jobTitleEnController.text = admin.jopEn;
    _addressArController.text = admin.addressAr;
    _addressEnController.text = admin.addressEn;
    _nationalIdController.text = admin.nationalId;
    _employeeIdController.text = admin.employeeId;
    _currentImageUrl = admin.profileImage;

    debugPrint('========== FIELDS POPULATED ==========');
  }

  void _onSavePressed(BuildContext context) {
    if (_isSubmitting) return;
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);

      final adminModel = AdminProfileModel(
        uid: '',
        email: _emailController.text.trim(),
        nameAr: _nameArController.text.trim(),
        nameEn: _nameEnController.text.trim(),
        jopAr: _jobTitleArController.text.trim(),
        jopEn: _jobTitleEnController.text.trim(),
        phone: _phoneController.text.trim(),
        addressAr: _addressArController.text.trim(),
        addressEn: _addressEnController.text.trim(),
        nationalId: _nationalIdController.text.trim(),
        employeeId: _employeeIdController.text.trim(),
        profileImage: _currentImageUrl,
        isActive: true,
        role: 'admin',
        isFirstLogin: true,
      );

      if (isEditing) {
        final updatedAdmin = adminModel.copyWith(uid: widget.existingUid!);
        context.read<AdminDataCubit>().saveAdminData(updatedAdmin);
      } else {
        context.read<AdminDataCubit>().createNewAdmin(adminModel);
      }
    }
  }

  String? _validateNationalId(String? value) {
    if (value == null || value.isEmpty) return "add_admin.required".tr();
    if (value.length != 14) return "add_admin.valid_national_id".tr();
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return "add_admin.valid_national_id".tr();
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return "add_admin.required".tr();
    if (!RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$').hasMatch(value)) {
      return "add_admin.valid_email_format".tr();
    }
    return null;
  }

  String? _requiredField(String? value) {
    if (value == null || value.isEmpty) return "add_admin.required".tr();
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocListener<AdminDataCubit, AdminDataState>(
      listenWhen: (previous, current) =>
          current is AdminSuccess ||
          current is AdminError ||
          current is AdminLoaded,
      listener: (context, state) {
        if (state is AdminLoaded) {
          debugPrint('✅ AddAdminPage received AdminLoaded');

          if (state.admin != null) {
            _populateFields(state.admin!);

            if (mounted) {
              setState(() {
                _isProfileLoaded = true;
              });
            }
          }
        } else if (state is AdminSuccess) {
          _isSubmitting = false;
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isEditing
                    ? "add_admin.edit_success_msg".tr()
                    : "add_admin.success_msg".tr(),
              ),
              backgroundColor: Colors.green,
            ),
          );
          Future.microtask(() {
            if (context.mounted && Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          });
        } else if (state is AdminError) {
          _isSubmitting = false;
          setState(() {});
          String errorMessage = state.error;
          if (state.error == "ERROR_EMAIL_ALREADY_IN_USE") {
            errorMessage = "add_admin.email_in_use".tr();
          } else if (state.error == "ERROR_WEAK_PASSWORD") {
            errorMessage = "add_admin.weak_password".tr();
          }
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _isReadOnly
                ? "add_admin.view_profile".tr()
                : (isEditing
                      ? "add_admin.edit_app_bar_title".tr()
                      : "add_admin.app_bar_title".tr()),
            style: theme.appBarTheme.titleTextStyle,
          ),
          centerTitle: true,
          elevation: 0,
          actions: [
            if (isEditing)
              IconButton(
                icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
                tooltip: isArabic ? 'حذف المستخدم' : 'Delete User',
                onPressed: _showDeleteConfirmationDialog,
              ),
            if (widget.existingUid != null)
              IconButton(
                icon: Icon(_isReadOnly ? Icons.edit : Icons.lock_open),
                tooltip: _isReadOnly
                    ? "add_admin.edit_mode".tr()
                    : "add_admin.lock_mode".tr(),
                onPressed: () => setState(() => _isReadOnly = !_isReadOnly),
              ),
          ],
        ),
        body: Stack(
          children: [
            BlocBuilder<AdminDataCubit, AdminDataState>(
              builder: (context, state) {
                // أثناء تحميل بيانات الأدمن
                if (isEditing && !_isProfileLoaded) {
                  if (state is AdminError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 60.sp,
                            color: AppColors.error,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            state.error,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: isDark ? Colors.white : AppColors.navyDark,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 16.h),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _isProfileLoaded = false;
                              });

                              context.read<AdminDataCubit>().getAdminProfile(
                                widget.existingUid!,
                              );
                            },
                            child: Text("retry".tr()),
                          ),
                        ],
                      ),
                    );
                  }

                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.darkGold),
                  );
                }

                // البيانات اتحملت
                return SingleChildScrollView(
                  padding: EdgeInsets.all(20.w),
                  physics: const BouncingScrollPhysics(),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildProfileImage(),
                        SizedBox(height: 20.h),
                        _buildSectionCard(
                          "add_admin.personal_info_section".tr(),
                          Icons.admin_panel_settings,
                          [
                            _buildTextField(
                              "add_admin.name_ar".tr(),
                              _nameArController,
                              Icons.person,
                              (v) => v!.isEmpty
                                  ? "add_admin.valid_name_ar".tr()
                                  : null,
                            ),
                            _buildTextField(
                              "add_admin.name_en".tr(),
                              _nameEnController,
                              Icons.person_outline,
                              (v) => v!.isEmpty
                                  ? "add_admin.valid_name_en".tr()
                                  : null,
                              isEn: true,
                            ),
                            _buildTextField(
                              "add_admin.email".tr(),
                              _emailController,
                              Icons.email_outlined,
                              _validateEmail,
                              isEn: true,
                            ),
                            _buildTextField(
                              "add_admin.phone".tr(),
                              _phoneController,
                              Icons.phone,
                              _requiredField,
                              keyboardType: TextInputType.phone,
                              isEn: true,
                            ),
                            _buildTextField(
                              "add_admin.national_id".tr(),
                              _nationalIdController,
                              Icons.badge,
                              _validateNationalId,
                              keyboardType: TextInputType.number,
                              isEn: true,
                              maxLength: 14,
                            ),
                            _buildTextField(
                              "add_admin.employee_id".tr(),
                              _employeeIdController,
                              Icons.work_history,
                              _requiredField,
                              keyboardType: TextInputType.number,
                              isEn: true,
                            ),
                          ],
                        ),
                        _buildSectionCard(
                          "add_admin.job_info_section".tr(),
                          Icons.business_center,
                          [
                            _buildTextField(
                              "add_admin.job_ar".tr(),
                              _jobTitleArController,
                              Icons.work,
                              (v) => v!.isEmpty
                                  ? "add_admin.valid_job_ar".tr()
                                  : null,
                            ),
                            _buildTextField(
                              "add_admin.job_en".tr(),
                              _jobTitleEnController,
                              Icons.work_outline,
                              (v) => v!.isEmpty
                                  ? "add_admin.valid_job_en".tr()
                                  : null,
                              isEn: true,
                            ),
                            _buildTextField(
                              "add_admin.address_ar".tr(),
                              _addressArController,
                              Icons.location_on,
                              _requiredField,
                            ),
                            _buildTextField(
                              "add_admin.address_en".tr(),
                              _addressEnController,
                              Icons.location_on_outlined,
                              _requiredField,
                              isEn: true,
                            ),
                          ],
                        ),
                        SizedBox(height: 30.h),
                        if (!_isReadOnly) _buildSaveButton(state),
                        SizedBox(height: 40.h),
                      ],
                    ),
                  ),
                );
              },
            ),

            BlocBuilder<AdminDataCubit, AdminDataState>(
              builder: (context, state) {
                if (state is AdminDeleting) {
                  return Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Center(
                      child: Card(
                        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.r),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(20.w),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircularProgressIndicator(
                                color: AppColors.error,
                              ),
                              SizedBox(height: 15.h),
                              Text(
                                "add_admin.deleting".tr(),
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.navyDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 50.r,
            backgroundColor: AppColors.navyLight.withOpacity(0.2),
            backgroundImage: _currentImageUrl.isNotEmpty
                ? CachedNetworkImageProvider(_currentImageUrl)
                : null,
            child: _currentImageUrl.isEmpty
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

  Widget _buildSaveButton(AdminDataState state) {
    final isLoading = state is AdminLoading || _isSubmitting;
    return SizedBox(
      width: double.infinity,
      height: 55.h,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.navyDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        onPressed: isLoading ? null : () => _onSavePressed(context),
        child: isLoading
            ? SizedBox(
                width: 24.w,
                height: 24.w,
                child: const CircularProgressIndicator(
                  color: AppColors.darkGold,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                isEditing
                    ? "add_admin.save_changes".tr()
                    : "add_admin.submit_button".tr(),
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.darkGold,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
                Text(
                  title,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: isDark ? Colors.white : AppColors.navyDark,
                  ),
                ),
              ],
            ),
            Divider(
              height: 30,
              color: isDark ? Colors.white24 : Colors.grey.shade300,
            ),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon,
    String? Function(String?)? validator, {
    bool isEn = false,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: TextFormField(
        controller: controller,
        validator: _isReadOnly ? null : validator,
        enabled: !_isReadOnly,
        keyboardType: keyboardType,
        maxLength: maxLength,
        textAlign: isEn
            ? TextAlign.left
            : (isArabic ? TextAlign.right : TextAlign.left),
        textDirection: isEn
            ? ui.TextDirection.ltr
            : (isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr),
        style: AppTextStyles.bodyMedium.copyWith(
          color: _isReadOnly
              ? (isDark ? Colors.white54 : Colors.grey)
              : (isDark ? Colors.white : AppColors.navyDark),
        ),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(
            icon,
            size: 20.sp,
            color: isDark ? Colors.white70 : AppColors.navyLight,
          ),
          labelStyle: AppTextStyles.bodySmall.copyWith(
            color: isDark ? Colors.white70 : AppColors.navyLight,
          ),
          alignLabelWithHint: true,
          counterText: '',
          filled: _isReadOnly,
          fillColor: _isReadOnly
              ? (isDark ? Colors.grey.shade800 : Colors.grey.shade200)
              : (isDark ? const Color(0xFF2A2A3E) : Colors.white),
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
}
