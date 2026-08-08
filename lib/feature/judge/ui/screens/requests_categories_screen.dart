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

class RequestsCategoriesScreen extends StatefulWidget {
  final String? filterStatus;

  const RequestsCategoriesScreen({super.key, required this.filterStatus});

  @override
  State<RequestsCategoriesScreen> createState() => _RequestsCategoriesScreenState();
}

class _RequestsCategoriesScreenState extends State<RequestsCategoriesScreen> {
  final List<Map<String, dynamic>> _categories = [
    {'key': 'university_president', 'icon': Icons.school},
    {'key': 'vice_university_president', 'icon': Icons.workspace_premium},
    {'key': 'dean', 'icon': Icons.account_balance},
    {'key': 'vice_dean', 'icon': Icons.business_center},
    {'key': 'head_dept', 'icon': Icons.class_},  
    {'key': 'quality_manager', 'icon': Icons.verified},
    {'key': 'admin_manager', 'icon': Icons.admin_panel_settings},
  ];

  String? _selectedRoleKey;

  /// نحدد إذا كانت الحالة الحالية تسمح بالتقييم ولا للعرض فقط
  bool get _isEvaluationPhase => widget.filterStatus == NominationRequestModel.statusPendingEvaluator;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final navy = theme.primaryColor;
    final gold = theme.colorScheme.secondary;

