import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:optialeader/feature/admin/data/model/nomination_request_model.dart';
import 'package:optialeader/feature/admin/logic/nomination_request_logic/nomination_request_cubit.dart';
import 'package:optialeader/feature/admin/logic/nomination_request_logic/nomonation_request_state.dart';
import 'package:optialeader/core/routing/routes.dart';

class OrdersListScreen extends StatefulWidget {
  const OrdersListScreen({super.key});

  @override
  State<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<OrdersListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    //  1. تغيير الطول من 3 لـ 4 عشان نضيف تبويب "قيد التحكيم"
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);
    context.read<NominationRequestCubit>().fetchAdminRequests(
      status: NominationRequestModel.statusPendingAdmin,
    );
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    
    String status;
    switch (_tabController.index) {
      case 0:
        status = NominationRequestModel.statusPendingAdmin;
        break;
      // ✅ 2. إضافة حالة الطلبات اللي عند المحكمين
      case 1:
        status = NominationRequestModel.statusPendingEvaluator;
        break;
      case 2:
        status = NominationRequestModel.statusEvaluated;
        break;
      case 3:
        status = NominationRequestModel.statusFinalApproved;
        break;
      default:
        status = NominationRequestModel.statusPendingAdmin;
    }
    context.read<NominationRequestCubit>().fetchAdminRequests(status: status);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryNavy = theme.primaryColor;
    final goldAccent = theme.colorScheme.secondary;
    final bgLight = theme.scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: primaryNavy,
        elevation: 10,
        title: Text(
          'orders.title'.tr(),
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 20.sp, color: Colors.white),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(Routes.admin);
            }
          },
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(80.h),
          child: Column(
            children: [
              Container(color: goldAccent, height: 4.h),
              Container(
                color: primaryNavy,
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true, // ✅ 3. تخلي التبويبات قادرة تعمل Scroll لو الشاشة ضيقة
                  indicatorColor: goldAccent,
                  indicatorWeight: 3.0,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white54,
                  labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp),
                  unselectedLabelStyle: TextStyle(fontSize: 12.sp),
                  tabs: [
                    Tab(text: 'orders.tabs.new_requests'.tr(), icon: const Icon(Icons.fiber_new_rounded, size: 18)),
                    // ✅ 4. إضافة التبويب الجديد للمحكمين
                    Tab(text: 'orders.tabs.pending_evaluator'.tr(), icon: const Icon(Icons.hourglass_top_rounded, size: 18)),
                    Tab(text: 'orders.tabs.evaluated'.tr(), icon: const Icon(Icons.rate_review_rounded, size: 18)),
                    Tab(text: 'orders.tabs.approved'.tr(), icon: const Icon(Icons.verified_rounded, size: 18)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: BlocBuilder<NominationRequestCubit, NominationRequestState>(
        builder: (context, state) {
          if (state is NominationRequestLoading) {
            return Center(child: CircularProgressIndicator(color: goldAccent));
          }

          if (state is NominationRequestError) {
            return Center(child: Text(state.message.tr(), style: const TextStyle(color: Colors.red)));
          }

          if (state is NominationRequestLoaded) {
            final requests = state.requests;

            if (requests.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox_outlined, size: 60.sp, color: Colors.grey[300]),
                    SizedBox(height: 10.h),
                    Text('orders.no_requests'.tr(), style: TextStyle(color: Colors.grey[500])),
                  ],
                ),
              );
            }

            return Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 5.h)),
                    ],
                  ),
                  child: TextField(
                    style: theme.textTheme.bodyMedium,
                    decoration: InputDecoration(
                      hintText: 'orders.search_hint'.tr(),
                      prefixIcon: Icon(Icons.search, color: primaryNavy, size: 22.sp),
                      filled: true,
                      fillColor: bgLight.withOpacity(0.4),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.r),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(15.w),
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      final request = requests[index];
                      return _buildOrderItem(context, request: request);
                    },
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildOrderItem(BuildContext context, {required NominationRequestModel request}) {
    final theme = Theme.of(context);
    final goldAccent = theme.colorScheme.secondary;
    final primaryNavy = theme.primaryColor;

    final dateStr = "${request.createdAt.day}/${request.createdAt.month}/${request.createdAt.year}";

    Color statusColor;
    String statusKey; 
    switch (request.status) {
      case NominationRequestModel.statusPendingAdmin:
        statusColor = Colors.blue;
        statusKey = 'orders.status.new'; 
        break;
      case NominationRequestModel.statusPendingEvaluator:
        statusColor = Colors.purple;
        statusKey = 'orders.status.pending_evaluator'; 
        break;
      case NominationRequestModel.statusEvaluated:
        statusColor = Colors.orange.shade700;
        statusKey = 'orders.status.evaluated'; 
        break;
      case NominationRequestModel.statusFinalApproved:
        statusColor = Colors.green.shade700;
        statusKey = 'orders.status.approved_final'; 
        break;
      // ✅ 5. إضافة حالة "بانتظار الإعلان" عشان الـ Admin يفرق بينهم
      case NominationRequestModel.statusFinalApprovedPendingAnnouncement:
        statusColor = Colors.teal;
        statusKey = 'orders.status.approved_pending_announcement'; 
        break;
      case NominationRequestModel.statusRejectedByAdmin:
      case NominationRequestModel.statusFinalRejected:
        statusColor = Colors.red;
        statusKey = 'orders.status.rejected'; 
        break;
      default:
        statusColor = Colors.grey;
        statusKey = 'orders.status.review'; 
    }

    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: goldAccent.withOpacity(0.1)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(15.w),
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.1),
          backgroundImage: request.doctorImageUrl != null ? NetworkImage(request.doctorImageUrl!) : null,
          child: request.doctorImageUrl == null 
            ? Icon(Icons.person_outline, color: statusColor, size: 20.sp) 
            : null,
        ),
        title: Text(
          request.doctorName,
          style: TextStyle(color: primaryNavy, fontWeight: FontWeight.bold, fontSize: 15.sp),
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 5.h),
          // ✅ 6. استبدال النص العربي الثابت بـ Key للترجمة باستخدام namedArgs
          child: Text(
            "orders.nomination_for_role".tr(namedArgs: {'role': request.targetRole.tr(), 'date': dateStr}), 
            style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])
          ),
        ),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: statusColor.withOpacity(0.5)),
          ),
          child: Text(
            statusKey.tr(), 
            style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11.sp),
          ),
        ),
        onTap: () {
          context.push(Routes.nominationRequestDetails, extra: request);
        },
      ),
    );
  }
}