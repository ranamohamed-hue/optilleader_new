import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:optialeader/core/theming/app_color.dart';
import 'package:optialeader/core/routing/routes.dart';

class AdminRequestTypeDialog extends StatelessWidget {
  const AdminRequestTypeDialog({super.key});

  static Future<void> show(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (_) => const AdminRequestTypeDialog(),
    );
  }

  void _openDoctorRequests(BuildContext context) {
    Navigator.of(context).pop();

    context.push(Routes.ordersList);
  }

  void _openEmployeeRequests(BuildContext context) {
    Navigator.of(context).pop();

    context.push(Routes.employeePendingRequests);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.assignment_rounded,
              size: 50.sp,
              color: AppColors.darkGold,
            ),

            SizedBox(height: 12.h),

            Text(
              'اختيار نوع الطلبات',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 8.h),

            Text(
              'اختاري نوع الطلبات التي تريدين إدارتها',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 24.h),

            _RequestTypeButton(
              icon: Icons.school_rounded,
              title: 'طلبات ترشيح الأطباء',
              color: colorScheme.primary,
              onTap: () => _openDoctorRequests(context),
            ),

            SizedBox(height: 14.h),

            _RequestTypeButton(
              icon: Icons.badge_rounded,
              title: 'طلبات ترشيح الموظفين',
              color: AppColors.darkGold,
              onTap: () => _openEmployeeRequests(context),
            ),

            SizedBox(height: 10.h),

            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RequestTypeButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _RequestTypeButton({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58.h,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(
          title,
          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
      ),
    );
  }
}
