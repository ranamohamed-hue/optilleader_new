import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';

import 'package:optialeader/core/routing/routes.dart';
import 'package:optialeader/core/theming/app_color.dart';
import 'package:optialeader/feature/admin/logic/employee/employee_nomination_admin_state%20.dart';

import 'package:optialeader/feature/employee/data/models/employee_nomination_request_model.dart';

import 'package:optialeader/feature/admin/logic/employee/employee_nomination_admin_cubit.dart';

class EmployeePendingRequestDetailsScreen extends StatefulWidget {
  final EmployeeNominationRequestModel request;

  const EmployeePendingRequestDetailsScreen({
    super.key,
    required this.request,
  });

  @override
  State<EmployeePendingRequestDetailsScreen> createState() =>
      _EmployeePendingRequestDetailsScreenState();
}

class _EmployeePendingRequestDetailsScreenState
    extends State<EmployeePendingRequestDetailsScreen> {
  // ============================================================
  // SELECTED EVALUATOR
  // ============================================================

  String? _selectedEvaluatorId;
  String? _selectedEvaluatorName;
  String? _selectedEvaluatorEmail;

  // ============================================================
  // TRANSLATION
  // ============================================================

  String _tr(String key) {
    return 'employee_pending_request.$key'.tr();
  }

  @override
  void initState() {
    super.initState();

    // لو الطلب بالفعل له محكم
    _selectedEvaluatorId = widget.request.evaluatorId;
    _selectedEvaluatorName = widget.request.evaluatorName;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocListener<EmployeeNominationAdminCubit,
        EmployeeNominationAdminState>(
      listener: (context, state) {
        // ========================================================
        // SUCCESS
        // ========================================================

        if (state is EmployeeNominationAdminActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'employee_pending_request.evaluator_assigned_success'
                    .tr(),
              ),
            ),
          );

          context.pop(true);
        }

        // ========================================================
        // ERROR
        // ========================================================

        if (state is EmployeeNominationAdminError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },

      child: Scaffold(
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
                      value: widget.request.employeeName,
                    ),

                    _buildInfoRow(
                      context,
                      icon: Icons.badge_outlined,
                      title: _tr('employee_id'),
                      value: widget.request.employeeId,
                    ),

                    _buildInfoRow(
                      context,
                      icon: Icons.work_outline_rounded,
                      title: _tr('current_job'),
                      value: widget.request.currentJob,
                    ),

                    _buildInfoRow(
                      context,
                      icon: Icons.account_balance_outlined,
                      title: _tr('sector'),
                      value: widget.request.sectorName,
                    ),

                    _buildInfoRow(
                      context,
                      icon: Icons.business_outlined,
                      title: _tr('department'),
                      value: widget.request.departmentName,
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
                      value: widget.request.announcementTitle,
                    ),

                    _buildInfoRow(
                      context,
                      icon: Icons.work_history_outlined,
                      title: _tr('target_role'),
                      value: widget.request.targetRole,
                    ),
                  ],
                ),

                // ==================================================
                // SELECT EVALUATOR
                // ==================================================

                if (widget.request.status ==
                    EmployeeNominationRequestModel.statusPendingAdmin) ...[
                  SizedBox(height: 16.h),

                  _buildEvaluatorSelectionCard(
                    context,
                  ),
                ],

                // ==================================================
                // VISION
                // ==================================================

                if (_hasText(widget.request.visionStatement)) ...[
                  SizedBox(height: 16.h),

                  _buildSection(
                    context,
                    title: _tr('vision_statement'),
                    icon: Icons.lightbulb_outline_rounded,
                    children: [
                      _buildTextBox(
                        context,
                        widget.request.visionStatement!,
                      ),
                    ],
                  ),
                ],

                // ==================================================
                // EVALUATOR DATA
                // ==================================================

                if (_hasEvaluator()) ...[
                  SizedBox(height: 16.h),

                  _buildSelectedEvaluatorCard(
                    context,
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
                      if (widget.request.interviewDate != null)
                        _buildInfoRow(
                          context,
                          icon: Icons.calendar_today_outlined,
                          title: _tr('date'),
                          value: DateFormat(
                            'dd/MM/yyyy',
                          ).format(
                            widget.request.interviewDate!,
                          ),
                        ),

                      _buildInfoRow(
                        context,
                        icon: Icons.access_time_rounded,
                        title: _tr('time'),
                        value: widget.request.interviewTime,
                      ),

                      _buildInfoRow(
                        context,
                        icon: Icons.location_on_outlined,
                        title: _tr('location'),
                        value: widget.request.interviewLocation,
                      ),
                    ],
                  ),
                ],

                // ==================================================
                // REJECTION
                // ==================================================

                if (widget.request.status ==
                        EmployeeNominationRequestModel
                            .statusRejectedByAdmin &&
                    _hasText(widget.request.rejectionReason)) ...[
                  SizedBox(height: 16.h),

                  _buildRejectionCard(
                    context,
                  ),
                ],

                // ==================================================
                // ADMIN NOTES
                // ==================================================

                if (_hasText(widget.request.adminNotes)) ...[
                  SizedBox(height: 16.h),

                  _buildSection(
                    context,
                    title: _tr('admin_notes'),
                    icon: Icons.notes_outlined,
                    children: [
                      _buildTextBox(
                        context,
                        widget.request.adminNotes!,
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
                        widget.request.createdAt,
                      ),
                    ),

                    if (widget.request.updatedAt != null)
                      _buildInfoRow(
                        context,
                        icon: Icons.update_rounded,
                        title: _tr('updated_at'),
                        value: DateFormat(
                          'dd/MM/yyyy - hh:mm a',
                        ).format(
                          widget.request.updatedAt!,
                        ),
                      ),
                  ],
                ),

                // ==================================================
                // FINAL APPROVAL
                // ==================================================

                if (widget.request.status ==
                        EmployeeNominationRequestModel.statusPendingAdmin &&
                    _selectedEvaluatorId != null) ...[
                  SizedBox(height: 20.h),

                  _buildFinalApprovalButton(
                    context,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // EVALUATOR SELECTION CARD
  // ============================================================

 Widget _buildEvaluatorSelectionCard(BuildContext context) {
  final theme = Theme.of(context);

  return Container(
    padding: EdgeInsets.all(17.w),

    decoration: BoxDecoration(
      color: theme.cardTheme.color ?? theme.cardColor,
      borderRadius: BorderRadius.circular(25.r),
      border: Border.all(
        color: AppColors.darkGold.withOpacity(0.25),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(
            theme.brightness == Brightness.dark ? 0.12 : 0.06,
          ),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    ),

    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 42.w,
              height: 42.w,
              decoration: BoxDecoration(
                color: AppColors.darkGold.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.person_search_outlined,
                color: AppColors.darkGold,
                size: 23.sp,
              ),
            ),

            SizedBox(width: 10.w),

            Expanded(
              child: Text(
                'اختيار المحكم',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 12.h),

        Text(
          'قم باختيار المحكم المسؤول عن تقييم طلب ترشح الموظف.',
          style: theme.textTheme.bodyMedium?.copyWith(
            height: 1.5,
          ),
        ),

        SizedBox(height: 14.h),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _openEvaluatorSelection,
            icon: const Icon(
              Icons.person_search_outlined,
            ),
            label: Text(
              _selectedEvaluatorId == null
                  ? 'عرض قائمة المحكمين'
                  : 'تغيير المحكم',
            ),
          ),
        ),
      ],
    ),
  );
} // ============================================================
  // OPEN EVALUATOR PAGE
  // ============================================================

  Future<void> _openEvaluatorSelection() async {
    final result = await context.push(
      Routes.employeeSelectEvaluator,
      extra: widget.request,
    );

    if (result == null || !mounted) {
      return;
    }

    if (result is! Map<String, dynamic>) {
      return;
    }

    setState(() {
      _selectedEvaluatorId = result['uid']?.toString();

      _selectedEvaluatorName =
          result['name']?.toString();

      _selectedEvaluatorEmail =
          result['email']?.toString();
    });
  }

  // ============================================================
  // SELECTED EVALUATOR CARD
  // ============================================================

  Widget _buildSelectedEvaluatorCard(
    BuildContext context,
  ) {
    final theme = Theme.of(context);

    final name = _selectedEvaluatorName ??
        widget.request.evaluatorName;

    if (!_hasText(name)) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(17.w),

      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? theme.cardColor,

        borderRadius: BorderRadius.circular(25.r),

        border: Border.all(
          color: AppColors.darkGold.withOpacity(0.30),
        ),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,

        children: [
          Row(
            children: [
              Container(
                width: 42.w,
                height: 42.w,

                decoration: BoxDecoration(
                  color: AppColors.darkGold.withOpacity(0.12),

                  borderRadius: BorderRadius.circular(12.r),
                ),

                child: Icon(
                  Icons.person_search_rounded,
                  color: AppColors.darkGold,
                  size: 23.sp,
                ),
              ),

              SizedBox(width: 10.w),

              Expanded(
                child: Text(
                  'المحكم المختار',

                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 14.h),

          _buildInfoRow(
            context,
            icon: Icons.person_outline,
            title: 'الاسم',
            value: name,
          ),

          if (_hasText(_selectedEvaluatorEmail))
            _buildInfoRow(
              context,
              icon: Icons.email_outlined,
              title: 'البريد',
              value: _selectedEvaluatorEmail,
            ),

          SizedBox(height: 8.h),

          OutlinedButton.icon(
            onPressed: _openEvaluatorSelection,

            icon: const Icon(
              Icons.swap_horiz_rounded,
            ),

            label: const Text(
              'تغيير المحكم',
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FINAL APPROVAL BUTTON
  // ============================================================

 Widget _buildFinalApprovalButton(
  BuildContext context,
) {
  return BlocBuilder<EmployeeNominationAdminCubit,
      EmployeeNominationAdminState>(
    builder: (context, state) {
      final isLoading =
          state is EmployeeNominationAdminActionLoading;

      return SizedBox(
        width: double.infinity,
        height: 52.h,
        child: ElevatedButton.icon(
          onPressed: isLoading
              ? null
              : _confirmFinalApproval,

          icon: isLoading
              ? SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(
                  Icons.check_circle_outline_rounded,
                ),

          label: Text(
            isLoading
                ? 'جاري الاعتماد والتحويل...'
                : 'اعتماد وتحويل للمحكم',
          ),
        ),
      );
    },
  );
}
  // ============================================================
  // CONFIRM FINAL APPROVAL
  // ============================================================

 Future<void> _confirmFinalApproval() async {
  // ==========================================================
  // VALIDATE REQUEST ID
  // ==========================================================

  final requestId = widget.request.id;

  if (requestId == null || requestId.trim().isEmpty) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'معرف الطلب غير موجود',
        ),
      ),
    );

    return;
  }

  // ==========================================================
  // VALIDATE EVALUATOR
  // ==========================================================

  final evaluatorId = _selectedEvaluatorId;
  final evaluatorName = _selectedEvaluatorName;

  if (evaluatorId == null ||
      evaluatorId.trim().isEmpty) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'يجب اختيار المحكم أولاً',
        ),
      ),
    );

    return;
  }

  if (evaluatorName == null ||
      evaluatorName.trim().isEmpty) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'اسم المحكم غير موجود',
        ),
      ),
    );

    return;
  }

  // ==========================================================
  // CONFIRM
  // ==========================================================

  final confirmed = await showDialog<bool>(
    context: context,

    builder: (dialogContext) {
      return AlertDialog(
        title: const Text(
          'تأكيد الاعتماد',
        ),

        content: Text(
          'هل أنت متأكد من اعتماد الطلب وتحويله إلى المحكم؟\n\n'
          '$evaluatorName',
        ),

        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(
                dialogContext,
                false,
              );
            },

            child: const Text(
              'إلغاء',
            ),
          ),

          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(
                dialogContext,
                true,
              );
            },

            icon: const Icon(
              Icons.check_rounded,
            ),

            label: const Text(
              'اعتماد',
            ),
          ),
        ],
      );
    },
  );

  // ==========================================================
  // USER CANCELLED
  // ==========================================================

  if (confirmed != true || !mounted) {
    return;
  }

  // ==========================================================
  // SEND TO CUBIT
  // ==========================================================

  context
      .read<EmployeeNominationAdminCubit>()
      .approveAndSendToEvaluator(
        requestId: requestId,
        evaluatorId: evaluatorId,
        evaluatorName: evaluatorName,
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

    switch (widget.request.status) {
      case EmployeeNominationRequestModel.statusPendingAdmin:
        title = _tr('pending_admin');
        description = _tr('pending_admin_description');
        icon = Icons.hourglass_top_rounded;
        break;

      case EmployeeNominationRequestModel.statusPendingEvaluator:
        title = _tr('pending_evaluator');
        description = _tr('pending_evaluator_description');
        icon = Icons.person_search_outlined;
        break;

      case EmployeeNominationRequestModel.statusRejectedByAdmin:
        title = _tr('rejected_by_admin');
        description = _tr('rejected_by_admin_description');
        icon = Icons.cancel_outlined;
        break;

      case EmployeeNominationRequestModel.statusEvaluated:
        title = _tr('evaluated');
        description = _tr('evaluated_description');
        icon = Icons.fact_check_outlined;
        break;

      case EmployeeNominationRequestModel.statusFinalApproved:
        title = _tr('final_approved');
        description = _tr('final_approved_description');
        icon = Icons.check_circle_outline_rounded;
        break;

      case EmployeeNominationRequestModel.statusFinalRejected:
        title = _tr('final_rejected');
        description = _tr('final_rejected_description');
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
        title = widget.request.status;
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
            color: AppColors.navyDark.withOpacity(0.20),

            blurRadius: 12,

            offset: const Offset(0, 5),
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

              color: AppColors.darkGold.withOpacity(0.18),

              border: Border.all(
                color: AppColors.darkGold.withOpacity(0.45),
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
              crossAxisAlignment: CrossAxisAlignment.start,

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
        color: theme.cardTheme.color ?? theme.cardColor,

        borderRadius: BorderRadius.circular(25.r),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              theme.brightness == Brightness.dark
                  ? 0.12
                  : 0.06,
            ),

            blurRadius: 10,

            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,

        children: [
          Row(
            children: [
              Container(
                width: 38.w,
                height: 38.w,

                decoration: BoxDecoration(
                  color: AppColors.darkGold.withOpacity(0.12),

                  borderRadius: BorderRadius.circular(12.r),
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

                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,

                    color:
                        theme.brightness == Brightness.dark
                            ? AppColors.darkText
                            : AppColors.navyDark,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          Divider(
            color: theme.dividerColor.withOpacity(0.35),
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
        crossAxisAlignment: CrossAxisAlignment.start,

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

              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,

                color:
                    theme.brightness == Brightness.dark
                        ? AppColors.darkText.withOpacity(0.75)
                        : AppColors.navyDark.withOpacity(0.75),
              ),
            ),
          ),

          SizedBox(width: 8.w),

          Expanded(
            child: Text(
              value!,

              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
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
            theme.brightness == Brightness.dark
                ? AppColors.darkBackground
                : AppColors.navyDark.withOpacity(0.04),

        borderRadius: BorderRadius.circular(15.r),

        border: Border.all(
          color: AppColors.darkGold.withOpacity(0.20),
        ),
      ),

      child: Text(
        text,

        style: theme.textTheme.bodyMedium?.copyWith(
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
            theme.brightness == Brightness.dark
                ? AppColors.darkBackground
                : AppColors.error.withOpacity(0.06),

        borderRadius: BorderRadius.circular(25.r),

        border: Border.all(
          color: AppColors.error.withOpacity(0.30),
        ),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

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

                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          Text(
            widget.request.rejectionReason!,

            style: theme.textTheme.bodyMedium?.copyWith(
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
    return _hasText(_selectedEvaluatorName) ||
        _hasText(widget.request.evaluatorName);
  }

  bool _hasInterviewData() {
    return widget.request.interviewDate != null ||
        _hasText(widget.request.interviewLocation) ||
        _hasText(widget.request.interviewTime);
  }

  bool _hasText(String? value) {
    return value != null &&
        value.trim().isNotEmpty;
  }
}