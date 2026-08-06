import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:optialeader/feature/database_admin/data/models/employee_model.dart';
import 'package:optialeader/feature/database_admin/logic/employee_logic/employee_cubit.dart';
import 'package:optialeader/feature/database_admin/logic/employee_logic/employee_state.dart';
import 'package:easy_localization/easy_localization.dart';

class AddEmployeePage extends StatefulWidget {
  const AddEmployeePage({super.key});

  @override
  State<AddEmployeePage> createState() => _AddEmployeePageState();
}

class _AddEmployeePageState extends State<AddEmployeePage> {
  final _formKey = GlobalKey<FormState>();

  final _nameArController = TextEditingController();
  final _nameEnController = TextEditingController();
  final _nationalityArController = TextEditingController(text: 'مصري');
  final _nationalityEnController = TextEditingController(text: 'Egyptian');
  final _nationalIdController = TextEditingController();
  final _employeeIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _jobArController = TextEditingController();
  final _jobEnController = TextEditingController();
  final _degreeController = TextEditingController(text: 'بكالوريوس');
  final _gradYearController = TextEditingController();
  final _experienceController = TextEditingController(text: '10');

  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  bool _hasCriminalRecord = false;
  bool _holdsPartyPosition = false;
  bool _disciplinaryClearance = true;
  bool _hasExcellentReports = false;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final employee = EmployeeModel(
      uid: '',
      nameAr: _nameArController.text.trim(),
      nameEn: _nameEnController.text.trim(),
      nationalityAr: _nationalityArController.text.trim(),
      nationalityEn: _nationalityEnController.text.trim(),
      nationalId: _nationalIdController.text.trim(),
      employeeId: _employeeIdController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      currentJobAr: _jobArController.text.trim(),
      currentJobEn: _jobEnController.text.trim(),
      degree: _degreeController.text.trim(),
      graduationYear: _gradYearController.text.trim(),
      yearsOfAdminExperience:
          int.tryParse(_experienceController.text.trim()) ?? 0,
      profileImage: '',
      hasCriminalRecord: _hasCriminalRecord,
      holdsPartyPosition: _holdsPartyPosition,
      disciplinaryClearance: _disciplinaryClearance,
      hasExcellentPerformanceReports: _hasExcellentReports,
      createdAt: DateTime.now(),
    );

    // ✅ تمرير الصورة هنا
    context.read<EmployeeDataCubit>().createNewEmployee(
      employee,
      profileImageFile: _profileImage,
    );
  }

  @override
  void dispose() {
    _nameArController.dispose();
    _nameEnController.dispose();
    _nationalIdController.dispose();
    _employeeIdController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _jobArController.dispose();
    _jobEnController.dispose();
    _gradYearController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocConsumer<EmployeeDataCubit, EmployeeDataState>(
      listener: (context, state) {
        if (state is EmployeeSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('add_employee.success_message'.tr()),
              backgroundColor: Colors.green,
            ),
          );
          context.pop();
        } else if (state is EmployeeError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        bool isLoading = state is EmployeeLoading;
        return Scaffold(
          // ✅ إضافة .tr()
          appBar: AppBar(title: Text('add_employee.title'.tr())),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50.r,
                      backgroundColor: theme.primaryColor.withOpacity(0.1),
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : null,
                      child: _profileImage == null
                          ? Icon(
                              Icons.add_a_photo,
                              size: 30.sp,
                              color: theme.primaryColor,
                            )
                          : null,
                    ),
                  ),
                  SizedBox(height: 20.h),

                  _buildTextField(
                    _nameArController,
                    'add_employee.fields.name_ar'.tr(),
                    isRequired: true,
                  ),
                  _buildTextField(
                    _nameEnController,
                    'add_employee.fields.name_en'.tr(),
                    isRequired: true,
                  ),
                  _buildTextField(
                    _nationalIdController,
                    'add_employee.fields.national_id'.tr(),
                    isRequired: true,
                    keyboardType: TextInputType.number,
                  ),
                  _buildTextField(
                    _employeeIdController,
                    'add_employee.fields.employee_id'.tr(),
                    isRequired: true,
                  ),
                  _buildTextField(
                    _emailController,
                    'add_employee.fields.email'.tr(),
                    isRequired: true,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  _buildTextField(
                    _phoneController,
                    'add_employee.fields.phone'.tr(),
                    isRequired: true,
                    keyboardType: TextInputType.phone,
                  ),
                  _buildTextField(
                    _jobArController,
                    'add_employee.fields.job_ar'.tr(),
                    isRequired: true,
                  ),
                  _buildTextField(
                    _jobEnController,
                    'add_employee.fields.job_en'.tr(),
                  ),
                  _buildTextField(
                    _degreeController,
                    'add_employee.fields.degree'.tr(),
                    isRequired: true,
                  ),
                  _buildTextField(
                    _gradYearController,
                    'add_employee.fields.grad_year'.tr(),
                    isRequired: true,
                    keyboardType: TextInputType.number,
                  ),
                  _buildTextField(
                    _experienceController,
                    'add_employee.fields.experience_years'.tr(),
                    isRequired: true,
                    keyboardType: TextInputType.number,
                  ),

                  SizedBox(height: 10.h),
                  _buildSwitchTile(
                    'add_employee.fields.criminal_record'.tr(),
                    _hasCriminalRecord,
                    (val) => setState(() => _hasCriminalRecord = val),
                  ),
                  _buildSwitchTile(
                    'add_employee.fields.party_position'.tr(),
                    _holdsPartyPosition,
                    (val) => setState(() => _holdsPartyPosition = val),
                  ),
                  _buildSwitchTile(
                    'add_employee.fields.disciplinary_clearance'.tr(),
                    !_disciplinaryClearance,
                    (val) => setState(() => _disciplinaryClearance = !val),
                  ),
                  _buildSwitchTile(
                    'add_employee.fields.excellent_reports'.tr(),
                    _hasExcellentReports,
                    (val) => setState(() => _hasExcellentReports = val),
                  ),

                  SizedBox(height: 30.h),
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'add_employee.save_data'.tr(), // ✅ إضافة .tr()
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool isRequired = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          // ✅ تعديل مسار الترجمة
          if (isRequired && (value == null || value.trim().isEmpty)) {
            return 'add_employee.fields.required'.tr();
          }
          return null;
        },
      ),
    );
  }

  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title, style: TextStyle(fontSize: 14.sp)),
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
    );
  }
}
