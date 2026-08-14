import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:optialeader/core/routing/routes.dart';
import 'package:optialeader/core/theming/app_color.dart';

class AdminApprovalTypeDialog extends StatelessWidget {
  const AdminApprovalTypeDialog({super.key});

  // ============================================================
  // SHOW
  // ============================================================

  static Future<void> show(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => const AdminApprovalTypeDialog(),
    );
  }

  // ============================================================
  // DOCTOR
  // ============================================================

  void _openDoctorApprovals(BuildContext context) {
    Navigator.of(context).pop();

    context.push(
      Routes.adminPendingRequestsPage,
    );
  }

  // ============================================================
  // EMPLOYEE
  // ============================================================

  void _openEmployeeApprovals(BuildContext context) {
    Navigator.of(context).pop();

    context.push(
      Routes.employeeCourseApprovalPage,
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ==================================================
            // HEADER ICON
            // ==================================================

            Container(
              width: 70.w,
              height: 70.w,
              decoration: BoxDecoration(
                color: AppColors.darkGold.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.verified_rounded,
                color: AppColors.darkGold,
                size: 38.sp,
              ),
            ),

            SizedBox(height: 14.h),

            // ==================================================
            // TITLE
            // ==================================================

            Text(
              'الموافقات',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 21.sp,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 8.h),

            Text(
              'اختاري نوع الإنجازات التي تريدين مراجعة طلبات الموافقة عليها',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
                fontSize: 14.sp,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 24.h),

            // ==================================================
            // DOCTOR APPROVALS
            // ==================================================

            _ApprovalButton(
              icon: Icons.school_rounded,
              title: 'موافقات إنجازات الأطباء',
              subtitle: 'الأبحاث والأنشطة والإنجازات الأكاديمية',
              color: colorScheme.primary,
              onTap: () {
                _openDoctorApprovals(context);
              },
            ),

            SizedBox(height: 14.h),

            // ==================================================
            // EMPLOYEE APPROVALS
            // ==================================================

            _ApprovalButton(
              icon: Icons.badge_rounded,
              title: 'موافقات إنجازات الموظفين',
              subtitle: 'الدورات والإنجازات الخاصة بالموظفين',
              color: AppColors.darkGold,
              onTap: () {
                _openEmployeeApprovals(context);
              },
            ),

            SizedBox(height: 12.h),

            // ==================================================
            // CANCEL
            // ==================================================

            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'إلغاء',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// APPROVAL BUTTON
// ================================================================

class _ApprovalButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ApprovalButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      child: Material(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18.r),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 15.h,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(
                color: color.withOpacity(0.25),
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 25.sp,
                  ),
                ),

                SizedBox(width: 14.w),

                // Text
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 15.sp,
                        ),
                      ),

                      SizedBox(height: 4.h),

                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withOpacity(0.65),
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 8.w),

                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16.sp,
                  color: color,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}