import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:optialeader/core/theming/app_color.dart';
import 'package:optialeader/core/theming/app_text_style.dart';
import 'package:optialeader/feature/database_admin/data/models/judge_profile_model.dart';
import 'package:optialeader/feature/database_admin/logic/judge_data/judge_data_cubit.dart';
import 'package:optialeader/feature/database_admin/logic/judge_data/judge_data_state.dart';
import 'dart:ui' as ui;

class AddJudgePage extends StatefulWidget {
  final String? existingUid;
  final bool isViewMode;

  const AddJudgePage({super.key, this.existingUid, this.isViewMode = false});

  @override
  State<AddJudgePage> createState() => _AddJudgePageState();
}

class _AddJudgePageState extends State<AddJudgePage> {
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

  bool _isReadOnly = true;
  String _currentImageUrl = '';

  @override
  void initState() {
    super.initState();
    _isReadOnly = widget.isViewMode;
    if (isEditing) {
      context.read<JudgeDataCubit>().getJudgeProfile(widget.existingUid!);
    }
  }

  // ✅ [إضافة] نافذة تأكيد الحذف
  void _showDeleteConfirmationDialog() {
    final isArabic = context.locale.languageCode == 'ar';

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.r),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: AppColors.error,
              size: 28.sp,
            ),
            SizedBox(width: 10.w),
            Text(isArabic ? 'تأكيد الحذف' : 'Confirm Deletion'),
          ],
        ),
        content: Text(
          isArabic
              ? 'هل أنت متأكد من حذف هذا المستخدم نهائياً؟ سيتم حذف جميع بياناته وملفاته ولا يمكن التراجع عن هذا الإجراء.'
              : 'Are you sure you want to delete this user permanently? All data and files will be deleted and this action cannot be undone.',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.navyDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              isArabic ? 'إلغاء' : 'Cancel',
              style: TextStyle(color: AppColors.navyLight),
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
              Navigator.pop(dialogContext); // إغلاق الديالوج
              context.read<JudgeDataCubit>().deleteJudge(
                widget.existingUid!,
              ); // تنفيذ الحذف
            },
            child: Text(
              isArabic ? 'حذف نهائي' : 'Delete',
              style: TextStyle(
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
      context.read<JudgeDataCubit>().updateJudgeProfileImage(
        widget.existingUid!,
        File(pickedFile.path),
      );
    }
  }

  void _populateFields(JudgeProfileModel judge) {
    _nameArController.text = judge.nameAr;
    _nameEnController.text = judge.nameEn;
    _emailController.text = judge.email;
    _phoneController.text = judge.phone;
    _jobTitleArController.text = judge.jopAr;
    _jobTitleEnController.text = judge.jopEn;
    _addressArController.text = judge.addressAr;
    _addressEnController.text = judge.addressEn;
    _nationalIdController.text = judge.nationalId;
    _employeeIdController.text = judge.employeeId;
    _currentImageUrl = judge.profileImage;
  }

  void _onSavePressed(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final judgeModel = JudgeProfileModel(
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
        role: 'judge',
        isFirstLogin: true,
      );

      if (isEditing) {
        final updatedJudge = judgeModel.copyWith(uid: widget.existingUid!);
        context.read<JudgeDataCubit>().saveJudgeData(updatedJudge);
      } else {
        context.read<JudgeDataCubit>().createNewJudge(judgeModel);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<JudgeDataCubit, JudgeDataState>(
      listenWhen: (previous, current) =>
          current is JudgeSuccess ||
          current is JudgeError ||
          current is JudgeLoaded,
      listener: (context, state) {
        if (state is JudgeLoaded) {
          _populateFields(state.judge!);
        } else if (state is JudgeSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isEditing
                    ? "add_judge.edit_success".tr()
                    : "add_judge.add_success".tr(),
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else if (state is JudgeError) {
          String errorMessage = state.error;
          if (state.error == "ERROR_EMAIL_ALREADY_IN_USE") {
            errorMessage = "add_judge.email_in_use".tr();
          } else if (state.error == "ERROR_WEAK_PASSWORD") {
            errorMessage = "add_judge.weak_password".tr();
          } else if (state.error == "ERROR_USER_CREATION_FAILED" ||
              state.error == "ERROR_AUTH_UNKNOWN") {
            errorMessage = "add_judge.auth_error".tr();
          }
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
                ? "add_judge.view_profile".tr()
                : (isEditing
                      ? "add_judge.edit_title".tr()
                      : "add_judge.add_title".tr()),
          ),
          centerTitle: true,
          elevation: 0,
          actions: [
            // ✅ [إضافة] زر حذف المستخدم
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
                    ? "add_judge.edit_mode".tr()
                    : "add_judge.lock_mode".tr(),
                onPressed: () => setState(() => _isReadOnly = !_isReadOnly),
              ),
          ],
        ),
        body: Stack(
          children: [
            // محتوى الفورم الأساسي
            BlocBuilder<JudgeDataCubit, JudgeDataState>(
              builder: (context, state) {
                if (isEditing &&
                    state is! JudgeLoaded &&
                    state is! JudgeError) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.darkGold),
                  );
                }

                return SingleChildScrollView(
                  padding: EdgeInsets.all(20.w),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildProfileImage(),
                        SizedBox(height: 20.h),
                        _buildSectionCard(
                          "add_judge.personal_info".tr(),
                          Icons.gavel,
                          [
                            _buildTextField(
                              "add_judge.name_ar".tr(),
                              _nameArController,
                              Icons.person,
                              (v) =>
                                  v!.isEmpty ? "add_judge.required".tr() : null,
                            ),
                            _buildTextField(
                              "add_judge.name_en".tr(),
                              _nameEnController,
                              Icons.person_outline,
                              (v) =>
                                  v!.isEmpty ? "add_judge.required".tr() : null,
                              isEn: true,
                            ),
                            _buildTextField(
                              "add_judge.email".tr(),
                              _emailController,
                              Icons.email_outlined,
                              (v) =>
                                  !RegExp(
                                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                  ).hasMatch(v!)
                                  ? "add_judge.invalid_email".tr()
                                  : null,
                              isEn: true,
                            ),
                            _buildTextField(
                              "add_judge.phone".tr(),
                              _phoneController,
                              Icons.phone,
                              (v) =>
                                  v!.isEmpty ? "add_judge.required".tr() : null,
                              keyboardType: TextInputType.phone,
                              isEn: true,
                            ),
                            _buildTextField(
                              "add_judge.national_id".tr(),
                              _nationalIdController,
                              Icons.badge,
                              (v) =>
                                  v!.isEmpty ? "add_judge.required".tr() : null,
                              keyboardType: TextInputType.number,
                              isEn: true,
                            ),
                            _buildTextField(
                              "add_judge.employee_id".tr(),
                              _employeeIdController,
                              Icons.work_history,
                              (v) =>
                                  v!.isEmpty ? "add_judge.required".tr() : null,
                              keyboardType: TextInputType.number,
                              isEn: true,
                            ),
                          ],
                        ),
                        _buildSectionCard(
                          "add_judge.job_info".tr(),
                          Icons.business_center,
                          [
                            _buildTextField(
                              "add_judge.job_ar".tr(),
                              _jobTitleArController,
                              Icons.work,
                              (v) =>
                                  v!.isEmpty ? "add_judge.required".tr() : null,
                            ),
                            _buildTextField(
                              "add_judge.job_en".tr(),
                              _jobTitleEnController,
                              Icons.work_outline,
                              (v) =>
                                  v!.isEmpty ? "add_judge.required".tr() : null,
                              isEn: true,
                            ),
                            _buildTextField(
                              "add_judge.address_ar".tr(),
                              _addressArController,
                              Icons.location_on,
                              (v) =>
                                  v!.isEmpty ? "add_judge.required".tr() : null,
                            ),
                            _buildTextField(
                              "add_judge.address_en".tr(),
                              _addressEnController,
                              Icons.location_on_outlined,
                              (v) =>
                                  v!.isEmpty ? "add_judge.required".tr() : null,
                              isEn: true,
                            ),
                          ],
                        ),
                        SizedBox(height: 30.h),
                        if (!_isReadOnly) _buildSaveButton(state),
                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
                );
              },
            ),

            // ✅ [إضافة] طبقة التحميل أثناء الحذف
            BlocBuilder<JudgeDataCubit, JudgeDataState>(
              builder: (context, state) {
                if (state is JudgeDeleting) {
                  return Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Center(
                      child: Card(
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
                                isArabic
                                    ? 'جاري حذف المستخدم...'
                                    : 'Deleting user...',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.navyDark,
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

  Widget _buildSectionCard(String title, IconData icon, List<Widget> children) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.r),
        side: BorderSide(color: AppColors.navyLight.withOpacity(0.1)),
      ),
      margin: EdgeInsets.only(bottom: 20.h),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.darkGold, size: 22.sp),
                SizedBox(width: 8.w),
                Text(
                  title,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.navyDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 25, thickness: 0.5),
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
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: TextFormField(
        controller: controller,
        validator: _isReadOnly ? null : validator,
        enabled: !_isReadOnly,
        keyboardType: keyboardType,
        textAlign: isEn
            ? TextAlign.left
            : (isArabic ? TextAlign.right : TextAlign.left),
        textDirection: isEn
            ? ui.TextDirection.ltr
            : (isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr),
        style: AppTextStyles.bodyMedium.copyWith(
          color: _isReadOnly ? Colors.grey : AppColors.navyDark,
        ),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20.sp, color: AppColors.navyLight),
          labelStyle: AppTextStyles.bodySmall.copyWith(
            color: AppColors.navyLight,
          ),
          alignLabelWithHint: true,
          filled: _isReadOnly,
          fillColor: _isReadOnly ? Colors.grey.shade200 : Colors.white,
        ),
      ),
    );
  }

  Widget _buildSaveButton(JudgeDataState state) {
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
        onPressed: state is JudgeLoading ? null : () => _onSavePressed(context),
        child: state is JudgeLoading
            ? const CircularProgressIndicator(color: AppColors.darkGold)
            : Text(
                isEditing
                    ? "add_judge.save_changes".tr()
                    : "add_judge.add_button".tr(),
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.darkGold,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
