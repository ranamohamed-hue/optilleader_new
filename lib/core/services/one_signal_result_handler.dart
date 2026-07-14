import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

// ✅ نستورد الـ navigatorKey العام من ملف الراوتر
import 'package:optialeader/core/routing/app_router.dart' show navigatorKey;

class OneSignalResultHandler {
  // ✅ متغير لحفظ بيانات الإشعار مؤقتاً لو الـ Context مش جاهز بعد
  static Map<String, dynamic>? _pendingNotificationData;

  /// تهيئة الاستماع للإشعارات (تُستدعى مرة واحدة من main)
  static void init() {
    OneSignal.Notifications.addClickListener((event) {
      final data = event.notification.additionalData;

      if (data != null && data['screen'] == 'competition_results') {
        if (navigatorKey.currentContext != null) {
          _showDialogFromData(data);
        } else {
          _pendingNotificationData = data;
        }
      }
    });
  }

  /// فحص إذا فيه إشعار مستني
  static void checkPendingNotification() {
    if (_pendingNotificationData != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final context = navigatorKey.currentContext;
        if (context != null && _pendingNotificationData != null) {
          _showDialogFromData(_pendingNotificationData!);
          _pendingNotificationData = null;
        }
      });
    }
  }

  /// استخراج البيانات وعرض الـ Dialog
  static void _showDialogFromData(Map<String, dynamic> data) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    final isWinner = data['isWinner'] == 'true';
    final rank = int.tryParse(data['rank']?.toString() ?? '0') ?? 0;

    List<String> topThreeNames = [];
    try {
      if (data['topThree'] is String) {
        topThreeNames = List<String>.from(jsonDecode(data['topThree']));
      }
    } catch (e) {
      debugPrint('Error parsing topThree: $e');
    }

    showResultsDialog(
      context: context,
      isWinner: isWinner,
      rank: rank,
      topThreeNames: topThreeNames,
    );
  }

  /// النافذة اللي هتظهر للمتسابق
  static void showResultsDialog({
    required BuildContext context,
    required bool isWinner,
    required int rank,
    required List<String> topThreeNames,
  }) {
    final String personalMessage = isWinner
        ? '🎉 مبروك! لقد حصلت على المركز $rank. نتمنى لك التوفيق في المرحلة القادمة.'
        : 'نأسف، لم تكن من الفائزين هذه المرة. لا تيأس واستمر في التطوير، الفرص القادمة بانتظارك!';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            title: const Text(
              '🏆 إعلان نتيجة المسابقة',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                const Text(
                  'الثلاثة الأوائل:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                ...topThreeNames.asMap().entries.map((entry) {
                  final emojis = ['🥇', '🥈', '🥉'];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Text(emojis[entry.key]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const Divider(height: 30),
                Text(
                  personalMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: isWinner
                        ? Colors.green.shade700
                        : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('حسناً'),
              ),
            ],
          ),
        );
      },
    );
  }
}
