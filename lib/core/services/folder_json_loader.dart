import 'dart:convert';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';

class FolderJsonLoader extends AssetLoader {
  const FolderJsonLoader();

  final List<String> fileNames = const [
    'acadimic_data',
    'add_admin',
    'add_doctor',
    'add_judge',
    'admin',
    'announce',
    'auth',
    'career_info',
    'dashboard',
    'dashboard_user',
    'database_admin_dashboard',
    'digital_archieve',
    'evaluation',
    'order',
    'report',
    'search',
    'setting',
    'uploadfiles',
    'employee_search',
    'add_files',
    'announcement_details_doctor',
    'user_list_page',
    'nomination_request',
    'admin_request',
    'employee_dashboard',
    'add_employee',
    'achievements_new',
    'system_scores',
    'employee_courses',
    'nomination_details',
    'pending_details',
    'evaluator_review', 
    'employee_review_scren'
  ];

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    final localeCode = locale.languageCode;
    
    // ✅ السحر هنا: نطلب من التطبيق تحميل كل الملفات في نفس الوقت (بالتوازي)
    final futures = fileNames.map((fileName) async {
      final filePath = '$path/$localeCode/$fileName.json';
      try {
        final jsonString = await rootBundle.loadString(filePath);
        return json.decode(jsonString) as Map<String, dynamic>;
      } catch (e) {
        // لو في ملف مش موجود، نرجع ماب فاضية عشان ما توقفش الباقي
        return <String, dynamic>{};
      }
    });

    // ننتظرهم كلهم يخلصوا مع بعض في نفس اللحظة
    final List<Map<String, dynamic>> results = await Future.wait(futures);

    // بعد ما كلهم وصلوا، ندمجهم بسرعة
    final Map<String, dynamic> mergedTranslations = {};
    for (var translations in results) {
      _deepMerge(mergedTranslations, translations);
    }

    print(' Loader: Merged ${fileNames.length} files successfully.');
    return mergedTranslations;
  }

  void _deepMerge(Map<String, dynamic> base, Map<String, dynamic> override) {
    override.forEach((key, value) {
      if (value is Map<String, dynamic> && base[key] is Map<String, dynamic>) {
        _deepMerge(base[key] as Map<String, dynamic>, value);
      } else {
        base[key] = value;
      }
    });
  }
}