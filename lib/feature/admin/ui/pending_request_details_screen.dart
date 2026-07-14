import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import 'package:optialeader/feature/doctor/data/model/research_paper_model.dart';
import 'package:optialeader/feature/doctor/logic/research_paper/research_paper_cubit.dart';
import 'package:optialeader/feature/doctor/logic/research_paper/research_paper_state.dart';

class PendingRequestDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> extra;

  const PendingRequestDetailsScreen({super.key, required this.extra});

  @override
  State<PendingRequestDetailsScreen> createState() =>
      _PendingRequestDetailsScreenState();
}

class _PendingRequestDetailsScreenState
    extends State<PendingRequestDetailsScreen> {
  late final dynamic item;
  late final String doctorUid;
  late final String type;

  final _scoreController = TextEditingController(text: '0.0');
  final _rejectionController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    item = widget.extra['item'];
    doctorUid = widget.extra['doctorUid'];
    type = widget.extra['type'];

    if (item is ResearchPaperModel) {
      _scoreController.text = (item as ResearchPaperModel).adminScore
          .toStringAsFixed(1);
    }
  }

  @override
  void dispose() {
    _scoreController.dispose();
    _rejectionController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String? url) async {
    if (url == null || url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('pending_details.cannot_open'.tr()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (type == 'paper' && item is ResearchPaperModel) {
      final paper = item as ResearchPaperModel;
      return _buildPaperDetails(context, theme, paper);
    }

    return Scaffold(
      appBar: AppBar(title: Text('pending_details.generic_title'.tr())),
      body: Center(child: Text('pending_details.generic_body'.tr())),
    );
  }

  Widget _buildPaperDetails(
    BuildContext context,
    ThemeData theme,
    ResearchPaperModel paper,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: Text('pending_details.appbar_title'.tr()),
        centerTitle: true,
      ),
      body: BlocListener<ResearchCubit, ResearchState>(
        listener: (context, state) {
          setState(() => _isLoading = state is ResearchLoading);

          if (state is ResearchSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('pending_details.success_msg'.tr()),
                backgroundColor: Colors.green,
              ),
            );
            context.pop();
          } else if (state is ResearchError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error), backgroundColor: Colors.red),
            );
            setState(() => _isLoading = false);
          }
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. كارت بيانات البحث والمجلة (مشترك بين الدولي والمحلي)
              _buildResearchAndJournalCard(theme, paper),
              SizedBox(height: 16.h),

              // 2. كارت بيانات الباحثين والترتيب (مشترك بين الدولي والمحلي)
              _buildAuthorsCard(theme, paper),
              SizedBox(height: 16.h),

              // 3. الشروط المحلية (يظهر فقط لو المجلة محلية)
              if (paper.isLocalJournal) ...[
                _buildLocalCriteriaCard(theme, paper),
                SizedBox(height: 16.h),
              ],

              // 4. قسم الملفات
              _buildFilesCard(theme, paper),
              SizedBox(height: 16.h),

              // 5. حساب النقاط الآلي
              _buildPointsSummaryCard(theme, paper),
              SizedBox(height: 24.h),

              // 6. خانة درجة الأدمن
              _buildAdminScoreSection(theme, paper),
              SizedBox(height: 24.h),

              // 7. أزرار الموافقة والرفض
              _buildActionButtons(paper),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // 1. كارت بيانات البحث والمجلة (اسم المجلة، التخصصية، الفهرسة، الربع)
  // ─────────────────────────────────────────────
  Widget _buildResearchAndJournalCard(
    ThemeData theme,
    ResearchPaperModel paper,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.menu_book, color: theme.primaryColor, size: 22.sp),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  paper.titleAr,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (paper.titleEn.isNotEmpty) ...[
            SizedBox(height: 4.h),
            Text(
              paper.titleEn,
              style: TextStyle(fontSize: 13.sp, color: Colors.grey[700]),
            ),
          ],
          Divider(height: 24.h),

          // ✅ اسم المجلة
          _buildDetailRow(
            'pending_details.journal_name'.tr(),
            paper.journalName,
          ),

          // ✅ هل المجلة متخصصة أم لا
          _buildDetailRow(
            'pending_details.journal_scope'.tr(),
            paper.journalScope == JournalScope.specialized
                ? 'pending_details.scope_specialized'.tr()
                : 'pending_details.scope_non_specialized'.tr(),
          ),

          // قاعدة الفهرسة
          _buildDetailRow(
            'pending_details.database'.tr(),
            _getDbLabel(paper.indexingDatabase),
          ),

          // المستوى (دولي/محلي)
          _buildDetailRow(
            'pending_details.journal_level'.tr(),
            paper.isLocalJournal
                ? 'pending_details.level_local'.tr()
                : 'pending_details.level_international'.tr(),
          ),

          // الربع (يظهر فقط لو دولي ومختار)
          if (paper.quartile != null)
            _buildDetailRow(
              'pending_details.quartile'.tr(),
              paper.quartile!.toUpperCase(),
            ),

          if (paper.issn.isNotEmpty)
            _buildDetailRow('pending_details.issn'.tr(), paper.issn),

          if (paper.journalUrl.isNotEmpty)
            _buildClickableRow(
              'pending_details.journal_url'.tr(),
              paper.journalUrl,
              () => _launchUrl(paper.journalUrl),
            ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // 2. كارت بيانات الباحثين والترتيب
  // ─────────────────────────────────────────────
  Widget _buildAuthorsCard(ThemeData theme, ResearchPaperModel paper) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.people, color: theme.primaryColor, size: 22.sp),
              SizedBox(width: 8.w),
              Text(
                'pending_details.authors_info'.tr(),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
            ],
          ),
          Divider(height: 24.h),

          // ✅ ترتيب الباحث
          _buildDetailRow(
            'pending_details.author_order'.tr(),
            '${paper.authorOrder}',
          ),

          // ✅ إجمالي الباحثين
          _buildDetailRow(
            'pending_details.total_authors'.tr(),
            '${paper.totalAuthors}',
          ),

          // ✅ عدد الباحثين في نفس التخصص
          _buildDetailRow(
            'pending_details.same_specialty'.tr(),
            '${paper.authorsInSameSpecialty}',
          ),

          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Icon(Icons.percent, color: Colors.blue, size: 18.sp),
                SizedBox(width: 8.w),
                Text(
                  '${'pending_details.participation_pct'.tr()}: ${(paper.participationPercentage * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                    color: Colors.blue.shade800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // 3. كارت الشروط المحلية (يظهر فقط لو محلي)
  // ─────────────────────────────────────────────
  Widget _buildLocalCriteriaCard(ThemeData theme, ResearchPaperModel paper) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_city,
                color: Colors.orange.shade800,
                size: 22.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'pending_details.local_criteria'.tr(),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade800,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          _buildCriteriaStatusRow(
            'localJournalCriteria.criteria1'.tr(),
            paper.peerReviewed,
          ),
          _buildCriteriaStatusRow(
            'localJournalCriteria.criteria2'.tr(),
            paper.indexedDatabase,
          ),
          _buildCriteriaStatusRow(
            'localJournalCriteria.criteria3'.tr(),
            paper.electronicPublishing,
          ),
          _buildCriteriaStatusRow(
            'localJournalCriteria.criteria4'.tr(),
            paper.knownEditorialBoard,
          ),
          _buildCriteriaStatusRow(
            'localJournalCriteria.criteria5'.tr(),
            paper.regularPublication,
          ),
          _buildCriteriaStatusRow(
            'localJournalCriteria.criteria6'.tr(),
            paper.externalReviewers,
          ),
          _buildCriteriaStatusRow(
            'localJournalCriteria.criteria7'.tr(),
            paper.specializedJournal,
          ),
          _buildCriteriaStatusRow(
            'localJournalCriteria.criteria8'.tr(),
            paper.externalAuthors,
          ),

          Divider(height: 24.h),

          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'pending_details.local_points_total'.tr(),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: paper.localJournalPoints > 0
                        ? Colors.orange
                        : Colors.grey,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    '${paper.localJournalPoints.toStringAsFixed(1)} / 7.0',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCriteriaStatusRow(String label, bool value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Icon(
            value ? Icons.check_circle : Icons.cancel,
            color: value ? Colors.green : Colors.red.shade300,
            size: 22.sp,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: value ? FontWeight.w600 : FontWeight.normal,
                decoration: value
                    ? TextDecoration.none
                    : TextDecoration.lineThrough,
                color: value ? Colors.black87 : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // 4. كارت الملفات
  // ─────────────────────────────────────────────
  Widget _buildFilesCard(ThemeData theme, ResearchPaperModel paper) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.attach_file, color: theme.primaryColor, size: 22.sp),
              SizedBox(width: 8.w),
              Text(
                'pending_details.attached_files'.tr(),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
            ],
          ),
          Divider(height: 24.h),

          _buildFileRow(
            icon: Icons.picture_as_pdf,
            label: 'pending_details.paper_file'.tr(),
            url: paper.paperFileUrl,
            color: Colors.red,
          ),

          if (paper.indexingProofUrl != null &&
              paper.indexingProofUrl!.isNotEmpty)
            _buildFileRow(
              icon: Icons.verified,
              label: 'pending_details.indexing_proof'.tr(),
              url: paper.indexingProofUrl,
              color: Colors.blue,
            ),

          if (paper.certifiedReportFileUrl != null &&
              paper.certifiedReportFileUrl!.isNotEmpty)
            _buildFileRow(
              icon: Icons.assignment_turned_in,
              label: 'pending_details.certified_report'.tr(),
              url: paper.certifiedReportFileUrl,
              color: Colors.green,
            ),
        ],
      ),
    );
  }

  Widget _buildFileRow({
    required IconData icon,
    required String label,
    required String? url,
    required Color color,
  }) {
    final hasFile = url != null && url.isNotEmpty;
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: InkWell(
        onTap: hasFile ? () => _launchUrl(url) : null,
        child: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 28.sp),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                    color: hasFile ? color : Colors.grey,
                  ),
                ),
              ),
              if (hasFile)
                Icon(Icons.open_in_new, color: color, size: 20.sp)
              else
                Text(
                  'pending_details.not_attached'.tr(),
                  style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // 5. كارت ملخص النقاط الآلي
  // ─────────────────────────────────────────────
  Widget _buildPointsSummaryCard(ThemeData theme, ResearchPaperModel paper) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calculate, color: Colors.green.shade800, size: 22.sp),
              SizedBox(width: 8.w),
              Text(
                'pending_details.points_summary'.tr(),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade800,
                ),
              ),
            ],
          ),
          Divider(height: 24.h),
          _buildDetailRow(
            'pending_details.journal_points'.tr(),
            paper.journalPoints.toStringAsFixed(1),
          ),
          _buildDetailRow(
            'pending_details.admin_score'.tr(),
            paper.adminScore.toStringAsFixed(1),
          ),
          _buildDetailRow(
            'pending_details.participation_pct'.tr(),
            '${(paper.participationPercentage * 100).toStringAsFixed(0)}%',
          ),
          Divider(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'pending_details.final_points'.tr(),
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16.sp),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  paper.finalPoints.toStringAsFixed(2),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // 6. خانة درجة الأدمن
  // ─────────────────────────────────────────────
  Widget _buildAdminScoreSection(ThemeData theme, ResearchPaperModel paper) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.verified_user, color: theme.primaryColor, size: 24.sp),
              SizedBox(width: 10.w),
              Text(
                'pending_details.report_title'.tr(),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            'pending_details.score_label'.tr(),
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
          ),
          SizedBox(height: 8.h),
          TextField(
            controller: _scoreController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: 'pending_details.score_hint'.tr(),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              prefixIcon: Icon(Icons.star, color: Colors.amber),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'pending_details.score_note'.tr(),
            style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // 7. أزرار الموافقة والرفض
  // ─────────────────────────────────────────────
  Widget _buildActionButtons(ResearchPaperModel paper) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50.h,
          child: ElevatedButton.icon(
            onPressed: _isLoading
                ? null
                : () {
                    final score = double.tryParse(_scoreController.text) ?? 0.0;
                    context.read<ResearchCubit>().approveResearch(
                      doctorUid,
                      paper.id,
                      adminScore: score,
                    );
                  },
            icon: _isLoading
                ? SizedBox(
                    width: 20.h,
                    height: 20.h,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Icon(Icons.check_circle_outline),
            label: Text(
              'pending_details.approve_btn'.tr(),
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          width: double.infinity,
          height: 50.h,
          child: OutlinedButton.icon(
            onPressed: _isLoading ? null : () => _showRejectDialog(paper),
            icon: Icon(Icons.cancel_outlined, color: Colors.red),
            label: Text(
              'pending_details.reject_btn'.tr(),
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.red, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // أدوات مساعدة
  // ─────────────────────────────────────────────

  void _showRejectDialog(ResearchPaperModel paper) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('pending_details.reject_dialog_title'.tr()),
        content: TextField(
          controller: _rejectionController,
          decoration: InputDecoration(
            hintText: 'pending_details.reject_hint'.tr(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('pending_details.cancel'.tr()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<ResearchCubit>().rejectResearch(
                doctorUid,
                paper.id,
                _rejectionController.text.trim(),
              );
              Navigator.pop(ctx);
            },
            child: Text(
              'pending_details.confirm_reject'.tr(),
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130.w,
            child: Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
                fontSize: 13.sp,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClickableRow(String title, String url, VoidCallback onTap) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130.w,
            child: Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
                fontSize: 13.sp,
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: onTap,
              child: Text(
                url,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getDbLabel(IndexingDatabase db) {
    switch (db) {
      case IndexingDatabase.scopus:
        return 'Scopus';
      case IndexingDatabase.webOfScience:
        return 'Web of Science';
      case IndexingDatabase.local:
        return 'pending_details.db_local'.tr();
      case IndexingDatabase.other:
        return 'pending_details.db_other'.tr();
    }
  }
}
