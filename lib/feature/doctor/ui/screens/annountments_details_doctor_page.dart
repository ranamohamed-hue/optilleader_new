import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:optialeader/core/routing/routes.dart';
import 'package:optialeader/feature/admin/data/model/announcement_model.dart';
import 'package:optialeader/feature/database_admin/logic/doctor_data/doctor_data_cubit.dart';
import 'package:optialeader/feature/database_admin/logic/leadership_scoring_engine/leadership_criteria_engine.dart';
import 'package:optialeader/feature/admin/ui/announces/mansoura_universities_data.dart';

class AnnouncementDetailsDoctorPage extends StatefulWidget {
  final String announcementId;

  const AnnouncementDetailsDoctorPage({
    super.key,
    required this.announcementId,
  });

  @override
  State<AnnouncementDetailsDoctorPage> createState() =>
      _AnnouncementDetailsDoctorPageState();
}

class _AnnouncementDetailsDoctorPageState
    extends State<AnnouncementDetailsDoctorPage> {
  bool _isCheckingEligibility = false;

  // ✅ تخزين بيانات الإعلان مرة واحدة
  DocumentSnapshot? _announcementSnapshot;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAnnouncement();
  }

  // ============================================================
  // جلب الإعلان
  // ============================================================

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
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // التقديم
  // ============================================================

  Future<void> _handleApply(AnnouncementModel announcement) async {
    final targetRole = announcement.targetRole;

    if (targetRole.isEmpty || targetRole == 'general') {
      _showErrorDialog("invalid_announcement_role".tr());
      return;
    }

    setState(() {
      _isCheckingEligibility = true;
    });

    try {
      final cubit = context.read<DoctorDataCubit>();

      final (isEligible, unmetCriteria) = await cubit.checkEligibility(
        targetRole: targetRole,
      );

      if (!mounted) return;

      if (isEligible) {
        context.push(
          Routes.doctorNominationRequest,
          extra: {'announcement': announcement},
        );
      } else {
        _showIneligibleDialog(unmetCriteria);
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog("generic_error".tr());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingEligibility = false;
        });
      }
    }
  }

  // ============================================================
  // Dialog الشروط غير المستوفاة
  // ============================================================

  void _showIneligibleDialog(List<CriterionStatus> unmetCriteria) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            const Icon(Icons.cancel_rounded, color: Colors.red, size: 28),
            const SizedBox(width: 10),
            Expanded(child: Text("announcement_details.ineligible_title".tr())),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "announcement_details.ineligible_body".tr(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              ...unmetCriteria.map(
                (c) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.close, color: Colors.red, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          context.locale.languageCode == 'ar'
                              ? c.titleAr
                              : c.titleEn,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("common.ok".tr()),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Dialog الخطأ
  // ============================================================

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("error".tr()),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
            },
            child: Text("common.ok".tr()),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Build
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // ==========================================================
    // Loading
    // ==========================================================

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: CircularProgressIndicator(color: colorScheme.secondary),
        ),
      );
    }

    // ==========================================================
    // الإعلان غير موجود
    // ==========================================================

    if (_announcementSnapshot == null || !_announcementSnapshot!.exists) {
      return Scaffold(
        appBar: AppBar(title: Text('announcement_details.title'.tr())),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 60.sp, color: Colors.grey),
              SizedBox(height: 10.h),
              Text('announcement_details.not_found'.tr()),
            ],
          ),
        ),
      );
    }

    // ==========================================================
    // بيانات الإعلان
    // ==========================================================

    final data = _announcementSnapshot!.data() as Map<String, dynamic>;

    final announcement = AnnouncementModel.fromMap(data, widget.announcementId);

    final String currentLang = context.locale.languageCode;

    final String title =
        data['title_$currentLang'] ??
        data['title'] ??
        'announcement_details.no_title'.tr();

    final String description =
        data['description_$currentLang'] ??
        data['description'] ??
        'announcement_details.no_description'.tr();

    final String? imageUrl = data['imageUrl'];

    final Timestamp? deadlineTimestamp = data['deadline'];

    final Timestamp? createdAtTimestamp = data['createdAt'];

    String formattedDeadline = '';

    if (deadlineTimestamp != null) {
      formattedDeadline = DateFormat(
        'EEEE, d MMMM yyyy',
        currentLang,
      ).format(deadlineTimestamp.toDate());
    }

    String postedDate = '';

    if (createdAtTimestamp != null) {
      postedDate = DateFormat(
        'd MMM yyyy',
        currentLang,
      ).format(createdAtTimestamp.toDate());
    }

    return Scaffold(
      backgroundColor: theme.primaryColor,

      // ========================================================
      // زر التقديم
      // ========================================================
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isCheckingEligibility
            ? null
            : () => _handleApply(announcement),
        elevation: 4,
        backgroundColor: colorScheme.secondary,
        icon: _isCheckingEligibility
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: colorScheme.primary,
                  strokeWidth: 2,
                ),
              )
            : Icon(Icons.send_rounded, color: colorScheme.primary),
        label: Text(
          "announce.details.apply_button".tr(),
          style: TextStyle(
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 14.sp,
          ),
        ),
      ),

      // ========================================================
      // Body
      // ========================================================
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ======================================================
          // AppBar
          // ======================================================
          SliverAppBar(
            expandedHeight: imageUrl != null ? 159.0.h : 80.0.h,
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: colorScheme.primary,
            elevation: 0,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(35)),
            ),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (imageUrl != null)
                    CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) {
                        return Container(color: Colors.black12);
                      },
                      errorWidget: (context, url, error) {
                        return Container(
                          color: colorScheme.primary.withOpacity(0.1),
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: colorScheme.primary,
                            size: 40.sp,
                          ),
                        );
                      },
                    ),

                  // =================================================
                  // Gradient
                  // =================================================
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(
                            imageUrl != null ? 0.3 : 0.0,
                          ),
                          colorScheme.primary.withOpacity(
                            imageUrl != null ? 0.8 : 1.0,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // =================================================
                  // Header
                  // =================================================
                  Padding(
                    padding: EdgeInsets.fromLTRB(15.w, 45.h, 20.w, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                            size: 22.sp,
                          ),
                          onPressed: () {
                            context.pop();
                          },
                        ),
                        SizedBox(width: 5.w),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "announce.details.badge_title_user".tr(),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              Text(
                                "common.app_name".tr(),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.secondary.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(2.5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colorScheme.secondary,
                              width: 2,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 26.r,
                            backgroundColor: Colors.white24,
                            child: Icon(
                              Icons.campaign_rounded,
                              color: Colors.white,
                              size: 24.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ========================================================
          // Details
          // ========================================================
          SliverPadding(
            padding: EdgeInsets.all(20.w),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildDetailCard(
                  context,
                  announcement: announcement,
                  title: title,
                  description: description,
                  deadline: formattedDeadline,
                  postedDate: postedDate,
                ),
                SizedBox(height: 100.h),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Detail Card
  // ============================================================

  Widget _buildDetailCard(
    BuildContext context, {
    required AnnouncementModel announcement,
    required String title,
    required String description,
    required String deadline,
    required String postedDate,
  }) {
    final theme = Theme.of(context);

    final colorScheme = theme.colorScheme;

    final bool showSector =
        announcement.targetRole == 'vice_president' ||
        announcement.targetRole == 'vice_dean';

    final bool showCollege = MansouraUniversitiesData.targetRoleRequiresFaculty(
      announcement.targetRole,
    );

    final bool showDepartment =
        MansouraUniversitiesData.targetRoleRequiresDepartment(
          announcement.targetRole,
        );

    final bool showAdminDept = announcement.targetRole == 'admin_manager';

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(28.r),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: context.locale.languageCode == 'ar' ? null : -15,
            left: context.locale.languageCode == 'ar' ? -15 : null,
            top: -15,
            child: Icon(
              Icons.campaign_rounded,
              size: 130.sp,
              color: colorScheme.secondary.withOpacity(0.04),
            ),
          ),

          Padding(
            padding: EdgeInsets.all(25.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==================================================
                // Badge
                // ==================================================
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.secondary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Text(
                    "announce.details.opportunity_badge".tr().toUpperCase(),
                    style: TextStyle(
                      color: colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 11.sp,
                    ),
                  ),
                ),

                SizedBox(height: 25.h),

                // ==================================================
                // Title
                // ==================================================
                Text(
                  title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),

                SizedBox(height: 18.h),

                // ==================================================
                // Description
                // ==================================================
                Text(
                  description,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant.withOpacity(0.8),
                    height: 1.7,
                    fontSize: 15.sp,
                  ),
                ),

                Padding(
                  padding: EdgeInsets.symmetric(vertical: 30.h),
                  child: Divider(
                    thickness: 0.8,
                    color: colorScheme.outlineVariant,
                  ),
                ),

                // ==================================================
                // Target Role
                // ==================================================
                _buildInfoRow(
                  context,
                  Icons.military_tech,
                  "announce.details.target_role".tr(),
                  announcement.targetRole.tr(),
                  colorScheme.secondary,
                ),

                SizedBox(height: 20.h),

                // ==================================================
                // Sector
                // ==================================================
                if (showSector && announcement.targetSector != null) ...[
                  _buildInfoRow(
                    context,
                    Icons.account_tree_outlined,
                    "edit_announcement.field_sector".tr(),
                    "sectors.${announcement.targetSector}".tr(),
                    Colors.deepOrange,
                  ),
                  SizedBox(height: 20.h),
                ],

                // ==================================================
                // Deadline
                // ==================================================
                if (deadline.isNotEmpty)
                  _buildInfoRow(
                    context,
                    Icons.timer_outlined,
                    "announce.details.deadline_label".tr(),
                    deadline,
                    Colors.redAccent,
                  ),

                if (deadline.isNotEmpty) SizedBox(height: 20.h),

                // ==================================================
                // Posted Date
                // ==================================================
                if (postedDate.isNotEmpty)
                  _buildInfoRow(
                    context,
                    Icons.calendar_today_rounded,
                    "announce.details.posted_label".tr(),
                    postedDate,
                    Colors.blueGrey,
                  ),

                if (postedDate.isNotEmpty) SizedBox(height: 20.h),

                // ==================================================
                // College
                // ==================================================
                if (showCollege && announcement.collegeName != null) ...[
                  _buildInfoRow(
                    context,
                    Icons.domain,
                    "announce.details.college".tr(),
                    announcement.collegeName!,
                    Colors.deepPurple,
                  ),
                  SizedBox(height: 20.h),
                ],

                // ==================================================
                // Department
                // ==================================================
                if (showDepartment && announcement.departmentName != null) ...[
                  _buildInfoRow(
                    context,
                    Icons.meeting_room,
                    "announce.details.department".tr(),
                    announcement.departmentName!,
                    Colors.teal,
                  ),
                  SizedBox(height: 20.h),
                ],

                // ==================================================
                // Admin Sector
                // ==================================================
                if (showAdminDept && announcement.adminSectorName != null) ...[
                  _buildInfoRow(
                    context,
                    Icons.account_balance,
                    "announce.details.admin_sector".tr(),
                    announcement.adminSectorName!,
                    Colors.indigo,
                  ),
                  SizedBox(height: 20.h),
                ],

                // ==================================================
                // Admin Sub Department
                // ==================================================
                if (showAdminDept && announcement.adminSubDeptName != null) ...[
                  _buildInfoRow(
                    context,
                    Icons.corporate_fare,
                    "announce.details.admin_sub_dept".tr(),
                    announcement.adminSubDeptName!,
                    Colors.amber.shade800,
                  ),
                ],

                // ==================================================
                // مستندات طلب الترشح
                // ==================================================
                SizedBox(height: 30.h),

                Divider(thickness: 0.8, color: colorScheme.outlineVariant),

                SizedBox(height: 25.h),

                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: colorScheme.secondary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: colorScheme.secondary.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ==================================================
                      // عنوان المستندات
                      // ==================================================
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: colorScheme.secondary,
                            size: 22.sp,
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              'announcement_details.application_documents_title'
                                  .tr(),
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 12.h),

                      // ==================================================
                      // الشهادة الصحية
                      // ==================================================
                      _buildRequiredDocumentRow(
                        context,
                        Icons.health_and_safety_outlined,
                        'announcement_details.health_certificate'.tr(),
                      ),

                      SizedBox(height: 10.h),

                      // ==================================================
                      // خطة التطوير
                      // ==================================================
                      _buildRequiredDocumentRow(
                        context,
                        Icons.description_outlined,
                        'announcement_details.development_plan'.tr(),
                      ),

                      SizedBox(height: 10.h),

                      // ==================================================
                      // مستندات أخرى
                      // ==================================================
                      _buildRequiredDocumentRow(
                        context,
                        Icons.folder_copy_outlined,
                        'announcement_details.other_documents'.tr(),
                      ),

                      SizedBox(height: 12.h),

                      Text(
                        'announcement_details.documents_uploaded_in_application'
                            .tr(),
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 11.sp,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Required Document Row
  // ============================================================

  Widget _buildRequiredDocumentRow(
    BuildContext context,
    IconData icon,
    String title,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(
          Icons.check_circle_outline,
          color: colorScheme.secondary,
          size: 19.sp,
        ),

        SizedBox(width: 8.w),

        Icon(icon, color: colorScheme.primary, size: 19.sp),

        SizedBox(width: 8.w),

        Expanded(
          child: Text(
            title,
            style: TextStyle(color: colorScheme.onSurface, fontSize: 13.sp),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // Info Row
  // ============================================================

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(icon, size: 20.sp, color: color),
        ),

        SizedBox(width: 15.w),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12.sp,
                ),
              ),

              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
