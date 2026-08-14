import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:optialeader/core/routing/routes.dart';
import 'package:optialeader/feature/doctor/data/model/conferance_model.dart';
import 'package:optialeader/feature/doctor/data/model/courses_model.dart';
import 'package:optialeader/feature/doctor/data/model/exhibition_venue_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:optialeader/feature/admin/logic/admin_approval/admin_approval_cubit.dart';
import 'package:optialeader/feature/admin/logic/admin_approval/admin_approval_state.dart';
// ✅ استورد ملف المسارات هنا (غيّر المسار حسب مكان الملف عندك)

/// ============================================================
/// صفحة تفاصيل الإنجاز (للأدمن) والموافقة / الرفض
/// ملاحظة: عند اختيار نوع "بحث علمي" يتم التحويل تلقائياً
///         لصفحة إدخال درجة الأدمن (PendingRequestDetailsScreen)
/// ============================================================
class AdminDetailsPage extends StatefulWidget {
  final dynamic item;
  final String doctorUid;
  final String type; // 'paper', 'conference', 'course', 'exhibition'

  const AdminDetailsPage({
    super.key,
    required this.item,
    required this.doctorUid,
    required this.type,
  });

  @override
  State<AdminDetailsPage> createState() => _AdminDetailsPageState();
}

class _AdminDetailsPageState extends State<AdminDetailsPage> {
  bool _navigatedToPaper = false;

  @override
    @override
  void initState() {
    super.initState();
    if (widget.type == 'paper') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_navigatedToPaper && mounted) {
          _navigatedToPaper = true;
          context.push(
            Routes.pendingPaperDetails,
            extra: {
              'item': widget.item,
              'doctorUid': widget.doctorUid,
              'type': widget.type,
            },
          ).then((_) {
            if (mounted) context.pop();
          });
        }
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryNavy = theme.primaryColor;
    final goldAccent = theme.colorScheme.secondary;

