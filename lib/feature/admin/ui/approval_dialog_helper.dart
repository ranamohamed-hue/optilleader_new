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
          title: const Text(
            'اختر نوع الاعتماد',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.school, color: Colors.blue),
                title: const Text(
                  'اعتماد أوراق أطباء / أعضاء هيئة تدريس',
                  style: TextStyle(fontSize: 14),
                ),
                onTap: () {
                  Navigator.pop(dialogContext); // إغلاق الديالوج
                  onDoctorTap(); // تنفيذ الانتقال لشاشة الأطباء
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.badge, color: Colors.green),
                title: const Text(
                  'اعتماد دورات موظفين',
                  style: TextStyle(fontSize: 14),
                ),
                onTap: () {
                  Navigator.pop(dialogContext); // إغلاق الديالوج
                  onEmployeeTap(); // تنفيذ الانتقال لشاشة الموظفين
                },
              ),
            ],
          ),
        );
      },
    );
  }
}