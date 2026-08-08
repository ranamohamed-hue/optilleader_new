import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:optialeader/feature/database_admin/data/models/admin_profile_model.dart';
import 'package:optialeader/feature/database_admin/logic/admin_data/admin_data_cubit.dart';
import 'package:optialeader/feature/database_admin/logic/admin_data/admin_data_state.dart';
import 'package:optialeader/feature/admin/data/model/nomination_request_model.dart';
import 'package:optialeader/feature/admin/logic/nomination_request_logic/nomination_request_cubit.dart';
import 'package:optialeader/feature/admin/logic/nomination_request_logic/nomonation_request_state.dart';
import 'package:optialeader/feature/notification/logic/app_notification_cubit.dart';
import 'package:optialeader/feature/notification/ui/notification_page.dart';
import 'package:optialeader/feature/setting/ui/setting.dart';
import 'package:optialeader/feature/database_admin/ui/screens/empolyee_search_page.dart';
import 'package:optialeader/feature/admin/ui/announces/announce.dart';
import 'package:optialeader/core/theming/app_color.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  bool _isExpanded = false;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        context.read<AdminDataCubit>().getAdminProfile(uid);
        context.read<NotificationCubit>().updateUserIdAndFetch(uid);
        context.read<NominationRequestCubit>().fetchAdminRequests(
          status: NominationRequestModel.statusPendingAdmin,
        );
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

  void _showWelcomeDialog() {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Row(
          children: [
            Icon(Icons.waving_hand_rounded, color: AppColors.darkGold, size: 28.sp),
            SizedBox(width: 10.w),
            Text('dashboard.welcome_title'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text('dashboard.welcome_body'.tr(), style: TextStyle(fontSize: 15.sp, height: 1.5)),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('dashboard.lets_start'.tr(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _HomeTab(
            currentIndex: _currentIndex,
            isExpanded: _isExpanded,
            onToggleExpanded: () => setState(() => _isExpanded = !_isExpanded),
            onTabTapped: _onTabTapped,
          ),
          _AnnouncementsTab(onBack: () => _onTabTapped(0)),
          const _SearchTab(),
          const _NotificationsTab(),
          _SettingsTab(onBackToHome: () => _onTabTapped(0)),
        ],
      ),
    );
  }
}

/// ============================================================
/// 1. تبويب الصفحة الرئيسية (Home Tab)
/// ============================================================
class _HomeTab extends StatelessWidget {
  final int currentIndex;
  final bool isExpanded;
  final VoidCallback onToggleExpanded;
  final ValueChanged<int> onTabTapped;

  const _HomeTab({
    required this.currentIndex,
    required this.isExpanded,
    required this.onToggleExpanded,
    required this.onTabTapped,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isArabic = context.locale.languageCode == 'ar';

    return BlocBuilder<AdminDataCubit, AdminDataState>(
      builder: (context, state) {
        if (state is AdminLoading) {
          return Center(child: CircularProgressIndicator(color: colorScheme.secondary));
        }

        if (state is AdminLoaded) {
          final admin = state.admin!;
          String fullDisplayName = isArabic ? admin.nameAr : admin.nameEn;
          if (fullDisplayName.trim().isEmpty) {
            fullDisplayName = FirebaseAuth.instance.currentUser?.displayName ?? 'dashboard.admin_role'.tr();
          }

          // ✅ جلب الوظيفة
          String jobTitle = isArabic 
              ? (admin.jopAr ?? '').trim() 
              : (admin.jopEn ?? '').trim();

          return SafeArea(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 20.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [colorScheme.primary, colorScheme.primaryContainer],
                    ),
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(30.r)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ✅ الاسم في الأول (بدون مرحباً)
                            Text(
                              fullDisplayName,
                              style: TextStyle(
                                color: colorScheme.onPrimary, 
                                fontWeight: FontWeight.bold, 
                                fontSize: 22.sp
                              ),
                              overflow: TextOverflow.ellipsis, 
                              maxLines: 1,
                            ),
                            // ✅ الوظيفة تحته لو موجودة
                            if (jobTitle.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  jobTitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: colorScheme.onPrimary.withOpacity(0.85), 
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.darkGold, width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 30.r,
                          backgroundColor: colorScheme.surface,
                          child: ClipOval(
                            child: admin.profileImage.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: admin.profileImage, 
                                    width: 60.r, 
                                    height: 60.r, 
                                    fit: BoxFit.cover,
                                    placeholder: (_, _) => const CircularProgressIndicator(),
                                    errorWidget: (_, _, _) => const Icon(Icons.person),
                                  )
                                : const Icon(Icons.person),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Row(
                    children: isArabic
                        ? [Expanded(child: _buildCardsList(context, state)), _buildSideBar(context)]
                        : [_buildSideBar(context), Expanded(child: _buildCardsList(context, state))],
                  ),
                ),
              ],
            ),
          );
        }

        if (state is AdminError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(state.error, style: TextStyle(color: colorScheme.error)),
                SizedBox(height: 10.h),
                ElevatedButton(
                  onPressed: () {
                    final uid = FirebaseAuth.instance.currentUser?.uid ?? "";
                    context.read<AdminDataCubit>().getAdminProfile(uid);
                  },
                  child: Text('dashboard.retry'.tr()),
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSideBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: isExpanded ? 130.w : 55.w,
      margin: EdgeInsets.only(
        left: context.locale.languageCode == 'ar' ? 6.w : 4.w,
        right: context.locale.languageCode == 'ar' ? 4.w : 6.w,
        top: 15.h,
      ),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [BoxShadow(color: colorScheme.primary.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 3))],
      ),
      child: Column(
        children: [
          SizedBox(height: 10.h),
          IconButton(
            icon: Icon(isExpanded ? Icons.menu_open : Icons.menu, color: AppColors.darkGold, size: 22.sp),
            onPressed: onToggleExpanded,
          ),
          SizedBox(height: 5.h),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildSideBarItem(Icons.home_outlined, Icons.home, 0, 'sidebar.home'.tr(), colorScheme, textTheme),
                _buildSideBarItem(Icons.list_alt_outlined, Icons.list_alt, -1, 'sidebar.orders'.tr(), colorScheme, textTheme, customAction: () => context.push('/admin/orders-list')),
                _buildSideBarItem(Icons.campaign_outlined, Icons.campaign, 1, 'sidebar.announcements'.tr(), colorScheme, textTheme),
                _buildSideBarItem(Icons.search, Icons.search, 2, 'sidebar.search'.tr(), colorScheme, textTheme),
                _buildSideBarItem(Icons.notifications_none_outlined, Icons.notifications, 3, 'sidebar.notifications'.tr(), colorScheme, textTheme),
              ],
            ),
          ),
          _buildSideBarItem(Icons.person_outline, Icons.person, 4, 'sidebar.settings'.tr(), colorScheme, textTheme),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  Widget _buildSideBarItem(IconData icon, IconData activeIcon, int index, String label, ColorScheme colorScheme, TextTheme textTheme, {VoidCallback? customAction}) {
    bool isSelected = customAction == null && currentIndex == index;
    final iconColor = isSelected ? AppColors.darkGold : colorScheme.onPrimary.withOpacity(0.8);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Material(
        color: isSelected ? AppColors.darkGold.withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(12.r),
        child: InkWell(
          onTap: customAction ?? () => onTabTapped(index),
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            height: 40.h,
            padding: EdgeInsets.symmetric(horizontal: isExpanded ? 8.w : 0),
            alignment: Alignment.center,
            child: isExpanded
                ? Row(
                    children: [
                      Icon(isSelected ? activeIcon : icon, color: iconColor, size: 20.sp),
                      SizedBox(width: 8.w),
                      Expanded(child: Text(label, style: textTheme.bodySmall?.copyWith(color: iconColor, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal), overflow: TextOverflow.ellipsis)),
                    ],
                  )
                : Icon(isSelected ? activeIcon : icon, color: iconColor, size: 22.sp),
          ),
        ),
      ),
    );
  }

  Widget _buildCardsList(BuildContext context, AdminLoaded state) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocBuilder<NominationRequestCubit, NominationRequestState>(
      builder: (context, reqState) {
        int newRequestsCount = 0;
        int underReviewCount = 0;

        if (reqState is NominationRequestLoaded) {
          newRequestsCount = reqState.requests
              .where((r) => r.status == NominationRequestModel.statusPendingAdmin)
              .length;
          underReviewCount = reqState.requests
              .where((r) =>
                  r.status == NominationRequestModel.statusPendingEvaluator ||
                  r.status == NominationRequestModel.statusEvaluated)
              .length;
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(left: 15.w, right: 15.w, top: 0, bottom: 10.h),
          child: Column(
            children: [
              _buildActionCard(
                context,
                title: 'dashboard.new_requests'.tr(),
                icon: Icons.note_add_rounded,
                value: newRequestsCount.toString(),
                color: colorScheme.primary,
                onTap: () => context.push('/admin/orders-list'),
              ),
              SizedBox(height: 18.h),
              _buildActionCard(
                context,
                title: 'dashboard.under_review'.tr(),
                icon: Icons.gavel_rounded,
                value: underReviewCount.toString(),
                color: AppColors.darkGold,
                onTap: () => context.push('/admin/orders-list'),
              ),
              SizedBox(height: 18.h),
              _buildActionCard(
                context,
                title: 'dashboard.add_announcement'.tr(),
                icon: Icons.campaign_rounded,
                value: '+',
                color: Colors.orange,
                onTap: () => context.push('/admin/edit-announcement'),
              ),
              SizedBox(height: 18.h),
              _buildActionCard(
                context,
                title: 'dashboard.pending_approvals'.tr(),
                icon: Icons.pending_actions_rounded,
                value: state.newRequestsCount.toString(),
                color: Colors.teal,
                onTap: () => context.push('/admin/pending-requests'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionCard(BuildContext context, {required String title, required IconData icon, required String value, required Color color, VoidCallback? onTap}) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24.r),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(minHeight: 110.h),
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: color.withOpacity(0.25), width: 1.5),
          boxShadow: [BoxShadow(color: color.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              width: 52.w, height: 52.w,
              decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 26.sp),
            ),
            SizedBox(width: 18.w),
            Expanded(child: Text(title, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 16.sp))),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(14.r)),
              child: Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: color, fontSize: 20.sp)),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnnouncementsTab extends StatelessWidget {
  final VoidCallback onBack;
  const _AnnouncementsTab({required this.onBack});
  @override
  Widget build(BuildContext context) => AnnouncementsPage(onBack: onBack);
}

class _SearchTab extends StatelessWidget {
  const _SearchTab();
  @override
  Widget build(BuildContext context) => const UserSearchScreen();
}

class _NotificationsTab extends StatelessWidget {
  const _NotificationsTab();
  @override
  Widget build(BuildContext context) => const NotificationsScreen();
}

class _SettingsTab extends StatelessWidget {
  final VoidCallback onBackToHome;
  const _SettingsTab({required this.onBackToHome});
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AdminDataCubit>().state;
    if (state is AdminLoaded) {
      return SettingsScreen(uid: state.admin!.uid, role: 'admin', onBack: onBackToHome);
    }
    return const Center(child: CircularProgressIndicator());
  }
}