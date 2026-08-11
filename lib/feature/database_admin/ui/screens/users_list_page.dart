import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:optialeader/core/routing/routes.dart';
import 'package:optialeader/core/theming/app_color.dart';
import 'package:optialeader/feature/database_admin/logic/admin_data/admin_data_cubit.dart';
import 'package:optialeader/feature/database_admin/logic/admin_data/admin_data_state.dart';
import 'package:optialeader/feature/database_admin/logic/doctor_data/doctor_data_cubit.dart';
import 'package:optialeader/feature/database_admin/logic/doctor_data/doctor_data_state.dart';
import 'package:optialeader/feature/database_admin/logic/employee_logic/employee_cubit.dart';
// ⚠️ تأكد من استيراد ملف الـ State الخاص بالموظفين بشكل صحيح
import 'package:optialeader/feature/database_admin/logic/employee_logic/employee_state.dart'; 
import 'package:optialeader/feature/database_admin/logic/judge_data/judge_data_cubit.dart';
import 'package:optialeader/feature/database_admin/logic/judge_data/judge_data_state.dart';

class UsersListPage extends StatefulWidget {
  final String role;

  const UsersListPage({super.key, required this.role});

  @override
  State<UsersListPage> createState() => _UsersListPageState();
}

class _UsersListPageState extends State<UsersListPage> {
  @override
  void initState() {
      debugPrint('🔥 UsersListPage role = ${widget.role}');
    super.initState();
    if (widget.role == 'doctor') {
      context.read<DoctorDataCubit>().watchAllDoctors();
    } else if (widget.role == 'judge') {
      context.read<JudgeDataCubit>().watchAllJudges();
    } else if (widget.role == 'admin') {
      context.read<AdminDataCubit>().watchAllAdmins();
    } else if (widget.role == 'admin_manager') { // ✅ تم توحيد الاسم
      context.read<EmployeeDataCubit>().watchAllEmployees();
    }
  }