    // ✅ لو بحث علمي نعرض شاشة تحميل بسيطة أثناء التحويل
    if (widget.type == 'paper') {
      return Scaffold(
        appBar: AppBar(
          title: Text('admin_details.paper_title'.tr()),
          backgroundColor: primaryNavy,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: goldAccent),
              SizedBox(height: 16.h),
              Text(
                'admin_details.redirecting_to_paper'.tr(),
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return BlocListener<AdminApprovalCubit, AdminApprovalState>(
      listener: (context, state) {
        if (state is AdminApprovalLoaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('admin_request.success_msg'.tr()),
              backgroundColor: Colors.green,
            ),
          );
          context.pop();
        } else if (state is AdminApprovalError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_getTitle()),
          backgroundColor: primaryNavy,
          elevation: 0,
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.r),
                child: _buildDetailsContent(),
              ),
            ),
            _buildActionButtons(context, primaryNavy, goldAccent),
          ],
        ),
      ),
    );
  }

  /// تحديد عنوان الـ AppBar بناءً على نوع النشاط
  String _getTitle() {
    switch (widget.type) {
      case 'conference':
        return 'admin_details.conference_title'.tr();
      case 'course':
        return 'admin_details.course_title'.tr();
      case 'exhibition':
        return 'admin_details.exhibition_title'.tr();
      default:
        return 'admin_details.default_title'.tr();
    }
  }

  /// توجيه بناء الويدجت للدالة المناسبة حسب نوع النشاط
  Widget _buildDetailsContent() {
    switch (widget.type) {
      case 'conference':
        return _buildConferenceDetails(widget.item as ConferenceModel);
      case 'course':
        return _buildCourseDetails(widget.item as CourseModel);
      case 'exhibition':
        return _buildExhibitionDetails(widget.item as ArtExhibitionModel);
      default:
        return Center(child: Text('admin_details.unknown_type'.tr()));
    }
  }

  // ==========================================
  // 2. تفاصيل المؤتمر
  // ==========================================
  Widget _buildConferenceDetails(ConferenceModel conf) {
    return _buildInfoCard(
      title: 'admin_details.conference_data'.tr(),
      icon: Icons.groups_rounded,
      children: [
        _buildDetailRow('admin_details.title'.tr(), conf.title),
        _buildDetailRow(
          'admin_details.scope'.tr(),
          conf.isInternational
              ? 'admin_details.international'.tr()
              : 'admin_details.local'.tr(),
        ),
        _buildDetailRow(
          'admin_details.specialization'.tr(),
          conf.isSpecialized
              ? 'admin_details.specialized'.tr()
              : 'admin_details.non_specialized'.tr(),
        ),
        _buildDetailRow(
          'admin_details.published_proceedings'.tr(),
          conf.isPublished ? 'common.yes'.tr() : 'common.no'.tr(),
        ),
        _buildDetailRow(
          'admin_details.participation_type'.tr(),
          _getParticipationTypeAr(conf.participationType),
        ),
        SizedBox(height: 10.h),
        _buildFileRow(
          'admin_details.certificate'.tr(),
          conf.certificateUrl,
          'image',
        ),
        if (conf.proceedingsUrl != null)
          _buildFileRow(
            'admin_details.published_paper'.tr(),
            conf.proceedingsUrl!,
            'pdf',
          ),
      ],
    );
  }

  // ==========================================
  // 3. تفاصيل الدورة
  // ==========================================
  Widget _buildCourseDetails(CourseModel course) {
    return _buildInfoCard(
      title: 'admin_details.course_data'.tr(),
      icon: Icons.school_rounded,
      children: [
        _buildDetailRow('admin_details.course_name'.tr(), course.title),
        _buildDetailRow('admin_details.organization'.tr(), course.organization),
        _buildDetailRow('admin_details.date'.tr(), course.date),
        _buildDetailRow(
          'admin_details.hours'.tr(),
          '${course.durationHours ?? 'admin_details.not_specified'.tr()}',
        ),
        _buildDetailRow(
          'admin_details.course_type'.tr(),
          course.isMandatory
              ? 'admin_details.mandatory_leadership'.tr()
              : 'admin_details.evaluative'.tr(),
        ),
        if (!course.isMandatory) ...[
          _buildDetailRow(
            'admin_details.category'.tr(),
            _getCourseCategoryAr(course.courseCategory),
          ),
          _buildDetailRow(
            'admin_details.scope'.tr(),
            _getCourseScopeAr(course.courseScope),
          ),
        ],
        SizedBox(height: 10.h),
        _buildFileRow(
          'admin_details.completion_certificate'.tr(),
          course.certificateUrl,
          course.certificateFileType,
        ),
      ],
    );
  }

  // ==========================================
  // 4. تفاصيل المعرض الفني
  // ==========================================
  Widget _buildExhibitionDetails(ArtExhibitionModel exh) {
    return _buildInfoCard(
      title: 'admin_details.exhibition_data'.tr(),
      icon: Icons.brush_rounded,
      children: [
        _buildDetailRow('admin_details.title'.tr(), exh.title),
        _buildDetailRow(
          'admin_details.works_count'.tr(),
          '${exh.numberOfWorks}',
        ),
        _buildDetailRow('admin_details.venue'.tr(), _getVenueAr(exh.venue)),
        if (exh.researcherNotes != null)
          _buildDetailRow(
            'admin_details.researcher_notes'.tr(),
            exh.researcherNotes!,
          ),
        SizedBox(height: 10.h),
        _buildFileRow(
          'admin_details.proof_file'.tr(),
          exh.proofFileUrl,
          exh.proofFileType,
        ),
      ],
    );
  }

  // ==========================================
  // 5. ويدجات مساعدة وبناء الواجهة
  // ==========================================

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(15.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Theme.of(context).primaryColor, size: 22.sp),
              SizedBox(width: 10.w),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          Divider(height: 20.h),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isLink = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140.w,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13.sp,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'admin_details.not_specified'.tr() : value,
              style: TextStyle(
                fontSize: 13.sp,
                color: isLink ? Colors.blue : Colors.black87,
                decoration: isLink
                    ? TextDecoration.underline
                    : TextDecoration.none,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileRow(String label, String? url, String? fileType) {
    if (url == null || url.isEmpty) return SizedBox.shrink();
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        fileType == 'pdf' ? Icons.picture_as_pdf : Icons.image,
        color: fileType == 'pdf' ? Colors.red : Colors.blue,
      ),
      title: Text(
        label,
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
      ),
      subtitle: Text(
        fileType?.toUpperCase() ?? 'FILE',
        style: TextStyle(fontSize: 11.sp, color: Colors.grey),
      ),
      trailing: Icon(Icons.open_in_new, color: Theme.of(context).primaryColor),
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
    );
  }

  // ==========================================
  // 6. دوال المنطق (الموافقة، الرفض، الترجمة)
  // ==========================================

  Widget _buildActionButtons(
    BuildContext context,
    Color primaryNavy,
    Color goldAccent,
  ) {
    return BlocBuilder<AdminApprovalCubit, AdminApprovalState>(
      builder: (context, state) {
        final isLoading = state is AdminApprovalLoading;
        return Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: isLoading
              ? Center(child: CircularProgressIndicator(color: goldAccent))
              : Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        onPressed: () => _approveItem(),
                        icon: const Icon(Icons.check_circle_outline),
                        label: Text(
                          'common.approve'.tr(),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red.shade700,
                          side: BorderSide(
                            color: Colors.red.shade700,
                            width: 1.5,
                          ),
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        onPressed: () async {
                          final reason = await _showRejectDialog(context);
                          if (reason != null) _rejectItem(reason);
                        },
                        icon: const Icon(Icons.cancel_outlined),
                        label: Text(
                          'common.reject'.tr(),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  void _approveItem() {
    final cubit = context.read<AdminApprovalCubit>();
    switch (widget.type) {
      case 'conference':
        final item = widget.item as ConferenceModel;
        cubit.approveConference(widget.doctorUid, item.id, item.title);
        break;
      case 'course':
        final item = widget.item as CourseModel;
        cubit.approveCourse(widget.doctorUid, item.id, item.title);
        break;
      case 'exhibition':
        final item = widget.item as ArtExhibitionModel;
        cubit.approveExhibition(widget.doctorUid, item.id, item.title);
        break;
    }
  }

  void _rejectItem(String reason) {
    final cubit = context.read<AdminApprovalCubit>();
    switch (widget.type) {
      case 'conference':
        final item = widget.item as ConferenceModel;
        cubit.rejectConference(widget.doctorUid, item.id, item.title, reason);
        break;
      case 'course':
        final item = widget.item as CourseModel;
        cubit.rejectCourse(widget.doctorUid, item.id, item.title, reason);
        break;
      case 'exhibition':
        final item = widget.item as ArtExhibitionModel;
        cubit.rejectExhibition(widget.doctorUid, item.id, item.title, reason);
        break;
    }
  }

  // ==========================================
  // دوال الترجمة للقوائم المنسدلة
  // ==========================================

  String _getParticipationTypeAr(ParticipationType type) {
    switch (type) {
      case ParticipationType.paperPresentation:
        return 'admin_details.full_paper'.tr();
      case ParticipationType.abstractPresentation:
        return 'admin_details.abstract_paper'.tr();
      case ParticipationType.attendanceOnly:
        return 'admin_details.attendance_only'.tr();
    }
  }

  String _getCourseCategoryAr(CourseCategory category) {
    switch (category) {
      case CourseCategory.administrative:
        return 'admin_details.cat_administrative'.tr();
      case CourseCategory.specialized:
        return 'admin_details.cat_specialized'.tr();
      case CourseCategory.general:
        return 'admin_details.cat_general'.tr();
      default:
        return 'admin_details.not_specified'.tr();
    }
  }

  String _getCourseScopeAr(CourseScope scope) {
    switch (scope) {
      case CourseScope.international:
        return 'admin_details.international'.tr();
      case CourseScope.local:
        return 'admin_details.local'.tr();
      default:
        return 'admin_details.not_specified'.tr();
    }
  }

   String _getVenueAr(ExhibitionVenue venue) {
    switch (venue) {
      case ExhibitionVenue.internationalAbroad:
        return 'admin_details.venue_intl_abroad'.tr();
      case ExhibitionVenue.internationalEgypt:
        return 'admin_details.venue_intl_egypt'.tr();
      case ExhibitionVenue.artFaculties:
        return 'admin_details.venue_art_faculties'.tr();
      case ExhibitionVenue.fineArtsSector:
        return 'admin_details.venue_fine_arts_sector'.tr();
      case ExhibitionVenue.foreignCulturalCenters:
        return 'admin_details.venue_foreign_centers'.tr();
      case ExhibitionVenue.artSyndicates:
        return 'admin_details.venue_art_syndicates'.tr();
      case ExhibitionVenue.culturePalaces:
        return 'admin_details.venue_culture_palaces'.tr();
      case ExhibitionVenue.ateliersCairoAlex:
        return 'admin_details.venue_ateliers'.tr();
      case ExhibitionVenue.privateGalleries:
        return 'admin_details.venue_private_galleries'.tr();
    }
  }

  // ==========================================
  // 7. ديلوج كتابة سبب الرفض
  // ==========================================
  Future<String?> _showRejectDialog(BuildContext context) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.r),
        ),
        title: Text(
          'admin_details.reject_reason_title'.tr(),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('admin_details.reject_reason_body'.tr()),
            const SizedBox(height: 15),
            TextField(
              controller: controller,
              minLines: 2,
              maxLines: 4,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'admin_details.reject_hint'.tr(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('common.cancel'.tr()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(
              dialogContext,
              controller.text.trim().isEmpty
                  ? 'admin_details.no_reason'.tr()
                  : controller.text.trim(),
            ),
            child: Text('admin_details.confirm_reject'.tr()),
          ),
        ],
      ),
    );
  }
}