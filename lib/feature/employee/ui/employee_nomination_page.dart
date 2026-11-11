import 'dart:io'; // ✅ مضاف
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart'; 

import 'package:optialeader/feature/database_admin/logic/leadership_scoring_engine/leadership_criteria_engine.dart';
import 'package:optialeader/core/services/criteria/admin_manager_criteria.dart';
import 'package:optialeader/feature/admin/data/model/announcement_model.dart';
import 'package:optialeader/feature/database_admin/data/models/employee_model.dart';
import 'package:optialeader/feature/employee/logic/EmployeenNominationCubit/employee_nomination_cubit.dart';
import 'package:optialeader/feature/employee/logic/EmployeenNominationCubit/employee_nomination_state.dart';

class EmployeeNominationPage extends StatefulWidget {
  final AnnouncementModel announcement;
  final EmployeeModel employee;

  const EmployeeNominationPage({
    super.key,
    required this.announcement,
    required this.employee,
  });

  @override
  State<EmployeeNominationPage> createState() => _EmployeeNominationPageState();
}

class _EmployeeNominationPageState extends State<EmployeeNominationPage> {
  final TextEditingController _visionController = TextEditingController();
  bool _isSubmitting = false;
  
  late final List<CriterionStatus> _requiredDocs;
  
  // ✅ تم التغيير إلى File عشان نرفع الملف الفعلي للكيوبت
  final Map<String, File> _pickedFiles = {};

  @override
  void initState() {
    super.initState();
    if (widget.announcement.targetRole == 'admin_manager') {
      final allCriteria = AdminManagerCriteriaCalculator.getCriteria(widget.employee);
      _requiredDocs = allCriteria.where((c) => c.needsDocument).toList();
    } else {
      _requiredDocs = [];
    }
  }

