import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:optialeader/core/theming/app_color.dart';
import 'package:optialeader/feature/employee/data/models/employee_nomination_request_model .dart';

class EmployeePendingRequestDetailsScreen extends StatelessWidget {
  final EmployeeNominationRequestModel request;

  const EmployeePendingRequestDetailsScreen({
    super.key,
    required this.request,
  });

  // ============================================================
  // TRANSLATION PREFIX
  // ============================================================

  String _tr(String key) {
    return 'employee_pending_request.$key'.tr();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _tr('employee_request_details'),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            16.w,
            16.h,
            16.w,
            30.h,
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // ==================================================
              // STATUS
              // ==================================================

              _buildStatusCard(
                context,
                isDark,
              ),

              SizedBox(height: 16.h),

              // ==================================================
              // EMPLOYEE DATA
              // ==================================================

              _buildSection(
                context,
                title: _tr('employee_data'),
                icon: Icons.person_outline_rounded,
                children: [

                  _buildInfoRow(
                    context,
                    icon: Icons.person_outline,
                    title: _tr('name'),
                    value: request.employeeName,
                  ),

                  _buildInfoRow(
                    context,
                    icon: Icons.badge_outlined,
                    title: _tr('employee_id'),
                    value: request.employeeId,
                  ),

                  _buildInfoRow(
                    context,
                    icon: Icons.work_outline_rounded,
                    title: _tr('current_job'),
                    value: request.currentJob,
                  ),

                  _buildInfoRow(
                    context,
                    icon: Icons.account_balance_outlined,
                    title: _tr('sector'),
                    value: request.sectorName,
                  ),

                  _buildInfoRow(
                    context,
                    icon: Icons.business_outlined,
                    title: _tr('department'),
                    value: request.departmentName,
                  ),
                ],
              ),

              SizedBox(height: 16.h),

              // ==================================================
              // NOMINATION DATA
              // ==================================================

              _buildSection(
                context,
                title: _tr('nomination_data'),
                icon: Icons.emoji_events_outlined,
                children: [

                  _buildInfoRow(
                    context,
                    icon: Icons.campaign_outlined,
                    title: _tr('announcement'),
                    value: request.announcementTitle,
                  ),

                  _buildInfoRow(
                    context,
                    icon: Icons.work_history_outlined,
                    title: _tr('target_role'),
                    value: request.targetRole,
                  ),
                ],
              ),

              // ==================================================
              // VISION
              // ==================================================

              if (_hasText(request.visionStatement)) ...[
                SizedBox(height: 16.h),

                _buildSection(
                  context,
                  title: _tr('vision_statement'),
                  icon: Icons.lightbulb_outline_rounded,
                  children: [
                    _buildTextBox(
                      context,
                      request.visionStatement!,
                    ),
                  ],
                ),
              ],

              // ==================================================
              // EVALUATOR
              // ==================================================

              if (_hasEvaluator()) ...[
                SizedBox(height: 16.h),

                _buildSection(
                  context,
                  title: _tr('evaluator_data'),
                  icon: Icons.person_search_outlined,
                  children: [

                    _buildInfoRow(
                      context,
                      icon: Icons.person_outline,
                      title: _tr('evaluator'),
                      value: request.evaluatorName,
                    ),
                  ],
                ),
              ],

              // ==================================================
              // INTERVIEW
              // ==================================================

              if (_hasInterviewData()) ...[
                SizedBox(height: 16.h),

                _buildSection(
                  context,
                  title: _tr('interview_data'),
                  icon: Icons.event_available_outlined,
                  children: [

                    if (request.interviewDate != null)
                      _buildInfoRow(
                        context,
                        icon: Icons.calendar_today_outlined,
                        title: _tr('date'),
                        value: DateFormat(
                          'dd/MM/yyyy',
                        ).format(
                          request.interviewDate!,
                        ),
                      ),

                    _buildInfoRow(
                      context,
                      icon: Icons.access_time_rounded,
                      title: _tr('time'),
                      value: request.interviewTime,
                    ),

                    _buildInfoRow(
                      context,
                      icon: Icons.location_on_outlined,
                      title: _tr('location'),
                      value: request.interviewLocation,
                    ),
                  ],
                ),
              ],

              // ==================================================
              // REJECTION
              // ==================================================

              if (request.status ==
                      EmployeeNominationRequestModel
                          .statusRejectedByAdmin &&
                  _hasText(request.rejectionReason)) ...[
                SizedBox(height: 16.h),

                _buildRejectionCard(
                  context,
                ),
              ],

              // ==================================================
              // ADMIN NOTES
              // ==================================================

              if (_hasText(request.adminNotes)) ...[
                SizedBox(height: 16.h),

                _buildSection(
                  context,
                  title: _tr('admin_notes'),
                  icon: Icons.notes_outlined,
                  children: [
                    _buildTextBox(
                      context,
                      request.adminNotes!,
                    ),
                  ],
                ),
              ],

              SizedBox(height: 16.h),

              // ==================================================
              // REQUEST INFORMATION
              // ==================================================

              _buildSection(
                context,
                title: _tr('request_information'),
                icon: Icons.info_outline_rounded,
                children: [

                  _buildInfoRow(
                    context,
                    icon: Icons.calendar_month_outlined,
                    title: _tr('created_at'),
                    value: DateFormat(
                      'dd/MM/yyyy - hh:mm a',
                    ).format(
                      request.createdAt,
                    ),
                  ),

                  if (request.updatedAt != null)
                    _buildInfoRow(
                      context,
                      icon: Icons.update_rounded,
                      title: _tr('updated_at'),
                      value: DateFormat(
                        'dd/MM/yyyy - hh:mm a',
                      ).format(
                        request.updatedAt!,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // STATUS CARD
  // ============================================================

  Widget _buildStatusCard(
    BuildContext context,
    bool isDark,
  ) {
    String title;
    String description;
    IconData icon;

    switch (request.status) {

      case EmployeeNominationRequestModel.statusPendingAdmin:

        title = _tr('pending_admin');

        description = _tr(
          'pending_admin_description',
        );

        icon = Icons.hourglass_top_rounded;

        break;

      case EmployeeNominationRequestModel.statusPendingEvaluator:

        title = _tr('pending_evaluator');

        description = _tr(
          'pending_evaluator_description',
        );

        icon = Icons.person_search_outlined;

        break;

      case EmployeeNominationRequestModel.statusRejectedByAdmin:

        title = _tr('rejected_by_admin');

        description = _tr(
          'rejected_by_admin_description',
        );

        icon = Icons.cancel_outlined;

        break;

      case EmployeeNominationRequestModel.statusEvaluated:

        title = _tr('evaluated');

        description = _tr(
          'evaluated_description',
        );

        icon = Icons.fact_check_outlined;

        break;

      case EmployeeNominationRequestModel.statusFinalApproved:

        title = _tr('final_approved');

        description = _tr(
          'final_approved_description',
        );

        icon = Icons.check_circle_outline_rounded;

        break;

      case EmployeeNominationRequestModel.statusFinalRejected:

        title = _tr('final_rejected');

        description = _tr(
          'final_rejected_description',
        );

        icon = Icons.cancel_outlined;

        break;

      case EmployeeNominationRequestModel
          .statusFinalApprovedPendingAnnouncement:

        title = _tr(
          'final_approved_pending_announcement',
        );

        description = _tr(
          'final_approved_pending_announcement_description',
        );

        icon = Icons.announcement_outlined;

        break;

      default:

        title = request.status;

        description = '';

        icon = Icons.info_outline_rounded;
    }

    return Container(
      padding: EdgeInsets.all(18.w),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.r),

        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,

          colors: [
            AppColors.navyDark,

            isDark
                ? AppColors.navyDark
                : AppColors.navyLight,
          ],
        ),

        boxShadow: [
          BoxShadow(
            color: AppColors.navyDark.withOpacity(
              0.20,
            ),

            blurRadius: 12,

            offset: const Offset(
              0,
              5,
            ),
          ),
        ],
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Container(
            width: 56.w,
            height: 56.w,

            decoration: BoxDecoration(
              shape: BoxShape.circle,

              color: AppColors.darkGold.withOpacity(
                0.18,
              ),

              border: Border.all(
                color: AppColors.darkGold.withOpacity(
                  0.45,
                ),
              ),
            ),

            child: Icon(
              icon,
              color: AppColors.darkGold,
              size: 28.sp,
            ),
          ),

          SizedBox(width: 14.w),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(
                  title,

                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                if (description.isNotEmpty) ...[
                  SizedBox(height: 5.h),

                  Text(
                    description,

                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13.sp,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION
  // ============================================================

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(17.w),

      decoration: BoxDecoration(
        color: theme.cardTheme.color ??
            theme.cardColor,

        borderRadius: BorderRadius.circular(25.r),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              theme.brightness ==
                      Brightness.dark
                  ? 0.12
                  : 0.06,
            ),

            blurRadius: 10,

            offset: const Offset(
              0,
              3,
            ),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.stretch,

        children: [

          Row(
            children: [

              Container(
                width: 38.w,
                height: 38.w,

                decoration: BoxDecoration(
                  color: AppColors.darkGold.withOpacity(
                    0.12,
                  ),

                  borderRadius:
                      BorderRadius.circular(
                    12.r,
                  ),
                ),

                child: Icon(
                  icon,
                  color: AppColors.darkGold,
                  size: 21.sp,
                ),
              ),

              SizedBox(width: 10.w),

              Expanded(
                child: Text(
                  title,

                  style: theme
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                    fontWeight:
                        FontWeight.bold,

                    color:
                        theme.brightness ==
                                Brightness.dark
                            ? AppColors.darkText
                            : AppColors.navyDark,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          Divider(
            color: theme.dividerColor.withOpacity(
              0.35,
            ),

            height: 1,
          ),

          SizedBox(height: 8.h),

          ...children,
        ],
      ),
    );
  }

  // ============================================================
  // INFO ROW
  // ============================================================

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? value,
  }) {
    if (!_hasText(value)) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 8.h,
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Icon(
            icon,
            size: 19.sp,
            color: AppColors.darkGold,
          ),

          SizedBox(width: 10.w),

          SizedBox(
            width: 105.w,

            child: Text(
              title,

              style: theme
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                fontWeight:
                    FontWeight.w600,

                color:
                    theme.brightness ==
                            Brightness.dark
                        ? AppColors.darkText
                            .withOpacity(
                            0.75,
                          )
                        : AppColors.navyDark
                            .withOpacity(
                            0.75,
                          ),
              ),
            ),
          ),

          SizedBox(width: 8.w),

          Expanded(
            child: Text(
              value!,

              style: theme
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                fontWeight:
                    FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TEXT BOX
  // ============================================================

  Widget _buildTextBox(
    BuildContext context,
    String text,
  ) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,

      padding: EdgeInsets.all(14.w),

      decoration: BoxDecoration(
        color:
            theme.brightness ==
                    Brightness.dark
                ? AppColors.darkBackground
                : AppColors.navyDark.withOpacity(
                    0.04,
                  ),

        borderRadius:
            BorderRadius.circular(
          15.r,
        ),

        border: Border.all(
          color: AppColors.darkGold.withOpacity(
            0.20,
          ),
        ),
      ),

      child: Text(
        text,

        style: theme
            .textTheme
            .bodyMedium
            ?.copyWith(
          height: 1.6,
        ),
      ),
    );
  }

  // ============================================================
  // REJECTION CARD
  // ============================================================

  Widget _buildRejectionCard(
    BuildContext context,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(17.w),

      decoration: BoxDecoration(
        color:
            theme.brightness ==
                    Brightness.dark
                ? AppColors.darkBackground
                : AppColors.error.withOpacity(
                    0.06,
                  ),

        borderRadius:
            BorderRadius.circular(
          25.r,
        ),

        border: Border.all(
          color: AppColors.error.withOpacity(
            0.30,
          ),
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Row(
            children: [

              Icon(
                Icons.info_outline_rounded,
                color: AppColors.error,
                size: 22.sp,
              ),

              SizedBox(width: 8.w),

              Text(
                _tr('rejection_reason'),

                style: theme
                    .textTheme
                    .titleMedium
                    ?.copyWith(
                  color: AppColors.error,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          Text(
            request.rejectionReason!,

            style: theme
                .textTheme
                .bodyMedium
                ?.copyWith(
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  bool _hasEvaluator() {
    return _hasText(
      request.evaluatorName,
    );
  }

  bool _hasInterviewData() {
    return request.interviewDate != null ||
        _hasText(
          request.interviewLocation,
        ) ||
        _hasText(
          request.interviewTime,
        );
  }

  bool _hasText(
    String? value,
  ) {
    return value != null &&
        value.trim().isNotEmpty;
  }
}