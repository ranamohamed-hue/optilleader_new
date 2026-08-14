
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:optialeader/feature/admin/data/model/employee_course_approval_model.dart';
import 'package:optialeader/feature/admin/logic/employee_admin_approval/employee_course_approval_cubit.dart';

class AdminEmployeeCourseDetailsScreen
    extends StatelessWidget {
  final EmployeeCourseApprovalModel item;

  const AdminEmployeeCourseDetailsScreen({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final cubit =
        context.read<EmployeeCourseApprovalCubit>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'تفاصيل الدورة التدريبية',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            // بيانات الموظف

            Card(
              child: Padding(
                padding:
                    const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [

                    const Text(
                      'بيانات الموظف',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    _info(
                      'الاسم',
                      item.employeeName,
                    ),

                    _info(
                      'الرقم الوظيفي',
                      item.employeeId,
                    ),

                    _info(
                      'الإدارة',
                      item.department,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // بيانات الدورة

            Card(
              child: Padding(
                padding:
                    const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [

                    const Text(
                      'بيانات الدورة',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    _info(
                      'اسم الدورة',
                      item.course.title,
                    ),

                    _info(
                      'الجهة المنظمة',
                      item.course.organization,
                    ),

                    _info(
                      'تاريخ الدورة',
                      item.course.date,
                    ),

                    _info(
                      'نوع الدورة',
                      item.course.courseType,
                    ),

                    if (item.course.durationHours !=
                        null)
                      _info(
                        'عدد الساعات',
                        item.course.durationHours!,
                      ),

                    _info(
                      'الحالة',
                      item.course.status,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            if (item.course.certificateFileUrl !=
                    null &&
                item.course.certificateFileUrl!
                    .isNotEmpty)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // launchUrl(...)
                  },
                  icon: const Icon(
                    Icons.picture_as_pdf,
                  ),
                  label: const Text(
                    'عرض الشهادة',
                  ),
                ),
              ),

            const SizedBox(height: 24),

            Row(
              children: [

                Expanded(
                  child:
                      ElevatedButton.icon(
                    onPressed: () {
                      cubit.approveCourse(
                        employeeUid:
                            item.employeeUid,
                        courseId:
                            item.course.id!,
                        courseTitle:
                            item.course.title,
                      );

                      Navigator.pop(
                        context,
                      );
                    },
                    icon: const Icon(
                      Icons.check,
                    ),
                    label: const Text(
                      'اعتماد',
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child:
                      ElevatedButton.icon(
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.red,
                    ),
                    onPressed: () {
                      _showRejectDialog(
                        context,
                        item,
                      );
                    },
                    icon: const Icon(
                      Icons.close,
                    ),
                    label: const Text(
                      'رفض',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _info(
    String title,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(
            '$title : ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}

void _showRejectDialog(
  BuildContext context,
  EmployeeCourseApprovalModel item,
) {
  final controller =
      TextEditingController();

  showDialog(
    context: context,
    builder: (_) {
      return AlertDialog(
        title: const Text(
          'سبب الرفض',
        ),
        content: TextField(
          controller: controller,
          maxLines: 3,
        ),
        actions: [

          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'إلغاء',
            ),
          ),

          ElevatedButton(
            onPressed: () {
              final reason =
                  controller.text.trim();

              if (reason.isEmpty) {
                return;
              }

              context
                  .read<
                      EmployeeCourseApprovalCubit>()
                  .rejectCourse(
                    employeeUid:
                        item.employeeUid,
                    courseId:
                        item.course.id!,
                    courseTitle:
                        item.course.title,
                    reason: reason,
                  );

              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text(
              'رفض',
            ),
          ),
        ],
      );
    },
  );
}
