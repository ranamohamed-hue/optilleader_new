import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:optialeader/core/routing/routes.dart';
import 'package:optialeader/feature/admin/data/model/announcement_model.dart';
import 'package:optialeader/feature/admin/data/model/nomination_request_model.dart';
import 'package:optialeader/feature/admin/logic/nomination_request_logic/nomination_request_cubit.dart';
import 'package:optialeader/feature/admin/logic/nomination_request_logic/nomonation_request_state.dart';

class RequestsCategoriesScreen extends StatefulWidget {
  final String? filterStatus;

  const RequestsCategoriesScreen({super.key, required this.filterStatus});

  @override
  State<RequestsCategoriesScreen> createState() =>
      _RequestsCategoriesScreenState();
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

  // ✅ متغيرات التحكم في المستويات الثلاثة
  String? _selectedRoleKey;
  String? _selectedAnnouncementId;

  // ✅ خريطة خفيفة: announcementId → AnnouncementModel (لعرض العنوان فقط)
  Map<String, AnnouncementModel> _announcementsData = {};

  bool get _isEvaluationPhase =>
      widget.filterStatus == NominationRequestModel.statusPendingEvaluator;

  @override
  void initState() {
    super.initState();
    _fetchAnnouncementsTitles();
  }

  /// ✅ جلب بيانات الإعلانات النشطة (خفيف - فقط للعناوين)
  Future<void> _fetchAnnouncementsTitles() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('announcements')
          .where('status', isEqualTo: 'Active')
          .get();

      if (!mounted) return;

