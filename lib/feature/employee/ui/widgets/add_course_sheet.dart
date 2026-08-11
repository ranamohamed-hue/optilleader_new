import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:optialeader/feature/employee/data/models/employee_course_model.dart';
import 'package:optialeader/feature/employee/logic/employee_courses_cubit.dart';
import 'package:optialeader/feature/employee/logic/employee_courses_state.dart';
import 'package:optialeader/feature/doctor/ui/widgets/file_picker_field.dart';
import 'package:optialeader/core/helper/file_halper.dart';

class AddCourseSheet extends StatefulWidget {
  final String uid;
  const AddCourseSheet({super.key, required this.uid});

  @override
  State<AddCourseSheet> createState() => _AddCourseSheetState();
}

class _AddCourseSheetState extends State<AddCourseSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _orgController = TextEditingController();
  final _hoursController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String _selectedType = 'general_admin';
  PickedFileData? _pickedFileData;

  @override
  void dispose() {
    _titleController.dispose();
    _orgController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_pickedFileData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('employee_courses.error_certificate_required'.tr())),
      );
      return;
    }

    final course = EmployeeCourseModel(
      title: _titleController.text.trim(),
      organization: _orgController.text.trim(),
      date: DateFormat.yMd(context.locale.languageCode).format(_selectedDate),
      durationHours: _hoursController.text.trim().isEmpty ? null : _hoursController.text.trim(),
      courseType: _selectedType,
      createdAt: DateTime.now(),
    );

    context.read<EmployeeCoursesCubit>().addCourse(
      uid: widget.uid,
      course: course,
      certificateFile: _pickedFileData!.file,
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    // ✅ تحديد الألوان الأساسية بناءً على وضع الثيم
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final hintColor = isDark ? Colors.white54 : Colors.black38;
    final iconColor = colorScheme.secondary; // اللون الذهبي أو الثانوي (ثابت في الوضعين)

    return BlocBuilder<EmployeeCoursesCubit, EmployeeCoursesState>(
      builder: (context, state) {
        final isUploading = state is EmployeeCoursesUploading;

        return Container(
          height: MediaQuery.of(context).size.height * 0.88,
          decoration: BoxDecoration(
            color: colorScheme.secondary,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Row(
                  children: [
                    Text(
                      'employee_courses.add_new_title'.tr(),
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold), // ✅ أبيض دائماً لأن الخلفية داكنة
                    ),
                    const Spacer(),
                    if (isUploading)
                      const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    else
                      IconButton(icon: const Icon(Icons.close, color: Colors.white70), onPressed: () => context.pop()),
                  ],
                ),
              ),
              Expanded(
                child: AbsorbPointer(
                  absorbing: isUploading,
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        _buildLabel('employee_courses.form.title'.tr(), Icons.title_rounded, textColor, iconColor),
                        _buildTextField(_titleController, 'employee_courses.form.hint_title'.tr(), textColor, hintColor, colorScheme),
                        const SizedBox(height: 20),
                        
                        _buildLabel('employee_courses.form.organization'.tr(), Icons.business_rounded, textColor, iconColor),
                        _buildTextField(_orgController, 'employee_courses.form.hint_org'.tr(), textColor, hintColor, colorScheme),
                        const SizedBox(height: 20),
                        
                        _buildLabel('employee_courses.form.type'.tr(), Icons.category_rounded, textColor, iconColor),
                        _buildTypeDropdown(textColor, hintColor, colorScheme),
                        const SizedBox(height: 20),
                        
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('employee_courses.form.date'.tr(), Icons.calendar_today_rounded, textColor, iconColor),
                                  _buildDateField(textColor, colorScheme),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('employee_courses.form.hours'.tr(), Icons.schedule_rounded, textColor, iconColor),
                                  _buildTextField(_hoursController, '24', textColor, hintColor, colorScheme, keyboardType: TextInputType.number),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),
                        
                        _buildLabel('employee_courses.form.certificate'.tr(), Icons.attach_file_rounded, textColor, iconColor),
                        const SizedBox(height: 8),
                        
                        FilePickerField(
                          label: 'employee_courses.form.hint_certificate'.tr(),
                          selectedFile: _pickedFileData,
                          onFileSelected: (file) => setState(() => _pickedFileData = file),
                          isRequired: true,
                        ),
                        
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: isUploading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.secondary,
                            foregroundColor: colorScheme.primary,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          child: Text(
                            'employee_courses.form.submit'.tr(),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Form UI Helpers (تم تعديلها لاستقبال الألوان الصريحة) ---

  Widget _buildLabel(String text, IconData icon, Color textColor, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textColor)),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, Color textColor, Color hintColor, ColorScheme colorScheme, {TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType ?? TextInputType.text,
      validator: (val) => val!.trim().isEmpty ? 'employee_courses.form.required'.tr() : null,
      style: TextStyle(color: textColor), // ✅ نص أسود أو أبيض
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: hintColor), // ✅ هينت رمادي متغير
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colorScheme.secondary, width: 1.5)),
      ),
    );
  }

  Widget _buildDateField(Color textColor, ColorScheme colorScheme) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(1990),
          lastDate: DateTime.now(),
        );
        if (picked != null) setState(() => _selectedDate = picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(DateFormat.yMd(context.locale.languageCode).format(_selectedDate), style: TextStyle(fontSize: 13, color: textColor)), // ✅ نص متغير
            Icon(Icons.calendar_month_rounded, size: 18, color: colorScheme.secondary),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeDropdown(Color textColor, Color hintColor, ColorScheme colorScheme) {
    final types = [
      'general_admin', 'leadership', 'hr_management', 'crisis_management', 
      'digital_transformation', 'project_management', 'quality_assurance'
    ];
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: types.contains(_selectedType) ? _selectedType : types.first,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: colorScheme.secondary),
          style: TextStyle(fontSize: 13, color: textColor), // ✅ نص متغير
          dropdownColor: colorScheme.surface,
          onChanged: (val) => setState(() => _selectedType = val!),
          items: types.map((t) => DropdownMenuItem(
            value: t, 
            child: Text('employee_courses.types.$t'.tr(), style: TextStyle(color: textColor)), // ✅ نص القائمة متغير
          )).toList(),
        ),
      ),
    );
  }
}