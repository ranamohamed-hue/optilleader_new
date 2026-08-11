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
  Color get _primaryNavy => Theme.of(context).colorScheme.primary;
  Color get _goldAccent => Theme.of(context).colorScheme.secondary;

  @override
  void initState() {
    super.initState();
    final String uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isNotEmpty) {
      context.read<NominationRequestCubit>().fetchEvaluatorRequests(uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    String pageTitle = 'judge_orders.title'.tr();
    if (widget.filterRole != null) {
      pageTitle = 'dashboardJudge.categories.${widget.filterRole}'.tr();
    }
    if (widget.filterStatus != null) {
      pageTitle += ' (${_getStatusName()})';
    }

    return Scaffold(
      // ✅ خلفية متكيفة بدل اللون الثابت الشفاف
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: _primaryNavy,
        title: Text(
          pageTitle,
          style: TextStyle(
            // ✅ onPrimary بدل Colors.white
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            // ✅ onPrimary بدل Colors.white
            color: colorScheme.onPrimary,
            size: 20.sp,
          ),
          onPressed: () => context.pop(),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(2.h),
          child: Container(color: _goldAccent, height: 2.h),
        ),
      ),
      body: BlocBuilder<NominationRequestCubit, NominationRequestState>(
        builder: (context, state) {
          if (state is NominationRequestLoading) {
            return Center(child: CircularProgressIndicator(color: _goldAccent));
          }
          if (state is NominationRequestError) {
            return Center(
              child: Text(
                state.message.tr(),
                style: TextStyle(color: colorScheme.error),
              ),
            );
          }

          if (state is NominationRequestLoaded) {
            List<NominationRequestModel> requests = state.requests;

            if (widget.filterStatus != null) {
              requests = requests
                  .where((r) => r.status == widget.filterStatus)
                  .toList();
            }

            if (widget.filterRole != null) {
              requests = requests
                  .where((r) => r.targetRole == widget.filterRole)
                  .toList();
            }

            if (requests.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 60.sp,
                      // ✅ لون متكيف بدل grey[300]
                      color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'judge_orders.no_requests'.tr(),
                      // ✅ onSurfaceVariant بدل grey[500]
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                return _buildRequestCard(context, requests[index]);
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
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
final isArabic = context.locale.languageCode == 'ar';

    final bool isEvaluated =
        request.status == NominationRequestModel.statusEvaluated ||
        request.status == NominationRequestModel.statusFinalApproved ||
        request.status == NominationRequestModel.statusFinalRejected;

    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
      decoration: BoxDecoration(
        // ✅ surface بدل Colors.white
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            // ✅ ظل متكيف
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        // ✅ حدود خفيفة في الثيم الداكن عشان الكروت تتفرق عن الخلفية
        border: isDark
            ? Border.all(color: colorScheme.outlineVariant.withOpacity(0.3), width: 1)
            : Border.all(color: _primaryNavy.withOpacity(0.05), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 70.w,
            height: 70.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // ✅ لون الخلفية متكيف
              color: _primaryNavy.withOpacity(isDark ? 0.2 : 0.05),
              border: Border.all(color: _goldAccent.withOpacity(0.3), width: 2),
            ),
            child: ClipOval(
              child: request.doctorImageUrl != null &&
                      request.doctorImageUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: request.doctorImageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Icon(
                        Icons.person_outline,
                        size: 35.sp,
                        color: _primaryNavy.withOpacity(0.5),
                      ),
                      errorWidget: (_, __, ___) => Icon(
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
                    // ✅ onSurface بدل Colors.black87
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 6.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: _goldAccent.withOpacity(isDark ? 0 : 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    request.targetRole.tr(),
                    style: TextStyle(
                      fontSize: 11.sp,
                      color:isDark?Colors.white:const Color.fromARGB(255, 8, 8, 8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),

          if (isEvaluated)
            Padding(
              padding: EdgeInsets.only(
                right: isArabic ? 20.w : 0,
                left: isArabic ? 0 : 20.w,
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  context.push('/judge/evaluationScreen', extra: request);
                },
                // ✅ شلنا color: Colors.white عشان foregroundColor يشتغل صح
                icon: Icon(Icons.visibility, size: 18.sp),
                // ✅ إصلاح علامة الاستفهام وإضافة بديل الإنجليزي
                label: Text(
                  isArabic ? 'عرض' : 'View',
                  style: TextStyle(fontSize: 12.sp),
                ),
              style: ElevatedButton.styleFrom(
                // ✅ لون واضح للزر في الداكن
                backgroundColor: isDark 
                    ? colorScheme.surfaceContainerHighest 
                    : Colors.grey.shade600,
                foregroundColor: isDark 
                    ? colorScheme.onSurface 
                    : Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 0,
              )),
            )
          else
            ElevatedButton.icon(
              onPressed: () =>
                  context.push(Routes.judgeEvaluation, extra: request),
              icon: Icon(
                Icons.edit_note_rounded,
                size: 18.sp,
                color: Colors.white,
              ),
              label: Text(
                'judge_orders.evaluate'.tr(),
                style: TextStyle(fontSize: 12.sp),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _goldAccent,
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