import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:optialeader/feature/admin/data/model/nomination_request_model.dart';
import 'package:optialeader/feature/admin/logic/nomination_request_logic/nomination_request_cubit.dart';
import 'package:optialeader/feature/admin/logic/nomination_request_logic/nomonation_request_state.dart';
import 'package:optialeader/feature/admin/ui/system_scores_card.dart';

class NominationRequestDetailsScreen extends StatefulWidget {
  final NominationRequestModel request;

  const NominationRequestDetailsScreen({super.key, required this.request});

  @override
  State<NominationRequestDetailsScreen> createState() =>
      _NominationRequestDetailsScreenState();
}

class _NominationRequestDetailsScreenState
    extends State<NominationRequestDetailsScreen> {
  // تم التعديل هنا
  String _collegeName = 'nomination_details.loading'.tr();
  String _departmentName = 'nomination_details.loading'.tr();

  @override
  void initState() {
    super.initState();
    _fetchCollegeDepartmentNames();
  }

  Future<void> _fetchCollegeDepartmentNames() async {
    final request = widget.request;

    if (request.collegeName != null && request.departmentName != null) {
      setState(() {
        _collegeName = request.collegeName!;
        _departmentName = request.departmentName!;
      });
      return;
    }

    try {
      String college = '-';
      String department = '-';

      if (request.collegeId != null) {
        final doc = await FirebaseFirestore.instance
            .collection('colleges')
            .doc(request.collegeId)
            .get();
        if (doc.exists) {
          college = doc.data()?['name'] ?? doc.data()?['nameAr'] ?? '-';
        }
      }

      if (request.departmentId != null) {
        final doc = await FirebaseFirestore.instance
            .collection('departments')
            .doc(request.departmentId)
            .get();
        if (doc.exists) {
          department = doc.data()?['name'] ?? doc.data()?['nameAr'] ?? '-';
        }
      }

      setState(() {
        _collegeName = college;
        _departmentName = department;
      });
    } catch (e) {
      setState(() {
        _collegeName = '-';
        _departmentName = '-';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryNavy = theme.primaryColor;
    final goldAccent = theme.colorScheme.secondary;
    final request = widget.request;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: primaryNavy,
        title: Text(
          'nomination_details.title'.tr(), // تم التعديل هنا
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20.sp,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocListener<NominationRequestCubit, NominationRequestState>(
        listener: (context, state) {
          if (state is NominationRequestActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message.tr()),
                backgroundColor: Colors.green,
              ),
            );
            context.pop();
          } else if (state is NominationRequestError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message.tr()),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDoctorInfoCard(request, primaryNavy, goldAccent),
              SizedBox(height: 16.h),
              _buildRequestInfoCard(request, primaryNavy),
              SizedBox(height: 16.h),
              SystemScoresCard(request: request),
              SizedBox(height: 16.h),
              _buildDeclarationFileCard(request, primaryNavy),
              SizedBox(height: 16.h),
              if (request.interviewEvaluation != null) ...[
                _buildEvaluatorCard(request, primaryNavy, goldAccent),
                SizedBox(height: 16.h),
              ],
              _buildActionButtons(request, primaryNavy, goldAccent),
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorInfoCard(
    NominationRequestModel request,
    Color primaryNavy,
    Color goldAccent,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35.r,
            backgroundColor: primaryNavy.withOpacity(0.1),
            backgroundImage: request.doctorImageUrl != null
                ? NetworkImage(request.doctorImageUrl!)
                : null,
            child: request.doctorImageUrl == null
                ? Icon(Icons.person, size: 35.sp, color: primaryNavy)
                : null,
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.doctorName,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: primaryNavy,
                  ),
                ),
                SizedBox(height: 6.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: goldAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    request.targetRole.tr(),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: primaryNavy,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  // تم التعديل هنا (كان ناقص البادئة)
                  '${'nomination_details.doctor_info.submission_date'.tr()} : ${DateFormat('yyyy-MM-dd').format(request.createdAt)}',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestInfoCard(
    NominationRequestModel request,
    Color primaryNavy,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: primaryNavy, size: 22.sp),
              SizedBox(width: 10.w),
              Text(
                'nomination_details.info_card.title'.tr(), // تم التعديل هنا
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: primaryNavy,
                ),
              ),
            ],
          ),
          Divider(height: 20.h),
          _buildInfoRow(
            'nomination_details.info_card.id'.tr(), // تم التعديل هنا
            request.id ?? '-',
          ),
          _buildInfoRow(
            'nomination_details.info_card.college'
                .tr(), // تم التعديل هنا (كان ناقص البادئة)
            _collegeName,
          ),
          _buildInfoRow(
            'nomination_details.info_card.department'.tr(), // تم التعديل هنا
            _departmentName,
          ),
          _buildInfoRow(
            'nomination_details.info_card.status'.tr(), // تم التعديل هنا
            _getStatusText(request.status),
          ),
          if (request.rejectionReason != null)
            _buildInfoRow(
              'nomination_details.info_card.rejection_reason'
                  .tr(), // تم التعديل هنا
              request.rejectionReason!,
            ),
        ],
      ),
    );
  }

  Widget _buildDeclarationFileCard(
    NominationRequestModel request,
    Color primaryNavy,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.attach_file, color: primaryNavy, size: 22.sp),
              SizedBox(width: 10.w),
              Text(
                'nomination_details.declaration.title'.tr(), // تم التعديل هنا
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: primaryNavy,
                ),
              ),
            ],
          ),
          Divider(height: 20.h),
          if (request.declarationFileUrl != null)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.picture_as_pdf,
                color: Colors.red,
                size: 30.sp,
              ),
              title: Text(
                'nomination_details.declaration.view_file'
                    .tr(), // تم التعديل هنا
              ),
              trailing: Icon(Icons.open_in_new, color: primaryNavy),
              onTap: () async {
                final uri = Uri.parse(request.declarationFileUrl!);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
            )
          else
            Text(
              'nomination_details.declaration.no_file'.tr(), // تم التعديل هنا
              style: TextStyle(color: Colors.grey[500]),
            ),
        ],
      ),
    );
  }

  Widget _buildEvaluatorCard(
    NominationRequestModel request,
    Color primaryNavy,
    Color goldAccent,
  ) {
    final evaluation = request.interviewEvaluation!;
    final totalScore =
        (evaluation['totalScore'] ?? request.evaluatorPoints ?? 0).toDouble();

    // ✅ كشف: هل التقييم بال نظام القديم ولا الجديد؟
    bool isNewFormat = evaluation.containsKey('emotionalBalanceCriteria');

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: goldAccent.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.gavel_rounded, color: goldAccent, size: 22.sp),
              SizedBox(width: 10.w),
              Text(
                'nomination_details.evaluator.title'.tr(),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: primaryNavy,
                ),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: goldAccent,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  '${totalScore.toStringAsFixed(1)} / 100',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13.sp,
                  ),
                ),
              ),
            ],
          ),
          Divider(height: 20.h),
          _buildInfoRow(
            'nomination_details.evaluator.evaluator_name'.tr(),
            request.evaluatorName ?? '-',
          ),
          if (request.interviewDate != null)
            _buildInfoRow(
              'nomination_details.evaluator.interview_date'.tr(),
              DateFormat('yyyy-MM-dd').format(request.interviewDate!),
            ),
          if (request.interviewLocation != null)
            _buildInfoRow(
              'nomination_details.evaluator.interview_location'.tr(),
              request.interviewLocation!,
            ),
          if (request.interviewTime != null)
            _buildInfoRow(
              'nomination_details.evaluator.interview_time'.tr(),
              request.interviewTime!,
            ),

          // ✅ سحب الدرجات بأمان (يتكيف مع القديم والجديد)
          _buildScoreRow(
            'nomination_details.evaluation.scores.scientific'.tr(),
            _getScoreSafe(
              evaluation,
              'scientificScore',
              'strategicThinkingScore',
            ),
            isNewFormat ? 25 : 40,
          ),
          _buildScoreRow(
            'nomination_details.evaluation.scores.leadership'.tr(),
            _getScoreSafe(
              evaluation,
              'leadershipScore',
              'participatoryLeadershipScore',
            ),
            isNewFormat ? 20 : 25,
          ),
          _buildScoreRow(
            'nomination_details.evaluation.scores.student_activities'.tr(),
            _getScoreSafe(
              evaluation,
              'studentActivitiesScore',
              'emotionalBalanceScore',
            ),
            isNewFormat ? 20 : 15,
          ),
          _buildScoreRow(
            'nomination_details.evaluation.scores.community_activities'.tr(),
            _getScoreSafe(
              evaluation,
              'communityActivitiesScore',
              'communityInteractionScore',
            ),
            isNewFormat ? 15 : 10,
          ),
          _buildScoreRow(
            'nomination_details.evaluation.scores.human_relation'.tr(),
            _getScoreSafe(
              evaluation,
              'humanRelationsScore',
              'legalAwarenessScore',
            ),
            isNewFormat ? 20 : 10,
          ),

          Divider(height: 20.h),
          Text(
            'nomination_details.evaluator.notes'.tr(),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            // ✅ سحب الملاحظات بأمان
            request.evaluatorNotes ??
                evaluation['emotionalBalanceNotes'] ??
                'nomination_details.evaluator.no_notes'.tr(),
            style: TextStyle(fontSize: 13.sp, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  // ✅ دالة مساعدة لسحب الدرجة بأمان
  double _getScoreSafe(
    Map<String, dynamic> eval,
    String oldKey,
    String newKey,
  ) {
    if (eval.containsKey(newKey))
      return (eval[newKey] as num?)?.toDouble() ?? 0.0;
    return (eval[oldKey] as num?)?.toDouble() ?? 0.0;
  }

  Widget _buildScoreRow(String label, dynamic score, double max) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13.sp)),
          Text(
            '${(score ?? 0).toStringAsFixed(1)} / $max',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
              color: Colors.green[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13.sp,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 13.sp, color: Colors.black87),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    NominationRequestModel request,
    Color primaryNavy,
    Color goldAccent,
  ) {
    if (request.status == NominationRequestModel.statusPendingAdmin) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 50.h,
            child: ElevatedButton.icon(
              onPressed: () => _showEvaluatorSelectionDialog(request),
              icon: Icon(Icons.gavel_rounded, size: 20.sp),
              label: Text(
                'nomination_details.actions.transfer'.tr(),
              ), // تم التعديل هنا
              style: ElevatedButton.styleFrom(
                backgroundColor: goldAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            height: 50.h,
            child: OutlinedButton.icon(
              onPressed: () => _showRejectDialog(request),
              icon: Icon(Icons.cancel_outlined, color: Colors.red, size: 20.sp),
              label: Text(
                'nomination_details.actions.reject'.tr(), // تم التعديل هنا
                style: TextStyle(color: Colors.red.shade700),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.red.shade700),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),
        ],
      );
    } else if (request.status ==
            NominationRequestModel.statusFinalApprovedPendingAnnouncement ||
        request.status == NominationRequestModel.statusEvaluated) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 50.h,
            child: ElevatedButton.icon(
              onPressed: () {
                context.read<NominationRequestCubit>().adminTakeAction(
                  request: request,
                  newStatus: NominationRequestModel.statusFinalApproved,
                );
              },
              icon: Icon(Icons.verified, size: 20.sp),
              label: Text(
                'nomination_details.actions.final_approval'
                    .tr(), // تم التعديل هنا
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            height: 50.h,
            child: OutlinedButton.icon(
              onPressed: () => _showRejectDialog(request, isFinalReject: true),
              icon: Icon(Icons.cancel_outlined, color: Colors.red, size: 20.sp),
              label: Text(
                'nomination_details.actions.final_reject'
                    .tr(), // تم التعديل هنا
                style: TextStyle(color: Colors.red.shade700),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.red.shade700),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      return SizedBox.shrink();
    }
  }

  void _showEvaluatorSelectionDialog(NominationRequestModel request) {
    final cubit = context.read<NominationRequestCubit>();

    // 1. اطلب البيانات من الـ Cubit
    cubit.fetchEvaluators();

    // 2. افتح الديالوج
    showDialog(
      context: context,
      builder: (ctx) {
        // ✅ الحل: لف الـ Dialog بـ BlocProvider.value عشان الـ Dialog يقدر يسمع للـ States
        return BlocProvider.value(
          value: cubit,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.person_search_rounded,
                  color: Theme.of(context).primaryColor,
                  size: 24.sp,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    'nomination_details.actions.select_evaluator'.tr(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
              ],
            ),

            // 3. الـ UI هيستجيب للـ State بشكل سليم دلوقتي
            content:
                BlocBuilder<NominationRequestCubit, NominationRequestState>(
                  builder: (context, state) {
                    // حالة التحميل
                    if (state is EvaluatorsLoading) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(30.w),
                          child: CircularProgressIndicator(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      );
                    }

                    // حالة الخطأ
                    if (state is EvaluatorsError) {
                      return Center(
                        child: Text(
                          state.message,
                          style: TextStyle(color: Colors.red, fontSize: 13.sp),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    // حالة النجاح وجلب الداتا
                    if (state is EvaluatorsLoaded) {
                      if (state.evaluators.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.w),
                            child: Text(
                              'nomination_details.actions.no_evaluators'.tr(),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13.sp,
                              ),
                            ),
                          ),
                        );
                      }

                      return Container(
                        width: double.maxFinite,
                        height: 300.h,
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: state.evaluators.length,
                          separatorBuilder: (context, index) =>
                              Divider(height: 1, color: Colors.grey.shade200),
                          itemBuilder: (context, index) {
                            final eval = state.evaluators[index];
                            final evalId = eval['id'];
                            final evalName =
                                eval['nameAr'] ?? eval['name'] ?? 'بدون اسم';

                            return InkWell(
                              onTap: () {
                                Navigator.pop(ctx); // إغلاق الـ Dialog أولاً
                                cubit.adminTakeAction(
                                  // استدعاء دالة التحويل
                                  request: request,
                                  newStatus: NominationRequestModel
                                      .statusPendingEvaluator,
                                  evaluatorId: evalId,
                                  evaluatorName: evalName,
                                );
                              },
                              child: ListTile(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 4.h,
                                ),
                                leading: CircleAvatar(
                                  radius: 18.r,
                                  backgroundColor: Theme.of(
                                    context,
                                  ).primaryColor.withOpacity(0.1),
                                  child: Icon(
                                    Icons.person_outline,
                                    color: Theme.of(context).primaryColor,
                                    size: 20.sp,
                                  ),
                                ),
                                title: Text(
                                  evalName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14.sp,
                                    color: Colors.black87,
                                  ),
                                ),
                                trailing: Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 16.sp,
                                  color: Colors.grey,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }

                    return SizedBox.shrink();
                  },
                ),

            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  'cancel'.tr(),
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRejectDialog(
    NominationRequestModel request, {
    bool isFinalReject = false,
  }) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          isFinalReject
              ? 'nomination_details.actions.final_reject'
                    .tr() // تم التعديل هنا
              : 'nomination_details.actions.confirm_reject'
                    .tr(), // تم التعديل هنا
        ),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'nomination_details.info_card.rejection_reason'
                .tr(), // تم التعديل هنا
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'nomination_details.actions.cancel'.tr(),
            ), // تم التعديل هنا
          ),
          ElevatedButton(
            onPressed: () {
              context.read<NominationRequestCubit>().adminTakeAction(
                request: request,
                newStatus: isFinalReject
                    ? NominationRequestModel.statusFinalRejected
                    : NominationRequestModel.statusRejectedByAdmin,
                rejectionReason: controller.text.trim(),
              );
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(
              'nomination_details.actions.confirm_reject'
                  .tr(), // تم التعديل هنا
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case NominationRequestModel.statusPendingAdmin:
        return 'nomination_details.statuses.pending_admin'
            .tr(); // تم التعديل هنا
      case NominationRequestModel.statusPendingEvaluator:
        return 'nomination_details.statuses.pending_evaluator'
            .tr(); // تم التعديل هنا
      case NominationRequestModel.statusEvaluated:
        return 'nomination_details.statuses.evaluated'.tr(); // تم التعديل هنا
      case NominationRequestModel.statusFinalApproved:
        return 'nomination_details.statuses.final_approved'
            .tr(); // تم التعديل هنا
      case NominationRequestModel.statusFinalApprovedPendingAnnouncement:
        return 'nomination_details.statuses.final_approved_pending'
            .tr(); // تم التعديل هنا
      case NominationRequestModel.statusRejectedByAdmin:
        return 'nomination_details.statuses.rejected_admin'
            .tr(); // تم التعديل هنا
      case NominationRequestModel.statusFinalRejected:
        return 'nomination_details.statuses.final_rejected'
            .tr(); // تم التعديل هنا
      default:
        return status;
    }
  }
}
