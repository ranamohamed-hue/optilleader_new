import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:optialeader/core/routing/routes.dart';
import 'package:optialeader/feature/admin/data/model/announcement_model.dart';
import 'package:optialeader/feature/admin/data/repo/announcement_repos/announcement_repo_impl.dart';
import 'package:optialeader/feature/admin/logic/announcement_logic/announcement_cubit.dart';
import 'package:optialeader/feature/admin/logic/announcement_logic/announcement_state.dart';
import 'package:optialeader/feature/database_admin/data/models/employee_model.dart';
import 'package:optialeader/feature/database_admin/logic/employee_logic/employee_cubit.dart';
import 'package:optialeader/feature/database_admin/logic/employee_logic/employee_state.dart';
import 'package:optialeader/feature/employee/ui/employee_archive_page.dart';
import 'package:optialeader/feature/notification/logic/app_notification_cubit.dart';
import 'package:optialeader/feature/notification/ui/notification_page.dart';
import 'package:optialeader/feature/notification/data/repo/notification_repo.dart';
import 'package:optialeader/feature/setting/ui/setting.dart';

class EmployeeDashboardScreen extends StatefulWidget {
  const EmployeeDashboardScreen({super.key});

  @override
  State<EmployeeDashboardScreen> createState() =>
      _EmployeeDashboardScreenState();
}

class _EmployeeDashboardScreenState extends State<EmployeeDashboardScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        context.read<EmployeeDataCubit>().getEmployeeProfile(uid);

        // ❌❌❌ شيلنا السطر ده لأن الكيوبت الجديد هيشتغل لوحده ❌❌❌
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorPrimary = theme.primaryColor;
    final colorGold = theme.colorScheme.secondary;

    return BlocProvider(
      create: (context) => AnnouncementCubit(
        context.read<AnnouncementRepositoryImpl>(),
        context.read<NotificationRepo>(),
        isAdmin: false, // ✅ الموظف مش هيشوف غير إعلانات الإدارة
      ),
      child: BlocBuilder<EmployeeDataCubit, EmployeeDataState>(
        builder: (context, state) {
          if (state is EmployeeLoading || state is EmployeeInitial) {
            return Scaffold(
              body: Center(child: CircularProgressIndicator(color: colorGold)),
            );
          }

          if (state is EmployeeError) {
            return Scaffold(body: Center(child: Text(state.error)));
          }

          if (state is EmployeeLoaded) {
            final employee = state.employee;

            return Scaffold(
              backgroundColor: theme.scaffoldBackgroundColor,
              body: IndexedStack(
                index: _currentIndex,
                children: [
                  _HomeTab(employee: employee),
                  _NotificationsTab(),
                  _SettingsTab(employee: employee),
                ],
              ),
              bottomNavigationBar: _buildBottomNav(),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildBottomNav() {
    final colorScheme = Theme.of(context).colorScheme;

    return BottomNavigationBar(
      selectedItemColor: colorScheme.secondary,
      unselectedItemColor: colorScheme.onSurfaceVariant,
      backgroundColor: colorScheme.surface,
      type: BottomNavigationBarType.fixed,
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home_rounded),
          label: 'employee_dashboard.nav.home'.tr(),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.notifications_active_outlined),
          label: 'employee_dashboard.nav.notifications'.tr(),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.settings_outlined),
          label: 'employee_dashboard.nav.settings'.tr(),
        ),
      ],
    );
  }
}

