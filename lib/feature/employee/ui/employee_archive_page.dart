import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:optialeader/feature/database_admin/data/models/employee_model.dart';
import 'package:optialeader/feature/database_admin/logic/employee_logic/employee_cubit.dart';
import 'package:optialeader/feature/database_admin/logic/employee_logic/employee_state.dart';
import 'package:optialeader/feature/doctor/ui/widgets/file_picker_field.dart';
import 'package:optialeader/core/helper/file_halper.dart';
import 'package:url_launcher/url_launcher.dart';

class EmployeeArchivePage extends StatefulWidget {
  final EmployeeModel employee;
  const EmployeeArchivePage({super.key, required this.employee});

  @override
  State<EmployeeArchivePage> createState() => _EmployeeArchivePageState();
}

class _EmployeeArchivePageState extends State<EmployeeArchivePage> {
  @override
  void initState() {
    super.initState();
    context.read<EmployeeDataCubit>().getEmployeeProfile(widget.employee.uid!);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorPrimary = theme.primaryColor;
    final colorGold = theme.colorScheme.secondary;

    return BlocListener<EmployeeDataCubit, EmployeeDataState>(
      listener: (context, state) {
        if (state is EmployeeLoaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("upload.file_upload_success".tr()),
              backgroundColor: Colors.green,
            ),
          );
        }
        if (state is EmployeeError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error ?? "upload.unexpected_error".tr()),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showQuickUploadSheet(context),
          backgroundColor: colorGold,
          child: Icon(Icons.cloud_upload, color: colorPrimary, size: 28.sp),
        ),
        appBar: AppBar(
          backgroundColor: colorPrimary,
          elevation: 0,
          toolbarHeight: 70.h,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, size: 20.sp, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'appbar_title'.tr(),
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18.sp),
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(2.h),
            child: Container(color: colorGold, height: 2.h),
          ),
        ),
        body: BlocBuilder<EmployeeDataCubit, EmployeeDataState>(
          builder: (context, state) {
            if (state is EmployeeLoading) {
              return Center(child: CircularProgressIndicator(color: colorGold));
            }

            List<dynamic> files = [];
            if (state is EmployeeLoaded) {
              files = state.employee.archiveFiles;
            } else if (state is EmployeeInitial) {
              files = widget.employee.archiveFiles;
            }

            return files.isEmpty
                ? _buildEmptyState(colorGold)
                : _buildFilesList(files, theme, colorGold);
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(Color gold) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_off_outlined, size: 80.sp, color: Colors.grey.shade500),
          SizedBox(height: 16.h),
          Text(
            'no_files_yet'.tr(),
            style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
  // ✅ تم تعديل هذه الدالة لتدعم المفاتيح النسبية الجديدة والبيانات القديمة في القاعدة
  Widget _buildFilesList(List<dynamic> files, ThemeData theme, Color gold) {
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: files.length,
      itemBuilder: (context, index) {
        final file = files[index] as Map<String, dynamic>;
        final url = file['url'] ?? '';
        final title = (file['title'] as String?) ?? 'untitled'.tr();
        
        final categoryRaw = (file['category'] as String?) ?? '';
        
        String categoryDisplay = '';
        if (categoryRaw.isNotEmpty) {
          if (categoryRaw.startsWith('employee_archieve.')) {
            // بيانات قديمة: نزيل البادئة ونترجم المفتاح النسبي الباقي
            categoryDisplay = categoryRaw.replaceFirst('employee_archieve.', '').tr();
          } else {
            // بيانات جديدة: نترجم المفتاح مباشرة
            categoryDisplay = categoryRaw.tr();
          }
        }

        final timestamp = file['uploadedAt'];
        
        String dateStr = '';
        if (timestamp != null) {
          try {
            DateTime dateTime;
            if (timestamp is Timestamp) {
              dateTime = timestamp.toDate();
            } else {
              dateTime = DateTime.parse(timestamp.toString());
            }
            dateStr = DateFormat('yyyy-MM-dd - hh:mm a').format(dateTime);
          } catch (e) {
            dateStr = '';
          }
        }

        final isPdf = url.toLowerCase().endsWith('.pdf');

        return Card(
          margin: EdgeInsets.only(bottom: 12.h),
          color: theme.cardColor.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
            side: BorderSide(color: theme.dividerColor),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12.r),
            onTap: () => _openFile(url),
            child: Padding(
              padding: EdgeInsets.all(12.w),
              child: Row(
                children: [
                  Container(
                    width: 50.w,
                    height: 50.h,
                    decoration: BoxDecoration(
                      color: isPdf ? Colors.red.shade100 : Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: isPdf
                        ? Icon(Icons.picture_as_pdf, color: Colors.red.shade700, size: 30.sp)
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(8.r),
                            child: Image.network(
                              url,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(Icons.broken_image, color: Colors.grey),
                            ),
                          ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),
                        if (categoryDisplay.isNotEmpty)
                          Text(
                            categoryDisplay,
                            style: TextStyle(fontSize: 12.sp, color: gold),
                          ),
                        if (dateStr.isNotEmpty) ...[
                          SizedBox(height: 2.h),
                          Text(
                            dateStr,
                            style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade500),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.download_rounded, color: theme.primaryColor),
                    onPressed: () => _openFile(url),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  void _openFile(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showQuickUploadSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (context) => _QuickUploadSheet(uid: widget.employee.uid!),
    );
  }
}

// ============================================================
class _QuickUploadSheet extends StatefulWidget {
  final String uid;
  const _QuickUploadSheet({required this.uid});

  @override
  State<_QuickUploadSheet> createState() => _QuickUploadSheetState();
}

class _QuickUploadSheetState extends State<_QuickUploadSheet> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String? _selectedCategory;
  PickedFileData? _pickedFileData;
  bool _isLoading = false;

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
    final primaryDark = theme.primaryColor;
    final accentGold = theme.colorScheme.secondary;

    return Padding(
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 16.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'upload.title'.tr(),
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 20.h),
            _buildInputField(
              label: "upload.label_title".tr(),
              hint: "upload.hint_title".tr(),
              controller: _titleController,
              gold: accentGold,
            ),
            SizedBox(height: 15.h),
            _buildCategoryDropdown(accentGold),
            SizedBox(height: 15.h),
            _buildInputField(
              label: "upload.label_desc".tr(),
              hint: "upload.hint_desc".tr(),
              controller: _descController,
              gold: accentGold,
              maxLines: 2,
            ),
            SizedBox(height: 20.h),
            FilePickerField(
              label: "upload.click_to_select".tr(),
              selectedFile: _pickedFileData,
              onFileSelected: (file) => setState(() {
                _pickedFileData = file;
              }),
              isRequired: true,
            ),
            SizedBox(height: 30.h),
            SizedBox(
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
                onPressed: _isLoading ? null : _submitUpload,
                child: _isLoading
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
            ),
          ],
        ),
      ),
    );
  }

  void _submitUpload() {
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
    setState(() => _isLoading = true);
    context.read<EmployeeDataCubit>().uploadArchiveFile(
          uid: widget.uid,
          file: _pickedFileData!.file,
          title: _titleController.text,
          description: _descController.text,
          category: _selectedCategory ?? 'archive.folders.misc',
        );
    Navigator.pop(context);
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required Color gold,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14.sp)),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: TextStyle(fontSize: 13.sp, color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: 13.sp, color: Colors.white54),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.white24),
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

  Widget _buildCategoryDropdown(Color gold) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "upload.label_category".tr(),
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14.sp),
        ),
        SizedBox(height: 8.h),
        DropdownButtonFormField<String>(
          style: TextStyle(fontSize: 13.sp, color: Colors.white),
          dropdownColor: Colors.grey.shade800,
          value: _selectedCategory,
                    hint: Text(
            "upload.hint_category".tr(), // ✅ تم إزالة الرقم 5 الخاطئ
            style: TextStyle(fontSize: 13.sp, color: Colors.white54),
          ),
          items: _categories.map((String category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Text(
                category.tr(),
                style: TextStyle(color: Colors.white, fontSize: 13.sp),
              ),
            );
          }).toList(),
          onChanged: (value) => setState(() => _selectedCategory = value),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.white24),
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