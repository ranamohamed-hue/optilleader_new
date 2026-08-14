import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:optialeader/feature/admin/data/model/employee_course_approval_model.dart';
import 'package:optialeader/feature/admin/logic/employee_admin_approval/employee_course_approval_cubit.dart';
import 'package:optialeader/feature/admin/logic/employee_admin_approval/employee_course_approval_state.dart';

class EmployeeCourseApprovalPage extends StatefulWidget {
  const EmployeeCourseApprovalPage({
    super.key,
  });

  @override
  State<EmployeeCourseApprovalPage> createState() =>
      _EmployeeCourseApprovalPageState();
}

class _EmployeeCourseApprovalPageState
    extends State<EmployeeCourseApprovalPage> {
  @override
  void initState() {
    super.initState();

    context
        .read<EmployeeCourseApprovalCubit>()
        .loadPendingCourses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'اعتماد الدورات التدريبية',
        ),
      ),
      body: BlocConsumer<
          EmployeeCourseApprovalCubit,
          EmployeeCourseApprovalState>(
        listener: (context, state) {
          if (state
              is EmployeeCourseApprovalSuccess) {
            ScaffoldMessenger.of(context)
                .showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                ),
              ),
            );
          }

          if (state
              is EmployeeCourseApprovalError) {
            ScaffoldMessenger.of(context)
                .showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state
                  is EmployeeCourseApprovalLoading ||
              state
                  is EmployeeCourseApprovalInitial) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          if (state
              is EmployeeCourseApprovalLoaded) {
            if (state.courses.isEmpty) {
              return const Center(
                child: Text(
                  'لا توجد دورات معلقة',
                ),
              );
            }

            return ListView.builder(
              padding:
                  const EdgeInsets.all(12),
              itemCount:
                  state.courses.length,
              itemBuilder:
                  (context, index) {
                return _CourseCard(
                  item:
                      state.courses[index],
                );
              },
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final EmployeeCourseApprovalModel item;

  const _CourseCard({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final cubit =
        context.read<
            EmployeeCourseApprovalCubit>();

    return Card(
      margin:
          const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding:
            const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              item.employeeName,
              style: const TextStyle(
                fontWeight:
                    FontWeight.bold,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'الرقم الوظيفي: ${item.employeeId}',
            ),

            Text(
              'الإدارة: ${item.department}',
            ),

            const Divider(height: 24),

            Text(
              'اسم الدورة: ${item.course.title}',
              style: const TextStyle(
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'الجهة المنظمة: ${item.course.organization}',
            ),

            Text(
              'تاريخ الدورة: ${item.course.date}',
            ),

            if (item.course.durationHours !=
                null)
              Text(
                'عدد الساعات: ${item.course.durationHours}',
              ),

            Text(
              'نوع الدورة: ${item.course.courseType}',
            ),

            const SizedBox(height: 16),

            if (item.course
                        .certificateFileUrl !=
                    null &&
                item.course
                    .certificateFileUrl!
                    .isNotEmpty)
              OutlinedButton.icon(
                onPressed: () {
                  // افتحي الملف هنا
                },
                icon: const Icon(
                  Icons.picture_as_pdf,
                ),
                label: const Text(
                  'عرض الشهادة',
                ),
              ),

            const SizedBox(height: 16),

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
          decoration:
              const InputDecoration(
            hintText:
                'اكتب سبب الرفض',
          ),
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