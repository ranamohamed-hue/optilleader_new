import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:optialeader/feature/database_admin/data/models/employee_model.dart';
import 'package:optialeader/feature/employee/data/models/employee_course_model.dart';
import 'package:optialeader/feature/employee/data/repo/employee_courses_repo.dart';
import 'package:optialeader/feature/employee/logic/employee_courses_cubit.dart';
import 'package:optialeader/feature/employee/logic/employee_courses_state.dart';

import 'widgets/course_card.dart';
import 'widgets/empty_courses_state.dart';
import 'widgets/add_course_sheet.dart';

class EmployeeCoursesPage extends StatelessWidget {
  final EmployeeModel employee;

  const EmployeeCoursesPage({
    super.key,
    required this.employee,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final uid = employee.uid ?? '';

    // ============================================================
    // حماية في حالة عدم وجود UID
    // ============================================================

    if (uid.isEmpty) {
      return Scaffold(
        backgroundColor: colorScheme.secondary,

        appBar: AppBar(
          backgroundColor: colorScheme.surface,

          title: Text(
            'employee_courses.page_title'.tr(),
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),

          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              size: 20,
              color: colorScheme.onSurface,
            ),
            onPressed: () => context.pop(),
          ),

          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(25),
            ),
          ),
        ),

        body: Center(
          child: Text(
            'employee_courses.invalid_employee'.tr(),
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    // ============================================================
    // Bloc Provider
    // ============================================================

    return BlocProvider(
      create: (context) {
        return EmployeeCoursesCubit(
          repo: EmployeeCoursesRepo(),
        )..loadCourses(uid);
      },

      // ============================================================
      // Bloc Listener
      // ============================================================

      child: BlocListener<EmployeeCoursesCubit, EmployeeCoursesState>(
        listener: (context, state) {
          // ======================================================
          // نجاح العملية
          // ======================================================

          if (state is EmployeeCoursesActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message.tr(),
                ),
                backgroundColor: Colors.green,
              ),
            );
          }

          // ======================================================
          // Error
          // ======================================================

          else if (state is EmployeeCoursesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                ),
                backgroundColor: colorScheme.error,
              ),
            );
          }
        },

        // ==========================================================
        // Scaffold
        // ==========================================================

        child: Scaffold(
          backgroundColor: colorScheme.secondary,

          // ======================================================
          // AppBar
          // ======================================================

          appBar: AppBar(
            backgroundColor: colorScheme.surface,

            title: Text(
              'employee_courses.page_title'.tr(),
              style: TextStyle(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),

            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new,
                size: 20,
                color: colorScheme.onSurface,
              ),

              onPressed: () => context.pop(),
            ),

            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(25),
              ),
            ),
          ),

          // ======================================================
          // Floating Action Button
          // ======================================================

          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              _showAddCourseSheet(context);
            },

            backgroundColor: colorScheme.secondary,

            icon: Icon(
              Icons.add_circle_outline,
              color: colorScheme.primary,
            ),

            label: Text(
              'employee_courses.add_button'.tr(),
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // ======================================================
          // Body
          // ======================================================

          body: BlocBuilder<
              EmployeeCoursesCubit,
              EmployeeCoursesState>(
            builder: (context, state) {
              // ==================================================
              // Initial / Loading
              // ==================================================

              if (state is EmployeeCoursesInitial ||
                  state is EmployeeCoursesLoading) {
                return Center(
                  child: CircularProgressIndicator(
                    color: colorScheme.secondary,
                  ),
                );
              }

              // ==================================================
              // Error
              // ==================================================

              if (state is EmployeeCoursesError) {
                return _buildErrorState(
                  context,
                  state.message,
                );
              }

              // ==================================================
              // Loaded
              // ==================================================

              if (state is EmployeeCoursesLoaded) {
                final List<EmployeeCourseModel> courses =
                    state.courses;

                // ------------------------------------------------
                // لا توجد دورات
                // ------------------------------------------------

                if (courses.isEmpty) {
                  return const EmptyCoursesState();
                }

                // ------------------------------------------------
                // قائمة الدورات
                // ------------------------------------------------

                return ListView.builder(
                  padding: const EdgeInsets.only(
                    bottom: 100,
                    left: 16,
                    right: 16,
                    top: 16,
                  ),

                  physics: const BouncingScrollPhysics(),

                  itemCount: courses.length,

                  itemBuilder: (context, index) {
                    final EmployeeCourseModel course =
                        courses[index];

                    return CourseCard(
                      course: course,
                    );
                  },
                );
              }

              // ==================================================
              // Uploading
              // ==================================================

              if (state is EmployeeCoursesUploading) {
                return Center(
                  child: CircularProgressIndicator(
                    color: colorScheme.secondary,
                  ),
                );
              }

              // ==================================================
              // Default
              // ==================================================

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  // ============================================================
  // Error State
  // ============================================================

  Widget _buildErrorState(
    BuildContext context,
    String message,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 60,
              color: colorScheme.error,
            ),

            const SizedBox(height: 16),

            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: () {
                final uid = employee.uid;

                if (uid == null || uid.isEmpty) {
                  return;
                }

                context
                    .read<EmployeeCoursesCubit>()
                    .loadCourses(uid);
              },

              icon: const Icon(
                Icons.refresh,
              ),

              label: Text(
                'employee_courses.retry'.tr(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // Add Course Bottom Sheet
  // ============================================================

  void _showAddCourseSheet(
    BuildContext context,
  ) {
    final uid = employee.uid;

    if (uid == null || uid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'employee_courses.invalid_employee'.tr(),
          ),
          backgroundColor:
              Theme.of(context).colorScheme.error,
        ),
      );

      return;
    }

    showModalBottomSheet(
      context: context,

      isScrollControlled: true,

      backgroundColor: Colors.transparent,

      builder: (sheetContext) {
        return AddCourseSheet(
          uid: uid,
        );
      },
    );
  }
}