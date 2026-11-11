import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:optialeader/feature/admin/data/model/employee_course_approval_model.dart';
import 'package:optialeader/feature/admin/logic/employee_admin_approval/employee_course_approval_cubit.dart';

class AdminEmployeeCourseDetailsScreen extends StatelessWidget {
  final EmployeeCourseApprovalModel item;

  const AdminEmployeeCourseDetailsScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<EmployeeCourseApprovalCubit>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text('employee_course_details.title'.tr())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'employee_course_details.employee_data'.tr(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _info(
                      'employee_course_details.name'.tr(),
                      item.employeeName,
                    ),
                    _info(
                      'employee_course_details.employee_id'.tr(),
                      item.employeeId,
                    ),
                    _info(
                      'employee_course_details.department'.tr(),
                      item.department,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'employee_course_details.course_data'.tr(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _info(
                      'employee_course_details.course_name'.tr(),
                      item.course.title,
                    ),
                    _info(
                      'employee_course_details.organization'.tr(),
                      item.course.organization,
                    ),
                    _info(
                      'employee_course_details.course_date'.tr(),
                      item.course.date,
                    ),
                    _info(
                      'employee_course_details.course_type'.tr(),
                      item.course.courseType,
                    ),
                    if (item.course.durationHours != null)
                      _info(
                        'employee_course_details.hours'.tr(),
                        item.course.durationHours!,
                      ),
                    _info(
                      'employee_course_details.status'.tr(),
                      item.course.status,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 1. زر عرض الشهادة (يظهر فقط لو الرابط موجود وصحيح)
            if (item.course.certificateFileUrl != null &&
                item.course.certificateFileUrl!.isNotEmpty) ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final url = Uri.parse(item.course.certificateFileUrl!);
                    if (await canLaunchUrl(url)) {
                      await launchUrl(
                        url,
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  },
                  icon: const Icon(Icons.picture_as_pdf),
                  label: Text(
                    'employee_course_details.view_certificate'.tr(),
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],

            // 2. ✅ زرار VerifyMe (يظهر دائماً بغض النظر عن وجود الرابط أو كونه وهمياً)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.secondary,
                  side: BorderSide(color: colorScheme.secondary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  final url = Uri.parse(
                    'https://verifyme-secure.lovable.app/',
                  );
                  if (await canLaunchUrl(url)) {
                    await launchUrl(
                      url,
                      mode: LaunchMode.externalApplication,
                    );
                  }
                },
                icon: const Icon(Icons.security, size: 18),
                label: Text(
                  'report.verify_me.course_button'.tr(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.secondary,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      cubit.approveCourse(
                        employeeUid: item.employeeUid,
                        courseId: item.course.id!,
                        courseTitle: item.course.title,
                      );
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.check),
                    label: Text('employee_course_details.approve'.tr()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () {
                      _showRejectDialog(context, item);
                    },
                    icon: const Icon(Icons.close),
                    label: Text('employee_course_details.reject'.tr()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _info(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(
            '$title : ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

void _showRejectDialog(BuildContext context, EmployeeCourseApprovalModel item) {
  final controller = TextEditingController();

  showDialog(
    context: context,
    builder: (_) {
      return AlertDialog(
        title: Text('employee_course_details.rejection_reason'.tr()),
        content: TextField(controller: controller, maxLines: 3),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('employee_course_details.cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () {
              final reason = controller.text.trim();
              if (reason.isEmpty) {
                return;
              }
              context.read<EmployeeCourseApprovalCubit>().rejectCourse(
                employeeUid: item.employeeUid,
                courseId: item.course.id!,
                courseTitle: item.course.title,
                reason: reason,
              );
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('employee_course_details.reject'.tr()),
          ),
        ],
      );
    },
  );
}