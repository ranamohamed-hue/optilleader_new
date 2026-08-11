import 'package:flutter/material.dart';

class CourseDetailChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const CourseDetailChip({super.key, required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context)
   {
     final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Icon(icon, size: 16, color: isDark?Colors.white:Colors.black),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ],
    );
  }
}