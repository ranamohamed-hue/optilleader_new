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
    {'key': 'dean', 'icon': Icons.account_balance},
    {'key': 'vice_dean', 'icon': Icons.business_center},
    {'key': 'head_dept', 'icon': Icons.class_},  
    {'key': 'quality_manager', 'icon': Icons.verified},
    {'key': 'admin_manager', 'icon': Icons.admin_panel_settings},
    {'key': 'other', 'icon': Icons.category},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final navy = theme.primaryColor;
    final gold = theme.colorScheme.secondary;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: navy,
        title: Text(
          _getAppBarTitle(),
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
      body: BlocBuilder<NominationRequestCubit, NominationRequestState>(
        builder: (context, state) {
          // ✅ تحسين: إضافة حالة التحميل
          if (state is NominationRequestLoading) {
            return Center(child: CircularProgressIndicator(color: gold));
          }

          // ✅ تحسين: إضافة حالة الخطأ
          if (state is NominationRequestError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wifi_off, size: 50.sp, color: Colors.grey),
                  SizedBox(height: 15.h),
                  Text(
                    'حدث خطأ في تحميل البيانات',
                    style: TextStyle(fontSize: 15.sp, color: Colors.grey[700]),
                  ),
                  SizedBox(height: 20.h),
                  ElevatedButton(
                    onPressed: () {
                      context.read<NominationRequestCubit>().fetchEvaluatorRequests(
                            FirebaseAuth.instance.currentUser?.uid ?? '',
                          );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: navy,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          List<NominationRequestModel> allRequests = [];
          if (state is NominationRequestLoaded) {
            allRequests = state.requests
                .where((r) => r.status == widget.filterStatus)
                .toList();
          }

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

                int count = 0;
                if (roleKey == 'other') {
                  final knownKeys = _categories
                      .map((c) => c['key'] as String)
                      .where((k) => k != 'other')
                      .toList();
                  count = allRequests
                      .where((r) => !knownKeys.contains(r.targetRole))
                      .length;
                } else {
                  count = allRequests
                      .where((r) => r.targetRole == roleKey)
                      .length;
                }

                return _buildCategoryCard(context, roleKey, icon, count);
              },
            ),
          );
        },
      ),
    );
  }

  String _getAppBarTitle() {
    // ✅ تم الرجوع للحالات الصحيحة الموجودة في الموديل
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

  Widget _buildCategoryCard(
    BuildContext context,
    String roleKey,
    IconData icon,
    int count,
  ) {
    final navy = Theme.of(context).primaryColor;
    final gold = Theme.of(context).colorScheme.secondary;

    return InkWell(
      onTap: () {
        context.push(
          Routes.ordersList, 
          extra: {'status': widget.filterStatus, 'role': roleKey},
        );
      },
      borderRadius: BorderRadius.circular(18.r),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10),
          ],
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
                decoration: BoxDecoration(
                  color: gold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, color: gold, size: 22.sp),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'dashboardJudge.categories.$roleKey'.tr(),
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: navy,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    "$count ${'dashboard.main_cards.request'.tr()}",
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
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
}