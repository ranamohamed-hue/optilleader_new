import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:optialeader/feature/employee/data/models/employee_course_model.dart';
import 'package:optialeader/feature/employee/logic/employee_courses_cubit.dart';
import 'course_detail_chip.dart';

class CourseCard extends StatelessWidget {
  final EmployeeCourseModel course;
  const CourseCard({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = _getStatusColor(course.status, colorScheme);
    final statusIcon = _getStatusIcon(course.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface, 
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: colorScheme.primary.withOpacity(isDark ? 0.2 : 0.04), blurRadius: 15, offset: const Offset(0, 8)),
        ],
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Text(course.title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: colorScheme.onSurface))),
              _buildStatusBadge(statusIcon, statusColor, course.status),
            ],
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: colorScheme.outlineVariant.withOpacity(0.3)),
          const SizedBox(height: 12),

          CourseDetailChip(icon: Icons.business_rounded, text: course.organization, color: colorScheme.primary),
          const SizedBox(height: 8),
          CourseDetailChip(icon: Icons.calendar_today_rounded, text: course.date, color: colorScheme.tertiary),
          if (course.durationHours != null) ...[
            const SizedBox(height: 8),
            CourseDetailChip(icon: Icons.schedule_rounded, text: '${course.durationHours} ${'employee_courses.hours'.tr()}', color: colorScheme.tertiary),
          ],
          const SizedBox(height: 8),
          CourseDetailChip(icon: Icons.category_rounded, text: 'employee_courses.types.${course.courseType}'.tr(), color: colorScheme.secondary),

          if (course.status == 'rejected' && course.rejectionReason != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: colorScheme.error.withOpacity(0.08), borderRadius: BorderRadius.circular(10), border: Border.all(color: colorScheme.error.withOpacity(0.2))),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.error_outline, color: colorScheme.error, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text('${'employee_courses.rejection_reason'.tr()}: ${course.rejectionReason}', style: TextStyle(fontSize: 12, color: colorScheme.error))),
                ],
              ),
            ),
          ],

          if (course.certificateFileUrl != null) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _showCertificateViewer(context, course.certificateFileUrl!),
              // ✅ التعديل هنا: تمرير الـ context للدالة
              child: _buildCertificatePreview(context, colorScheme),
            ),
          ],

          const SizedBox(height: 12),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton.icon(
              onPressed: () => _confirmDelete(context),
              icon: Icon(Icons.delete_outline, size: 16, color: isDark?Colors.white:Colors.black),
              label: Text('common.delete'.tr(), style: TextStyle(color: isDark?Colors.white:Colors.black, fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(IconData icon, Color color, String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4), width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 5),
          Text(
            'employee_courses.status.$status'.tr(), 
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  // ✅ التعديل هنا: استقبال الـ context كمدخل
  Widget _buildCertificatePreview(BuildContext context, ColorScheme colorScheme) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: colorScheme.secondary.withOpacity(0.3))),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: course.certificateFileType == 'pdf'
            ? Container(
                color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.picture_as_pdf, size: 40, color: isDark ? Colors.white : Colors.black),
                      const SizedBox(height: 4),
                      Text(
                        'employee_courses.view_pdf'.tr(), 
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black, 
                          fontWeight: FontWeight.bold, 
                          fontSize: 12
                        )
                      ),
                    ]
                  ),
                ),
              )
            : CachedNetworkImage(
                imageUrl: course.certificateFileUrl!, 
                fit: BoxFit.cover, 
                placeholder: (_,__) => Center(child: CircularProgressIndicator(color: colorScheme.secondary, strokeWidth: 2)), 
                errorWidget: (_,__,___) => Icon(Icons.broken_image, color: colorScheme.outline, size: 40)
              ),
      ),
    );
  }

  void _showCertificateViewer(BuildContext context, String url) {
    if (course.certificateFileType == 'pdf') {
      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      showDialog(context: context, builder: (ctx) => Dialog(child: ClipRRect(borderRadius: BorderRadius.circular(16), child: InteractiveViewer(minScale: 0.5, maxScale: 4.0, child: CachedNetworkImage(imageUrl: url, fit: BoxFit.contain)))));
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final colorScheme = Theme.of(context).colorScheme;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text('employee_courses.delete_confirm_title'.tr()),
        content: Text('employee_courses.delete_confirm_body'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false), 
            child: Text('common.cancel'.tr(), style: TextStyle(color: colorScheme.onSurface)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true), 
            child: Text('common.delete'.tr(), style: TextStyle(color: colorScheme.error)),
          ),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      context.read<EmployeeCoursesCubit>().deleteCourse(course);
    }
  }

  Color _getStatusColor(String status, ColorScheme colorScheme) {
    switch (status) {
      case 'approved': return Colors.green.shade700; 
      case 'rejected': return Colors.red.shade600;  
      case 'pending': return Colors.amber.shade700; 
      default: return colorScheme.primary;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'approved': return Icons.check_circle;
      case 'rejected': return Icons.cancel;
      case 'pending': return Icons.hourglass_top; 
      default: return Icons.help_outline;
    }
  }
}