// ============================================================
// 1. تبويب الصفحة الرئيسية
// ============================================================
class _HomeTab extends StatelessWidget {
  final EmployeeModel employee;
  const _HomeTab({required this.employee});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorPrimary = theme.primaryColor;
    final colorGold = theme.colorScheme.secondary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              decoration: BoxDecoration(
                color: colorPrimary,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(30.r),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          employee.nameAr,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          employee.currentJobAr,
                          style: TextStyle(color: colorGold, fontSize: 12.sp),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: colorGold, width: 3),
                    ),
                    child: CircleAvatar(
                      radius: 30.r,
                      backgroundColor: Colors.white24,
                      child: ClipOval(
                        child: employee.profileImage.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: employee.profileImage,
                                width: 60.r,
                                height: 60.r,
                                fit: BoxFit.cover,
                                placeholder: (_, _) => Icon(
                                  Icons.person,
                                  color: colorGold,
                                  size: 30.sp,
                                ),
                                errorWidget: (_, _, _) => Icon(
                                  Icons.person,
                                  color: colorGold,
                                  size: 30.sp,
                                ),
                              )
                            : Icon(Icons.person, color: colorGold, size: 30.sp),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionCard(
                          context,
                          icon: Icons.upload_file,
                          title: 'employee_dashboard.actions.upload_files'.tr(),
                          color: isDark
                              ? const Color.fromARGB(255, 221, 178, 114)
                              : colorGold,
                          onTap: () {
                            context.push(
                              Routes.employeeArchievePage,
                              extra: employee,
                            );
                          },
                        ),
                      ),
                      SizedBox(width: 15.w),
                      Expanded(
                        child: _buildActionCard(
                          context,
                          icon: Icons.school_rounded,
                          title: 'employee_dashboard.actions.courses'.tr(),
                          color: colorGold,
                          onTap: () => context.push(
                            Routes.employeeCourses,
                            extra: employee,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 25.h),
                  _buildSectionTitle(
                    colorGold,
                    colorPrimary,
                    'employee_dashboard.sections.latest_announcements'.tr(),
                  ),
                  SizedBox(height: 15.h),
                  _buildAnnouncementsList(context),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 25.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(icon, color: color, size: 32.sp),
            ),
            SizedBox(height: 12.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(Color gold, Color navy, String title) {
    return Row(
      children: [
        Container(
          width: 5.w,
          height: 20.h,
          decoration: BoxDecoration(
            color: gold,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        SizedBox(width: 12.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: navy,
          ),
        ),
      ],
    );
  }

  Widget _buildAnnouncementsList(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<AnnouncementCubit, AnnouncementState>(
      builder: (context, state) {
        if (state is AnnouncementLoading) {
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colorScheme.secondary,
            ),
          );
        }

        if (state is AnnouncementError) {
          return Center(
            child: Text(
              'حدث خطأ في جلب الإعلانات',
              style: TextStyle(color: colorScheme.error),
            ),
          );
        }

        List<AnnouncementModel> announcements = [];
        if (state is AnnouncementLoaded) {
          announcements = state.announcements;
        }

        if (announcements.isEmpty) {
          return Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: Text(
                'employee_dashboard.sections.no_announcements'.tr(),
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ),
          );
        }

        final displayedAnnouncements = announcements.take(3).toList();

        return Column(
          children: displayedAnnouncements.map((ann) {
            return Card(
              margin: EdgeInsets.only(bottom: 10.h),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
                side: BorderSide(
                  color: colorScheme.outlineVariant.withOpacity(0.3),
                ),
              ),
              color: colorScheme.surface,
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 8.h,
                ),
                leading: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.campaign_rounded,
                    color: colorScheme.primary,
                    size: 22.sp,
                  ),
                ),
                title: Text(
                  ann.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                    color: colorScheme.onSurface,
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 14.sp,
                  color: colorScheme.outline,
                ),
onTap: () {
  context.push(
    '${Routes.announcementDetailsAdminPage}?id=${ann.id}',
  );
},              ),
            );
          }).toList(),
        );
      },
    );
  }
}

// ============================================================
// 2. تبويب الإشعارات
// ============================================================
class _NotificationsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const NotificationsScreen();
}

// ============================================================
// 3. تبويب الإعدادات
// ============================================================
class _SettingsTab extends StatelessWidget {
  final EmployeeModel employee;
  const _SettingsTab({required this.employee});

  @override
  Widget build(BuildContext context) =>
      SettingsScreen(uid: employee.uid ?? '', role: 'employee');
}
