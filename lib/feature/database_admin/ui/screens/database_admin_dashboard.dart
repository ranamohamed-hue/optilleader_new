import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:optialeader/core/routing/routes.dart';
import 'package:optialeader/feature/database_admin/data/models/database_admin_model.dart';
import 'package:optialeader/feature/database_admin/logic/database_admin_data/database_admin_state.dart';
import 'package:optialeader/feature/database_admin/logic/database_admin_data/databse_admin_cubit.dart';
import 'package:optialeader/core/theming/app_color.dart';
import 'package:optialeader/feature/database_admin/routing/database_admin_routes.dart';
import 'package:optialeader/feature/notification/logic/app_notification_cubit.dart';
import 'package:optialeader/feature/notification/ui/notification_page.dart';
import 'package:optialeader/feature/setting/ui/setting.dart';

class DatabaseAdminDashboard extends StatefulWidget {
  const DatabaseAdminDashboard({super.key});

  @override
  State<DatabaseAdminDashboard> createState() => _DatabaseAdminDashboardState();
}

class _DatabaseAdminDashboardState extends State<DatabaseAdminDashboard> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        context.read<DatabseAdminCubit>().getProfile(uid);
        context.read<NotificationCubit>().fetchNotifications();
      }
      _checkAndShowWelcomeDialog();
    });
  }

  void _checkAndShowWelcomeDialog() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final creationTime = user.metadata.creationTime;
    final lastSignInTime = user.metadata.lastSignInTime;

    if (creationTime != null && lastSignInTime != null) {
      final difference = lastSignInTime.difference(creationTime).inMinutes;
      if (difference < 2) {
        _showWelcomeDialog();
      }
    }
  }

  // ✅ [تعديل] استخدام الترجمة بدل النصوص الثابتة
  void _showWelcomeDialog() {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Row(
          children: [
            Icon(
              Icons.waving_hand_rounded,
              color: AppColors.darkGold,
              size: 28.sp,
            ),
            SizedBox(width: 10.w),
            Text(
              "dashboard.welcome_title".tr(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          "dashboard.welcome_message".tr(),
          style: TextStyle(fontSize: 15.sp, height: 1.5),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                "dashboard.lets_start".tr(),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    final tabs = [
    const _HomeTab(),
    const _NotificationsTab(),
    _SettingsTab(
      onBack: () {
        setState(() {
          _currentIndex = 0;
        });
      },
    ),
  ];
    print("DatabaseAdminDashboard build");
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: tabs),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: 'dashboard.home'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.notifications_none_outlined),
            activeIcon: const Icon(Icons.notifications),
            label: 'dashboard.notifications'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings_outlined),
            activeIcon: const Icon(Icons.settings),
            label: 'dashboard.settings'.tr(),
          ),
        ],
      ),
    );
  }
}

