import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WelcomeHelper {
  /// دالة للتحقق هل هو أول تسجيل دخول وعرض الديالوج
  static void checkAndShowWelcomeDialog(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final creationTime = user.metadata.creationTime;
    final lastSignInTime = user.metadata.lastSignInTime;

    // لو تاريخ إنشاء الحساب وآخر تسجيل دخول متقاربين (أقل من دقيقتين)، يبقى أول مرة يسجل
    if (creationTime != null && lastSignInTime != null) {
      final difference = lastSignInTime.difference(creationTime).inMinutes;
      
      // بنشرط أقل من دقيقتين عشان لو سجل خروج ودخل تاني في نفس الدقيقة يعتبر أول مرة
      if (difference < 2) {
        _showWelcomeDialog(context);
      }
    }
  }

  /// تصميم الديالوج الترحيبي المشترك
  static void _showWelcomeDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isArabic = context.locale.languageCode == 'ar';

    showDialog(
      context: context,
      barrierDismissible: false, // المستخدم لازم يضغط على الزر
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Row(
          children: [
            Icon(Icons.waving_hand_rounded, color: Colors.orange, size: 28.sp),
            SizedBox(width: 10.w),
            Text(
              isArabic ? 'أهلاً بك!' : 'Welcome!',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          isArabic
              ? 'يسعدنا انضمامك لمنصة OptiLeader.\nيمكنك البدء في استكشاف الميزات الخاصة بك من القائمة الجانبية.'
              : 'Welcome to OptiLeader platform.\nYou can start exploring your features from the side menu.',
          style: TextStyle(fontSize: 15.sp, height: 1.5),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                isArabic ? 'لنبدأ!' : "Let's Start!",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }
}