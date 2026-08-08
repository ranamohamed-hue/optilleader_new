import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:optialeader/core/routing/routes.dart';
import 'package:optialeader/feature/database_admin/data/models/doctor_profile_model.dart';
import 'package:optialeader/feature/database_admin/logic/doctor_data/doctor_data_cubit.dart';
import 'package:optialeader/feature/database_admin/logic/doctor_data/doctor_data_state.dart';
import 'package:optialeader/feature/admin/logic/announcement_logic/announcement_cubit.dart';
import 'package:optialeader/feature/admin/logic/announcement_logic/announcement_state.dart';

class DashboardUserPage extends StatefulWidget {
  const DashboardUserPage({super.key});

  @override
  State<DashboardUserPage> createState() => _DashboardUserPageState();
}

class _DashboardUserPageState extends State<DashboardUserPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        context.read<DoctorDataCubit>().getDoctorProfile(uid);
        // ✅ جلب الإعلانات عشان تظهر في الداشبورد مع شارة النتائج
        context.read<AnnouncementCubit>().fetchAnnouncements();
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Row(
          children: [
            Icon(Icons.waving_hand_rounded, color: Colors.orange, size: 28.sp),
            SizedBox(width: 10.w),
            Text(
              'dashboard_user.welcome'.tr(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'dashboard_user.message'.tr(),
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
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'dashboard_user.lets_start'.tr(),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _calculateCareerProgress(DoctorProfileModel? doctor) {
    if (doctor == null) return 0.0;
    final int total = doctor.totalAchievements;
    final int approved = doctor.totalApprovedAchievements;
    if (total == 0) return 0.0;
    return approved / total;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryNavy = theme.colorScheme.primary;
    final goldAccent = theme.colorScheme.secondary;
    final scaffoldBg = theme.scaffoldBackgroundColor;

    return BlocBuilder<DoctorDataCubit, DoctorDataState>(
      builder: (context, state) {
        if (state is DoctorInitial || state is DoctorLoading) {
          return Scaffold(
            backgroundColor: scaffoldBg,
            body: Center(child: CircularProgressIndicator(color: goldAccent)),
          );
        }

        if (state is DoctorLoaded) {
          final doctor = state.doctor;
          final String uid =
              doctor?.uid ?? FirebaseAuth.instance.currentUser?.uid ?? '';
          final String role = doctor?.role ?? 'doctor';

          return Scaffold(
            backgroundColor: scaffoldBg,
            appBar: AppBar(
              backgroundColor: primaryNavy,
              elevation: 0,
              toolbarHeight: 80.h,
              centerTitle: false,
              titleSpacing: 20,
              automaticallyImplyLeading: false,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  
                  Text(
                    context.locale.languageCode == 'ar'
                        ? (doctor?.nameAr ??
                              'dashboard_user.doctor_default'.tr())
                        : (doctor?.nameEn ??
                              'dashboard_user.doctor_default'.tr()),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                    ),


                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6,),
 Text(
                    context.locale.languageCode == 'ar'
                        ? (doctor?.currentJobAr??
                              'dashboard_user.doctor_default'.tr())
                        : (doctor?.currentJobEn ??
                              'dashboard_user.doctor_default'.tr()),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                    ),


                    overflow: TextOverflow.ellipsis,
                  ),

                ],
              ),
              actions: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: _buildProfileAvatar(goldAccent, doctor?.profileImage),
                ),
              ],
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(3.h),
                child: Container(color: goldAccent, height: 3.h),
              ),
            ),
            body: RefreshIndicator(
              onRefresh: () async {
                if (uid.isNotEmpty) {
                  await context.read<DoctorDataCubit>().getDoctorProfile(uid);
                }
              },
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 12.w,
                      mainAxisSpacing: 12.h,
                      childAspectRatio: 1.15,
                      children: [
                        _buildStatCard(
                          'dashboard_user.achievements'.tr(),
                          Icons.emoji_events_outlined,
                          goldAccent,
                          'dashboard_user.achievements_msg'.tr(
                            args: ['${doctor?.totalAchievements ?? 0}'],
                          ),
                          primaryNavy,
                          onTap: () => context.push(
                            '${Routes.archievementPage}?uid=$uid',
                          ),
                        ),
                        _buildStatCard(
                          'dashboard_user.academic_data'.tr(),
                          Icons.school_outlined,
                          goldAccent,
                          (doctor?.academicHistory != null &&
                                  doctor!.academicHistory.isNotEmpty)
                              ? (doctor.academicHistory.first['degree'] ??
                                    'dashboard_user.no_credentials'.tr())
                              : 'dashboard_user.no_credentials'.tr(),
                          primaryNavy,
                          onTap: () =>
                              context.push('${Routes.acadiminData}?uid=$uid'),
                        ),
                                                                     _buildStatusCard(
                          'dashboard_user.requests_status'.tr(),
                          '${doctor?.totalPendingAchievements ?? 0}',
                          'dashboard_user.pending'.tr(),
                          Colors.red.shade50,
                          Colors.red.shade900,
                          onTap: () {
                            if (doctor != null) {
                              // ✅ استخدام الثابت اللي عرفناه في Routes
                              context.push(Routes.doctorRequestsStatus, extra: doctor);
                            }
                          },
                        ),
                        _buildProgressCard(
                          'dashboard_user.career_path'.tr(),
                          _calculateCareerProgress(doctor),
                          primaryNavy,
                          goldAccent,
                          onTap: () =>
                              context.push('${Routes.careerInfo}?uid=$uid'),
                        ),
                      ],
                    ),
                    SizedBox(height: 25.h),
                    _buildSectionTitle(
                      primaryNavy,
                      goldAccent,
                      'dashboard_user.latest_opportunities'.tr(),
                    ),
                    SizedBox(height: 10.h),

                    // ✅ إظهار الإعلانات مع شارة النتائج
                    BlocBuilder<AnnouncementCubit, AnnouncementState>(
                      builder: (context, announceState) {
                        if (announceState is AnnouncementLoaded) {
                          if (announceState.announcements.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 20.h),
                                child: Text(
                                  'dashboard_user.no_opportunities'.tr(),
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 13.sp,
                                  ),
                                ),
                              ),
                            );
                          }

                          final displayAnnouncements = announceState
                              .announcements
                              .take(3)
                              .toList();

                          return Column(
                            children: displayAnnouncements.map((ann) {
                              final bool hasResults =
                                  ann.isResultAnnounced == true;

                              return Padding(
                                padding: EdgeInsets.only(bottom: 10.h),
                                child: _buildOpportunityItem(
                                  title: ann.title.isNotEmpty
                                      ? ann.title
                                      : 'إعلان جديد',
                                  subtitle: ann.description.isNotEmpty
                                      ? ann.description
                                      : '',
                                  icon: hasResults
                                      ? Icons.emoji_events_outlined
                                      : Icons.campaign_outlined,
                                  iconBg: hasResults
                                      ? Colors.amber.shade50
                                      : primaryNavy.withOpacity(0.05),
                                  navy: primaryNavy,
                                  gold: goldAccent,
                                  showResultsBadge: hasResults,
                                  onTap: () {
                                    if (hasResults) {
                                      // ✅ التوجيه الصحيح لصفحة النتائج
                                      context.push(
                                        Routes.competitionResultsView,
                                        extra: {
                                          'announcementId': ann.id,
                                          'currentDoctorId': uid,
                                        },
                                      );
                                    } else {
                                      context.push(
                                        '${Routes.announcementsDetailsDoctor}?id=${ann.id}',
                                      );
                                    }
                                  },
                                ),
                              );
                            }).toList(),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),

                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: _buildBottomNav(
              primaryNavy,
              goldAccent,
              uid,
              role,
            ),
          );
        }

        if (state is DoctorError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 48.sp),
                  SizedBox(height: 16.h),
                  Text(
                    state.error ?? 'dashboard_user.error_message'.tr(),
                    style: TextStyle(color: Colors.red, fontSize: 14.sp),
                  ),
                  SizedBox(height: 20.h),
                  ElevatedButton(
                    onPressed: () {
                      final uid = FirebaseAuth.instance.currentUser?.uid;
                      if (uid != null) {
                        context.read<DoctorDataCubit>().getDoctorProfile(uid);
                      }
                    },
                    child: Text('retry'.tr()),
                  ),
                ],
              ),
            ),
          );
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }

  Widget _buildProfileAvatar(Color gold, String? imageUrl) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: gold, width: 2),
      ),
      child: CircleAvatar(
        radius: 35.r,
        backgroundColor: Colors.white10,
        backgroundImage: (imageUrl != null && imageUrl.isNotEmpty)
            ? CachedNetworkImageProvider(imageUrl)
            : null,
        child: (imageUrl == null || imageUrl.isEmpty)
            ? Icon(Icons.person, color: gold, size: 24.sp)
            : null,
      ),
    );
  }

  Widget _buildSectionTitle(Color navy, Color gold, String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 4.w,
              height: 16.h,
              decoration: BoxDecoration(
                color: gold,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: () {},
          child: Text(
            'dashboard_user.view_all'.tr(),
            style: TextStyle(
              color: gold,
              fontWeight: FontWeight.bold,
              fontSize: 11.sp,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    IconData icon,
    Color gold,
    String content,
    Color navy, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15.r),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.r),
          border: Border.all(color: gold.withOpacity(0.3), width: 1.2),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: gold, size: 16.sp),
                SizedBox(width: 5.w),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: navy,
                      fontSize: 11.sp,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              content,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 10.sp,
                height: 1.3,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(
    String title,
    String count,
    String label,
    Color bgColor,
    Color textColor, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15.r),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(15.r),
          border: Border.all(color: textColor.withOpacity(0.3), width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: textColor,
                fontSize: 11.sp,
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      count,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    Text(
                      label,
                      style: TextStyle(color: textColor, fontSize: 9.sp),
                    ),
                  ],
                ),
                Icon(
                  Icons.notifications_active_outlined,
                  color: textColor.withOpacity(0.4),
                  size: 20.sp,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(
    String title,
    double progress,
    Color navy,
    Color gold, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15.r),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.r),
          border: Border.all(color: navy.withOpacity(0.1), width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: navy,
                fontSize: 11.sp,
              ),
            ),
            const Spacer(),
            ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: navy.withOpacity(0.05),
                color: gold,
                minHeight: 5.h,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'dashboard_user.completed_percent'.tr(
                args: ['${(progress * 100).toInt()}%'],
              ),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 10.sp,
                color: navy,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOpportunityItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconBg,
    required Color navy,
    required Color gold,
    bool showResultsBadge = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15.r),
      child: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: showResultsBadge ? Colors.amber.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(15.r),
          border: Border.all(
            color: showResultsBadge
                ? Colors.amber.shade300
                : gold.withOpacity(0.15),
            width: showResultsBadge ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                icon,
                color: showResultsBadge ? Colors.amber.shade700 : navy,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.sp,
                      color: showResultsBadge ? Colors.amber.shade900 : navy,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: showResultsBadge
                          ? Colors.amber.shade700
                          : Colors.grey,
                      fontSize: 10.sp,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

                      if (showResultsBadge) ...[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.amber.shade600,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.emoji_events, size: 12.sp, color: Colors.white),
                    SizedBox(width: 3.w),
                    Text(
                      'dashboard_user.results_badge'.tr(), 
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
            ],

            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 12.sp,
              color: showResultsBadge ? Colors.amber.shade600 : gold,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(Color navy, Color gold, String uid, String role) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: gold,
      unselectedItemColor: Colors.grey.shade400,
      currentIndex: 3,
      backgroundColor: Colors.white,
      elevation: 25,
      selectedFontSize: 10.sp,
      unselectedFontSize: 10.sp,
      onTap: (index) {
        switch (index) {
          case 0:
            context.push(Routes.settings, extra: {'uid': uid, 'role': role});
            break;
          case 1:
            context.push(Routes.notification);
            break;
          case 2:
            context.push('${Routes.digitalArchieve}?uid=$uid');
            break;
          case 3:
            break;
        }
      },
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.settings_outlined),
          label: 'dashboard_user.nav.settings'.tr(),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.notifications_none),
          label: 'dashboard_user.nav.notifications'.tr(),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.folder_open_outlined),
          label: 'dashboard_user.nav.files'.tr(),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.home_filled),
          label: 'dashboard_user.nav.home'.tr(),
        ),
      ],
    );
  }
}
