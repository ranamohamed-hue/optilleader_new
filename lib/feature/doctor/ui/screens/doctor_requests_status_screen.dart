import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:optialeader/feature/database_admin/data/models/doctor_profile_model.dart';
import 'package:optialeader/feature/doctor/data/model/verefication_status.dart';

class DoctorRequestsStatusScreen extends StatefulWidget {
  final DoctorProfileModel doctor;

  const DoctorRequestsStatusScreen({super.key, required this.doctor});

  @override
  State<DoctorRequestsStatusScreen> createState() => _DoctorRequestsStatusScreenState();
}

class _DoctorRequestsStatusScreenState extends State<DoctorRequestsStatusScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getItemsByStatus(VerificationStatus status) {
    List<Map<String, dynamic>> items = [];

    for (var p in widget.doctor.researchPapers.where((p) => p.status == status)) {
      items.add({
        'type': 'dashboard_user.status.paper'.tr(),
        'title': p.titleAr.isNotEmpty ? p.titleAr : p.titleEn,
        'icon': Icons.description_outlined,
      });
    }

    for (var c in widget.doctor.conferences.where((c) => c.status == status)) {
      items.add({
        'type': 'dashboard_user.status.conference'.tr(),
        'title': c.title,
        'icon': Icons.groups_outlined,
      });
    }

    for (var e in widget.doctor.exhibitions.where((e) => e.status == status)) {
      items.add({
        'type': 'dashboard_user.status.exhibition'.tr(),
        'title': e.title,
        'icon': Icons.brush_outlined,
      });
    }

    for (var c in widget.doctor.courses.where((c) => c.status == status)) {
      items.add({
        'type': 'dashboard_user.status.course'.tr(),
        'title': c.title,
        'icon': Icons.school_outlined,
      });
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final pendingItems = _getItemsByStatus(VerificationStatus.pending);
    final approvedItems = _getItemsByStatus(VerificationStatus.approved);
    final rejectedItems = _getItemsByStatus(VerificationStatus.rejected);

    // ✅ تحديد الألوان لكل حالة
    final Color pendingColor = Colors.orange.shade700;
    final Color approvedColor = Colors.green.shade700;
    final Color rejectedColor = Colors.red.shade700;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        title: Text(
          'dashboard_user.requests_status'.tr(),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: colorScheme.secondary,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: [
            Tab(text: 'dashboard_user.status.pending_tab'.tr(args: [pendingItems.length.toString()])),
            Tab(text: 'dashboard_user.status.approved_tab'.tr(args: [approvedItems.length.toString()])),
            Tab(text: 'dashboard_user.status.rejected_tab'.tr(args: [rejectedItems.length.toString()])),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildList(pendingItems, pendingColor, 'dashboard_user.status.pending_msg'.tr()),
          _buildList(approvedItems, approvedColor, 'dashboard_user.status.approved_msg'.tr()),
          _buildList(rejectedItems, rejectedColor, 'dashboard_user.status.rejected_msg'.tr()),
        ],
      ),
    );
  }

  Widget _buildList(List<Map<String, dynamic>> items, Color statusColor, String emptyMsg) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 60.sp, color: statusColor.withOpacity(0.3)),
            SizedBox(height: 10.h),
            Text(
              emptyMsg,
              style: TextStyle(color: Colors.grey[500], fontSize: 14.sp),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            // ✅ بوردر بلون الحالة
            border: Border.all(color: statusColor.withOpacity(0.3), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: statusColor.withOpacity(0.05), 
                blurRadius: 10, 
                offset: Offset(0, 4)
              ),
            ],
          ),
          child: Row(
            children: [
              // ✅ أيقونة بلون الحالة
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  item['icon'] as IconData, 
                  color: statusColor, 
                  size: 24.sp
                ),
              ),
              SizedBox(width: 15.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ نوع النشاط بلون الحالة
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        item['type'] as String,
                        style: TextStyle(
                          fontSize: 10.sp, 
                          color: statusColor, 
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      item['title'] as String,
                      style: TextStyle(
                        fontSize: 14.sp, 
                        fontWeight: FontWeight.w600, 
                        color: Colors.black87
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // ✅ أيقونة حالة في الآخر (نجاح، ساعة انتظار، إلغاء)
              Icon(
                statusColor == Colors.green.shade700 
                    ? Icons.check_circle 
                    : statusColor == Colors.orange.shade700 
                        ? Icons.hourglass_top 
                        : Icons.cancel,
                color: statusColor,
                size: 26.sp,
              ),
            ],
          ),
        );
      },
    );
  }
}