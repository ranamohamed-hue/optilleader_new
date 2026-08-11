import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:optialeader/feature/database_admin/data/models/employee_model.dart';
import 'package:optialeader/feature/employee/data/repo/employee_courses_repo.dart';
import 'package:optialeader/feature/employee/logic/employee_courses_cubit.dart';
import 'package:optialeader/feature/employee/logic/employee_courses_state.dart';

import 'widgets/course_card.dart';
import 'widgets/empty_courses_state.dart';
import 'widgets/add_course_sheet.dart';

class EmployeeCoursesPage extends StatelessWidget {
  final EmployeeModel employee;
  const EmployeeCoursesPage({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final uid = employee.uid ?? '';

    return BlocProvider(
      // حقن الـ Repo داخل الـ Cubit
      create: (context) => EmployeeCoursesCubit(repo: EmployeeCoursesRepo())..loadCourses(uid),
      child: BlocListener<EmployeeCoursesCubit, EmployeeCoursesState>(
        listener: (context, state) {
          // ✅ الاستماع للأحداث (Side Effects) فقط
          if (state is EmployeeCoursesActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message.tr()), backgroundColor: Colors.green),
            );
            // إغلاق الـ Bottom Sheet بعد النجاح
            if (Navigator.canPop(context)) Navigator.pop(context);
          } else if (state is EmployeeCoursesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error), backgroundColor: colorScheme.error),
            );
          }
        },
        child: Scaffold(
          backgroundColor: colorScheme.secondary,
                  appBar: AppBar(
            backgroundColor: colorScheme.surface, // ✅ تحديد لون الخلفية صراحة
            title: Text(
              'employee_courses.page_title'.tr(),
              style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold), // ✅ لون العنوان واضح
            ),
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new, 
                size: 20, 
                color: colorScheme.onSurface, // ✅ لون السهم واضح (أبيض في الليلي، أسود في الفاتح)
              ),
              onPressed: () => Navigator.of(context).pop(), // ✅ استخدام Navigator.pop المباشر لضمان الرجوع
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
            ),
          ),
         
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddCourseSheet(context),
            backgroundColor: colorScheme.secondary,
            icon: Icon(Icons.add_circle_outline, color: colorScheme.primary),
            label: Text(
              'employee_courses.add_button'.tr(),
              style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold),
            ),
          ),
          body: BlocBuilder<EmployeeCoursesCubit, EmployeeCoursesState>(
            builder: (context, state) {
              // حالة التحميل الأولى
              if (state is EmployeeCoursesLoading || state is EmployeeCoursesInitial) {
                return Center(child: CircularProgressIndicator(color: colorScheme.secondary));
              }

              // حالة جلب البيانات
              final courses = (state is EmployeeCoursesLoaded) ? state.courses : <dynamic>[];

              if (courses.isEmpty) {
                return const EmptyCoursesState();
              }

              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 100, left: 16, right: 16, top: 16),
                physics: const BouncingScrollPhysics(),
                itemCount: courses.length,
                itemBuilder: (context, index) {
                  return CourseCard(course: courses[index]);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showAddCourseSheet(BuildContext context) {
    showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  builder: (context) => AddCourseSheet(uid: employee.uid!), // ✅ لا تنسَ تمرير الـ uid
);
  }
}