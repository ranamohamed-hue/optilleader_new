import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:optialeader/core/routing/routes.dart';

Future<void> showJudgeOrdersTypeDialog(
  BuildContext context,
) async {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final isDark = theme.brightness == Brightness.dark;

  await showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          'judge_orders.choose_type'.tr(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTypeOption(
              context: dialogContext,
              icon: Icons.school_outlined,
              title: 'doctor'.tr(),
              subtitle: 'judge_orders.doctor_requests'.tr(),
              colorScheme: colorScheme,
              isDark: isDark,
              onTap: () {
                Navigator.of(dialogContext).pop();

                context.push(
                  Routes.judgeOrderList,
                );
              },
            ),

            SizedBox(height: 12.h),

            _buildTypeOption(
              context: dialogContext,
              icon: Icons.badge_outlined,
              title: 'employee'.tr(),
              subtitle: 'judge_orders.employee_requests'.tr(),
              colorScheme: colorScheme,
              isDark: isDark,
              onTap: () {
                Navigator.of(dialogContext).pop();

                context.push(
                  Routes.employeeJudgeOrdersList,
                );
              },
            ),
          ],
        ),
      );
    },
  );
}

Widget _buildTypeOption({
  required BuildContext context,
  required IconData icon,
  required String title,
  required String subtitle,
  required ColorScheme colorScheme,
  required bool isDark,
  required VoidCallback onTap,
}) {
  final navy = colorScheme.primary;
  final gold = colorScheme.secondary;

  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16.r),
    child: Container(
      width: double.infinity,
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: isDark
            ? colorScheme.surfaceContainerHighest
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: navy.withOpacity(
            isDark ? 0.25 : 0.08,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              isDark ? 0.2 : 0.03,
            ),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50.w,
            height: 50.h,
            decoration: BoxDecoration(
              color: gold.withOpacity(
                isDark ? 0.18 : 0.1,
              ),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(
              icon,
              color: gold,
              size: 27.sp,
            ),
          ),

          SizedBox(width: 13.w),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),

                SizedBox(height: 4.h),

                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color:
                        colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          Icon(
            Icons.arrow_forward_ios,
            size: 16.sp,
            color: colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    ),
  );
}