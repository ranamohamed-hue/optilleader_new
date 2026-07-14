import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:optialeader/feature/database_admin/data/models/doctor_profile_model.dart';
import 'package:optialeader/feature/doctor/data/model/verefication_status.dart'; // ✅ تم إضافة الـ Import الناقص
import 'package:optialeader/feature/admin/logic/admin_approval/admin_approval_cubit.dart';
import 'package:optialeader/feature/admin/logic/admin_approval/admin_approval_state.dart';
import 'package:optialeader/feature/admin/ui/admin_details_page.dart';

/// ============================================================
/// صفحة الطلبات المعلقة للأدمن
/// وظيفتها: عرض قائمة الأطباء اللي عندهم طلبات معلقة (أبحاث، مؤتمرات، معارض، دورات)
/// وتمريرهم لصفحة التفاصيل للموافقة أو الرفض.
/// ============================================================
class AdminPendingRequestsPage extends StatefulWidget {
  const AdminPendingRequestsPage({super.key});

  @override
  State<AdminPendingRequestsPage> createState() =>
      _AdminPendingRequestsPageState();
}

class _AdminPendingRequestsPageState extends State<AdminPendingRequestsPage> {
  @override
  void initState() {
    super.initState();
    // جلب الطلبات المعلقة فور فتح الصفحة
    context.read<AdminApprovalCubit>().getPendingRequests();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('admin_pending.title'.tr()),
        centerTitle: true,
      ),
      body: BlocConsumer<AdminApprovalCubit, AdminApprovalState>(
        listener: (context, state) {
          if (state is AdminApprovalError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message.tr()),
                backgroundColor: colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AdminApprovalLoading) {
            return Center(
              child: CircularProgressIndicator(color: colorScheme.primary),
            );
          }
          if (state is AdminApprovalLoaded) {
            if (state.doctorsWithPending.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 64,
                      color: colorScheme.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'admin_pending.no_pending'.tr(),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              color: colorScheme.primary,
              onRefresh: () =>
                  context.read<AdminApprovalCubit>().getPendingRequests(),
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(12.0),
                itemCount: state.doctorsWithPending.length,
                itemBuilder: (context, index) {
                  final doctor = state.doctorsWithPending[index];
                  return _buildDoctorSection(context, doctor);
                },
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  /// بناء قسم الدكتور الواحد (ExpansionTile) ويندرج تحته كل الأنشطة المعلقة تابعه
  Widget _buildDoctorSection(BuildContext context, DoctorProfileModel doctor) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // ✅ إصلاح الخطأ: إضافة الكلمة المفتاحية `final` للسطرين اللي تحت
    final pendingPapers = doctor.researchPapers
        .where((p) => p.status == VerificationStatus.pending)
        .toList();
    final pendingConferences = doctor.conferences
        .where((c) => c.status == VerificationStatus.pending)
        .toList();
    final pendingExhibitions = doctor.exhibitions
        .where((e) => e.status == VerificationStatus.pending)
        .toList();
    final pendingCourses = doctor.courses
        .where((c) => c.status == VerificationStatus.pending)
        .toList();

    // حساب إجمالي الطلبات المعلقة للدكتور ده (لعرضه في الـ Subtitle)
    int totalPending =
        pendingPapers.length +
        pendingConferences.length +
        pendingExhibitions.length +
        pendingCourses.length;

    // لو مفيش طلبات معلقة، لا ترسم أي حاجة للدكتور ده
    if (totalPending == 0) return const SizedBox.shrink();

    // أخذ أول حرف من اسم الدكتور لعرضه كـ Avatar
    String initial = doctor.nameAr.isNotEmpty ? doctor.nameAr[0] : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.only(bottom: 12),
          leading: CircleAvatar(
            backgroundColor: colorScheme.primaryContainer,
            child: Text(
              initial,
              style: TextStyle(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            doctor.nameAr,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          subtitle: Text(
            'admin_pending.review_count'.tr(args: [totalPending.toString()]),
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          // عرض الأنشطة المعلقة كعناصر قائمة داخل الـ ExpansionTile
          children: [
            ...pendingPapers.map(
              (paper) => _buildItemCard(
                context,
                doctor.uid ?? '',
                paper,
                'paper',
                paper.titleAr,
                Icons.description,
                colorScheme.primary,
              ),
            ),
            ...pendingConferences.map(
              (conf) => _buildItemCard(
                context,
                doctor.uid ?? '',
                conf,
                'conference',
                conf.title,
                Icons.groups,
                colorScheme.secondary,
              ),
            ),
            ...pendingExhibitions.map(
              (exh) => _buildItemCard(
                context,
                doctor.uid ?? '',
                exh,
                'exhibition',
                exh.title,
                Icons.brush,
                colorScheme.tertiary,
              ),
            ),
            ...pendingCourses.map(
              (course) => _buildItemCard(
                context,
                doctor.uid ?? '',
                course,
                'course',
                course.title,
                Icons.school,
                colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// كارت العنصر الواحد داخل قسم الدكتور (اللي بيتنقل لصفحة التفاصيل عند الضغط عليه)
  Widget _buildItemCard(
    BuildContext context,
    String doctorUid,
    dynamic item,
    String type,
    String title,
    IconData icon,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 2,
      child: ListTile(
        onTap: () {
          // التنقل لصفحة التفاصيل مع تمرير بيانات النشاط والـ Cubit
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => BlocProvider.value(
                value: context.read<AdminApprovalCubit>(),
                child: AdminDetailsPage(
                  item: item,
                  doctorUid: doctorUid,
                  type: type,
                ),
              ),
            ),
          );
        },
        leading: Icon(icon, color: color),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'admin_pending.pending_review'.tr(),
              style: const TextStyle(color: Colors.orange, fontSize: 12),
            ),
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        isThreeLine: true,
      ),
    );
  }
}
