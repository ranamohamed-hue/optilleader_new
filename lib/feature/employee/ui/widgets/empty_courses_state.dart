import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class EmptyCoursesState extends StatelessWidget {
  const EmptyCoursesState({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school_outlined, size: 80, color: colorScheme.primary.withOpacity(0.2)),
          const SizedBox(height: 20),
          Text('employee_courses.no_courses'.tr(), style: TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('employee_courses.no_courses_hint'.tr(), style: TextStyle(fontSize: 13, color: colorScheme.outline), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}