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
    'employee_review_screen',
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
    'nomination_request_details',
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
    final Map<String, dynamic> mergedTranslations = {};

    for (final fileName in fileNames) {
      final filePath = '$path/$localeCode/$fileName.json';
      
      try {
        final jsonString = await rootBundle.loadString(filePath);
        final Map<String, dynamic> translations = json.decode(jsonString);
        _deepMerge(mergedTranslations, translations);
      } catch (e) {
        // لو في ملف مش موجود في لغة معينة، هيطبع التحذير ده ومش هيقف التطبيق
        print(' Loader: Could not load $filePath. Error: $e');
      }
    }

    print(' Loader: Merged Translations Keys: ${mergedTranslations.keys.toList()}');
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