// تبويب الرئيسية
class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return BlocBuilder<DatabseAdminCubit, DatabaseAdminState>(
      builder: (context, state) {
        if (state is DatabaseAdminLoading) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: colorScheme.secondary),
            ),
          );
        }

        if (state is DatabaseAdminError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: colorScheme.error,
                      size: 60.sp,
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      "${"dashboard.error".tr()}: ${state.message}",
                      textAlign: TextAlign.center,
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (state is DatabaseAdminSuccess) {
          // ✅ تعريف المتغير بالنوع الصريح
          final DatabaseAdminProfileModel adminModel = state.profile;
          final isArabic = context.locale.languageCode == 'ar';

          // ✅ جلب الاسم من الموديل
          String displayName = isArabic ? adminModel.nameAr : adminModel.nameEn;

          if (displayName.trim().isEmpty) {
            displayName = isArabic ? 'أدمن قاعدة البيانات' : 'Database Admin';
          }

          return Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  /// --- الهيدر العلوي ---
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 25.w,
                      vertical: 20.h,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.navyDark, AppColors.navyLight],
                      ),
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
                                displayName,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.sp,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              SizedBox(height: 6),
                              Text(
                                isArabic
                                    ? 'أدمن قاعدة بيانات'
                                    : 'Database Admin',
                                style: TextStyle(
                                  color: AppColors.darkGold,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.darkGold,
                              width: 2,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 30.r,
                            backgroundColor: AppColors.navyLight,
                            child: ClipOval(
                              child: adminModel.profileImage.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: adminModel.profileImage,
                                      width: 70.r,
                                      height: 70.r,
                                      fit: BoxFit.cover,
                                      placeholder: (_, _) =>
                                          const CircularProgressIndicator(
                                            color: AppColors.darkGold,
                                          ),
                                      errorWidget: (_, _, _) => Icon(
                                        Icons.person,
                                        color: Colors.white.withOpacity(0.7),
                                      ),
                                    )
                                  : Icon(
                                      Icons.person,
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// --- باقي محتوى الصفحة ---
                  Expanded(
                    child: RefreshIndicator(
                      color: colorScheme.secondary,
                      onRefresh: () async => await context
                          .read<DatabseAdminCubit>()
                          .getProfile(adminModel.uid),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 20.h,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "dashboard.system_overview".tr(),
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 15.h),
                            Row(
                              children: [
                                _buildStatCard(
                                  context,
                                  "dashboard.doctors".tr(),
                                  state.doctorsCount.toString(),
                                  Icons.school,
                                  Colors.blue,
                                  'doctor',
                                ),
                                SizedBox(width:50),
                                _buildStatCard(
                                  context,
                                  "dashboard.judges".tr(),
                                  state.judgesCount.toString(),
                                  Icons.gavel,
                                  colorScheme.secondary,
                                  'judge',
                                ),
                               
                              ],
                            ),
                            SizedBox(height: 10.h),
                            // ✅ كارت عداد الموظفين
                            Row(
                              children: [
                                _buildStatCard(
                                  context,
                                  "dashboard.admins".tr(),
                                  state.adminsCount.toString(),
                                  Icons.admin_panel_settings,
                                  Colors.green,
                                  'admin',
                                ),
                                SizedBox(width: 50,),
                                _buildStatCard(
                                  context,
                                  "dashboard.employees".tr(),
                                  state.employeesCount.toString(),
                                  Icons.admin_panel_settings,
                                  Colors.green,
                                  'admin_manager',
                                ),
                              ],
                            ),

                            SizedBox(height: 20.h),
                            Text(
                              "dashboard.manage_data".tr(),
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 15.h),
                            _buildActionCard(
                              context,
                              "dashboard.search".tr(),
                              Icons.person_search,
                              Colors.teal,
                              Routes.searchPage,
                            ),
                            _buildActionCard(
                              context,
                              "dashboard.add_doctor".tr(),
                              Icons.person_add_alt_1,
                              colorScheme.primary,
                              Routes.addDoctorPage,
                            ),
                            _buildActionCard(
                              context,
                              "dashboard.add_admin".tr(),
                              Icons.manage_accounts,
                              colorScheme.primaryContainer,
                              Routes.addAdminPage,
                            ),
                            _buildActionCard(
                              context,
                              "dashboard.add_judge".tr(),
                              Icons.verified_user,
                              const Color(0xFF1A1A3F),
                              Routes.addJudgePage,
                            ),
                            _buildActionCard(
                              context,
                              "dashboard.add_employee".tr(),
                              Icons.badge,
                              Colors.orange,
                              Routes.addEmployeePage, 
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          body: Center(
            child: CircularProgressIndicator(color: colorScheme.secondary),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color iconColor,
    String role,
  ) {
    final theme = Theme.of(context);
    return Expanded(
      child: GestureDetector(
        onTap: () => context.push(Routes.usersListPage, extra: role),
        child: Card(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 15.h),
            child: Column(
              children: [
                Icon(icon, color: iconColor, size: 24.sp),
                SizedBox(height: 5.h),
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color bgColor,
    String route,
  ) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => context.push(route),
      child: Container(
        margin: EdgeInsets.only(bottom: 15.h),
        padding: EdgeInsets.all(18.w),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(15.r),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.secondary, size: 26.sp),
            SizedBox(width: 15.w),
            Text(
              title,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              color: theme.colorScheme.secondary,
              size: 14.sp,
            ),
          ],
        ),
      ),
    );
  }
} // تبويب التنبيهات

class _NotificationsTab extends StatelessWidget {
  const _NotificationsTab();
  @override
  Widget build(BuildContext context) {
    final state = context.watch<DatabseAdminCubit>().state;
    if (state is DatabaseAdminSuccess) return const NotificationsScreen();
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

// تبويب الإعدادات
class _SettingsTab extends StatelessWidget {
  final VoidCallback onBack;

  const _SettingsTab({
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<DatabseAdminCubit>().state;

    if (state is DatabaseAdminSuccess) {
      return SettingsScreen(
        uid: state.profile.uid,
        role: 'database_admin',
        onBack: onBack,
      );
    }

    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}