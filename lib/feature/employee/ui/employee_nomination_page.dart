import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:optialeader/feature/admin/data/model/announcement_model.dart';
import 'package:optialeader/feature/database_admin/data/models/employee_model.dart';

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
  final _visionController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitNomination() async {
    setState(() => _isSubmitting = true);

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      await FirebaseFirestore.instance.collection('nomination_requests').add({
        'user_id': uid,
        'user_name': widget.employee.nameAr,
        'user_role': 'admin_manager',
        'announcement_id': widget.announcement.id,
        'announcement_title': widget.announcement.title,
        'target_role': widget.announcement.targetRole,
        'vision_statement': _visionController.text.trim(),
        'status': 'pending',
        'created_at': Timestamp.now(),
        'admin_sector_name': widget.employee.adminSectorName,
        'admin_sub_dept_name': widget.employee.adminSubDeptName,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم إرسال طلب الترشح بنجاح'), backgroundColor: Colors.green),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ أثناء الإرسال'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
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

    return Scaffold(
      appBar: AppBar(
        title: Text('تقديم طلب الترشح'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // بيانات الموظف
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(color: colorScheme.surface, borderRadius: BorderRadius.circular(16.r), border: Border.all(color: colorScheme.outlineVariant)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('بيانات المتقدم', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  SizedBox(height: 10.h),
                  _buildDataRow('الاسم', widget.employee.nameAr),
                  _buildDataRow('الوظيفة الحالية', widget.employee.currentJobAr),
                  if (widget.employee.adminSectorName != null) _buildDataRow('القطاع', widget.employee.adminSectorName!),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            // بيانات الإعلان
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(color: colorScheme.primaryContainer.withOpacity(0.3), borderRadius: BorderRadius.circular(16.r), border: Border.all(color: colorScheme.primary.withOpacity(0.3))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('الوظيفة المتقدم لها', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.primary)),
                  SizedBox(height: 10.h),
                  _buildDataRow('المسمى الوظيفي', widget.announcement.title),
                ],
              ),
            ),
            SizedBox(height: 30.h),

            // حقل الرؤية
            Text('رؤيتك للتطوير (اختياري)', style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
            SizedBox(height: 10.h),
            TextField(
              controller: _visionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'اكتب رؤيتك ومقترحاتك لتطوير العمل...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                alignLabelWithHint: true,
              ),
            ),
            SizedBox(height: 40.h),

            // زر الإرسال
            SizedBox(
              width: double.infinity,
              height: 55.h,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitNomination,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
                ),
                child: _isSubmitting
                    ? CircularProgressIndicator(color: Colors.white)
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send_rounded, color: Colors.white),
                          SizedBox(width: 10.w),
                          Text('إرسال الطلب', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.sp)),
                        ],
                      ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow(String title, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$title: ', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w600, fontSize: 13.sp)),
          Expanded(child: Text(value, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}