import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ApprovalDialogHelper {
  static void show(
    BuildContext context, {
    required VoidCallback onDoctorTap,
    required VoidCallback onEmployeeTap,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'approval_dialog.title'.tr(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.school,
                  color: Colors.blue,
                ),
                title: Text(
                  'approval_dialog.doctor'.tr(),
                  style: const TextStyle(fontSize: 14),
                ),
                onTap: () {
                  Navigator.pop(dialogContext);
                  onDoctorTap();
                },
              ),

              const Divider(),

              ListTile(
                leading: const Icon(
                  Icons.badge,
                  color: Colors.green,
                ),
                title: Text(
                  'approval_dialog.employee'.tr(),
                  style: const TextStyle(fontSize: 14),
                ),
                onTap: () {
                  Navigator.pop(dialogContext);
                  onEmployeeTap();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}