    return Scaffold(
      // ✅ لون الخلفية الأساسي
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: navy,
        title: Text(
          _selectedRoleKey != null 
              ? 'dashboardJudge.categories.$_selectedRoleKey'.tr() 
              : _getAppBarTitle(),
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20.sp),
          onPressed: () {
            if (_selectedRoleKey != null) {
              setState(() => _selectedRoleKey = null);
            } else {
              context.pop();
            }
          }, 
        ),
      ),
      body: BlocBuilder<NominationRequestCubit, NominationRequestState>(
        builder: (context, state) {
          if (state is NominationRequestLoading) {
            return Center(child: CircularProgressIndicator(color: gold));
          }

          if (state is NominationRequestError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wifi_off, size: 50.sp, color: Colors.grey),
                  SizedBox(height: 15.h),
                  // ✅ تمت الترجمة
                  Text(
                    'judge_categories.error_message'.tr(), 
                    style: TextStyle(fontSize: 15.sp, color: Colors.grey[700]),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20.h),
                  ElevatedButton(
                    onPressed: () => context.read<NominationRequestCubit>().fetchEvaluatorRequests(FirebaseAuth.instance.currentUser?.uid ?? ''),
                    style: ElevatedButton.styleFrom(backgroundColor: navy, foregroundColor: Colors.white),
                    // ✅ تمت الترجمة
                    child: Text('judge_categories.retry'.tr()),
                  ),
                ],
              ),
            );
          }

          List<NominationRequestModel> baseRequests = [];
          if (state is NominationRequestLoaded) {
            baseRequests = state.requests.where((r) => r.status == widget.filterStatus).toList();
          }

          // ✅✅✅ حالة اختيار كارت معين (عرض الطلبات الخاصة بيه) ✅✅✅
          if (_selectedRoleKey != null) {
            final filteredRequests = baseRequests.where((r) => r.targetRole == _selectedRoleKey).toList();

            return Column(
              children: [
                // كارت اسم الإعلان / الوظيفة في الأعلى (أبيض)
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
                  padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14.r),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: Offset(0, 3)),
                    ],
                    border: Border.all(color: gold.withOpacity(0.3), width: 1),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(color: gold.withOpacity(0.1), borderRadius: BorderRadius.circular(10.r)),
                        child: Icon(Icons.campaign_outlined, color: gold, size: 20.sp),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          'dashboardJudge.categories.$_selectedRoleKey'.tr(),
                          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: navy),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(color: navy.withOpacity(0.05), borderRadius: BorderRadius.circular(8.r)),
                        child: Text(
                          "$filteredRequests.length ${'dashboard.main_cards.request'.tr()}",
                          style: TextStyle(fontSize: 11.sp, color: Colors.grey[600], fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),

                // ✅ قائمة الطلبات (بلون الخلفية المميز)
                if (filteredRequests.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox_outlined, size: 60.sp, color: Colors.grey[300]),
                          SizedBox(height: 10.h),
                          Text('judge_orders.no_requests'.tr(), style: TextStyle(color: Colors.grey[500])),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    // ✅✅✅ هنا لون خلفية القائمة ✅✅✅
                    child: Container(
                      color: navy.withOpacity(0.04), // خلفية كحلي فاتحة جداً للقائمة
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
                        itemCount: filteredRequests.length,
                        itemBuilder: (context, index) {
                          return _buildRequestCard(context, filteredRequests[index], navy, gold);
                        },
                      ),
                    ),
                  ),
              ],
            );
          }

          // ✅✅✅ الحالة الأساسية (عرض شبكة الكروت) ✅✅✅
          return Padding(
            padding: EdgeInsets.all(20.w),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15.w,
                mainAxisSpacing: 15.h,
                childAspectRatio: 0.95, 
              ),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final roleKey = category['key'] as String;
                final icon = category['icon'] as IconData;
                int count = baseRequests.where((r) => r.targetRole == roleKey).length;

                return _buildCategoryCard(context, roleKey, icon, count, navy, gold);
              },
            ),
          );
        },
      ),
    );
  }

  // =====================================================================
  // كارت التصنيف (الوظيفة)
  // =====================================================================
  Widget _buildCategoryCard(BuildContext context, String roleKey, IconData icon, int count, Color navy, Color gold) {
    return InkWell(
      onTap: () => setState(() => _selectedRoleKey = roleKey),
      borderRadius: BorderRadius.circular(18.r),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
          border: Border.all(color: navy.withOpacity(0.05)),
        ),
        child: Padding(
          padding: EdgeInsets.all(15.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(color: gold.withOpacity(0.1), borderRadius: BorderRadius.circular(12.r)),
                child: Icon(icon, color: gold, size: 22.sp),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'dashboardJudge.categories.$roleKey'.tr(),
                    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: navy),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    "$count ${'dashboard.main_cards.request'.tr()}",
                    style: TextStyle(fontSize: 11.sp, color: Colors.grey[600], fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =====================================================================
  // كارت الطلب
  // =====================================================================
  Widget _buildRequestCard(BuildContext context, NominationRequestModel request, Color navy, Color gold) {
    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
      decoration: BoxDecoration(
        color: Colors.white, // ✅ الكارت أبيض عشان يظهر فوق الخلفية الكحلي
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))],
        border: Border.all(color: navy.withOpacity(0.05), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 65.w,
            height: 65.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: navy.withOpacity(0.05),
              border: Border.all(color: gold.withOpacity(0.3), width: 2),
            ),
            child: ClipOval(
              child: request.doctorImageUrl != null && request.doctorImageUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: request.doctorImageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Icon(Icons.person_outline, size: 30.sp, color: navy.withOpacity(0.5)),
                      errorWidget: (_, __, ___) => Icon(Icons.person_outline, size: 30.sp, color: navy),
                    )
                  : Icon(Icons.person_outline, size: 30.sp, color: navy),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  request.doctorName,
                  style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: Colors.black87),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 5.h),
                Text(
                  request.targetRole.tr(),
                  style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          
          // ✅ تمت ترجمة الأزرار
          if (_isEvaluationPhase)
            ElevatedButton.icon(
              onPressed: () => context.push(Routes.judgeEvaluation, extra: request),
              icon: Icon(Icons.edit_note_rounded, size: 16.sp, color: Colors.white),
              label: Text('judge_orders.evaluate'.tr(), style: TextStyle(fontSize: 11.sp)),
              style: ElevatedButton.styleFrom(
                backgroundColor: gold,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                elevation: 0,
              ),
            )
          else
            ElevatedButton.icon(
              onPressed: () => context.push('/judge/evaluationScreen', extra: request),
              icon: Icon(Icons.visibility, size: 16.sp, color: Colors.white),
              label: Text('judge_orders.view'.tr(), style: TextStyle(fontSize: 11.sp)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade600,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                elevation: 0,
              ),
            ),
        ],
      ),
    );
  }

  String _getAppBarTitle() {
    if (widget.filterStatus == NominationRequestModel.statusPendingEvaluator) {
      return 'dashboard.main_cards.new'.tr();
    }
    if (widget.filterStatus == NominationRequestModel.statusEvaluated) {
      return 'dashboard.main_cards.reviewing'.tr();
    }
    if (widget.filterStatus == NominationRequestModel.statusFinalApproved) {
      return 'dashboard.main_cards.evaluated'.tr();
    }
    return 'dashboardJudge.categories.title'.tr();
  }
}