      final Map<String, AnnouncementModel> data = {};
      for (var doc in snapshot.docs) {
        data[doc.id] = AnnouncementModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }
      setState(() => _announcementsData = data);
    } catch (e) {
      debugPrint('⚠️ خطأ في جلب الإعلانات: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final navy = colorScheme.primary;
    final gold = colorScheme.secondary;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: navy,
        foregroundColor: colorScheme.onPrimary,
        centerTitle: true,
        title: Text(
          _getAppBarTitle(),
          style: TextStyle(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: colorScheme.onPrimary,
            size: 20.sp,
          ),
          onPressed: () {
            if (_selectedAnnouncementId != null) {
              setState(() => _selectedAnnouncementId = null);
            } else if (_selectedRoleKey != null) {
              setState(() => _selectedRoleKey = null);
            } else {
              context.pop();
            }
          },
        ),
      ),
      body: BlocBuilder<NominationRequestCubit, NominationRequestState>(
        builder: (context, state) {
          // ── حالة التحميل ──
          if (state is NominationRequestLoading) {
            return Center(child: CircularProgressIndicator(color: gold));
          }

          // ── حالة الخطأ ──
          if (state is NominationRequestError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wifi_off, size: 50.sp, color: colorScheme.outline),
                  SizedBox(height: 15.h),
                  Text(
                    'judge_categories.error_message'.tr(),
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20.h),
                  ElevatedButton(
                    onPressed: () => context
                        .read<NominationRequestCubit>()
                        .fetchEvaluatorRequests(
                          FirebaseAuth.instance.currentUser?.uid ?? '',
                        ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: navy,
                      foregroundColor: colorScheme.onPrimary,
                    ),
                    child: Text('judge_categories.retry'.tr()),
                  ),
                ],
              ),
            );
          }

          // ── فلترة الطلبات حسب الحالة ──
          List<NominationRequestModel> baseRequests = [];
          if (state is NominationRequestLoaded) {
            baseRequests = state.requests
                .where((r) => r.status == widget.filterStatus)
                .toList();
          }

          // ═══════════════════════════════════════════════════════════
          // 🟢 المستوى الثالث: عرض المتقدمين لإعلان معين
          // ═══════════════════════════════════════════════════════════
          if (_selectedRoleKey != null && _selectedAnnouncementId != null) {
            final announcement = _announcementsData[_selectedAnnouncementId];
            final applicants = baseRequests
                .where(
                  (r) =>
                      r.targetRole == _selectedRoleKey &&
                      r.announcementId == _selectedAnnouncementId,
                )
                .toList();

            return Column(
              children: [
                // كارت ملخص الإعلان
                _buildAnnouncementSummaryCard(
                  announcement: announcement,
                  fallbackCollegeName: applicants.isNotEmpty
                      ? (applicants.first.collegeName ??
                          'dashboardJudge.unknown_college'.tr())
                      : '',
                  fallbackDeptName: applicants.isNotEmpty
                      ? applicants.first.departmentName
                      : null,
                  applicantsCount: applicants.length,
                  navy: navy,
                  gold: gold,
                  isDark: isDark,
                ),

                // قائمة المتقدمين
                if (applicants.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 60.sp,
                            color: colorScheme.outline,
                          ),
                          SizedBox(height: 15.h),
                          Text(
                            'judge_orders.no_requests'.tr(),
                            style:
                                TextStyle(color: colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: Container(
                      color: navy.withOpacity(isDark ? 0.03 : 0.02),
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 15.h,
                        ),
                        itemCount: applicants.length,
                        itemBuilder: (context, index) =>
                            _buildRequestCard(
                          context: context,
                          request: applicants[index],
                          navy: navy,
                          gold: gold,
                          isDark: isDark,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          }

          // ═══════════════════════════════════════════════════════════
          // 🟡 المستوى الثاني: عرض الإعلانات الخاصة بالوظيفة المختارة
          // ═══════════════════════════════════════════════════════════
          if (_selectedRoleKey != null) {
            final roleRequests = baseRequests
                .where((r) => r.targetRole == _selectedRoleKey)
                .toList();

            // ✅ تجميع الطلبات حسب announcementId
            final Map<String, List<NominationRequestModel>> grouped = {};
            for (var req in roleRequests) {
              grouped.putIfAbsent(req.announcementId, () => []).add(req);
            }

            if (grouped.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.campaign_outlined,
                      size: 60.sp,
                      color: colorScheme.outline,
                    ),
                    SizedBox(height: 15.h),
                    Text(
                      'judge_orders.no_requests'.tr(),
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              itemCount: grouped.length,
              itemBuilder: (context, index) {
                final annId = grouped.keys.elementAt(index);
                final annRequests = grouped[annId]!;
                final firstReq = annRequests.first;
                final announcement = _announcementsData[annId];

                return _buildAnnouncementCard(
                  context: context,
                  announcementId: annId,
                  announcement: announcement,
                  fallbackCollegeName:
                      firstReq.collegeName ?? 'dashboardJudge.unknown_college'.tr(),
                  fallbackDeptName: firstReq.departmentName,
                  applicantsCount: annRequests.length,
                  navy: navy,
                  gold: gold,
                  isDark: isDark,
                );
              },
            );
          }

          // ═══════════════════════════════════════════════════════════
          // 🔵 المستوى الأول: شبكة الوظائف (الافتراضي)
          // ═══════════════════════════════════════════════════════════
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
                final count = baseRequests
                    .where((r) => r.targetRole == roleKey)
                    .length;

                return _buildCategoryCard(
                  context: context,
                  roleKey: roleKey,
                  icon: icon,
                  count: count,
                  navy: navy,
                  gold: gold,
                  isDark: isDark,
                );
              },
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // 🔵 كارت الوظيفة (المستوى الأول)
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildCategoryCard({
    required BuildContext context,
    required String roleKey,
    required IconData icon,
    required int count,
    required Color navy,
    required Color gold,
    required bool isDark,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => setState(() {
        _selectedRoleKey = roleKey;
        _selectedAnnouncementId = null;
      }),
      borderRadius: BorderRadius.circular(18.r),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.black.withOpacity(0.04),
              blurRadius: 10,
            ),
          ],
          border: Border.all(
            color: navy.withOpacity(isDark ? 0.2 : 0.05),
          ),
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
                  color: gold.withOpacity(isDark ? 0.2 : 0.1),
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
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    "$count ${'dashboard.main_cards.request'.tr()}",
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: colorScheme.onSurfaceVariant,
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

  // ═══════════════════════════════════════════════════════════════════
  // 🟡 كارت الإعلان (المستوى الثاني)
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildAnnouncementCard({
    required BuildContext context,
    required String announcementId,
    required AnnouncementModel? announcement,
    required String fallbackCollegeName,
    required String? fallbackDeptName,
    required int applicantsCount,
    required Color navy,
    required Color gold,
    required bool isDark,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    // ✅ نعرض عنوان الإعلان لو موجود، ولو لا نعرض الكلية والقسم
    final String displayTitle;
    final String displaySubtitle;

    if (announcement != null) {
      displayTitle = announcement.title;
      final dept = announcement.departmentName;
      final college = announcement.collegeName ?? fallbackCollegeName;
      displaySubtitle = (dept != null && dept.isNotEmpty)
          ? '$college - $dept'
          : college;
    } else {
      displayTitle = fallbackCollegeName;
      displaySubtitle = (fallbackDeptName != null && fallbackDeptName.isNotEmpty)
          ? '$fallbackCollegeName - $fallbackDeptName'
          : fallbackCollegeName;
    }

    return InkWell(
      onTap: () => setState(() => _selectedAnnouncementId = announcementId),
      borderRadius: BorderRadius.circular(18.r),
      child: Container(
        margin: EdgeInsets.only(bottom: 15.h),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: navy.withOpacity(isDark ? 0.2 : 0.08)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: gold.withOpacity(isDark ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(
                Icons.campaign_outlined,
                color: gold,
                size: 26.sp,
              ),
            ),
            SizedBox(width: 15.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayTitle,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    displaySubtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    "$applicantsCount ${'dashboard.main_cards.request'.tr()}",
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: gold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: colorScheme.onSurfaceVariant.withOpacity(0.5),
              size: 18.sp,
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // 🟢 كارت ملخص الإعلان (أعلى قائمة المتقدمين - المستوى الثالث)
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildAnnouncementSummaryCard({
    required AnnouncementModel? announcement,
    required String fallbackCollegeName,
    required String? fallbackDeptName,
    required int applicantsCount,
    required Color navy,
    required Color gold,
    required bool isDark,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    final String title;
    if (announcement != null) {
      title = announcement.title;
    } else {
      final dept = fallbackDeptName;
      title = (dept != null && dept.isNotEmpty)
          ? '$fallbackCollegeName - $dept'
          : fallbackCollegeName;
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: gold.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: gold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.people_alt_outlined,
              color: gold,
              size: 22.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: navy.withOpacity(isDark ? 0.15 : 0.05),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              "$applicantsCount ${'dashboard.main_cards.request'.tr()}",
              style: TextStyle(
                fontSize: 11.sp,
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // 👤 كارت المتقدم (المستوى الثالث)
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildRequestCard({
    required BuildContext context,
    required NominationRequestModel request,
    required Color navy,
    required Color gold,
    required bool isDark,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: navy.withOpacity(isDark ? 0.2 : 0.05),
        ),
      ),
      child: Row(
        children: [
          // صورة الدكتور
          Container(
            width: 65.w,
            height: 65.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: navy.withOpacity(isDark ? 0.2 : 0.05),
              border: Border.all(color: gold.withOpacity(0.3), width: 2),
            ),
            child: ClipOval(
              child: request.doctorImageUrl != null &&
                      request.doctorImageUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: request.doctorImageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Icon(
                        Icons.person_outline,
                        size: 30.sp,
                        color: navy.withOpacity(0.5),
                      ),
                      errorWidget: (_, __, ___) => Icon(
                        Icons.person_outline,
                        size: 30.sp,
                        color: navy,
                      ),
                    )
                  : Icon(Icons.person_outline, size: 30.sp, color: navy),
            ),
          ),
          SizedBox(width: 12.w),
          // بيانات الدكتور
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  request.doctorName,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 5.h),
                Text(
                  request.targetRole.tr(),
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          // زر التقييم / العرض
          if (_isEvaluationPhase)
            ElevatedButton.icon(
              onPressed: () =>
                  context.push(Routes.judgeEvaluation, extra: request),
              icon: Icon(Icons.edit_note_rounded, size: 16.sp),
              label: Text(
                'judge_orders.evaluate'.tr(),
                style: TextStyle(fontSize: 11.sp),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: gold,
                foregroundColor: colorScheme.onPrimary,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                elevation: 0,
              ),
            )
          else
            ElevatedButton.icon(
              onPressed: () =>
                  context.push(Routes.judgeEvaluation, extra: request),
              icon: Icon(Icons.visibility, size: 16.sp),
              label: Text(
                'judge_orders.view'.tr(),
                style: TextStyle(fontSize: 12.sp),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark
                    ? colorScheme.surfaceContainerHighest
                    : Colors.grey.shade600,
                foregroundColor: isDark ? colorScheme.onSurface : Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                elevation: 0,
              ),
            ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // عنوان الـ AppBar حسب المستوى الحالي
  // ═══════════════════════════════════════════════════════════════════
  String _getAppBarTitle() {
    if (_selectedAnnouncementId != null) {
      return 'judge_orders.applicants_list_title'.tr();
    }
    if (_selectedRoleKey != null) {
      return 'dashboardJudge.categories.$_selectedRoleKey'.tr();
    }

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