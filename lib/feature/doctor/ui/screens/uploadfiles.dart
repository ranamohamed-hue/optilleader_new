import 'dart:io';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:optialeader/core/routing/routes.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:optialeader/feature/database_admin/logic/doctor_data/doctor_data_cubit.dart';
import 'package:optialeader/feature/database_admin/logic/doctor_data/doctor_data_state.dart';
import 'package:optialeader/core/helper/file_halper.dart';
import 'package:optialeader/feature/doctor/ui/widgets/file_picker_field.dart';

class UploadFilePage extends StatefulWidget {
  final String doctorUid;

  const UploadFilePage({super.key, required this.doctorUid});

  @override
  State<UploadFilePage> createState() => _UploadFilePageState();
}

class _UploadFilePageState extends State<UploadFilePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  String? _selectedCategory;

  PickedFileData? _pickedFileData;

  final List<String> _categories = [
    'archive.folders.certificates',
    'archive.folders.id',
    'archive.folders.decisions',
    'archive.folders.misc',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryDark = theme.colorScheme.primary;
    final accentGold = theme.colorScheme.secondary;

    return BlocListener<DoctorDataCubit, DoctorDataState>(
      listener: (context, state) {
        if (state is DoctorLoaded) {
          ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
      content: Text("file_upload_success".tr()), // ✅ مربوط
      backgroundColor: Colors.green,
    ),
          );
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(Routes.user);
          }
        }

        if (state is DoctorError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(

content: Text(state.error ?? "unexpected_error".tr()),      
        backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: primaryDark,
          elevation: 0,
          toolbarHeight: 70.h,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              size: 20.sp,
              color: Colors.white,
            ),
            onPressed: () =>
                context.canPop() ? context.pop() : context.go(Routes.user),
          ),
          title: Text(
            'upload.title'.tr(),
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18.sp,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(2.h),
            child: Container(color: accentGold, height: 2.h),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "upload.subtitle".tr(),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: primaryDark,
                ),
              ),
              SizedBox(height: 30.h),

              _buildInputField(
                label: "upload.label_title".tr(),
                hint: "upload.hint_title".tr(),
                controller: _titleController,
                primary: primaryDark,
                gold: accentGold,
              ),
              SizedBox(height: 15.h),

              _buildCategoryDropdown(primaryDark, accentGold),
              SizedBox(height: 15.h),

              _buildInputField(
                label: "upload.label_desc".tr(),
                hint: "upload.hint_desc".tr(),
                controller: _descController,
                primary: primaryDark,
                gold: accentGold,
                maxLines: 3,
              ),
              SizedBox(height: 25.h),

              FilePickerField(
                label: "upload.click_to_select".tr(),
                selectedFile: _pickedFileData,
                onFileSelected: (file) {
                  setState(() {
                    _pickedFileData = file;
                  });
                },
                isRequired: true,
              ),
              SizedBox(height: 40.h),

              BlocBuilder<DoctorDataCubit, DoctorDataState>(
                builder: (context, state) {
                  final isLoading = state is DoctorLoading;

                  return SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryDark,
                        foregroundColor: accentGold,
                        disabledBackgroundColor: primaryDark.withOpacity(0.6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      onPressed: isLoading
                          ? null 
                          : () {
                              if (_pickedFileData == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("upload.error_file_required".tr())),
                                );
                                return;
                              }
                              if (_titleController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("upload.error_title_required".tr())),
                                );
                                return;
                              }

                              context.read<DoctorDataCubit>().uploadArchiveFile(
                                    uid: widget.doctorUid,
                                    file: _pickedFileData!.file,
                                    title: _titleController.text,
                                    description: _descController.text,
                                    category: _selectedCategory ?? 'archive.folders.misc',
                                  );
                            },
                      child: isLoading
                          ? SizedBox(
                              width: 24.w,
                              height: 24.w,
                              child: CircularProgressIndicator(
                                color: accentGold,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(
                              "upload.btn_upload".tr(),
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown(Color primary, Color gold) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "upload.label_category".tr(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: primary,
            fontSize: 14.sp,
          ),
        ),
        SizedBox(height: 8.h),
        DropdownButtonFormField<String>(
          style: TextStyle(fontSize: 13.sp, color: Colors.black),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 12.h,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: primary.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: gold, width: 1.5.w),
            ),
          ),
          initialValue: _selectedCategory,
          hint: Text(
            "upload.hint_category".tr(),
            style: TextStyle(fontSize: 13.sp),
          ),
          items: _categories.map((String category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Text(category.tr()),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCategory = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required Color primary,
    required Color gold,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: primary,
            fontSize: 14.sp,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: TextStyle(fontSize: 13.sp, color: Colors.black),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: 13.sp, color: Colors.grey.shade400),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 12.h,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: primary.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: gold, width: 1.5.w),
            ),
          ),
        ),
      ],
    );
  }
}