import 'package:cached_network_image/cached_network_image.dart'; 
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:optialeader/core/routing/routes.dart'; 
import 'package:optialeader/feature/admin/data/model/nomination_request_model.dart';
import 'package:optialeader/feature/admin/logic/nomination_request_logic/nomination_request_cubit.dart';
import 'package:optialeader/feature/admin/logic/nomination_request_logic/nomonation_request_state.dart';

class JudgeOrdersListScreen extends StatefulWidget {
  final String? filterStatus;
  final String? filterRole;

  const JudgeOrdersListScreen({super.key, this.filterStatus, this.filterRole});

  @override
  State<JudgeOrdersListScreen> createState() => _JudgeOrdersListScreenState();
}

class _JudgeOrdersListScreenState extends State<JudgeOrdersListScreen> {
  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isNotEmpty) {
      context.read<NominationRequestCubit>().fetchEvaluatorRequests(uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryNavy = theme.primaryColor;
    final goldAccent = theme.colorScheme.secondary;

    String pageTitle = 'judge_orders.title'.tr();
    if (widget.filterRole != null) {
      pageTitle = 'dashboardJudge.categories.${widget.filterRole}'.tr();
    }
    if (widget.filterStatus != null) {
      pageTitle += ' (${_getStatusName()})';
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: primaryNavy,
        title: Text(
          pageTitle,
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
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(2.h),
          child: Container(color: goldAccent, height: 2.h),
        ),
      ),
      body: BlocBuilder<NominationRequestCubit, NominationRequestState>(
        builder: (context, state) {
          if (state is NominationRequestLoading) {
            return Center(child: CircularProgressIndicator(color: goldAccent));
          }
          if (state is NominationRequestError) {
            return Center(child: Text(state.message.tr()));
          }

          if (state is NominationRequestLoaded) {
            List<NominationRequestModel> requests = state.requests;

            if (widget.filterStatus != null) {
              requests = requests
                  .where((r) => r.status == widget.filterStatus)
                  .toList();
            }

            if (widget.filterRole != null) {
              if (widget.filterRole == 'other') {
                final knownKeys = [
                  'dean',
                  'vice_dean',
                  'head_dept',
                  'quality_manager',
                  'admin_manager',
                ];
                requests = requests
                    .where((r) => !knownKeys.contains(r.targetRole))
                    .toList();
              } else {
                requests = requests
                    .where((r) => r.targetRole == widget.filterRole)
                    .toList();
              }
            }

            if (requests.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 60.sp,
                      color: Colors.grey[300],
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'judge_orders.no_requests'.tr(),
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final request = requests[index];
                return _buildRequestCard(
                  context,
                  request,
                  primaryNavy,
                  goldAccent,
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
    NominationRequestModel request,
    Color primaryColor,
    Color accentColor,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
        border: Border.all(color: primaryColor.withOpacity(0.05), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 70.w,
            height: 70.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryColor.withOpacity(0.05),
              border: Border.all(color: accentColor.withOpacity(0.3), width: 2),
            ),
            child: ClipOval(
              child: request.doctorImageUrl != null &&
                      request.doctorImageUrl!.isNotEmpty
                  ? CachedNetworkImage( // ✅ 3. استبدال Image.network بـ CachedNetworkImage
                      imageUrl: request.doctorImageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Icon(
                        Icons.person_outline,
                        size: 35.sp,
                        color: primaryColor.withOpacity(0.5),
                      ),
                      errorWidget: (_, __, ___) => Icon(
                        Icons.person_outline,
                        size: 35.sp,
                        color: primaryColor,
                      ),
                    )
                  : Icon(
                      Icons.person_outline,
                      size: 35.sp,
                      color: primaryColor,
                    ),
            ),
          ),
          SizedBox(width: 15.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  request.doctorName,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        request.targetRole.tr(),
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(width: 10.w),
          ElevatedButton.icon(
                        onPressed: () => context.push(
              Routes.judgeEvaluation, // ✅ حط اسم المسار الصحيح بتاعك هنا
              extra: request,
            ),
            icon: Icon(
              Icons.edit_note_rounded,
              size: 18.sp,
              color: Colors.white,
            ),
            label: Text('judge_orders.evaluate'.tr()),
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusName() {
    if (widget.filterStatus == NominationRequestModel.statusPendingEvaluator) {
      return 'dashboard.main_cards.new'.tr();
    }
    if (widget.filterStatus == NominationRequestModel.statusEvaluated) {
      return 'dashboard.main_cards.reviewing'.tr();
    }
    if (widget.filterStatus == NominationRequestModel.statusFinalApproved) {
      return 'dashboard.main_cards.evaluated'.tr();
    }
    return '';
  }
}