import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:optialeader/feature/database_admin/data/models/employee_model.dart';

import 'package:optialeader/feature/employee/data/models/employee_course_model.dart';
import 'package:optialeader/feature/employee/data/repo/employee_courses_repo.dart';
import 'package:optialeader/feature/employee/logic/employee_courses_cubit.dart';
import 'package:optialeader/feature/employee/logic/employee_courses_state.dart';

class EmployeeCoursesPage extends StatelessWidget {
  final EmployeeModel employee;

  const EmployeeCoursesPage({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorPrimary = theme.primaryColor;
    final colorGold = theme.colorScheme.secondary;
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return BlocProvider(
      create: (context) => EmployeeCoursesCubit()..loadCourses(uid),
      child: BlocListener<EmployeeCoursesCubit, EmployeeCoursesState>(
        listener: (context, state) {
          if (state is EmployeeCoursesActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message.tr()),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context); // قفل الـ Bottom Sheet
          } else if (state is EmployeeCoursesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error.tr()),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text('employee_courses.page_title'.tr()),
            backgroundColor: colorPrimary,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              onPressed: () => context.pop(),
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddCourseSheet(context),
            backgroundColor: colorGold,
            icon: Icon(Icons.add_circle_outline, color: colorPrimary, size: 22),
            label: Text(
              'employee_courses.add_button'.tr(),
              style: TextStyle(
                color: colorPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
          ),
          body: BlocBuilder<EmployeeCoursesCubit, EmployeeCoursesState>(
            builder: (context, state) {
              if (state is EmployeeCoursesLoading ||
                  state is EmployeeCoursesInitial) {
                return Center(
                  child: CircularProgressIndicator(color: colorGold),
                );
              }

              if (state is EmployeeCoursesError &&
                  state.error != 'employee_courses.error_upload' &&
                  state.error != 'employee_courses.error_delete') {
                return Center(child: Text(state.error.tr()));
              }

              final courses = (state is EmployeeCoursesLoaded)
                  ? state.courses
                  : <EmployeeCourseModel>[];

              if (courses.isEmpty) {
                return _buildEmptyState(context, colorPrimary);
              }

              return ListView.builder(
                padding: EdgeInsets.only(
                  bottom: 100.h,
                  left: 16.w,
                  right: 16.w,
                  top: 16.h,
                ),
                physics: const BouncingScrollPhysics(),
                itemCount: courses.length,
                itemBuilder: (context, index) {
                  return _buildCourseCard(
                    context,
                    courses[index],
                    colorPrimary,
                    colorGold,
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, Color navy) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school_outlined,
            size: 80.sp,
            color: navy.withOpacity(0.2),
          ),
          SizedBox(height: 20.h),
          Text(
            'employee_courses.no_courses'.tr(),
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'employee_courses.no_courses_hint'.tr(),
            style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(
    BuildContext context,
    EmployeeCourseModel course,
    Color navy,
    Color gold,
  ) {
    final statusColor = _getStatusColor(course.status, navy);
    final statusIcon = _getStatusIcon(course.status);

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: navy.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  course.title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: navy,
                    height: 1.3,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 14.sp, color: statusColor),
                    SizedBox(width: 4.w),
                    Text(
                      'employee_courses.status.${course.status}'.tr(),
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Divider(height: 1, color: Colors.grey.shade100),
          SizedBox(height: 12.h),

          _buildDetailChip(Icons.business_rounded, course.organization, navy),
          SizedBox(height: 8.h),
          _buildDetailChip(
            Icons.calendar_today_rounded,
            course.date,
            Colors.blueGrey,
          ),
          if (course.durationHours != null) ...[
            SizedBox(height: 8.h),
            _buildDetailChip(
              Icons.schedule_rounded,
              '${course.durationHours} ${'employee_courses.hours'.tr()}',
              Colors.teal,
            ),
          ],
          SizedBox(height: 8.h),
          _buildDetailChip(
            Icons.category_rounded,
            'employee_courses.types.${course.courseType}'.tr(),
            Colors.deepPurple,
          ),

          if (course.status == 'rejected' &&
              course.rejectionReason != null) ...[
            SizedBox(height: 12.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: Colors.red.shade100),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red.shade700,
                    size: 18.sp,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      '${'employee_courses.rejection_reason'.tr()}: ${course.rejectionReason}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (course.certificateFileUrl != null) ...[
            SizedBox(height: 12.h),
            GestureDetector(
              onTap: () =>
                  _showCertificateViewer(context, course.certificateFileUrl!),
              child: Container(
                height: 120.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: gold.withOpacity(0.3)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: course.certificateFileType == 'pdf'
                      ? Container(
                          color: Colors.red.shade50,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.picture_as_pdf,
                                  size: 40.sp,
                                  color: Colors.red,
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'employee_courses.view_pdf'.tr(),
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : CachedNetworkImage(
                          imageUrl: course.certificateFileUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, _) => Center(
                            child: CircularProgressIndicator(
                              color: gold,
                              strokeWidth: 2,
                            ),
                          ),
                          errorWidget: (_, _, _) => Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                            size: 40.sp,
                          ),
                        ),
                ),
              ),
            ),
          ],

          SizedBox(height: 12.h),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton.icon(
              onPressed: () => _confirmDelete(context, course),
              icon: Icon(
                Icons.delete_outline,
                size: 16.sp,
                color: Colors.red.shade400,
              ),
              label: Text(
                'common.delete'.tr(),
                style: TextStyle(color: Colors.red.shade400, fontSize: 12.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailChip(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: color.withOpacity(0.7)),
        SizedBox(width: 8.w),
        Text(
          text,
          style: TextStyle(
            fontSize: 13.sp,
            color: Colors.black87.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  void _showCertificateViewer(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.contain,
              placeholder: (_, _) => SizedBox(
                height: 300.h,
                child: Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (_, _, _) => SizedBox(
                height: 200.h,
                child: Center(child: Icon(Icons.broken_image, size: 50)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    EmployeeCourseModel course,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.r),
        ),
        title: Text('employee_courses.delete_confirm_title'.tr()),
        content: Text('employee_courses.delete_confirm_body'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('common.cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'common.delete'.tr(),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      context.read<EmployeeCoursesCubit>().deleteCourse(course);
    }
  }

  Color _getStatusColor(String status, Color navy) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return navy;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.hourglass_top;
    }
  }

  void _showAddCourseSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddCourseSheet(),
    );
  }
}

// ============================================================
// 📝 فورم الإضافة (يستدعي الكيوبيت)
// ============================================================
class _AddCourseSheet extends StatefulWidget {
  @override
  State<_AddCourseSheet> createState() => _AddCourseSheetState();
}

class _AddCourseSheetState extends State<_AddCourseSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _orgController = TextEditingController();
  final _hoursController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String _selectedType = 'general';
  XFile? _pickedFile;
  final _picker = ImagePicker();

  @override
  void dispose() {
    _titleController.dispose();
    _orgController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.r),
        ),
        title: Text('employee_courses.pick_file_title'.tr()),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pop(ctx, ImageSource.gallery),
            icon: const Icon(Icons.image),
            label: Text('employee_courses.pick_image'.tr()),
          ),
          TextButton.icon(
            onPressed: () => Navigator.pop(ctx, ImageSource.camera),
            icon: const Icon(Icons.camera_alt),
            label: Text('employee_courses.pick_camera'.tr()),
          ),
        ],
      ),
    );

    if (source != null) {
      final file = await _picker.pickImage(
        source: source,
        requestFullMetadata: false,
      );
      if (file != null) setState(() => _pickedFile = file);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('employee_courses.error_certificate_required'.tr()),
        ),
      );
      return;
    }

    final course = EmployeeCourseModel(
      title: _titleController.text.trim(),
      organization: _orgController.text.trim(),
      date: DateFormat.yMd(context.locale.languageCode).format(_selectedDate),
      durationHours: _hoursController.text.trim().isEmpty
          ? null
          : _hoursController.text.trim(),
      courseType: _selectedType,
      createdAt: DateTime.now(),
    );

    context.read<EmployeeCoursesCubit>().addCourse(
      course: course,
      certificateFile: File(_pickedFile!.path),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final navy = theme.primaryColor;
    final gold = theme.colorScheme.secondary;

    return BlocBuilder<EmployeeCoursesCubit, EmployeeCoursesState>(
      builder: (context, state) {
        final isUploading = state is EmployeeCoursesUploading;

        return Container(
          height: MediaQuery.of(context).size.height * 0.88,
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: navy,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(30.r),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      'employee_courses.add_new_title'.tr(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    if (isUploading)
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: gold,
                          strokeWidth: 2,
                        ),
                      )
                    else
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.white70),
                        onPressed: () => context.pop(),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: AbsorbPointer(
                  absorbing: isUploading,
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      padding: EdgeInsets.all(20.w),
                      children: [
                        _buildLabel(
                          'employee_courses.form.title'.tr(),
                          Icons.title_rounded,
                          gold,
                        ),
                        _buildTextFiled(
                          _titleController,
                          'employee_courses.form.hint_title'.tr(),
                        ),
                        SizedBox(height: 20.h),
                        _buildLabel(
                          'employee_courses.form.organization'.tr(),
                          Icons.business_rounded,
                          gold,
                        ),
                        _buildTextFiled(
                          _orgController,
                          'employee_courses.form.hint_org'.tr(),
                        ),
                        SizedBox(height: 20.h),
                        _buildLabel(
                          'employee_courses.form.type'.tr(),
                          Icons.category_rounded,
                          gold,
                        ),
                        _buildTypeDropdown(navy, gold),
                        SizedBox(height: 20.h),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel(
                                    'employee_courses.form.date'.tr(),
                                    Icons.calendar_today_rounded,
                                    gold,
                                  ),
                                  _buildDateField(navy),
                                ],
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel(
                                    'employee_courses.form.hours'.tr(),
                                    Icons.schedule_rounded,
                                    gold,
                                  ),
                                  _buildTextFiled(
                                    _hoursController,
                                    '24',
                                    keyboardType: TextInputType.number,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 25.h),
                        _buildLabel(
                          'employee_courses.form.certificate'.tr(),
                          Icons.attach_file_rounded,
                          gold,
                        ),
                        _buildFilePicker(navy, gold),
                        SizedBox(height: 30.h),
                        ElevatedButton(
                          onPressed: isUploading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: gold,
                            foregroundColor: navy,
                            minimumSize: Size(double.infinity, 50.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.r),
                            ),
                          ),
                          child: Text(
                            'employee_courses.form.submit'.tr(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLabel(String text, IconData icon, Color color) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Icon(icon, size: 16.sp, color: color),
          SizedBox(width: 6.w),
          Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13.sp,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFiled(
    TextEditingController controller,
    String hint, {
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType ?? TextInputType.text,
      validator: (val) =>
          val!.trim().isEmpty ? 'employee_courses.form.required'.tr() : null,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.secondary,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildDateField(Color navy) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(1990),
          lastDate: DateTime.now(),
        );
        if (picked != null) setState(() => _selectedDate = picked);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat.yMd(context.locale.languageCode).format(_selectedDate),
              style: TextStyle(fontSize: 13.sp),
            ),
            Icon(Icons.calendar_month_rounded, size: 18.sp, color: navy),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeDropdown(Color navy, Color gold) {
    final types = [
      'general',
      'specialized',
      'administrative',
      'mandatory_leadership',
    ];
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedType,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: gold),
          style: TextStyle(fontSize: 13.sp, color: Colors.black87),
          onChanged: (val) => setState(() => _selectedType = val!),
          items: types
              .map(
                (t) => DropdownMenuItem(
                  value: t,
                  child: Text('employee_courses.types.$t'.tr()),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildFilePicker(Color navy, Color gold) {
    return GestureDetector(
      onTap: _pickFile,
      child: Container(
        height: 160.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: _pickedFile != null ? gold : Colors.grey.shade300,
            width: _pickedFile != null ? 2 : 1,
          ),
        ),
        child: _pickedFile != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(File(_pickedFile!.path), fit: BoxFit.cover),
                    Positioned(
                      top: 8.h,
                      right: 8.w,
                      child: Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_upload_outlined,
                    size: 40.sp,
                    color: navy.withOpacity(0.4),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'employee_courses.form.hint_certificate'.tr(),
                    style: TextStyle(color: Colors.grey, fontSize: 13.sp),
                  ),
                ],
              ),
      ),
    );
  }
}
