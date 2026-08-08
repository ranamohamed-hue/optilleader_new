import 'dart:ui' as ui;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:optialeader/core/routing/routes.dart';
import 'package:optialeader/feature/admin/data/model/nomination_request_model.dart';
import 'package:optialeader/feature/admin/logic/nomination_request_logic/nomination_request_cubit.dart';
import 'package:optialeader/feature/admin/logic/nomination_request_logic/nomonation_request_state.dart';
import 'package:optialeader/feature/database_admin/logic/judge_data/judge_data_cubit.dart';
import 'package:optialeader/feature/database_admin/logic/judge_data/judge_data_state.dart';
import 'package:optialeader/feature/notification/logic/app_notification_cubit.dart';

class MohakemDashboardHome extends StatefulWidget {
  const MohakemDashboardHome({super.key});

  @override
  State<MohakemDashboardHome> createState() => _MohakemDashboardHomeState();
}

class _MohakemDashboardHomeState extends State<MohakemDashboardHome> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  void _loadInitialData() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      context.read<JudgeDataCubit>().getJudgeProfile(uid);
      context.read<NotificationCubit>().fetchNotifications();
      context.read<NominationRequestCubit>().fetchEvaluatorRequests(uid);
    }
    _checkAndShowWelcomeDialog();
  }

  void _refreshRequests() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null && mounted) {
      context.read<NominationRequestCubit>().fetchEvaluatorRequests(uid);
    }
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
              'dashboardJudge.welcome_title'.tr(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'dashboardJudge.welcome_body'.tr(),
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
                'dashboardJudge.lets_start'.tr(),
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
    final theme = Theme.of(context);
    final colorPrimary = theme.colorScheme.primary;
    final colorGold = theme.colorScheme.secondary;

    return BlocBuilder<JudgeDataCubit, JudgeDataState>(
      builder: (context, state) {
        if (state is JudgeInitial || state is JudgeLoading) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator(color: colorGold)),
          );
        }

        if (state is JudgeError) {
          return Scaffold(body: Center(child: Text(state.error ?? "Error")));
        }

        if (state is JudgeLoaded) {
          final judge = state.judge!;
          final isArabic = context.locale.languageCode == 'ar';
          final displayName = isArabic
              ? (judge.nameAr.isNotEmpty
                    ? judge.nameAr
                    : "dashboardJudge.default_name".tr())
              : (judge.nameEn.isNotEmpty
                    ? judge.nameEn
                    : "dashboardJudge.default_name".tr());

          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: Column(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colorPrimary,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(30.r),
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 10.h,
                      ),
                      child: _buildHeaderRow(
                        context,
                        colorGold,
                        displayName,
                        judge.profileImage,
                        judge.jopAr, // ✅ تمرير الوظيفة
                      ),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 3.0,
                  color: colorGold,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 25.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'dashboardJudge.system_overview'.tr(),
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 20.h),

                        BlocBuilder<NominationRequestCubit, NominationRequestState>(
                          builder: (context, reqState) {
                            int newCount = 0;
                            int reviewingCount = 0;
                            int completedCount = 0;

                            if (reqState is NominationRequestLoaded) {
                              newCount = reqState.requests
                                  .where((r) => r.status == NominationRequestModel.statusPendingEvaluator)
                                  .length;
                              reviewingCount = reqState.requests
                                  .where((r) => r.status == NominationRequestModel.statusEvaluated)
                                  .length;
                              completedCount = reqState.requests
                                  .where((r) => r.status == NominationRequestModel.statusFinalApproved)
                                  .length;
                            }

                            return Column(
                              children: [
                                _buildMainStatCard(
                                  context,
                                  'dashboard.main_cards.new'.tr(),
                                  newCount.toString(),
                                  Icons.inbox,
                                  Colors.blue,
                                  NominationRequestModel.statusPendingEvaluator,
                                ),
                                SizedBox(height: 15.h),
                                _buildMainStatCard(
                                  context,
                                  'dashboard.main_cards.reviewing'.tr(),
                                  reviewingCount.toString(),
                                  Icons.hourglass_empty,
                                  Colors.orange,
                                  NominationRequestModel.statusEvaluated,
                                ),
                                SizedBox(height: 15.h),
                                _buildMainStatCard(
                                  context,
                                  'dashboard.main_cards.evaluated'.tr(),
                                  completedCount.toString(),
                                  Icons.check_circle,
                                  Colors.green,
                                  NominationRequestModel.statusFinalApproved,
                                ),
                              ],
                            );
                          },
                        ),

                        SizedBox(height: 30.h),

                        BlocBuilder<NominationRequestCubit, NominationRequestState>(
                          builder: (context, reqState) {
                            if (reqState is NominationRequestLoaded &&
                                reqState.requests.isNotEmpty) {
                              return _buildRecentRequestsSection(
                                context,
                                reqState.requests,
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
              ],
            ),
            bottomNavigationBar: _buildBottomNav(
              colorPrimary,
              colorGold,
              judge.uid,
              judge.role,
            ),
          );
        }
        return const Scaffold(body: SizedBox.shrink());
      },
    );
  }

  Widget _buildRecentRequestsSection(
    BuildContext context,
    List<NominationRequestModel> allRequests,
  ) {
    final theme = Theme.of(context);
    final gold = theme.colorScheme.secondary;
    final navy = theme.primaryColor;

    List<NominationRequestModel> recentList = List.from(allRequests);
    
    // ✅ إزالة الطلبات اللي تم تحديد موعد مقابلة لها من القائمة
    recentList.removeWhere((request) => request.interviewDate != null);
    
    recentList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    recentList = recentList.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle(gold, navy, 'dashboardJudge.recent_requests_title'.tr()),
            TextButton(
              onPressed: () async {
                await context.push('/judge/orders-list', extra: {});
                _refreshRequests();
              },
              child: Text(
                'dashboardJudge.view_all'.tr(),
                style: TextStyle(color: gold, fontSize: 12.sp),
              ),
            ),
          ],
        ),
        SizedBox(height: 15.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18.r),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10),
            ],
          ),
          child: Column(
            children: List.generate(recentList.length, (index) {
              final request = recentList[index];
              return InkWell(
                onTap: () async {
                  await context.push('/judge/evaluationScreen', extra: request);
                  _refreshRequests();
                },
                borderRadius: index == recentList.length - 1
                    ? BorderRadius.vertical(bottom: Radius.circular(18.r))
                    : BorderRadius.zero,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 15.w,
                    vertical: 12.h,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22.r,
                        backgroundColor: navy.withOpacity(0.05),
                        child: ClipOval(
                          child:
                              request.doctorImageUrl != null &&
                                  request.doctorImageUrl!.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: request.doctorImageUrl!,
                                  width: 44.r,
                                  height: 44.r,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => Icon(
                                    Icons.person_outline,
                                    color: navy,
                                    size: 22.sp,
                                  ),
                                  errorWidget: (_, __, ___) => Icon(
                                    Icons.person_outline,
                                    color: navy,
                                    size: 22.sp,
                                  ),
                                )
                              : Icon(
                                  Icons.person_outline,
                                  color: navy,
                                  size: 22.sp,
                                ),
                        ),
                      ),
                      SizedBox(width: 15.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              request.doctorName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13.sp,
                                color: navy,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              "dashboardJudge.nomination_for_role".tr(
                                namedArgs: {'role': request.targetRole.tr()},
                              ),
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: gold.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          Icons.chevron_right,
                          color: gold,
                          size: 18.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildMainStatCard(
    BuildContext context,
    String title,
    String count,
    IconData icon,
    Color color,
    String filterStatus,
  ) {
    return InkWell(
      onTap: () async {
        await context.push(
          '/judge/categories-screen',
          extra: {'status': filterStatus},
        );
        _refreshRequests();
      },
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
          ],
          border: Border.all(color: color.withOpacity(0.2), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15.r),
              ),
              child: Icon(icon, color: color, size: 28.sp),
            ),
            SizedBox(width: 20.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    "$count ${'dashboard.main_cards.request'.tr()}",
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 20.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderRow(
    BuildContext context,
    Color gold,
    String name,
    String? imageUrl,
    String? jobTitle, 
  ) {
    final isArabic = context.locale.languageCode == 'ar';
    return Row(
      textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // ✅ تغيير المحاذاة لليسار
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp, // ✅ تكبير الخط
                  fontWeight: FontWeight.bold,
                ),
              ),
              // ✅ عرض الوظيفة لو موجودة
              if (jobTitle != null && jobTitle!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    jobTitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 13.sp,
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(width: 15.w),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: gold, width: 3.w),
          ),
          child: CircleAvatar(
            radius: 28.r,
            backgroundColor: Colors.white.withOpacity(0.15),
            child: ClipOval(
              child: (imageUrl != null && imageUrl.isNotEmpty)
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: 56.r,
                      height: 56.r,
                      fit: BoxFit.cover,
                      placeholder: (_, _) =>
                          Icon(Icons.person, color: gold, size: 30.sp),
                      errorWidget: (_, _, _) =>
                          Icon(Icons.person, color: gold, size: 30.sp),
                    )
                  : Icon(Icons.person, color: gold, size: 30.sp),
            ),
          ),
        ),
      ],
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
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav(Color navy, Color gold, String uid, String role) {
    return BottomNavigationBar(
      selectedItemColor: gold,
      unselectedItemColor: navy.withOpacity(0.4),
      type: BottomNavigationBarType.fixed,
      currentIndex: 0,
      onTap: (index) async {
        switch (index) {
          case 0:
            break;
          case 1:
            await context.push(Routes.notification);
            _refreshRequests();
            break;
          case 2:
            await context.push('/judge/orders-list');
            _refreshRequests();
            break;
          case 3:
            await context.push(
              Routes.settings,
              extra: {'uid': uid, 'role': role},
            );
            break;
        }
      },
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.grid_view_rounded),
          label: 'dashboardJudge.tooltips.home'.tr(),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.notifications_active_outlined),
          label: 'dashboardJudge.notifications'.tr(),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.assignment_outlined),
          label: 'orders.title'.tr(),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.settings_outlined),
          label: 'dashboardJudge.tooltips.settings'.tr(),
        ),
      ],
    );
  }
}