  @override
  Widget build(BuildContext context) {
    String title = '';
    switch (widget.role) {
      case 'doctor':
        title = 'users_list_doctors'.tr();
        break;
      case 'judge':
        title = 'users_list_judges'.tr();
        break;
      case 'admin':
        title = 'users_list_admins'.tr();
        break;
      case 'admin_manager': 
        title = 'users_list_admins_manager'.tr();
        break;
    }

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: _buildBody(context),
    );
  }

    Widget _buildBody(BuildContext context) {
    // ═══════════════════════════════════════════════════════
    // 1. الأطباء
    // ═══════════════════════════════════════════════════════
    if (widget.role == 'doctor') {
      return BlocBuilder<DoctorDataCubit, DoctorDataState>(
        builder: (context, state) {
          // ✅ لو مفيش بيانات ولا لودينج ولا خطأ = جاي من عملية نجاح، نفعل ريفريش
          if (state is! AllDoctorLoaded && state is! DoctorLoading && state is! DoctorError) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) context.read<DoctorDataCubit>().watchAllDoctors();
            });
            return const Center(child: CircularProgressIndicator(color: AppColors.darkGold));
          }

          if (state is DoctorLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.darkGold));
          }
          if (state is AllDoctorLoaded) {
            return _buildUsersList(
              context,
              state.doctors!.map((d) => _UserInfo(uid: d.uid ?? '', nameAr: d.nameAr, nameEn: d.nameEn, jobAr: d.currentJobAr, jobEn: d.currentJobEn, image: d.profileImage, role: 'doctor')).toList(),
            );
          }
          if (state is DoctorError) {
            return Center(child: Text(state.error ?? 'unknown_error'.tr()));
          }
          return const SizedBox();
        },
      );
    }

    // ═══════════════════════════════════════════════════════
    // 2. القضاة
    // ═══════════════════════════════════════════════════════
    if (widget.role == 'judge') {
      return BlocBuilder<JudgeDataCubit, JudgeDataState>(
        builder: (context, state) {
          // ✅ نفس المنطق الآمن
          if (state is! AllJudgesLoaded && state is! JudgeLoading && state is! JudgeError) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) context.read<JudgeDataCubit>().watchAllJudges();
            });
            return const Center(child: CircularProgressIndicator(color: AppColors.darkGold));
          }

          if (state is JudgeLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.darkGold));
          }
          if (state is AllJudgesLoaded) {
            return _buildUsersList(
              context,
              state.judges.map((j) => _UserInfo(uid: j.uid, nameAr: j.nameAr, nameEn: j.nameEn, jobAr: j.jopAr, jobEn: j.jopEn, image: j.profileImage, role: 'judge')).toList(),
            );
          }
          if (state is JudgeError) {
            return Center(child: Text(state.error ?? 'unknown_error'.tr()));
          }
          return const SizedBox();
        },
      );
    }

    // ═══════════════════════════════════════════════════════
    // 3. الأدمن
    // ═══════════════════════════════════════════════════════
    if (widget.role == 'admin') {
      return BlocBuilder<AdminDataCubit, AdminDataState>(
        builder: (context, state) {
          // ✅ نفس المنطق الآمن
          if (state is! AllAdminsLoaded && state is! AdminLoading && state is! AdminError) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) context.read<AdminDataCubit>().watchAllAdmins();
            });
            return const Center(child: CircularProgressIndicator(color: AppColors.darkGold));
          }

          if (state is AdminLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.darkGold));
          }
          if (state is AllAdminsLoaded) {
            return _buildUsersList(
              context,
              state.admins.map((a) => _UserInfo(uid: a.uid ?? '', nameAr: a.nameAr, nameEn: a.nameEn, jobAr: a.jopAr ?? '', jobEn: a.jopEn ?? '', image: a.profileImage, role: 'admin')).toList(),
            );
          }
          if (state is AdminError) {
            return Center(child: Text(state.error ?? 'unknown_error'.tr()));
          }
          return const SizedBox();
        },
      );
    }

    // ═══════════════════════════════════════════════════════
    // 4. الموظفين الإداريين
    // ═══════════════════════════════════════════════════════
    if (widget.role == 'admin_manager') {
      return BlocBuilder<EmployeeDataCubit, EmployeeDataState>(
        builder: (context, state) {
          // ✅ نفس المنطق الآمن
          if (state is! AllEmployeesLoaded && state is! EmployeeLoading && state is! EmployeeError) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) context.read<EmployeeDataCubit>().watchAllEmployees();
            });
            return const Center(child: CircularProgressIndicator(color: AppColors.darkGold));
          }

          if (state is EmployeeLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.darkGold));
          }
          if (state is AllEmployeesLoaded) {
            if (state.employees.isEmpty) {
              return Center(child: Text('no_users_found'.tr()));
            }
            return _buildUsersList(
              context,
              state.employees.map((e) => _UserInfo(uid: e.uid ?? '', nameAr: e.nameAr, nameEn: e.nameEn, jobAr: e.currentJobAr, jobEn: e.currentJobEn, image: e.profileImage, role: 'admin_manager')).toList(),
            );
          }
          if (state is EmployeeError) {
            return Center(child: Text(state.error));
          }
          return const SizedBox();
        },
      );
    }

    return Center(child: Text('invalid_role'.tr()));
  }
  Widget _buildUsersList(BuildContext context, List<_UserInfo> users) {
    if (users.isEmpty) {
      return Center(child: Text('no_users_found'.tr()));
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        final isArabic = context.locale.languageCode == 'ar';

        return GestureDetector(
          onTap: () {
            String route = '';
            if (user.role == 'doctor') {
              route = Routes.addDoctorPage;
            } else if (user.role == 'judge') {
              route = Routes.addJudgePage;
            } else if (user.role == 'admin') {
              route = Routes.addAdminPage;
            } else if (user.role == 'admin_manager') {
              route = Routes.addEmployeePage; // ✅ توجيه لصفحة تفاصيل/تعديل الموظف
            }

            if (route.isNotEmpty) {
              context.push(
                route,
                extra: {'existingUid': user.uid, 'isViewMode': true},
              );
            }
          },
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
            elevation: 3,
            margin: EdgeInsets.only(bottom: 15.h),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30.r,
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: ClipOval(
                      child: user.image.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: user.image,
                              fit: BoxFit.cover,
                              width: 60.r,
                              height: 60.r,
                              placeholder: (_, _) => Icon(Icons.person, size: 25.sp),
                              errorWidget: (_, _, _) => Icon(Icons.person, size: 25.sp, color: Colors.white),
                            )
                          : Icon(Icons.person, size: 25.sp, color: Colors.white),
                    ),
                  ),
                  SizedBox(width: 15.w),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isArabic ? user.nameAr : user.nameEn,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        SizedBox(height: 5.h),
                        Text(
                          isArabic ? user.jobAr : user.jobEn,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  
                  Icon(Icons.arrow_forward, color: Theme.of(context).colorScheme.secondary, size: 24.sp),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _UserInfo {
  final String uid;
  final String nameAr;
  final String nameEn;
  final String jobAr;
  final String jobEn;
  final String image;
  final String role;

  _UserInfo({
    required this.uid,
    required this.nameAr,
    required this.nameEn,
    required this.jobAr,
    required this.jobEn,
    required this.image,
    required this.role,
  });
}