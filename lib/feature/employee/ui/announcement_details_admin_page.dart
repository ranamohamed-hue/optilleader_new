import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:optialeader/feature/employee/ui/employee_nomination_page.dart';
import 'package:optialeader/core/routing/routes.dart';
import 'package:optialeader/feature/admin/data/model/announcement_model.dart';
import 'package:optialeader/feature/admin/ui/announces/mansoura_universities_data.dart';
import 'package:optialeader/feature/database_admin/data/models/employee_model.dart';
import 'package:optialeader/feature/database_admin/logic/employee_logic/employee_cubit.dart';
import 'package:optialeader/feature/database_admin/logic/employee_logic/employee_state.dart';
import 'package:optialeader/feature/database_admin/logic/leadership_scoring_engine/leadership_criteria_engine.dart';

class AnnouncementDetailsEmployeePage extends StatefulWidget {
  final String announcementId;
  const AnnouncementDetailsEmployeePage({
    super.key,
    required this.announcementId,
  });

  @override
  State<AnnouncementDetailsEmployeePage> createState() =>
      _AnnouncementDetailsEmployeePageState();
}

class _AnnouncementDetailsEmployeePageState
    extends State<AnnouncementDetailsEmployeePage> {
  bool _isCheckingEligibility = false;
  DocumentSnapshot? _announcementSnapshot;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAnnouncement();
  }

  Future<void> _fetchAnnouncement() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('announcements')
          .doc(widget.announcementId)
          .get();
      
      if (mounted) {
        setState(() {
          _announcementSnapshot = snapshot;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ═══════════════════════════════════════════════════════
  // ✅✅✅ دالة فحص الشروط للموظف (مطابقة للمحرك بالظبط) ✅✅✅
  // ═══════════════════════════════════════════════════════
  List<CriterionStatus> _checkEmployeeEligibility(EmployeeModel employee, String targetRole) {
    if (targetRole != 'admin_manager') {
      return [
        CriterionStatus(
          titleAr: 'هذا الإعلان غير متاح للموظفين الإداريين',
          titleEn: 'This announcement is not available for administrative employees',
          isMet: false,
          isAutoChecked: true,
        )
      ];
    }

    // ✅ نفس شروط _getAdminManagerCriteria الموجودة في المحرك
    final criteria = [
      CriterionStatus(
        titleAr: 'خبرة موثقة في مجال العمل الإداري بالجامعات',
        titleEn: 'Documented experience in university administrative work',
        isMet: employee.hasAdminExperience ?? false,
        isAutoChecked: false,
        details: 'يتطلب مراجعة السيرة الذاتية',
      ),
      CriterionStatus(
        titleAr: 'إجادة التعامل المحترف مع برمجيات الحاسب الآلي ونظم التحول الرقمي',
        titleEn: 'Professional proficiency in computer software',
        isMet: employee.hasICDL ?? false,
        isAutoChecked: true,
      ),
      CriterionStatus(
        titleAr: 'الحصول على مؤهل جامعي عالٍ مناسب لطبيعة الوظيفة',
        titleEn: 'Must hold an appropriate higher university degree',
        isMet: true,
        isAutoChecked: true,
        details: 'مستوفي - موظف إداري',
      ),
      CriterionStatus(
        titleAr: 'تقدير امتياز في تقارير تقييم الأداء عن آخر 4 سنوات',
        titleEn: 'Excellent rating in performance reports for the last 4 years',
        isMet: employee.hasExcellentPerformanceReports ?? false,
        isAutoChecked: true,
      ),
      CriterionStatus(
        titleAr: 'خلو السجل الوظيفي من أي جزاءات تأديبية',
        titleEn: 'Clean disciplinary record',
        isMet: employee.disciplinaryClearance,
        isAutoChecked: true,
      ),
      CriterionStatus(
        titleAr: 'دورات تدريبية متخصصة في الإدارة الحديثة وحل الأزمات والموارد البشرية',
        titleEn: 'Specialized training in modern management, crisis management, and HR',
        isMet: employee.hasAdminTraining ?? false,
        isAutoChecked: true,
        details: (employee.hasAdminTraining == true) ? 'يوجد دورات مطابقة' : 'لم يتم العثور على دورات مطابقة',
      ),
      CriterionStatus(
        titleAr: 'مشاركة إيجابية في تطوير منظومة العمل الإداري خلال آخر 3 سنوات',
        titleEn: 'Positive participation in developing the administrative system over the last 3 years',
        isMet: employee.hasParticipationProof ?? false,
        isAutoChecked: false,
        details: 'يتطلب تقديم أوراق ثبوتية للأدمن',
      ),
    ];

    return criteria.where((c) => !c.isMet).toList();
  }

  // ═══════════════════════════════════════════════════════
  // ✅✅✅ دالة الضغط على زر الترشح ✅✅✅
  // ═══════════════════════════════════════════════════════
  Future<void> _handleApply(AnnouncementModel announcement) async {
    final targetRole = announcement.targetRole;
    if (targetRole.isEmpty || targetRole == 'general') {
      _showErrorDialog("invalid_announcement_role".tr());
      return;
    }

    setState(() => _isCheckingEligibility = true);

    try {
      final state = context.read<EmployeeDataCubit>().state;
      if (state is! EmployeeLoaded) return;

      final unmetCriteria = _checkEmployeeEligibility(state.employee, targetRole);
      final isEligible = unmetCriteria.isEmpty;

      if (!mounted) return;

      if (isEligible) {
      // ✅ صح
context.push(Routes.employeeNominationPage);
      } else {
        _showIneligibleDialog(unmetCriteria);
      }
    } catch (e) {
      if (mounted) _showErrorDialog("generic_error".tr());
    } finally {
      if (mounted) setState(() => _isCheckingEligibility = false);
    }
  }

  void _showIneligibleDialog(List<CriterionStatus> unmetCriteria) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            Icon(Icons.cancel_rounded, color: Colors.red, size: 28),
            SizedBox(width: 10),
            Text("announcement_details.ineligible_title".tr()),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("announcement_details.ineligible_body".tr(), style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 15),
              ...unmetCriteria.map((c) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.close, color: Colors.red, size: 18),
                    SizedBox(width: 8),
                    Expanded(child: Text(context.locale.languageCode == 'ar' ? c.titleAr : c.titleEn)),
                  ],
                ),
              )),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text("common.ok".tr()))],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("error".tr()),
        content: Text(message),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text("common.ok".tr()))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_isLoading) {
      return Scaffold(appBar: AppBar(), body: Center(child: CircularProgressIndicator(color: colorScheme.secondary)));
    }

    if (_announcementSnapshot == null || !_announcementSnapshot!.exists) {
      return Scaffold(
        appBar: AppBar(title: Text('announcement_details.title'.tr())),
        body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.error_outline, size: 60.sp, color: Colors.grey), SizedBox(height: 10.h), Text('announcement_details.not_found'.tr())])),
      );
    }

    final data = _announcementSnapshot!.data() as Map<String, dynamic>;
    final announcement = AnnouncementModel.fromMap(data, widget.announcementId);

    final String currentLang = context.locale.languageCode;
    final String title = data['title_$currentLang'] ?? data['title'] ?? 'announcement_details.no_title'.tr();
    final String description = data['description_$currentLang'] ?? data['description'] ?? 'announcement_details.no_description'.tr();
    final String? imageUrl = data['imageUrl'];

    String formattedDeadline = '';
    if (data['deadline'] != null) formattedDeadline = DateFormat('EEEE, d MMMM yyyy', currentLang).format((data['deadline'] as Timestamp).toDate());

    String postedDate = '';
    if (data['createdAt'] != null) postedDate = DateFormat('d MMM yyyy', currentLang).format((data['createdAt'] as Timestamp).toDate());

    return Scaffold(
      backgroundColor: theme.primaryColor,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isCheckingEligibility ? null : () => _handleApply(announcement),
        elevation: 4,
        backgroundColor: colorScheme.secondary,
        icon: _isCheckingEligibility ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: colorScheme.primary, strokeWidth: 2)) : Icon(Icons.send_rounded, color: colorScheme.primary),
        label: Text("announce.details.apply_button".tr(), style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 14.sp)),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: imageUrl != null ? 159.0.h : 80.0.h,
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: colorScheme.primary,
            elevation: 0,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(35))),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (imageUrl != null) CachedNetworkImage(imageUrl: imageUrl, fit: BoxFit.cover, placeholder: (context, url) => Container(color: Colors.black12), errorWidget: (context, url, error) => Container(color: colorScheme.primary.withOpacity(0.1), child: Icon(Icons.broken_image_outlined, color: colorScheme.primary, size: 40.sp))),
                  Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withOpacity(imageUrl != null ? 0.3 : 0.0), colorScheme.primary.withOpacity(imageUrl != null ? 0.8 : 1.0)]))),
                  Padding(
                    padding: EdgeInsets.fromLTRB(15.w, 45.h, 20.w, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconButton(icon: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 22.sp), onPressed: () => context.pop()),
                        SizedBox(width: 5.w),
                        Expanded(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text("announce.details.badge_title_user".tr(), style: theme.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5)), Text("common.app_name".tr(), style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.secondary.withOpacity(0.9)))])),
                        Container(padding: const EdgeInsets.all(2.5), decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: colorScheme.secondary, width: 2)), child: CircleAvatar(radius: 26.r, backgroundColor: Colors.white24, child: Icon(Icons.campaign_rounded, color: Colors.white, size: 24.sp))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.all(20.w),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildDetailCard(context, announcement: announcement, title: title, description: description, deadline: formattedDeadline, postedDate: postedDate),
                SizedBox(height: 100.h),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(BuildContext context, {required AnnouncementModel announcement, required String title, required String description, required String deadline, required String postedDate}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool showSector = announcement.targetRole == 'vice_president' || announcement.targetRole == 'vice_dean';
    final bool showCollege = MansouraUniversitiesData.targetRoleRequiresFaculty(announcement.targetRole);
    final bool showDepartment = MansouraUniversitiesData.targetRoleRequiresDepartment(announcement.targetRole);
    final bool showAdminDept = announcement.targetRole == 'admin_manager';

    return Container(
      decoration: BoxDecoration(color: colorScheme.surface, borderRadius: BorderRadius.circular(28.r), boxShadow: [BoxShadow(color: colorScheme.shadow.withOpacity(0.05), blurRadius: 25, offset: const Offset(0, 12))]),
      child: Stack(
        children: [
          Positioned(right: context.locale.languageCode == 'ar' ? null : -15, left: context.locale.languageCode == 'ar' ? -15 : null, top: -15, child: Icon(Icons.campaign_rounded, size: 130.sp, color: colorScheme.secondary.withOpacity(0.04))),
          Padding(
            padding: EdgeInsets.all(25.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h), decoration: BoxDecoration(color: colorScheme.secondary.withOpacity(0.12), borderRadius: BorderRadius.circular(14.r)), child: Text("announce.details.opportunity_badge".tr().toUpperCase(), style: TextStyle(color: colorScheme.secondary, fontWeight: FontWeight.bold, fontSize: 11.sp))),
                SizedBox(height: 25.h),
                Text(title, style: theme.textTheme.headlineSmall?.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.bold, height: 1.3)),
                SizedBox(height: 18.h),
                Text(description, style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant.withOpacity(0.8), height: 1.7, fontSize: 15.sp)),
                Padding(padding: EdgeInsets.symmetric(vertical: 30.h), child: Divider(thickness: 0.8, color: colorScheme.outlineVariant)),
                _buildInfoRow(context, Icons.military_tech, "announce.details.target_role".tr(), announcement.targetRole.tr(), colorScheme.secondary),
                SizedBox(height: 20.h),
                if (showSector && announcement.targetSector != null) ...[ _buildInfoRow(context, Icons.account_tree_outlined, "edit_announcement.field_sector".tr(), "sectors.${announcement.targetSector}".tr(), Colors.deepOrange), SizedBox(height: 20.h) ],
                if (deadline.isNotEmpty) _buildInfoRow(context, Icons.timer_outlined, "announce.details.deadline_label".tr(), deadline, Colors.redAccent),
                if (deadline.isNotEmpty) SizedBox(height: 20.h),
                if (postedDate.isNotEmpty) _buildInfoRow(context, Icons.calendar_today_rounded, "announce.details.posted_label".tr(), postedDate, Colors.blueGrey),
                if (postedDate.isNotEmpty) SizedBox(height: 20.h),
                if (showCollege && announcement.collegeName != null) ...[ _buildInfoRow(context, Icons.domain, "announce.details.college".tr(), announcement.collegeName!, Colors.deepPurple), SizedBox(height: 20.h) ],
                if (showDepartment && announcement.departmentName != null) ...[ _buildInfoRow(context, Icons.meeting_room, "announce.details.department".tr(), announcement.departmentName!, Colors.teal), SizedBox(height: 20.h) ],
                if (showAdminDept && announcement.adminSectorName != null) ...[ _buildInfoRow(context, Icons.account_balance, "announce.details.admin_sector".tr(), announcement.adminSectorName!, Colors.indigo), SizedBox(height: 20.h) ],
                if (showAdminDept && announcement.adminSubDeptName != null) _buildInfoRow(context, Icons.corporate_fare, "announce.details.admin_sub_dept".tr(), announcement.adminSubDeptName!, Colors.amber.shade800),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value, Color color) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(padding: EdgeInsets.all(10.w), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12.r)), child: Icon(icon, size: 20.sp, color: color)),
        SizedBox(width: 15.w),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12.sp)), Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp, color: colorScheme.onSurface))]))
      ],
    );
  }
}