  Future<void> _submitNomination() async {
    if (_isSubmitting) return;

    if (_requiredDocs.any((doc) => !_pickedFiles.containsKey(doc.documentType))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى رفع جميع الملفات والمستندات المطلوبة'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // ✅ تم تمرير الملفات للكيوبت
    await context.read<EmployeeNominationCubit>().submitNominationRequest(
      announcement: widget.announcement,
      employeeId: widget.employee.employeeId,
      employeeName: widget.employee.nameAr,
      employeeImageUrl: null,
      currentJob: widget.employee.currentJobAr,
      sectorName: widget.employee.adminSectorName,
      departmentName: widget.employee.adminSubDeptName,
      visionStatement: _visionController.text.trim().isEmpty ? null : _visionController.text.trim(),
      requiredFiles: _pickedFiles, // ✅ الملفات الفعلية
    );
  }

  @override
  void dispose() {
    _visionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocListener<EmployeeNominationCubit, EmployeeNominationState>(
      listener: (context, state) {
        if (state is EmployeeNominationLoading) {
          if (mounted) setState(() => _isSubmitting = true);
        } else if (state is EmployeeNominationActionSuccess) {
          if (mounted) {
            setState(() => _isSubmitting = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('employee_nomination_page.nomination.success'.tr()), backgroundColor: Colors.green),
            );
            context.pop();
          }
        } else if (state is EmployeeNominationError) {
          if (mounted) {
            setState(() => _isSubmitting = false);
            String message = state.message;
            if (state.message.contains('.') || state.message.contains('_')) {
              final translated = state.message.tr();
              if (translated != state.message) message = translated;
            }
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('employee_nomination_page.nomination.title'.tr()),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('employee_nomination_page.nomination.applicant_data'.tr(), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    SizedBox(height: 12.h),
                    _buildDataRow(context, 'employee_nomination_page.nomination.name'.tr(), widget.employee.nameAr),
                    _buildDataRow(context, 'employee_nomination_page.nomination.current_job'.tr(), widget.employee.currentJobAr),
                    if (widget.employee.adminSectorName != null && widget.employee.adminSectorName!.trim().isNotEmpty)
                      _buildDataRow(context, 'employee_nomination_page.nomination.sector'.tr(), widget.employee.adminSectorName!),
                    if (widget.employee.adminSubDeptName != null && widget.employee.adminSubDeptName!.trim().isNotEmpty)
                      _buildDataRow(context, 'employee_nomination_page.nomination.department'.tr(), widget.employee.adminSubDeptName!),
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('employee_nomination_page.nomination.job_applied_for'.tr(), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.primary)),
                    SizedBox(height: 12.h),
                    _buildDataRow(context, 'اسم الإعلان', widget.announcement.title),
                  ],
                ),
              ),

              if (_requiredDocs.isNotEmpty) ...[
                SizedBox(height: 25.h),
                Text('الملفات والمستندات المطلوبة', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                SizedBox(height: 12.h),
                ..._requiredDocs.map((doc) => _buildRequiredDocumentCard(context, doc)),
                SizedBox(height: 10.h),
              ],

              SizedBox(height: 30.h),

              Text('employee_nomination_page.nomination.development_vision'.tr(), style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
              SizedBox(height: 10.h),
              TextField(
                controller: _visionController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'employee_nomination_page.nomination.vision_hint'.tr(),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                  alignLabelWithHint: true,
                  contentPadding: EdgeInsets.all(14.w),
                ),
              ),

              SizedBox(height: 20.h),

              Container(
                width: double.infinity,
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(color: colorScheme.primaryContainer.withOpacity(0.35), borderRadius: BorderRadius.circular(12.r)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline_rounded, color: colorScheme.primary, size: 22.sp),
                    SizedBox(width: 10.w),
                    Expanded(child: Text('employee_nomination_page.nomination.info_message'.tr(), style: theme.textTheme.bodyMedium)),
                  ],
                ),
              ),

              SizedBox(height: 30.h),

              SizedBox(
                width: double.infinity,
                height: 55.h,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitNomination,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    disabledBackgroundColor: colorScheme.primary.withOpacity(0.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
                  ),
                  child: _isSubmitting
                      ? SizedBox(width: 24.w, height: 24.w, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.send_rounded, color: Colors.white, size: 22.sp),
                            SizedBox(width: 10.w),
                            Text('employee_nomination_page.nomination.submit'.tr(), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.sp)),
                          ],
                        ),
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequiredDocumentCard(BuildContext context, CriterionStatus doc) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final bool isPicked = _pickedFiles.containsKey(doc.documentType);
    final String fileName = isPicked ? _pickedFiles[doc.documentType]!.path.split('/').last : '';

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isPicked ? Colors.green.withOpacity(0.05) : colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: isPicked ? Colors.green : theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: isPicked ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              isPicked ? Icons.check_circle_outline : Icons.upload_file,
              color: isPicked ? Colors.green : Colors.orange,
              size: 22.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.locale.languageCode == 'ar' ? doc.titleAr : doc.titleEn,
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 2.h),
                isPicked 
                ? Text(fileName, style: theme.textTheme.bodySmall?.copyWith(color: Colors.green, fontSize: 11.sp), maxLines: 1, overflow: TextOverflow.ellipsis)
                : Text(doc.details ?? '', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontSize: 11.sp)),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: () async {
              // ✅ تم تصحيح أمر اختيار الملفات
              FilePickerResult? result = await FilePicker.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['pdf', 'jpg', 'png', 'jpeg'],
              );

              // ✅ حفظ الملف الفعلي وليس اسمه فقط
              if (result != null && result.files.single.path != null) {
                setState(() {
                  _pickedFiles[doc.documentType!] = File(result.files.single.path!);
                });
              }
            },
            icon: Icon(isPicked ? Icons.edit_document : Icons.cloud_upload_outlined, size: 18.sp, color: theme.colorScheme.primary),
            label: Text(isPicked ? 'تغيير' : 'رفع', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  Widget _buildDataRow(BuildContext context, String title, String? value) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$title: ', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600, fontSize: 13.sp)),
          Expanded(child: Text(value?.trim().isNotEmpty == true ? value! : '-', style: theme.textTheme.bodySmall?.copyWith(fontSize: 13.sp, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}