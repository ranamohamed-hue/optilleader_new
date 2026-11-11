import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';

import 'package:optialeader/core/routing/routes.dart';

import 'package:optialeader/feature/employee/data/models/employee_nomination_request_model.dart';
import 'package:optialeader/feature/employee/logic/EmployeenNominationCubit/employee_nomination_cubit.dart';
import 'package:optialeader/feature/employee/logic/EmployeenNominationCubit/employee_nomination_state.dart';

class EmployeeJudgeOrdersListScreen extends StatefulWidget {
  final String? filterStatus;
  final String? filterRole;

  const EmployeeJudgeOrdersListScreen({
    super.key,
    this.filterStatus,
    this.filterRole,
  });

  @override
  State<EmployeeJudgeOrdersListScreen> createState() =>
      _EmployeeJudgeOrdersListScreenState();
}

class _EmployeeJudgeOrdersListScreenState
    extends State<EmployeeJudgeOrdersListScreen> {
  Color get _primaryNavy =>
      Theme.of(context).colorScheme.primary;

  Color get _goldAccent =>
      Theme.of(context).colorScheme.secondary;

  @override
  void initState() {
    super.initState();

    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    if (uid.isNotEmpty) {
      context
          .read<EmployeeNominationCubit>()
          .fetchEvaluatorRequests(uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    String pageTitle = 'judge_orders.title'.tr();

    if (widget.filterRole != null) {
      pageTitle =
          'dashboardJudge.categories.${widget.filterRole}'.tr();
    }

    if (widget.filterStatus != null) {
      pageTitle += ' (${_getStatusName()})';
    }

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: _primaryNavy,
        foregroundColor: colorScheme.onPrimary,
        title: Text(
          pageTitle,
          style: TextStyle(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: colorScheme.onPrimary,
            size: 20.sp,
          ),
          onPressed: () => context.pop(),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(2.h),
          child: Container(
            color: _goldAccent,
            height: 2.h,
          ),
        ),
      ),
      body: BlocBuilder<EmployeeNominationCubit,
          EmployeeNominationState>(
        builder: (context, state) {
          if (state is EmployeeNominationLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: _goldAccent,
              ),
            );
          }

          if (state is EmployeeNominationError) {
            return Center(
              child: Text(
                state.message.tr(),
                style: TextStyle(
                  color: colorScheme.error,
                ),
              ),
            );
          }

          if (state is EmployeeNominationLoaded) {
            List<EmployeeNominationRequestModel> requests =
                state.requests;

            // فلترة حسب الحالة
            if (widget.filterStatus != null) {
              requests = requests
                  .where(
                    (request) =>
                        request.status == widget.filterStatus,
                  )
                  .toList();
            }

            // فلترة حسب الوظيفة
            if (widget.filterRole != null) {
              requests = requests
                  .where(
                    (request) =>
                        request.targetRole ==
                        widget.filterRole,
                  )
                  .toList();
            }

            if (requests.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 60.sp,
                      color: colorScheme.onSurfaceVariant
                          .withOpacity(0.4),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'judge_orders.no_requests'.tr(),
                      style: TextStyle(
                        color:
                            colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.symmetric(
                horizontal: 20.w,
                vertical: 20.h,
              ),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                return _buildRequestCard(
                  context,
                  requests[index],
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildRequestCard(
    BuildContext context,
    EmployeeNominationRequestModel request,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark =
        theme.brightness == Brightness.dark;

    // ✅ تم حذف (isArabic) نهائياً

    final bool isEvaluated =
        request.status ==
            EmployeeNominationRequestModel
                .statusEvaluated ||
        request.status ==
            EmployeeNominationRequestModel
                .statusFinalApproved ||
        request.status ==
            EmployeeNominationRequestModel
                .statusFinalRejected;

    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      padding: EdgeInsets.symmetric(
        horizontal: 15.w,
        vertical: 15.h,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: isDark
            ? Border.all(
                color: colorScheme.outlineVariant
                    .withOpacity(0.3),
                width: 1,
              )
            : Border.all(
                color:
                    _primaryNavy.withOpacity(0.05),
                width: 1,
              ),
      ),
      child: Row(
        children: [
          // صورة الموظف
          Container(
            width: 70.w,
            height: 70.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _primaryNavy.withOpacity(
                isDark ? 0.2 : 0.05,
              ),
              border: Border.all(
                color:
                    _goldAccent.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: ClipOval(
              child:
                  request.employeeImageUrl != null &&
                          request.employeeImageUrl!
                              .isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl:
                              request.employeeImageUrl!,
                          fit: BoxFit.cover,
                          placeholder:
                              (_, __) => Icon(
                            Icons.person_outline,
                            size: 35.sp,
                            color: _primaryNavy
                                .withOpacity(0.5),
                          ),
                          errorWidget:
                              (_, __, ___) => Icon(
                            Icons.person_outline,
                            size: 35.sp,
                            color: _primaryNavy,
                          ),
                        )
                      : Icon(
                          Icons.person_outline,
                          size: 35.sp,
                          color: _primaryNavy,
                        ),
            ),
          ),

          SizedBox(width: 15.w),

          // بيانات الموظف
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
                    fontSize: 16.sp,
                    fontWeight:
                        FontWeight.bold,
                    color:
                        colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                ),

                SizedBox(height: 6.h),

                Container(
                  padding:
                      EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 4.h,
                  ),
                  decoration:
                      BoxDecoration(
                    color:
                        _goldAccent.withOpacity(
                      isDark ? 0 : 0.1,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                            8.r),
                  ),
                  // ✅ تم تغييرها للوظيفة المسجلة بدل targetRole
                  child: Text(
                    request.currentJob ?? '---',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: isDark
                          ? Colors.white
                          : const Color.fromARGB(
                              255,
                              8,
                              8,
                              8,
                            ),
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: 10.w),

          // =====================================================
          // زر العرض إذا تم التقييم
          // =====================================================
          if (isEvaluated)
            Padding(
              // ✅ تعديل الـ Padding ليشتغل في الاتجاهين بدون isArabic
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: ElevatedButton.icon(
                onPressed: () {
                  context.push(
                    Routes.employeeInterviewEvaluation,
                    extra: request,
                  );
                },
                icon: Icon(
                  Icons.visibility,
                  size: 18.sp,
                ),
                label: Text(
                  'judge_orders.view'.tr(),
                  style: TextStyle(
                    fontSize: 12.sp,
                  ),
                ),
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor: isDark
                      ? colorScheme
                          .surfaceContainerHighest
                      : Colors.grey.shade600,
                  foregroundColor: isDark
                      ? colorScheme.onSurface
                      : Colors.white,
                  padding:
                      EdgeInsets.symmetric(
                    horizontal: 15.w,
                    vertical: 12.h,
                  ),
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                            12.r),
                  ),
                  elevation: 0,
                ),
              ),
            )

          // =====================================================
          // زر التقييم إذا لم يتم التقييم
          // =====================================================
          else
            ElevatedButton.icon(
              onPressed: () {
                context.push(
                  Routes.employeeInterviewEvaluation,
                  extra: request,
                );
              },
              icon: Icon(
                Icons.edit_note_rounded,
                size: 18.sp,
                color: Colors.white,
              ),
              label: Text(
                'judge_orders.evaluate'.tr(),
                style: TextStyle(
                  fontSize: 12.sp,
                ),
              ),
              style:
                  ElevatedButton.styleFrom(
                backgroundColor: _goldAccent,
                foregroundColor: Colors.white,
                padding:
                    EdgeInsets.symmetric(
                  horizontal: 15.w,
                  vertical: 12.h,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                          12.r),
                ),
                elevation: 0,
              ),
            ),
        ],
      ),
    );
  }

  String _getStatusName() {
    if (widget.filterStatus ==
        EmployeeNominationRequestModel
            .statusPendingEvaluator) {
      return 'dashboard.main_cards.new'.tr();
    }

    if (widget.filterStatus ==
        EmployeeNominationRequestModel
            .statusEvaluated) {
      return 'dashboard.main_cards.reviewing'
          .tr();
    }

    if (widget.filterStatus ==
        EmployeeNominationRequestModel
            .statusFinalApproved) {
      return 'dashboard.main_cards.evaluated'
          .tr();
    }

    return '';
  }
}