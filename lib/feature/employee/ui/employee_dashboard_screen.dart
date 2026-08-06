import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:optialeader/core/routing/routes.dart';
import 'package:optialeader/feature/database_admin/data/models/employee_model.dart';
import 'package:optialeader/feature/database_admin/logic/employee_logic/employee_cubit.dart';
import 'package:optialeader/feature/database_admin/logic/employee_logic/employee_state.dart';
import 'package:optialeader/feature/notification/logic/app_notification_cubit.dart';
import 'package:optialeader/feature/notification/ui/notification_page.dart';
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
        context.read<NotificationCubit>().fetchNotifications();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorPrimary = theme.primaryColor;
    final colorGold = theme.colorScheme.secondary;

    return BlocBuilder<EmployeeDataCubit, EmployeeDataState>(
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
                _HomeTab(
                  employee: employee,
                  onTabTapped: (index) => setState(() => _currentIndex = index),
                ),
                _NotificationsTab(),
                _SettingsTab(employee: employee),
              ],
            ),
            bottomNavigationBar: _buildBottomNav(
              colorPrimary,
              colorGold,
              employee,
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildBottomNav(Color navy, Color gold, EmployeeModel employee) {
    return BottomNavigationBar(
      selectedItemColor: gold,
      unselectedItemColor: navy.withOpacity(0.4),
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
  final ValueChanged<int> onTabTapped;

  const _HomeTab({required this.employee, required this.onTabTapped});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorPrimary = theme.primaryColor;
    final colorGold = theme.colorScheme.secondary;

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // ====== Header ======
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
                          'employee_dashboard.welcome'.tr(),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14.sp,
                          ),
                        ),
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
                  // ====== كروت الإجراءات السريعة (صف 1) ======
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionCard(
                          context,
                          icon: Icons.upload_file,
                          title: 'employee_dashboard.actions.upload_files'.tr(),
                          color: Colors.blue,
                          onTap: () => context.push(Routes.digitalArchieve),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _buildActionCard(
                          context,
                          icon: Icons.badge_rounded,
                          title: 'employee_dashboard.actions.career_info'.tr(),
                          color: Colors.teal,
                          onTap: () => context.push(Routes.careerInfo),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 15.h),

                  // ====== كروت الإجراءات السريعة (صف 2) ======
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionCard(
                          context,
                          icon: Icons.school_rounded,
                          title: 'employee_dashboard.actions.courses'.tr(),
                          color: Colors.deepPurple,
                          onTap: () => context.push(
                            Routes.employeeCourses,
                            extra: employee,
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _buildActionCard(
                          context,
                          icon: Icons.work_history_rounded,
                          title: 'employee_dashboard.actions.promotions'.tr(),
                          color: Colors.orange,
                          onTap: () {
                            // TODO: route for promotions
                          },
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 25.h),

                  // ====== أحدث الإعلانات ======
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
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30.sp),
            SizedBox(height: 8.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: color,
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

  // ====== قائمة أحدث 3 إعلانات ======
  Widget _buildAnnouncementsList(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('announcements')
          .where('status', isEqualTo: 'Active')
          .orderBy('createdAt', descending: true)
          .limit(3)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(strokeWidth: 2));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: Text(
                'employee_dashboard.sections.no_announcements'.tr(),
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        final docs = snapshot.data!.docs;
        return Column(
          children: docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final title =
                data['title'] ??
                data['title_ar'] ??
                'employee_dashboard.announcement.no_title'.tr();
            return Card(
              margin: EdgeInsets.only(bottom: 10.h),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 8.h,
                ),
                leading: Icon(
                  Icons.campaign_rounded,
                  color: Theme.of(context).primaryColor,
                ),
                title: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 14.sp,
                  color: Colors.grey,
                ),
                onTap: () {
                  // ممكن تفتح شاشة تفاصيل الإعلان هنا
                },
              ),
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
  Widget build(BuildContext context) {
    return const NotificationsScreen();
  }
}

// ============================================================
// 3. تبويب الإعدادات
// ============================================================
class _SettingsTab extends StatelessWidget {
  final EmployeeModel employee;

  const _SettingsTab({required this.employee});

  @override
  Widget build(BuildContext context) {
    return SettingsScreen(uid: employee.uid ?? '', role: 'employee');
  }
}