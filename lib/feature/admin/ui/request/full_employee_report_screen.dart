import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:optialeader/feature/admin/data/model/nomination_score_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:optialeader/feature/admin/data/model/nomination_request_model.dart';
import 'package:optialeader/feature/admin/logic/nomination_request_logic/nomination_request_cubit.dart';
import 'package:optialeader/feature/admin/logic/nomination_request_logic/nomonation_request_state.dart';
import 'package:optialeader/feature/database_admin/data/models/judge_profile_model.dart';

// ✅ Imports الضرورية التي كانت مفقودة
import 'package:optialeader/feature/database_admin/data/models/doctor_profile_model.dart';
import 'package:optialeader/feature/database_admin/logic/leadership_scoring_engine/leadership_scoring_engine.dart';

class FullEmployeeReportScreen extends StatefulWidget {
  final NominationRequestModel request;
  const FullEmployeeReportScreen({super.key, required this.request});

  @override
  State<FullEmployeeReportScreen> createState() =>
      _FullEmployeeReportScreenState();
}

class _FullEmployeeReportScreenState extends State<FullEmployeeReportScreen> {
  String? _selectedJudgeId;
  List<JudgeProfileModel> _judgesList = [];

  Future<void> _recalculateScores() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('report.messages.repeat_calculate'.tr()),
        duration: Duration(seconds: 2),
      ),
    );

    try {
      String? doctorId = widget.request.doctorId;

      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(doctorId)
          .get();

      if (!docSnapshot.exists) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('خطأ: بيانات الدكتور غير موجودة')),
          );
        }
        return;
      }

      final doctor = DoctorProfileModel.fromJson(
        docSnapshot.data()!,
        docSnapshot.id,
      );

      // ✅ بناء موديل الدرجات الجديد
      final NominationScoreModel scores =
          LeadershipScoringEngine.buildScoreModel(doctor);

      // ✅ تحديث الطلب في قاعدة البيانات باستخدام الحقل الجديد scores
      await FirebaseFirestore.instance
          .collection('nomination_requests')
          .doc(widget.request.id)
          .update({'scores': scores.toMap()});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('report.messages.update_success'.tr()),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      print(e.toString());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${'report.messages.error_calculate'.tr()} $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryNavy = theme.primaryColor;
    final goldAccent = theme.colorScheme.secondary;
    bool isEvaluated =
        widget.request.status == NominationRequestModel.statusEvaluated ||
        widget.request.status ==
            NominationRequestModel.statusFinalApprovedPendingAnnouncement;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: primaryNavy,
        elevation: 0,
        title: Text(
          'report.title'.tr(),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 20.sp),
          onPressed: () => context.pop(),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(2.h),
          child: Container(color: goldAccent, height: 2.h),
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
          padding: EdgeInsets.all(20.w),
          child: Column(
            children: [
              _buildEmployeeHeader(context, goldAccent, primaryNavy),
              SizedBox(height: 25.h),
              _buildSystemPointsCard(context, primaryNavy, goldAccent),
              SizedBox(height: 25.h),
              if (widget.request.declarationFileUrl != null)
                _buildDeclarationSection(context, primaryNavy),
              SizedBox(height: 25.h),
              if (isEvaluated)
                _buildEvaluatorReportAndFinalDecision(
                  context,
                  primaryNavy,
                  goldAccent,
                )
              else if (widget.request.status ==
                  NominationRequestModel.statusPendingAdmin)
                _buildActionSection(context, primaryNavy, goldAccent),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmployeeHeader(BuildContext context, Color gold, Color navy) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: navy.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: gold.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35.r,
            backgroundColor: navy,
            backgroundImage: widget.request.doctorImageUrl != null
                ? NetworkImage(widget.request.doctorImageUrl!)
                : null,
            child: widget.request.doctorImageUrl == null
                ? Icon(Icons.person, color: gold, size: 30.sp)
                : null,
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.request.doctorName,
                  style: TextStyle(
                    color: navy,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                  ),
                ),
                Text(
                  "${'report.header.role_label'.tr()} ${widget.request.targetRole.tr()}",
                  style: TextStyle(color: Colors.grey[600], fontSize: 12.sp),
                ),
                if (widget.request.collegeName != null)
                  Text(
                    "${widget.request.collegeName} - ${widget.request.departmentName ?? ''}",
                    style: TextStyle(color: Colors.grey[500], fontSize: 11.sp),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemPointsCard(BuildContext context, Color navy, Color gold) {
    final scores = widget.request.scores;
    final List<dynamic> itemsDetails = scores?.itemsDetails ?? [];
    final totalPoints = scores?.achievementsTotal ?? 0.0;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'report.system_points.title'.tr(),
                style: TextStyle(
                  color: navy,
                  fontWeight: FontWeight.bold,
                  fontSize: 15.sp,
                ),
              ),
              if (itemsDetails.isEmpty)
                InkWell(
                  onTap: _recalculateScores,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.refresh,
                          size: 12.sp,
                          color: Colors.orange.shade900,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          "report.messages.repeat_calculate".tr(),
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.orange.shade900,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          Divider(height: 20.h),

          // ✅ عرض الكروت التفصيلية للأبحاث والأنشطة
          if (itemsDetails.isNotEmpty) ...[
            ...itemsDetails.map(
              (detail) => _buildTransparencyCard(detail, navy, gold),
            ),
            SizedBox(height: 15.h),
          ] else ...[
            Center(
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Text(
                  'report.categories.no_degree'.tr(),
                  style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],

          Divider(height: 25.h),
          // المجموع الكلي
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'report.system_points.total'.tr(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                  color: navy,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: gold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  "${totalPoints.toStringAsFixed(1)} ${'report.system_points.point_unit'.tr()}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                    color: gold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ✅ ويدجت جديد لعرض كارت تفصيلي لكل نشاط/بحث
  Widget _buildTransparencyCard(
    Map<String, dynamic> detail,
    Color navy,
    Color gold,
  ) {
    // استخراج البيانات مع وضع قيم افتراضية آمنة
    final String title = detail['title'] ?? 'بدون عنوان';
    final String type = detail['type'] ?? '-';
    final String category = detail['category'] ?? '-';
    final String scope = detail['scope'] ?? '-';
    final String status = detail['status'] ?? '-';
    final double points = (detail['points'] is double)
        ? (detail['points'] as double)
        : 0.0;

    // لون الحالة (معتمد أو مرفوض)
    Color statusColor = status == 'approved' ? Colors.green : Colors.grey;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الصف الأول: العنوان والدرجة
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.description_outlined, size: 16.sp, color: navy),
              SizedBox(width: 8.w),
              // العنوان ياخد المساحة المتبقية
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.sp,
                    color: Colors.black87,
                  ),
                  // عشان لو العنوان طويل يتعدل السطر
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 10.w),
              // عرض الدرجة بوضوح
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: gold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  "${points.toStringAsFixed(1)}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                    color: gold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),

          // الصف الثاني: التاجز (Tags) للتفاصيل
          Wrap(
            spacing: 8.w,
            runSpacing: 6.h,
            children: [
              _buildInfoChip('report.categories.type'.tr(), type, navy),
              _buildInfoChip(
                'report.categories.category'.tr(),
                category,
                Colors.blueGrey,
              ),
              _buildInfoChip(
                'report.categories.scope'.tr(),
                scope,
                Colors.purple,
              ),
              _buildInfoChip(
                'report.categories.status'.tr(),
                status,
                statusColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ✅ ويدجت مساعد لعمل شريط صغير (Chip) للتفاصيل
  Widget _buildInfoChip(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "$label: ",
            style: TextStyle(fontSize: 10.sp, color: Colors.grey[600]),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 10.sp,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeclarationSection(BuildContext context, Color navy) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: TextButton.icon(
        onPressed: () async {
          final url = Uri.parse(widget.request.declarationFileUrl!);
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          } else if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('report.declaration.open_link_msg'.tr())),
            );
          }
        },
        icon: Icon(
          Icons.picture_as_pdf,
          color: Colors.blue.shade700,
          size: 24.sp,
        ),
        label: Text(
          'report.declaration.view_file'.tr(),
          style: TextStyle(
            color: Colors.blue.shade700,
            fontWeight: FontWeight.bold,
            fontSize: 14.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildActionSection(BuildContext context, Color navy, Color gold) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'report.actions.transfer_title'.tr(),
            style: TextStyle(
              color: navy,
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 12.h),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .where('role', isEqualTo: 'judge')
                .where('is_active', isEqualTo: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'report.categories.judge_error'.tr(),
                    style: TextStyle(color: Colors.red, fontSize: 12.sp),
                    textAlign: TextAlign.center,
                  ),
                );
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Text(
                    'report.categories.no_judge'.tr(),
                    style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                  ),
                );
              }

              _judgesList = snapshot.data!.docs
                  .map(
                    (doc) => JudgeProfileModel.fromJson(
                      doc.data() as Map<String, dynamic>,
                      doc.id,
                    ),
                  )
                  .toList();

              // ✅ تم تصحيح الخطأ (initialValue -> value)
              return DropdownButtonFormField<String>(
                value: _selectedJudgeId,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[50],
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: gold),
                  ),
                ),
                hint: Text(
                  'report.actions.choose_judge'.tr(),
                  style: TextStyle(fontSize: 14.sp),
                ),
                items: _judgesList
                    .map(
                      (judge) => DropdownMenuItem<String>(
                        value: judge.uid,
                        child: Text(
                          judge.nameAr,
                          style: TextStyle(fontSize: 14.sp),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (id) => setState(() => _selectedJudgeId = id),
              );
            },
          ),
          SizedBox(height: 30.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showRejectionDialog(
                    context,
                    NominationRequestModel.statusRejectedByAdmin,
                  ),
                  icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                  label: Text(
                    'report.actions.reject'.tr(),
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 13.sp,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (_selectedJudgeId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('report.actions.judge_required'.tr()),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }
                    String evaluatorName =
                        'report.evaluation_report.not_specified'.tr();
                    for (var judge in _judgesList) {
                      if (judge.uid == _selectedJudgeId) {
                        evaluatorName = judge.nameAr;
                        break;
                      }
                    }
                    context.read<NominationRequestCubit>().adminTakeAction(
                      request: widget.request,
                      newStatus: NominationRequestModel.statusPendingEvaluator,
                      evaluatorId: _selectedJudgeId!,
                      evaluatorName: evaluatorName,
                    );
                  },
                  icon: Icon(Icons.swap_horiz, color: navy, size: 20.sp),
                  label: Text(
                    'report.actions.transfer'.tr(),
                    style: TextStyle(
                      color: navy,
                      fontWeight: FontWeight.bold,
                      fontSize: 13.sp,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gold,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEvaluatorReportAndFinalDecision(
    BuildContext context,
    Color navy,
    Color gold,
  ) {
    final request = widget.request;
    final evaluation = request.interviewEvaluation ?? {};

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.rate_review_rounded,
                color: Colors.orange.shade800,
                size: 22.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                "report.evaluation_report.title".tr(),
                style: TextStyle(
                  color: Colors.orange.shade900,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                ),
              ),
            ],
          ),
          Divider(height: 20.h, color: Colors.orange.shade200),
          _buildReportRow(
            context,
            Icons.person_outline,
            'report.evaluation_report.evaluator_name'.tr(),
            request.evaluatorName ??
                'report.evaluation_report.not_specified'.tr(),
          ),
          SizedBox(height: 12.h),
          // ✅ تم تصحيح المسافات الزائدة والنقط
          _buildReportRow(
            context,
            Icons.calendar_month,
            'report.evaluation_report.interview_date'.tr(),
            request.interviewDate != null
                ? "${request.interviewDate!.day}/${request.interviewDate!.month}/${request.interviewDate!.year}"
                : 'report.evaluation_report.not_set'.tr(),
          ),
          SizedBox(height: 12.h),
          // ✅ تم تصحيح المسافات والترجمة
          _buildReportRow(
            context,
            Icons.score_rounded,
            'report.evaluation_report.score'.tr(),
            "${request.evaluatorPoints ?? 0} ${'report.system_points.point_unit'.tr()}",
          ),
          SizedBox(height: 20.h),

          // ✅ تم تصحيح مسارات الترجمة لتتشابه مع الـ JSON الجديد
          _buildScoreDetailRow(
            'report.evaluation.scores.scientific'.tr(),
            evaluation['scientificScore'],
            40,
          ),
          _buildScoreDetailRow(
            'report.evaluation.scores.leadership'.tr(),
            evaluation['leadershipScore'],
            25,
          ),
          _buildScoreDetailRow(
            'report.evaluation.scores.student_activities'.tr(),
            evaluation['studentActivitiesScore'],
            15,
          ),
          _buildScoreDetailRow(
            'report.evaluation.scores.community_activities'.tr(),
            evaluation['communityActivitiesScore'],
            10,
          ),
          _buildScoreDetailRow(
            'report.evaluation.scores.human_relation'.tr(),
            evaluation['humanRelationsScore'],
            10,
          ),

          SizedBox(height: 20.h),
          // ✅ تم تصحيح المسافات وإضافة .tr()
          Text(
            'report.evaluation_report.notes_label'.tr(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: navy,
              fontSize: 13.sp,
            ),
          ),
          SizedBox(height: 5.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: Colors.orange.shade100),
            ),
            child: Text(
              request.evaluatorNotes ??
                  'report.evaluation_report.no_notes'.tr(),
              style: TextStyle(fontSize: 13.sp, color: Colors.grey[800]),
            ),
          ),
          SizedBox(height: 30.h),
          // ✅ تم تصحيح المسافات وإضافة .tr()
          Text(
            'report.evaluation_report.final_decision'.tr(),
            style: TextStyle(
              color: navy,
              fontWeight: FontWeight.bold,
              fontSize: 15.sp,
            ),
          ),
          SizedBox(height: 15.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showRejectionDialog(
                    context,
                    NominationRequestModel.statusFinalRejected,
                  ),
                  icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                  label: Text(
                    'report.evaluation_report.final_reject'.tr(),
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                ),
              ),
              SizedBox(width: 15.w),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () =>
                      context.read<NominationRequestCubit>().adminTakeAction(
                        request: widget.request,
                        newStatus: NominationRequestModel
                            .statusFinalApprovedPendingAnnouncement,
                      ),
                  icon: const Icon(Icons.verified_rounded, color: Colors.white),
                  // ✅ تم تصحيح المسافة الزائدة
                  label: Text(
                    'report.evaluation_report.final_approve'.tr(),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreDetailRow(String label, dynamic score, double max) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12.sp, color: Colors.grey[700]),
          ),
          Text(
            '${(score ?? 0.0).toStringAsFixed(1)} / $max',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: Colors.green[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(icon, size: 18.sp, color: Colors.orange.shade800),
        SizedBox(width: 8.w),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13.sp,
            color: Colors.grey[700],
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13.sp,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  void _showRejectionDialog(BuildContext context, String rejectionStatus) {
    final TextEditingController reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        // ✅ تم إضافة .tr()
        title: Text(
          'report.reject_dialog.title'.tr(),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: reasonController,
          // ✅ تم إضافة .tr()
          decoration: InputDecoration(
            hintText: 'report.reject_dialog.hint'.tr(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('report.reject_dialog.cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<NominationRequestCubit>().adminTakeAction(
                request: widget.request,
                newStatus: rejectionStatus,
                rejectionReason: reasonController.text.trim(),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(
              'report.reject_dialog.confirm'.tr(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
