import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:optialeader/core/routing/routes.dart';
import 'package:optialeader/core/theming/app_color.dart';
import 'package:optialeader/feature/admin/logic/employee/employee_nomination_admin_state%20.dart';
import 'package:optialeader/feature/employee/data/models/employee_nomination_request_model.dart';
import 'package:optialeader/feature/admin/logic/employee/employee_nomination_admin_cubit.dart';

class EmployeePendingRequestDetailsScreen extends StatefulWidget {
  final EmployeeNominationRequestModel request;

  const EmployeePendingRequestDetailsScreen({super.key, required this.request});

  @override
  State<EmployeePendingRequestDetailsScreen> createState() =>
      _EmployeePendingRequestDetailsScreenState();
}

class _EmployeePendingRequestDetailsScreenState
    extends State<EmployeePendingRequestDetailsScreen> {
  String? _selectedEvaluatorId;
  String? _selectedEvaluatorName;
  String? _selectedEvaluatorEmail;

  String _tr(String key) {
    return 'employee_pending_request.$key'.tr();
  }

  @override
  void initState() {
    super.initState();
    _selectedEvaluatorId = widget.request.evaluatorId;
    _selectedEvaluatorName = widget.request.evaluatorName;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return BlocListener<
      EmployeeNominationAdminCubit,
      EmployeeNominationAdminState
    >(
      listener: (context, state) {
        if (state is EmployeeNominationAdminActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_tr('evaluator_assigned_success')),
              backgroundColor: Colors.green,
            ),
          );
          context.pop(true);
        }

        if (state is EmployeeNominationAdminError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_tr('employee_request_details')),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusCard(isDark),
                SizedBox(height: 16.h),

                _buildSection(
                  title: _tr('employee_data'),
                  icon: Icons.person_outline_rounded,
                  children: [
                    _buildInfoRow(
                      title: _tr('name'),
                      value: widget.request.employeeName,
                    ),
                    _buildInfoRow(
                      title: _tr('employee_id'),
                      value: widget.request.employeeId,
                    ),
                    _buildInfoRow(
                      title: _tr('current_job'),
                      value: widget.request.currentJob,
                    ),
                    _buildInfoRow(
                      title: _tr('sector'),
                      value: widget.request.sectorName,
                    ),
                    _buildInfoRow(
                      title: _tr('department'),
                      value: widget.request.departmentName,
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                _buildSection(
                  title: _tr('nomination_data'),
                  icon: Icons.emoji_events_outlined,
                  children: [
                    _buildInfoRow(
                      title: _tr('announcement'),
                      value: widget.request.announcementTitle,
                    ),
                    _buildInfoRow(
                      title: _tr('target_role'),
                      value: widget.request.targetRole,
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                if (_hasFiles()) ...[
                  _buildUploadedFilesSection(),
                  SizedBox(height: 16.h),
                ],

                // ✅ زرار VerifyMe المضاف بعناية لخدمة التحقق من المستندات المرفقة
                _buildVerifyMeButton(colorScheme),
                SizedBox(height: 16.h),

                if (widget.request.status ==
                    EmployeeNominationRequestModel.statusPendingAdmin) ...[
                  _buildEvaluatorSelectionCard(),
                  SizedBox(height: 16.h),
                ],

                if (_hasText(widget.request.visionStatement)) ...[
                  _buildSection(
                    title: _tr('vision_statement'),
                    icon: Icons.lightbulb_outline_rounded,
                    children: [_buildTextBox(widget.request.visionStatement!)],
                  ),
                  SizedBox(height: 16.h),
                ],

                if (_hasEvaluator()) ...[
                  _buildSelectedEvaluatorCard(),
                  SizedBox(height: 16.h),
                ],

                if (_hasInterviewData()) ...[
                  _buildSection(
                    title: _tr('interview_data'),
                    icon: Icons.event_available_outlined,
                    children: [
                      if (widget.request.interviewDate != null)
                        _buildInfoRow(
                          title: _tr('date'),
                          value: DateFormat(
                            'dd/MM/yyyy',
                          ).format(widget.request.interviewDate!),
                        ),
                      _buildInfoRow(
                        title: _tr('time'),
                        value: widget.request.interviewTime,
                      ),
                      _buildInfoRow(
                        title: _tr('location'),
                        value: widget.request.interviewLocation,
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                ],

                if (_hasEvaluationData()) ...[
                  _buildEvaluationResultCard(),
                  SizedBox(height: 16.h),
                ],

                if (widget.request.status ==
                        EmployeeNominationRequestModel.statusRejectedByAdmin &&
                    _hasText(widget.request.rejectionReason)) ...[
                  _buildRejectionCard(),
                  SizedBox(height: 16.h),
                ],

                if (_hasText(widget.request.adminNotes)) ...[
                  _buildSection(
                    title: _tr('admin_notes'),
                    icon: Icons.notes_outlined,
                    children: [_buildTextBox(widget.request.adminNotes!)],
                  ),
                  SizedBox(height: 16.h),
                ],

                _buildSection(
                  title: _tr('request_information'),
                  icon: Icons.info_outline_rounded,
                  children: [
                    _buildInfoRow(
                      title: _tr('created_at'),
                      value: DateFormat(
                        'dd/MM/yyyy - hh:mm a',
                      ).format(widget.request.createdAt),
                    ),
                    if (widget.request.updatedAt != null)
                      _buildInfoRow(
                        title: _tr('updated_at'),
                        value: DateFormat(
                          'dd/MM/yyyy - hh:mm a',
                        ).format(widget.request.updatedAt!),
                      ),
                  ],
                ),

                if (widget.request.status ==
                    EmployeeNominationRequestModel.statusEvaluated) ...[
                  SizedBox(height: 24.h),
                  _buildFinalDecisionButtons(),
                ],

                if (widget.request.status ==
                        EmployeeNominationRequestModel.statusPendingAdmin &&
                    _selectedEvaluatorId != null) ...[
                  SizedBox(height: 24.h),
                  _buildFinalApprovalButton(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🛠️ دالة زرار VerifyMe
  Widget _buildVerifyMeButton(ColorScheme colorScheme) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.secondary,
          side: BorderSide(color: colorScheme.secondary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          padding: EdgeInsets.symmetric(vertical: 12.h),
        ),
        onPressed: () async {
          final url = Uri.parse('https://verifyme-secure.lovable.app/');
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          }
        },
        icon: const Icon(Icons.security, size: 20),
        label: Text(
          'التحقق من المستندات (VerifyMe)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
        ),
      ),
    );
  }

  Widget _buildStatusCard(bool isDark) {
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
        title = _tr('final_approved_pending_announcement');
        description = _tr('final_approved_pending_announcement_description');
        icon = Icons.announcement_outlined;
        break;
      default:
        title = widget.request.status;
        description = '';
        icon = Icons.info_outline_rounded;
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [
            AppColors.navyDark,
            isDark ? AppColors.navyDark : AppColors.navyLight,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.navyDark.withOpacity(0.20),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
              border: Border.all(color: AppColors.darkGold.withOpacity(0.45)),
            ),
            child: Icon(icon, color: AppColors.darkGold, size: 28.sp),
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
                    fontSize: 16.sp,
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

  Widget _buildEvaluationResultCard() {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: theme.colorScheme.secondary.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.fact_check_outlined,
                color: theme.colorScheme.secondary,
                size: 22.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                _tr('evaluation_result'),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.secondary,
                ),
              ),
            ],
          ),
          Divider(height: 24.h),
          if (widget.request.evaluatorPoints != null)
            _buildInfoRow(
              title: _tr('total_score'),
              value:
                  '${widget.request.evaluatorPoints!.toStringAsFixed(1)} / 100',
            ),
          if (_hasText(widget.request.evaluatorNotes))
            _buildInfoRow(
              title: _tr('evaluator_notes'),
              value: widget.request.evaluatorNotes,
            ),
        ],
      ),
    );
  }

  Widget _buildFinalDecisionButtons() {
    return BlocBuilder<
      EmployeeNominationAdminCubit,
      EmployeeNominationAdminState
    >(
      builder: (context, state) {
        final isLoading = state is EmployeeNominationAdminActionLoading;
        return Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 50.h,
                child: ElevatedButton.icon(
                  onPressed: isLoading
                      ? null
                      : () => _giveFinalDecision(isApproved: true),
                  icon: isLoading
                      ? SizedBox(
                          width: 20.h,
                          height: 20.h,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_circle_outline_rounded),
                  label: Text(
                    _tr('final_approve'),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 15.w),
            Expanded(
              child: SizedBox(
                height: 50.h,
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : _showFinalRejectionDialog,
                  icon: const Icon(Icons.cancel_outlined),
                  label: Text(
                    _tr('final_reject'),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildUploadedFilesSection() {
    final theme = Theme.of(context);
    final docs = widget.request.uploadedDocuments;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.5),
        ),
        boxShadow: theme.brightness == Brightness.dark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.attach_file_rounded,
                color: theme.primaryColor,
                size: 22.sp,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  _tr('attached_files'),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          Divider(height: 24.h),
          ...docs!.entries.map((entry) {
            final String docName = entry.key;
            final String docUrl = entry.value;
            final bool isPdf =
                docUrl.toLowerCase().endsWith('.pdf') ||
                docName.toLowerCase().contains('pdf');

            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: InkWell(
                onTap: docUrl.isNotEmpty
                    ? () async {
                        final uri = Uri.parse(docUrl);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      }
                    : null,
                borderRadius: BorderRadius.circular(10.r),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest
                        .withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: (isPdf ? Colors.red : theme.primaryColor)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          isPdf ? Icons.picture_as_pdf : Icons.image_outlined,
                          color: isPdf ? Colors.red : theme.primaryColor,
                          size: 24.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          docName,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        Icons.download_rounded,
                        color: theme.primaryColor,
                        size: 22.sp,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.5),
        ),
        boxShadow: theme.brightness == Brightness.dark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: theme.primaryColor, size: 22.sp),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          Divider(height: 24.h),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow({required String title, String? value}) {
    final theme = Theme.of(context);
    if (!_hasText(value)) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130.w,
            child: Text(
              title,
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
                fontSize: 13.sp,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value!,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextBox(String text) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13.sp,
          height: 1.6,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildEvaluatorSelectionCard() {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_search_outlined,
                color: theme.primaryColor,
                size: 22.sp,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  _tr('evaluator_selection'),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          Divider(height: 24.h),
          Text(
            _tr('evaluator_selection_description'),
            style: TextStyle(
              fontSize: 13.sp,
              height: 1.5,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 14.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _openEvaluatorSelection,
              icon: const Icon(Icons.person_search_outlined),
              label: Text(
                _selectedEvaluatorId == null
                    ? _tr('view_evaluators')
                    : _tr('change_evaluator'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedEvaluatorCard() {
    final theme = Theme.of(context);
    final name = _selectedEvaluatorName ?? widget.request.evaluatorName;
    if (!_hasText(name)) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: theme.colorScheme.tertiary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_search_rounded,
                color: theme.primaryColor,
                size: 22.sp,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  _tr('selected_evaluator'),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          Divider(height: 24.h),
          _buildInfoRow(title: _tr('evaluator_name'), value: name),
          if (_hasText(_selectedEvaluatorEmail))
            _buildInfoRow(
              title: _tr('evaluator_email'),
              value: _selectedEvaluatorEmail,
            ),
          SizedBox(height: 8.h),
          OutlinedButton.icon(
            onPressed: _openEvaluatorSelection,
            icon: const Icon(Icons.swap_horiz_rounded),
            label: Text(_tr('change_evaluator')),
          ),
        ],
      ),
    );
  }

  Widget _buildRejectionCard() {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: theme.colorScheme.error.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: theme.colorScheme.error,
                size: 22.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                _tr('rejection_reason'),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ),
          Divider(height: 24.h),
          Text(
            widget.request.rejectionReason!,
            style: TextStyle(
              fontSize: 13.sp,
              height: 1.6,
              color: theme.colorScheme.onErrorContainer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalApprovalButton() {
    return BlocBuilder<
      EmployeeNominationAdminCubit,
      EmployeeNominationAdminState
    >(
      builder: (context, state) {
        final isLoading = state is EmployeeNominationAdminActionLoading;
        return SizedBox(
          width: double.infinity,
          height: 50.h,
          child: ElevatedButton.icon(
            onPressed: isLoading ? null : _confirmFinalApproval,
            icon: isLoading
                ? SizedBox(
                    width: 20.h,
                    height: 20.h,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.check_circle_outline_rounded),
            label: Text(
              isLoading ? _tr('approving_and_sending') : _tr('final_approval'),
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _openEvaluatorSelection() async {
    final result = await context.push(
      Routes.employeeSelectEvaluator,
      extra: widget.request,
    );
    if (result == null || !mounted || result is! Map<String, dynamic>) return;

    setState(() {
      _selectedEvaluatorId = result['uid']?.toString();
      _selectedEvaluatorName = result['name']?.toString();
      _selectedEvaluatorEmail = result['email']?.toString();
    });
  }

  Future<void> _confirmFinalApproval() async {
    final requestId = widget.request.id;
    if (requestId == null || requestId.trim().isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_tr('request_id_missing'))));
      return;
    }

    final evaluatorId = _selectedEvaluatorId;
    final evaluatorName = _selectedEvaluatorName;

    if (evaluatorId == null || evaluatorId.trim().isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_tr('evaluator_required'))));
      return;
    }

    if (evaluatorName == null || evaluatorName.trim().isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_tr('evaluator_name_missing'))));
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(_tr('confirm_approval')),
          content: Text('${_tr('confirm_approval_message')}\n\n$evaluatorName'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text('common.cancel'.tr()),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(dialogContext, true),
              icon: const Icon(Icons.check_rounded),
              label: Text('common.confirm'.tr()),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    context.read<EmployeeNominationAdminCubit>().approveAndSendToEvaluator(
      requestId: requestId,
      evaluatorId: evaluatorId,
      evaluatorName: evaluatorName,
      employeeName: widget.request.employeeName,
      targetRole: widget.request.targetRole,
      employeeId: widget.request.employeeId,
    );
  }

  Future<void> _giveFinalDecision({
    required bool isApproved,
    String? rejectionReason,
  }) async {
    final confirmText = isApproved
        ? _tr('confirm_final_approval_message')
        : _tr('confirm_final_rejection_message');

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            isApproved
                ? _tr('confirm_final_approval')
                : _tr('confirm_final_rejection'),
          ),
          content: Text(confirmText),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text('common.cancel'.tr()),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text('common.confirm'.tr()),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    context.read<EmployeeNominationAdminCubit>().giveFinalDecision(
      requestId: widget.request.id!,
      isApproved: isApproved,
      rejectionReason: rejectionReason,
    );
  }

  Future<void> _showFinalRejectionDialog() async {
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(_tr('rejection_reason')),
          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration: InputDecoration(hintText: _tr('rejection_hint')),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text('common.cancel'.tr()),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isEmpty) return;
                Navigator.pop(dialogContext, true);
              },
              child: Text('common.confirm'.tr()),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      _giveFinalDecision(
        isApproved: false,
        rejectionReason: controller.text.trim(),
      );
    }
  }

  bool _hasEvaluationData() {
    return widget.request.evaluatorPoints != null ||
        _hasText(widget.request.evaluatorNotes);
  }

  bool _hasFiles() {
    final docs = widget.request.uploadedDocuments;
    return docs != null && docs.isNotEmpty;
  }

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
    return value != null && value.trim().isNotEmpty;
  }
}
