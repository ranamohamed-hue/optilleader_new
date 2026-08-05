import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:optialeader/feature/admin/data/model/announcement_model.dart';
import 'package:optialeader/feature/admin/logic/announcement_logic/announcement_cubit.dart';
import 'package:intl/intl.dart';
import 'package:optialeader/feature/admin/logic/announcement_logic/announcement_state.dart';

// ✅ استدعاءات إضافية مطلوبة للقطاعات وزر النتائج
import 'package:optialeader/feature/admin/logic/nomination_request_logic/nomination_request_cubit.dart';
import 'package:optialeader/feature/admin/logic/nomination_request_logic/nomonation_request_state.dart';
import 'package:optialeader/feature/admin/ui/announces/competition_results_sheet.dart';
import 'package:optialeader/feature/admin/ui/announces/mansoura_universities_data.dart';

Color getAnnouncementStatusColor(String status, ColorScheme colorScheme) {
  switch (status) {
    case 'Active':
      return Colors.blue;
    case 'Pending':
      return Colors.orange.shade700;
    case 'Closed':
      return colorScheme.error;
    default:
      return Colors.grey;
  }
}

class AnnouncementsPage extends StatelessWidget {
  final VoidCallback? onBack;

  const AnnouncementsPage({super.key, this.onBack});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: BlocBuilder<AnnouncementCubit, AnnouncementState>(
        builder: (context, state) {
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildHeader(context, colorScheme, theme),
              ..._buildBodyBasedOnState(state, theme),
            ],
          );
        },
      ),
      floatingActionButton: _buildFAB(context, colorScheme),
    );
  }

  List<Widget> _buildBodyBasedOnState(
    AnnouncementState state,
    ThemeData theme,
  ) {
    if (state is AnnouncementLoading) {
      return [
        const SliverFillRemaining(
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }
    if (state is AnnouncementLoaded) {
      if (state.announcements.isEmpty)
        return [_buildEmptyState("announce.no_data".tr())];
      return [_buildAnnouncementsList(state.announcements)];
    }
    if (state is AnnouncementError) return [_buildErrorState(state.message)];
    return [
      SliverFillRemaining(
        child: Center(child: Text("announce.preparing".tr())),
      ),
    ];
  }

  Widget _buildHeader(
    BuildContext context,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    return SliverAppBar(
      expandedHeight: 130.0,
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: colorScheme.primary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(35)),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colorScheme.primary, colorScheme.primaryContainer],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () => onBack != null ? onBack!() : context.pop(),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "announce.title".tr(),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "announce.subtitle".tr(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.secondary.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnnouncementsList(List<AnnouncementModel> announcements) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) =>
              _buildAnnouncementCard(context, announcements[index]),
          childCount: announcements.length,
        ),
      ),
    );
  }

  Widget _buildAnnouncementCard(
    BuildContext context,
    AnnouncementModel announcement,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final statusColor = getAnnouncementStatusColor(
      announcement.status,
      colorScheme,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () =>
              context.push('/admin/announcement-details', extra: announcement),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              announcement.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                          Icon(
                            context.locale.languageCode == 'ar'
                                ? Icons.arrow_back_ios
                                : Icons.arrow_forward_ios,
                            size: 12,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        announcement.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(thickness: 0.6),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.group_outlined,
                            size: 18,
                            color: statusColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "${announcement.applicants} ${'announce.details.person_unit'.tr()}",
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              "announce.${announcement.status.toLowerCase()}"
                                  .tr(),
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (announcement.imageUrl != null &&
                    announcement.imageUrl!.isNotEmpty) ...[
                  const SizedBox(width: 15),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: announcement.imageUrl!,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => Container(
                        color: Colors.grey[200],
                        width: 70,
                        height: 70,
                      ),
                      errorWidget: (_, _, _) =>
                          const Icon(Icons.broken_image, size: 40),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String msg) => SliverFillRemaining(
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_rounded, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 10),
          Text(msg, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    ),
  );

  Widget _buildErrorState(String errorCode) => SliverFillRemaining(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: 60,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 16),
            Text(
              errorCode.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.redAccent),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _buildFAB(BuildContext context, ColorScheme colorScheme) {
    return FloatingActionButton.extended(
      onPressed: () => context.push('/admin/edit-announcement'),
      backgroundColor: colorScheme.primary,
      icon: Icon(Icons.add_rounded, color: colorScheme.secondary),
      label: Text(
        "announce.add_button".tr(),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

// ============================================================
// ✅ شاشة التفاصيل (مدعومة بالقطاعات وأزرار النتائج الذكية)
// ============================================================
class AnnouncementDetailsPage extends StatelessWidget {
  final AnnouncementModel announcement;

  const AnnouncementDetailsPage({super.key, required this.announcement});

  Future<void> _confirmDelete(BuildContext context) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("announce.delete.confirm_title".tr()),
        content: Text("announce.delete.confirm_body".tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text("common.cancel".tr()),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              "common.delete".tr(),
              style: TextStyle(color: Theme.of(ctx).colorScheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      context.read<AnnouncementCubit>().deleteAnnouncement(
        announcement.id!,
        announcement.imageUrl,
      );
      context.pop();
    }
  }

  void _showResultsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (ctx) => CompetitionResultsSheet(
        announcementId: announcement.id!,
        announcementTitle: announcement.title,
        onConfirmAnnounce: () {
          context.read<NominationRequestCubit>().announceCompetitionResults(
            announcementId: announcement.id!,
            announcementTitle: announcement.title,
          );
        },
      ),
    );
  }

  Widget _buildAnnounceResultButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade700, Colors.amber.shade500],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () => _showResultsSheet(context),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.emoji_events, color: Colors.white, size: 26),
                SizedBox(width: 12),
                Text(
                  '🏆 عرض النتائج والإعلان',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final statusColor = getAnnouncementStatusColor(
      announcement.status,
      colorScheme,
    );

    // ✅ شرط ذكي: إظهار زر الإعلان فقط إذا كان الإعلان مقفول ولم يتم الإعلان عنه مسبقاً
    final bool canAnnounceResults =
        announcement.status == 'Closed' &&
        (announcement.isResultAnnounced == null ||
            announcement.isResultAnnounced == false);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            context.push('/admin/edit-announcement', extra: announcement),
        elevation: 4,
        backgroundColor: colorScheme.primary,
        icon: Icon(Icons.edit_note_rounded, color: colorScheme.secondary),
        label: Text(
          "announce.details.edit_button".tr(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
      body: BlocListener<NominationRequestCubit, NominationRequestState>(
        listener: (context, state) {
          if (state is NominationRequestActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            context.read<AnnouncementCubit>().fetchAnnouncements();
            Future.delayed(const Duration(milliseconds: 500), () {
              if (context.mounted) context.pop();
            });
          } else if (state is NominationRequestError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: announcement.imageUrl != null ? 300.0 : 160.0,
              pinned: true,
              automaticallyImplyLeading: false,
              backgroundColor: colorScheme.primary,
              elevation: 0,
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.delete_sweep_outlined,
                    color: Colors.white70,
                  ),
                  onPressed: () => _confirmDelete(context),
                ),
                const SizedBox(width: 10),
              ],
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(35),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (announcement.imageUrl != null)
                      CachedNetworkImage(
                        imageUrl: announcement.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            Container(color: Colors.black12),
                        errorWidget: (context, url, error) => Container(
                          color: colorScheme.primary.withOpacity(0.1),
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: colorScheme.primary,
                            size: 40,
                          ),
                        ),
                      ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(
                              announcement.imageUrl != null ? 0.3 : 0.0,
                            ),
                            colorScheme.primary.withOpacity(
                              announcement.imageUrl != null ? 0.8 : 1.0,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 60, 20, 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.white,
                              size: 22,
                            ),
                            onPressed: () => context.pop(),
                          ),
                          const SizedBox(width: 5),
                          Container(
                            padding: const EdgeInsets.all(2.5),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: colorScheme.secondary,
                                width: 2,
                              ),
                            ),
                            child: const CircleAvatar(
                              radius: 26,
                              backgroundColor: Colors.white24,
                              child: Icon(
                                Icons.admin_panel_settings,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "announce.details.badge_title".tr(),
                                  style: textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                Text(
                                  "common.app_name".tr(),
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.secondary.withOpacity(
                                      0.9,
                                    ),
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
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildAnnouncementDetailCard(
                    context,
                    announcement: announcement,
                  ),
                  const SizedBox(height: 20),

                  // ✅ عرض الزر فقط إذا تحقق الشرط
                  if (canAnnounceResults) _buildAnnounceResultButton(context),

                  const SizedBox(height: 100),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncementDetailCard(
    BuildContext context, {
    required AnnouncementModel announcement,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final statusColor = getAnnouncementStatusColor(
      announcement.status,
      colorScheme,
    );

    final formattedDeadline = DateFormat(
      'EEEE, d MMMM yyyy',
      context.locale.languageCode,
    ).format(announcement.deadline);
    final postedDate = DateFormat(
      'd MMM yyyy',
      context.locale.languageCode,
    ).format(announcement.createdAt);

    // 🧠 شروط العرض المتطابقة مع المحركين
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
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.05),
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
              size: 130,
              color: statusColor.withOpacity(0.04),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    "announce.${announcement.status.toLowerCase()}"
                        .tr()
                        .toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                Text(
                  announcement.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  announcement.description,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.black87.withOpacity(0.7),
                    height: 1.7,
                    fontSize: 15,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 30),
                  child: Divider(thickness: 0.8),
                ),

                _buildInfoRow(
                  context,
                  Icons.military_tech,
                  "announce.details.target_role".tr(),
                  announcement.targetRole.tr(),
                  colorScheme.secondary,
                ),
                const SizedBox(height: 20),

                // ✅ عرض القطاع (لنائب الرئيس ووكيل الكلية)
                if (showSector && announcement.targetSector != null) ...[
                  _buildInfoRow(
                    context,
                    Icons.account_tree_outlined,
                    "edit_announcement.field_sector".tr(),
                    "sectors.${announcement.targetSector}".tr(),
                    Colors.deepOrange,
                  ),
                  const SizedBox(height: 20),
                ],

                _buildInfoRow(
                  context,
                  Icons.groups_rounded,
                  "announce.details.applicants_label".tr(),
                  "${announcement.applicants} ${'announce.details.person_unit'.tr()}",
                  statusColor,
                ),
                const SizedBox(height: 20),
                _buildInfoRow(
                  context,
                  Icons.timer_outlined,
                  "announce.details.deadline_label".tr(),
                  formattedDeadline,
                  colorScheme.primary,
                ),
                const SizedBox(height: 20),
                _buildInfoRow(
                  context,
                  Icons.calendar_today_rounded,
                  "announce.details.posted_label".tr(),
                  postedDate,
                  Colors.blueGrey,
                ),

                // ✅ عرض الكلية والقسم بشروط ذكية
                if (showCollege && announcement.collegeName != null) ...[
                  const SizedBox(height: 20),
                  _buildInfoRow(
                    context,
                    Icons.domain,
                    "announce.details.college".tr(),
                    announcement.collegeName!,
                    Colors.deepPurple,
                  ),
                ],
                if (showDepartment && announcement.departmentName != null) ...[
                  const SizedBox(height: 20),
                  _buildInfoRow(
                    context,
                    Icons.meeting_room,
                    "announce.details.department".tr(),
                    announcement.departmentName!,
                    Colors.teal,
                  ),
                ],

                // ✅ عرض الإدارات لو كان الدور إداري
                if (showAdminDept && announcement.adminSectorName != null) ...[
                  const SizedBox(height: 20),
                  _buildInfoRow(
                    context,
                    Icons.account_balance,
                    "announce.details.admin_sector".tr(),
                    announcement.adminSectorName!,
                    Colors.indigo,
                  ),
                ],
                if (showAdminDept && announcement.adminSubDeptName != null) ...[
                  const SizedBox(height: 20),
                  _buildInfoRow(
                    context,
                    Icons.corporate_fare,
                    "announce.details.admin_sub_dept".tr(),
                    announcement.adminSubDeptName!,
                    Colors.amber.shade800,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
