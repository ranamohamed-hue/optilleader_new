import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';

import 'package:optialeader/core/routing/routes.dart';
import 'package:optialeader/feature/admin/data/model/announcement_model.dart';
import 'package:optialeader/feature/employee/data/models/employee_nomination_request_model.dart';
import 'package:optialeader/feature/employee/logic/EmployeenNominationCubit/employee_nomination_cubit.dart';
import 'package:optialeader/feature/employee/logic/EmployeenNominationCubit/employee_nomination_state.dart';

class EmployeeRequestsCategoriesScreen extends StatefulWidget {
  final String? filterStatus;

  const EmployeeRequestsCategoriesScreen({
    super.key,
    required this.filterStatus,
  });

  @override
  State<EmployeeRequestsCategoriesScreen> createState() =>
      _EmployeeRequestsCategoriesScreenState();
}

class _EmployeeRequestsCategoriesScreenState
    extends State<EmployeeRequestsCategoriesScreen> {
  // الموظفين عندهم وظيفة واحدة فقط
  static const String _employeeRoleKey = 'admin_manager';

  String? _selectedAnnouncementId;

  // announcementId -> AnnouncementModel
  Map<String, AnnouncementModel> _announcementsData = {};

  bool get _isEvaluationPhase =>
      widget.filterStatus ==
      EmployeeNominationRequestModel.statusPendingEvaluator;

  @override
  void initState() {
    super.initState();

    _fetchAnnouncementsTitles();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

      if (uid.isNotEmpty) {
        context
            .read<EmployeeNominationCubit>()
            .fetchEvaluatorRequests(uid);
      }
    });
  }

  // ============================================================
  // جلب الإعلانات النشطة
  // ============================================================

  Future<void> _fetchAnnouncementsTitles() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('announcements')
          .where('status', isEqualTo: 'Active')
          .get();

      if (!mounted) return;

      final Map<String, AnnouncementModel> data = {};

      for (final doc in snapshot.docs) {
        data[doc.id] = AnnouncementModel.fromMap(
          doc.data(),
          doc.id,
        );
      }

      setState(() {
        _announcementsData = data;
      });
    } catch (e) {
      debugPrint(
        '⚠️ خطأ في جلب إعلانات الموظفين: $e',
      );
    }
  }

  // ============================================================
  // إعادة تحميل الطلبات
  // ============================================================

  void _retry() {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    if (uid.isNotEmpty) {
      context
          .read<EmployeeNominationCubit>()
          .fetchEvaluatorRequests(uid);
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final navy = colorScheme.primary;
    final gold = colorScheme.secondary;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor: navy,
        foregroundColor: colorScheme.onPrimary,
        centerTitle: true,

        title: Text(
          _getAppBarTitle(),
          style: TextStyle(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),

        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: colorScheme.onPrimary,
            size: 20.sp,
          ),
          onPressed: () {
            // المستوى الثالث -> المستوى الثاني
            if (_selectedAnnouncementId != null) {
              setState(() {
                _selectedAnnouncementId = null;
              });
            } else {
              // المستوى الثاني -> المستوى الأول
              context.pop();
            }
          },
        ),

        bottom: PreferredSize(
          preferredSize: Size.fromHeight(2.h),
          child: Container(
            color: gold,
            height: 2.h,
          ),
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: BlocBuilder<
          EmployeeNominationCubit,
          EmployeeNominationState>(
        builder: (context, state) {
          // ====================================================
          // Loading
          // ====================================================

          if (state is EmployeeNominationLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: gold,
              ),
            );
          }

          // ====================================================
          // Error
          // ====================================================

          if (state is EmployeeNominationError) {
            return _buildErrorState(
              context: context,
              navy: navy,
              colorScheme: colorScheme,
            );
          }

          // ====================================================
          // الطلبات
          // ====================================================

          List<EmployeeNominationRequestModel> baseRequests = [];

          if (state is EmployeeNominationLoaded) {
            baseRequests = state.requests
                .where(
                  (request) =>
                      request.applicantType == 'employee' &&
                      request.status == widget.filterStatus &&
                      request.targetRole == _employeeRoleKey,
                )
                .toList();
          }

          // ====================================================
          // المستوى الثالث
          // الموظفين داخل إعلان معين
          // ====================================================

          if (_selectedAnnouncementId != null) {
            final announcement =
                _announcementsData[_selectedAnnouncementId];

            final applicants = baseRequests
                .where(
                  (request) =>
                      request.announcementId ==
                      _selectedAnnouncementId,
                )
                .toList();

            return Column(
              children: [
                _buildAnnouncementSummaryCard(
                  announcement: announcement,
                  fallbackTitle: applicants.isNotEmpty
                      ? applicants.first.announcementTitle
                      : '',
                  applicantsCount: applicants.length,
                  navy: navy,
                  gold: gold,
                  isDark: isDark,
                ),

                if (applicants.isEmpty)
                  Expanded(
                    child: _buildEmptyState(
                      context,
                      icon: Icons.inbox_outlined,
                      colorScheme: colorScheme,
                    ),
                  )
                else
                  Expanded(
                    child: Container(
                      color: navy.withOpacity(
                        isDark ? 0.03 : 0.02,
                      ),
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 15.h,
                        ),
                        itemCount: applicants.length,
                        itemBuilder: (context, index) {
                          return _buildEmployeeRequestCard(
                            context: context,
                            request: applicants[index],
                            navy: navy,
                            gold: gold,
                            isDark: isDark,
                          );
                        },
                      ),
                    ),
                  ),
              ],
            );
          }

          // ====================================================
          // المستوى الثاني
          // الإعلانات الخاصة بالموظفين
          // ====================================================

          final Map<
                  String,
                  List<EmployeeNominationRequestModel>>
              grouped = {};

          for (final request in baseRequests) {
            grouped
                .putIfAbsent(
                  request.announcementId,
                  () => [],
                )
                .add(request);
          }

          if (grouped.isEmpty) {
            return _buildEmptyState(
              context,
              icon: Icons.campaign_outlined,
              colorScheme: colorScheme,
            );
          }

          return ListView.builder(
            padding: EdgeInsets.symmetric(
              horizontal: 20.w,
              vertical: 20.h,
            ),
            itemCount: grouped.length,
            itemBuilder: (context, index) {
              final announcementId =
                  grouped.keys.elementAt(index);

              final announcementRequests =
                  grouped[announcementId]!;

              final firstRequest =
                  announcementRequests.first;

              final announcement =
                  _announcementsData[announcementId];

              return _buildAnnouncementCard(
                context: context,
                announcementId: announcementId,
                announcement: announcement,
                fallbackTitle:
                    firstRequest.announcementTitle,
                applicantsCount:
                    announcementRequests.length,
                navy: navy,
                gold: gold,
                isDark: isDark,
              );
            },
          );
        },
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildErrorState({
    required BuildContext context,
    required Color navy,
    required ColorScheme colorScheme,
  }) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(25.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off,
              size: 50.sp,
              color: colorScheme.outline,
            ),

            SizedBox(height: 15.h),

            Text(
              'employee_categories.error_message'.tr(),
              style: TextStyle(
                fontSize: 15.sp,
                color: colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 20.h),

            ElevatedButton(
              onPressed: _retry,
              style: ElevatedButton.styleFrom(
                backgroundColor: navy,
                foregroundColor: colorScheme.onPrimary,
              ),
              child: Text(
                'employee_categories.retry'.tr(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmptyState(
    BuildContext context, {
    required IconData icon,
    required ColorScheme colorScheme,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 60.sp,
            color: colorScheme.outline,
          ),

          SizedBox(height: 15.h),

          Text(
            'judge_orders.no_requests'.tr(),
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // كارت الإعلان
  // المستوى الثاني
  // ============================================================

  Widget _buildAnnouncementCard({
    required BuildContext context,
    required String announcementId,
    required AnnouncementModel? announcement,
    required String fallbackTitle,
    required int applicantsCount,
    required Color navy,
    required Color gold,
    required bool isDark,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    final displayTitle =
        announcement?.title ?? fallbackTitle;

    final String displaySubtitle;

    if (announcement != null) {
      final college =
          announcement.collegeName ?? '';

      final department =
          announcement.departmentName;

      if (department != null &&
          department.isNotEmpty &&
          college.isNotEmpty) {
        displaySubtitle =
            '$college - $department';
      } else if (college.isNotEmpty) {
        displaySubtitle = college;
      } else {
        displaySubtitle =
            'employee_categories.admin_manager_job'.tr(); 
      }
    } else {
      displaySubtitle =
          'employee_categories.admin_manager_job'.tr(); 
    }

    return InkWell(
      onTap: () {
        setState(() {
          _selectedAnnouncementId =
              announcementId;
        });
      },
      borderRadius: BorderRadius.circular(18.r),
      child: Container(
        margin: EdgeInsets.only(bottom: 15.h),
        padding: EdgeInsets.symmetric(
          horizontal: 20.w,
          vertical: 18.h,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius:
              BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: navy.withOpacity(
              isDark ? 0.2 : 0.08,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: gold.withOpacity(
                  isDark ? 0.2 : 0.1,
                ),
                borderRadius:
                    BorderRadius.circular(14.r),
              ),
              child: Icon(
                Icons.campaign_outlined,
                color: gold,
                size: 26.sp,
              ),
            ),

            SizedBox(width: 15.w),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    displayTitle,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color:
                          colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                  ),

                  SizedBox(height: 4.h),

                  Text(
                    displaySubtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: colorScheme
                          .onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                  ),

                  SizedBox(height: 6.h),

                  Text(
                    '$applicantsCount ${'dashboard.main_cards.request'.tr()}',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: gold,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              Icons.arrow_forward_ios,
              color: colorScheme
                  .onSurfaceVariant
                  .withOpacity(0.5),
              size: 18.sp,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ملخص الإعلان
  // المستوى الثالث
  // ============================================================

  Widget _buildAnnouncementSummaryCard({
    required AnnouncementModel? announcement,
    required String fallbackTitle,
    required int applicantsCount,
    required Color navy,
    required Color gold,
    required bool isDark,
  }) {
    final colorScheme =
        Theme.of(context).colorScheme;

    final title =
        announcement?.title ?? fallbackTitle;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 20.w,
        vertical: 15.h,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 15.w,
        vertical: 14.h,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius:
            BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: gold.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: gold.withOpacity(0.1),
              borderRadius:
                  BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.people_alt_outlined,
              color: gold,
              size: 22.sp,
            ),
          ),

          SizedBox(width: 12.w),

          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          SizedBox(width: 8.w),

          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 10.w,
              vertical: 4.h,
            ),
            decoration: BoxDecoration(
              color: navy.withOpacity(
                isDark ? 0.15 : 0.05,
              ),
              borderRadius:
                  BorderRadius.circular(8.r),
            ),
            child: Text(
              '$applicantsCount ${'dashboard.main_cards.request'.tr()}',
              style: TextStyle(
                fontSize: 11.sp,
                color:
                    colorScheme.onSurfaceVariant,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // كارت الموظف
  // المستوى الثالث
  // ============================================================

  Widget _buildEmployeeRequestCard({
    required BuildContext context,
    required EmployeeNominationRequestModel request,
    required Color navy,
    required Color gold,
    required bool isDark,
  }) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      padding: EdgeInsets.symmetric(
        horizontal: 15.w,
        vertical: 15.h,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius:
            BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: navy.withOpacity(
            isDark ? 0.2 : 0.05,
          ),
        ),
      ),
      child: Row(
        children: [
          // ======================================================
          // صورة الموظف
          // ======================================================

          Container(
            width: 65.w,
            height: 65.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: navy.withOpacity(
                isDark ? 0.2 : 0.05,
              ),
              border: Border.all(
                color: gold.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: request.employeeImageUrl !=
                          null &&
                      request.employeeImageUrl!
                          .isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl:
                          request.employeeImageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) =>
                          Icon(
                        Icons.person_outline,
                        size: 30.sp,
                        color:
                            navy.withOpacity(0.5),
                      ),
                      errorWidget:
                          (_, __, ___) => Icon(
                        Icons.person_outline,
                        size: 30.sp,
                        color: navy,
                      ),
                    )
                  : Icon(
                      Icons.person_outline,
                      size: 30.sp,
                      color: navy,
                    ),
            ),
          ),

          SizedBox(width: 12.w),

          // ======================================================
          // بيانات الموظف
          // ======================================================

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Text(
                  request.employeeName,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color:
                        colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                ),

                SizedBox(height: 5.h),

                if (request.currentJob != null &&
                    request.currentJob!
                        .isNotEmpty)
                  Text(
                    request.currentJob!,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: colorScheme
                          .onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                  ),

                if (request.departmentName !=
                        null &&
                    request.departmentName!
                        .isNotEmpty) ...[
                  SizedBox(height: 3.h),
                  Text(
                    request.departmentName!,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: colorScheme
                          .onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          SizedBox(width: 10.w),

          // ======================================================
          // زر التقييم / العرض
          // ======================================================

          if (_isEvaluationPhase)
            ElevatedButton.icon(
              onPressed: () {
                context.push(
                  Routes.employeeInterviewEvaluation,
                  extra: request,
                );
              },
              icon: Icon(
                Icons.edit_note_rounded,
                size: 16.sp,
              ),
              label: Text(
                'judge_orders.evaluate'.tr(),
                style: TextStyle(
                  fontSize: 11.sp,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: gold,
                foregroundColor:
                    colorScheme.onPrimary,
                padding:
                    EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 10.h,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(10.r),
                ),
                elevation: 0,
              ),
            )
          else
            ElevatedButton.icon(
              onPressed: () {
                context.push(
                  Routes.employeeInterviewEvaluation,
                  extra: request,
                );
              },
              icon: Icon(
                Icons.visibility,
                size: 16.sp,
              ),
              label: Text(
                'judge_orders.view'.tr(),
                style: TextStyle(
                  fontSize: 12.sp,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark
                    ? colorScheme
                        .surfaceContainerHighest
                    : Colors.grey.shade600,
                foregroundColor: isDark
                    ? colorScheme.onSurface
                    : Colors.white,
                padding:
                    EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 10.h,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(10.r),
                ),
                elevation: 0,
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // APP BAR TITLE
  // ============================================================

  String _getAppBarTitle() {
    if (_selectedAnnouncementId != null) {
      return 'judge_orders.applicants_list_title'
          .tr();
    }

    if (widget.filterStatus ==
        EmployeeNominationRequestModel
            .statusPendingEvaluator) {
      return 'dashboard.main_cards.new'.tr();
    }

   if (widget.filterStatus ==
    EmployeeNominationRequestModel.statusFinalApproved) {
  return 'dashboard.main_cards.reviewing'.tr();
}

if (widget.filterStatus ==
    EmployeeNominationRequestModel.statusEvaluated) {
  return 'dashboard.main_cards.evaluated'.tr();
}

    if (widget.filterStatus ==
        EmployeeNominationRequestModel
            .statusFinalRejected) {
      return 'dashboard.main_cards.rejected'
          .tr();
    }

    return 'dashboardJudge.categories.title'.tr();
  }
}