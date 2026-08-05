import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';

import 'package:optialeader/core/theming/app_color.dart';
import 'package:optialeader/core/theming/app_text_style.dart';
import 'package:optialeader/feature/database_admin/data/models/doctor_profile_model.dart';
import 'package:optialeader/feature/database_admin/logic/doctor_data/doctor_data_cubit.dart';
import 'package:optialeader/feature/database_admin/logic/doctor_data/doctor_data_state.dart';

class AcademicControllers {
  final TextEditingController degree = TextEditingController();
  final TextEditingController major = TextEditingController();
  final TextEditingController place = TextEditingController();

  DateTime? date;
  String type = 'degree';

  void dispose() {
    degree.dispose();
    major.dispose();
    place.dispose();
  }

  void clear() {
    degree.clear();
    major.clear();
    place.clear();
    date = null;
    type = 'degree';
  }

  Map<String, dynamic> toMap() {
    return {
      'degree': degree.text.trim(),
      'major': major.text.trim(),
      'date': date != null ? Timestamp.fromDate(date!) : null,
      'place': place.text.trim(),
      'type': type,
    };
  }
}

class AddDoctorPage extends StatefulWidget {
  final String? existingUid;
  final bool isViewMode;

  const AddDoctorPage({super.key, this.existingUid, this.isViewMode = false});

  @override
  State<AddDoctorPage> createState() => _AddDoctorPageState();
}

class _AddDoctorPageState extends State<AddDoctorPage> {
  final _formKey = GlobalKey<FormState>();

  DoctorProfileModel? _existingDoctor;

  final _nameAr = TextEditingController();
  final _nameEn = TextEditingController();
  final _nationalityAr = TextEditingController();
  final _nationalityEn = TextEditingController();
  final _currentJobAr = TextEditingController();
  final _currentJobEn = TextEditingController();

  final _universityAr = TextEditingController();
  final _universityEn = TextEditingController();
  final _facultyAr = TextEditingController();
  final _facultyEn = TextEditingController();
  final _departmentAr = TextEditingController();
  final _departmentEn = TextEditingController();

  final _collageAr = TextEditingController();
  final _collageEn = TextEditingController();

  final _nationalId = TextEditingController();
  final _employeeId = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _addressAr = TextEditingController();
  final _addressEn = TextEditingController();

  DateTime? birthDate;
  DateTime? professorRankDate;
  DateTime? hiringDate;

  bool _hasBeenDean = false;
  bool _hasBeenHead = false;
  bool hasCriminalRecord = false;
  bool holdsPartyPosition = false;

  final List<String> _internalCommittees = [];
  final _committeeNameController = TextEditingController();

  final Map<String, String> statusMapping = {
    "أعزب": "Single",
    "متزوج": "Married",
    "أرمل": "Widowed",
    "مطلق": "Divorced",
  };
  String? selectedStatusAr;
  String? selectedStatusEn;

  final List<String> academicTypes = ['degree', 'promotion', 'certificate'];

  List<AcademicControllers> academicControllersList = [];
  List<Map<String, dynamic>> _digitalArchive = [];

  bool isOnVacation = false;
  bool hasPermanentPosition = true;
  bool disciplinaryClearance = true;

  // ✅ حقول القانون الجديد
  bool isOnSecondment = false;
  bool isOnUnpaidLeave = false;
  DateTime? activeDutySinceDate;
  bool hasSupremeCouncilTraining = false;
  bool hasFLDCTraining = false;

  bool _isReadOnly = true;
  String _currentImageUrl = '';

  XFile? _pickedImageFile;

  bool get isArabic => context.locale.languageCode == 'ar';
  bool get isEditing => widget.existingUid != null;

  @override
  void initState() {
    super.initState();
    _isReadOnly = widget.isViewMode;
    if (isEditing) {
      context.read<DoctorDataCubit>().getDoctorProfile(widget.existingUid!);
    }
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.r),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: AppColors.error,
              size: 28.sp,
            ),
            SizedBox(width: 10.w),
            Text('add_doctor.delete_confirm_title'.tr()),
          ],
        ),
        content: Text(
          'add_doctor.delete_confirm_body'.tr(),
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.navyDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              "common.cancel".tr(),
              style: TextStyle(color: AppColors.navyLight),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<DoctorDataCubit>().deleteDoctor(widget.existingUid!);
            },
            child: Text(
              'add_doctor.permanent_delete'.tr(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in academicControllersList) {
      controller.dispose();
    }
    _nameAr.dispose();
    _nameEn.dispose();
    _nationalityAr.dispose();
    _nationalityEn.dispose();
    _currentJobAr.dispose();
    _currentJobEn.dispose();
    _universityAr.dispose();
    _universityEn.dispose();
    _facultyAr.dispose();
    _facultyEn.dispose();
    _departmentAr.dispose();
    _departmentEn.dispose();
    _collageAr.dispose();
    _collageEn.dispose();
    _nationalId.dispose();
    _employeeId.dispose();
    _email.dispose();
    _phone.dispose();
    _addressAr.dispose();
    _addressEn.dispose();
    _committeeNameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (pickedFile != null) {
      if (isEditing && widget.existingUid != null) {
        context.read<DoctorDataCubit>().uploadAndSetProfileImage(
          widget.existingUid!,
          File(pickedFile.path),
        );
      } else {
        setState(() {
          _pickedImageFile = pickedFile;
          _currentImageUrl = '';
        });
      }
    }
  }

  Future<void> _pickAndUploadArchiveFile() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );
    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) =>
            _ArchiveFileDialog(file: file, uid: widget.existingUid!),
      );
    }
  }

  void _resetForm() {
    setState(() {
      _formKey.currentState?.reset();
      _nameAr.clear();
      _nameEn.clear();
      _nationalityAr.clear();
      _nationalityEn.clear();
      _currentJobAr.clear();
      _currentJobEn.clear();
      _universityAr.clear();
      _universityEn.clear();
      _facultyAr.clear();
      _facultyEn.clear();
      _departmentAr.clear();
      _departmentEn.clear();
      _collageAr.clear();
      _collageEn.clear();
      _nationalId.clear();
      _employeeId.clear();
      _email.clear();
      _phone.clear();
      _addressAr.clear();
      _addressEn.clear();
      for (var ctrl in academicControllersList) {
        ctrl.clear();
      }
      academicControllersList.clear();
      _digitalArchive.clear();
      _internalCommittees.clear();
      birthDate = null;
      professorRankDate = null;
      hiringDate = null;
      selectedStatusAr = null;
      selectedStatusEn = null;
      _pickedImageFile = null;
      _currentImageUrl = '';
      _existingDoctor = null;

      // ✅ مسح حقول القانون الجديد
      isOnSecondment = false;
      isOnUnpaidLeave = false;
      activeDutySinceDate = null;
      hasSupremeCouncilTraining = false;
      hasFLDCTraining = false;
    });
  }

  void _addCommittee() {
    final name = _committeeNameController.text.trim();
    if (name.isEmpty) return;
    setState(() {
      _internalCommittees.add(name);
      _committeeNameController.clear();
    });
  }

  void _removeCommittee(int index) {
    setState(() {
      _internalCommittees.removeAt(index);
    });
  }

  void _onSavePressed() {
    if (_formKey.currentState!.validate()) {
      if (birthDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("add_doctor.validate_birth_date".tr())),
        );
        return;
      }

      final previousRoles = <String>[];
      if (_hasBeenDean) previousRoles.add('dean');
      if (_hasBeenHead) previousRoles.add('head_department');

      final doctorModel = DoctorProfileModel(
        uid: '',
        nameAr: _nameAr.text.trim(),
        nameEn: _nameEn.text.trim(),
        nationalityAr: _nationalityAr.text.trim(),
        nationalityEn: _nationalityEn.text.trim(),
        currentJobAr: _currentJobAr.text.trim(),
        currentJobEn: _currentJobEn.text.trim(),
        universityAr: _universityAr.text.trim(),
        universityEn: _universityEn.text.trim(),
        facultyAr: _facultyAr.text.trim(),
        facultyEn: _facultyEn.text.trim(),
        departmentAr: _departmentAr.text.trim(),
        departmentEn: _departmentEn.text.trim(),
        collageAr: _collageAr.text.trim(),
        collageEn: _collageEn.text.trim(),
        professorRankDate: professorRankDate,
        hiringDate: hiringDate,
        previousLeadershipRoles: previousRoles,
        hasCriminalRecord: hasCriminalRecord,
        holdsPartyPosition: holdsPartyPosition,
        socialStatusAr: selectedStatusAr ?? '',
        socialStatusEn: selectedStatusEn ?? '',
        nationalId: _nationalId.text.trim(),
        employeeId: _employeeId.text.trim(),
        birthDate: birthDate,
        profileImage: _currentImageUrl,
        email: _email.text.trim(),
        phone: _phone.text.trim(),
        addressAr: _addressAr.text.trim(),
        addressEn: _addressEn.text.trim(),
        academicHistory: academicControllersList.map((e) => e.toMap()).toList(),
        disciplinaryClearance: disciplinaryClearance,
        hasPermanentPosition: hasPermanentPosition,
        isOnVacation: isOnVacation,
        isActive: true,
        digitalArchive: _digitalArchive,

        cvUrl: _existingDoctor?.cvUrl,
        alternativeEmail: _existingDoctor?.alternativeEmail,
        researchPapers: _existingDoctor?.researchPapers ?? const [],
        conferences: _existingDoctor?.conferences ?? const [],
        exhibitions: _existingDoctor?.exhibitions ?? const [],
        courses: _existingDoctor?.courses ?? const [],
        academicActivities: _existingDoctor?.academicActivities,

        internalCommittees: _internalCommittees,

        hasHealthCertificate: _existingDoctor?.hasHealthCertificate,
        hasCommitteeMembership: _existingDoctor?.hasCommitteeMembership,
        hasSelfEvaluationReport: _existingDoctor?.hasSelfEvaluationReport,
        hasArbitrationPlan: _existingDoctor?.hasArbitrationPlan,
        hasAdminExperience: _existingDoctor?.hasAdminExperience,
        hasExcellentPerformanceReports:
            _existingDoctor?.hasExcellentPerformanceReports,
        isTop3Senior: _existingDoctor?.isTop3Senior,

        // ✅ حفظ حقول القانون الجديد
        isOnSecondment: isOnSecondment,
        isOnUnpaidLeave: isOnUnpaidLeave,
        activeDutySinceDate: activeDutySinceDate,
        hasSupremeCouncilTraining: hasSupremeCouncilTraining,
        hasFLDCTraining: hasFLDCTraining,
        workPlanFileUrl: _existingDoctor?.workPlanFileUrl,
        workPlanStatus: _existingDoctor?.workPlanStatus,
      );

      if (isEditing) {
        final updatedDoctor = doctorModel.copyWith(uid: widget.existingUid!);
        context.read<DoctorDataCubit>().saveDoctorData(updatedDoctor);
      } else {
        context.read<DoctorDataCubit>().createNewDoctor(doctorModel);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<DoctorDataCubit, DoctorDataState>(
      listenWhen: (prev, curr) =>
          curr is DoctorSuccess || curr is DoctorError || curr is DoctorLoaded,
      listener: (context, state) {
        if (state is DoctorLoaded) {
          final doc = state.doctor!;

          _existingDoctor = doc;

          _nameAr.text = doc.nameAr;
          _nameEn.text = doc.nameEn;
          _nationalityAr.text = doc.nationalityAr;
          _nationalityEn.text = doc.nationalityEn;
          _currentJobAr.text = doc.currentJobAr;
          _currentJobEn.text = doc.currentJobEn;
          _universityAr.text = doc.universityAr;
          _universityEn.text = doc.universityEn;
          _facultyAr.text = doc.facultyAr;
          _facultyEn.text = doc.facultyEn;
          _departmentAr.text = doc.departmentAr;
          _departmentEn.text = doc.departmentEn;
          _collageAr.text = doc.collageAr;
          _collageEn.text = doc.collageEn;
          _nationalId.text = doc.nationalId;
          _employeeId.text = doc.employeeId;
          _email.text = doc.email;
          _phone.text = doc.phone;
          _addressAr.text = doc.addressAr;
          _addressEn.text = doc.addressEn;
          birthDate = doc.birthDate;
          selectedStatusAr = doc.socialStatusAr;
          selectedStatusEn = doc.socialStatusEn;
          disciplinaryClearance = doc.disciplinaryClearance;
          hasPermanentPosition = doc.hasPermanentPosition;
          isOnVacation = doc.isOnVacation;
          _currentImageUrl = doc.profileImage;

          professorRankDate = doc.professorRankDate;
          hiringDate = doc.hiringDate;

          _hasBeenDean = doc.previousLeadershipRoles.contains('dean');
          _hasBeenHead = doc.previousLeadershipRoles.contains(
            'head_department',
          );
          hasCriminalRecord = doc.hasCriminalRecord;
          holdsPartyPosition = doc.holdsPartyPosition;

          _internalCommittees.clear();
          _internalCommittees.addAll(doc.internalCommittees);

          // ✅ قراءة حقول القانون الجديد
          isOnSecondment = doc.isOnSecondment ?? false;
          isOnUnpaidLeave = doc.isOnUnpaidLeave ?? false;
          activeDutySinceDate = doc.activeDutySinceDate;
          hasSupremeCouncilTraining = doc.hasSupremeCouncilTraining ?? false;
          hasFLDCTraining = doc.hasFLDCTraining ?? false;

          academicControllersList.clear();
          for (var item in doc.academicHistory) {
            final ctrl = AcademicControllers();
            ctrl.degree.text = item['degree'] ?? '';
            ctrl.major.text = item['major'] ?? '';
            if (item['date'] is Timestamp) {
              ctrl.date = (item['date'] as Timestamp).toDate();
            }
            ctrl.place.text = item['place'] ?? '';
            ctrl.type = item['type'] ?? 'degree';
            academicControllersList.add(ctrl);
          }

          _digitalArchive = List.from(doc.digitalArchive);
          setState(() {});
        } else if (state is DoctorSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isEditing
                    ? "add_doctor.edit_success_msg".tr()
                    : "add_doctor.success_msg".tr(),
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else if (state is DoctorError) {
          String errorMessage = state.error ?? "error".tr();
          if (state.error == "ERROR_EMAIL_ALREADY_IN_USE") {
            errorMessage = "add_doctor.email_in_use".tr();
          } else if (state.error == "ERROR_WEAK_PASSWORD")
            errorMessage = "add_doctor.weak_password".tr();
          else if (state.error == "ERROR_USER_CREATION_FAILED" ||
              state.error == "ERROR_AUTH_UNKNOWN")
            errorMessage = "add_doctor.auth_error".tr();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _isReadOnly
                ? "add_doctor.view_profile".tr()
                : (isEditing
                      ? "add_doctor.edit_title".tr()
                      : "add_doctor.title".tr()),
            style: theme.appBarTheme.titleTextStyle,
          ),
          actions: [
            if (isEditing)
              IconButton(
                icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
                onPressed: _showDeleteConfirmationDialog,
              ),
            if (widget.existingUid != null)
              IconButton(
                icon: Icon(_isReadOnly ? Icons.edit : Icons.lock_open),
                onPressed: () => setState(() => _isReadOnly = !_isReadOnly),
              ),
            if (!_isReadOnly)
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _resetForm,
              ),
          ],
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              physics: const BouncingScrollPhysics(),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildProfileImage(),
                    SizedBox(height: 20.h),

                    _buildSectionCard(
                      "add_doctor.identity_job".tr(),
                      Icons.person_pin_rounded,
                      [
                        _buildVerticalDoubleField(
                          "add_doctor.name_ar".tr(),
                          _nameAr,
                          "add_doctor.name_en".tr(),
                          _nameEn,
                          Icons.person,
                        ),
                        SizedBox(height: 15.h),
                        _buildVerticalDoubleField(
                          "add_doctor.nat_ar".tr(),
                          _nationalityAr,
                          "add_doctor.nat_en".tr(),
                          _nationalityEn,
                          Icons.flag,
                        ),
                        SizedBox(height: 15.h),
                        _buildSocialStatusDropdown(),
                        SizedBox(height: 15.h),
                        _buildVerticalDoubleField(
                          "add_doctor.job_ar".tr(),
                          _currentJobAr,
                          "add_doctor.job_en".tr(),
                          _currentJobEn,
                          Icons.work,
                        ),
                        SizedBox(height: 15.h),
                        _buildVerticalDoubleField(
                          "add_doctor.university_ar".tr(),
                          _universityAr,
                          "add_doctor.university_en".tr(),
                          _universityEn,
                          Icons.account_balance,
                        ),
                        SizedBox(height: 15.h),
                        _buildVerticalDoubleField(
                          "add_doctor.faculty_ar".tr(),
                          _facultyAr,
                          "add_doctor.faculty_en".tr(),
                          _facultyEn,
                          Icons.school,
                        ),
                        SizedBox(height: 15.h),
                        _buildVerticalDoubleField(
                          "add_doctor.collage_ar".tr(),
                          _collageAr,
                          "add_doctor.collage_en".tr(),
                          _collageEn,
                          Icons.business,
                        ),
                        SizedBox(height: 15.h),
                        _buildVerticalDoubleField(
                          "add_doctor.department_ar".tr(),
                          _departmentAr,
                          "add_doctor.department_en".tr(),
                          _departmentEn,
                          Icons.category,
                        ),
                        SizedBox(height: 15.h),
                        Row(
                          children: [
                            Expanded(
                              child: _buildField(
                                "add_doctor.national_id".tr(),
                                _nationalId,
                                Icons.badge,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: _buildField(
                                "add_doctor.employee_id".tr(),
                                _employeeId,
                                Icons.work_history,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 15.h),
                        _buildDatePicker(
                          "add_doctor.birth_date".tr(),
                          birthDate,
                          (date) => setState(() => birthDate = date),
                        ),
                      ],
                    ),

                    _buildSectionCard(
                      "add_doctor.leadership_section".tr(),
                      Icons.military_tech,
                      [
                        _buildDatePicker(
                          "add_doctor.hiring_date".tr(),
                          hiringDate,
                          (date) => setState(() => hiringDate = date),
                        ),
                        SizedBox(height: 10.h),
                        _buildDatePicker(
                          "add_doctor.professor_rank_date".tr(),
                          professorRankDate,
                          (date) => setState(() => professorRankDate = date),
                        ),
                        SizedBox(height: 10.h),
                        _buildSwitch(
                          "add_doctor.been_dean".tr(),
                          _hasBeenDean,
                          (v) => setState(() => _hasBeenDean = v),
                        ),
                        _buildSwitch(
                          "add_doctor.been_head".tr(),
                          _hasBeenHead,
                          (v) => setState(() => _hasBeenHead = v),
                        ),
                        _buildSwitch(
                          "add_doctor.has_criminal_record".tr(),
                          hasCriminalRecord,
                          (v) => setState(() => hasCriminalRecord = v),
                        ),
                        _buildSwitch(
                          "add_doctor.holds_party_position".tr(),
                          holdsPartyPosition,
                          (v) => setState(() => holdsPartyPosition = v),
                        ),
                      ],
                    ),

                    _buildInternalCommitteesSection(),

                    _buildSectionCard(
                      "add_doctor.contact_info".tr(),
                      Icons.contact_phone,
                      [
                        _buildField(
                          "add_doctor.email".tr(),
                          _email,
                          Icons.alternate_email,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        _buildField(
                          "add_doctor.phone".tr(),
                          _phone,
                          Icons.phone_android,
                          keyboardType: TextInputType.phone,
                        ),
                        SizedBox(height: 15.h),
                        _buildVerticalDoubleField(
                          "add_doctor.address_ar".tr(),
                          _addressAr,
                          "add_doctor.address_en".tr(),
                          _addressEn,
                          Icons.location_on,
                        ),
                      ],
                    ),

                    _buildSectionCard(
                      "add_doctor.academic_history".tr(),
                      Icons.school,
                      [
                        ...academicControllersList.asMap().entries.map(
                          (entry) =>
                              _buildAcademicEntry(entry.key, entry.value),
                        ),
                        if (!_isReadOnly)
                          Center(
                            child: TextButton.icon(
                              onPressed: () => setState(
                                () => academicControllersList.add(
                                  AcademicControllers(),
                                ),
                              ),
                              icon: const Icon(
                                Icons.add_circle,
                                color: AppColors.darkGold,
                              ),
                              label: Text(
                                "add_doctor.add_degree".tr(),
                                style: TextStyle(color: AppColors.navyDark),
                              ),
                            ),
                          ),
                      ],
                    ),

                    if (isEditing) _buildDigitalArchiveSection(),

                    // ===== قسم الأهلية =====
                    _buildSectionCard(
                      "add_doctor.eligibility".tr(),
                      Icons.verified_user,
                      [
                        _buildSwitch(
                          "add_doctor.clearance".tr(),
                          disciplinaryClearance,
                          (v) => setState(() => disciplinaryClearance = v),
                        ),
                        _buildSwitch(
                          "add_doctor.permanent_pos".tr(),
                          hasPermanentPosition,
                          (v) => setState(() => hasPermanentPosition = v),
                        ),
                        _buildSwitch(
                          "add_doctor.on_vacation".tr(),
                          isOnVacation,
                          (v) => setState(() => isOnVacation = v),
                        ),

                        // ✅ إضافات القانون الجديد مع الترجمة
                        _buildSwitch(
                          "add_doctor.secondment".tr(),
                          isOnSecondment,
                          (v) => setState(() => isOnSecondment = v),
                        ),
                        _buildSwitch(
                          "add_doctor.unpaid_leave".tr(),
                          isOnUnpaidLeave,
                          (v) => setState(() => isOnUnpaidLeave = v),
                        ),
                        SizedBox(height: 15.h),
                        _buildDatePicker(
                          "add_doctor.active_duty_date".tr(),
                          activeDutySinceDate,
                          (date) => setState(() => activeDutySinceDate = date),
                        ),
                        SizedBox(height: 15.h),
                        _buildSwitch(
                          "add_doctor.supreme_council_training".tr(),
                          hasSupremeCouncilTraining,
                          (v) => setState(() => hasSupremeCouncilTraining = v),
                        ),
                        _buildSwitch(
                          "add_doctor.fldc_training".tr(),
                          hasFLDCTraining,
                          (v) => setState(() => hasFLDCTraining = v),
                        ),
                      ],
                    ),
                    SizedBox(height: 30.h),
                    if (!_isReadOnly) _buildSaveButton(),
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
            BlocBuilder<DoctorDataCubit, DoctorDataState>(
              builder: (context, state) {
                if (state is DoctorDeleting) {
                  return Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Center(
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.r),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(20.w),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircularProgressIndicator(
                                color: AppColors.error,
                              ),
                              SizedBox(height: 15.h),
                              Text(
                                'add_doctor.deleting_user'.tr(),
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.navyDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ويدجت قسم اللجان الداخلية
  // ============================================================
  Widget _buildInternalCommitteesSection() {
    return _buildSectionCard(
      "add_doctor.internal_committees".tr(),
      Icons.groups_rounded,
      [
        if (_internalCommittees.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h),
            child: Text(
              "add_doctor.no_committees".tr(),
              style: TextStyle(color: Colors.grey, fontSize: 13.sp),
            ),
          ),
        ..._internalCommittees.asMap().entries.map((entry) {
          final index = entry.key;
          final name = entry.value;
          return Container(
            margin: EdgeInsets.only(bottom: 8.h),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppColors.navyLight.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.commit_rounded,
                  size: 18.sp,
                  color: AppColors.darkGold,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    name,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.navyDark,
                    ),
                  ),
                ),
                if (!_isReadOnly)
                  IconButton(
                    onPressed: () => _removeCommittee(index),
                    icon: Icon(
                      Icons.close,
                      color: AppColors.error,
                      size: 20.sp,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
              ],
            ),
          );
        }),
        if (!_isReadOnly) ...[
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _committeeNameController,
                  enabled: !_isReadOnly,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.navyDark,
                  ),
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                  decoration: InputDecoration(
                    hintText: "add_doctor.committee_name_hint".tr(),
                    hintStyle: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.navyLight,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 10.h,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  onFieldSubmitted: (_) => _addCommittee(),
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.darkGold,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: IconButton(
                  onPressed: _addCommittee,
                  icon: Icon(Icons.add, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildDigitalArchiveSection() {
    return _buildSectionCard(
      "add_doctor.digital_archive".tr(),
      Icons.folder_open,
      [
        if (_digitalArchive.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h),
            child: Text(
              "add_doctor.no_archive".tr(),
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ..._digitalArchive.asMap().entries.map((entry) {
          final item = entry.value;
          return ListTile(
            leading: Icon(Icons.insert_drive_file, color: AppColors.navyLight),
            title: Text(
              item['title'] ?? 'Untitled',
              style: AppTextStyles.bodyMedium,
            ),
            subtitle: Text(
              item['uploaded_at'] ?? '',
              style: AppTextStyles.bodySmall,
            ),
            trailing: IconButton(
              icon: Icon(Icons.open_in_new, color: AppColors.darkGold),
              onPressed: () {},
            ),
          );
        }),
        if (!_isReadOnly)
          Center(
            child: OutlinedButton.icon(
              onPressed: _pickAndUploadArchiveFile,
              icon: Icon(Icons.upload_file, color: AppColors.navyDark),
              label: Text("add_doctor.upload_file".tr()),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.navyDark,
                side: BorderSide(color: AppColors.navyDark),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProfileImage() {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 50.r,
            backgroundColor: AppColors.navyLight.withOpacity(0.2),
            backgroundImage: _pickedImageFile != null
                ? FileImage(File(_pickedImageFile!.path)) as ImageProvider
                : (_currentImageUrl.isNotEmpty
                      ? CachedNetworkImageProvider(_currentImageUrl)
                      : null),
            child: (_pickedImageFile == null && _currentImageUrl.isEmpty)
                ? Icon(Icons.person, size: 50.sp, color: AppColors.navyLight)
                : null,
          ),
          if (!_isReadOnly)
            Positioned(
              bottom: 0,
              right: 0,
              child: CircleAvatar(
                radius: 18.r,
                backgroundColor: AppColors.darkGold,
                child: IconButton(
                  icon: Icon(Icons.camera_alt, size: 18.r, color: Colors.white),
                  onPressed: _pickImage,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, IconData icon, List<Widget> children) {
    return Card(
      color: Colors.white,
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
      margin: EdgeInsets.only(bottom: 20.h),
      child: Padding(
        padding: EdgeInsets.all(18.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.darkGold, size: 22.sp),
                SizedBox(width: 10.w),
                Text(
                  title,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.navyDark,
                  ),
                ),
              ],
            ),
            const Divider(height: 30),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController ctrl,
    IconData? icon, {
    bool isEn = false,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      enabled: !_isReadOnly,
      textAlign: isEn
          ? TextAlign.left
          : (isArabic ? TextAlign.right : TextAlign.left),
      validator: _isReadOnly
          ? null
          : (v) => v!.isEmpty ? "add_doctor.required".tr() : null,
      style: AppTextStyles.bodyMedium.copyWith(
        color: _isReadOnly ? Colors.grey : AppColors.navyDark,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null
            ? Icon(icon, color: AppColors.navyLight)
            : null,
        labelStyle: AppTextStyles.bodySmall.copyWith(
          color: AppColors.navyLight,
        ),
        filled: _isReadOnly,
        fillColor: _isReadOnly ? Colors.grey.shade200 : Colors.white,
      ),
    );
  }

  Widget _buildVerticalDoubleField(
    String labelAr,
    TextEditingController ctrlAr,
    String labelEn,
    TextEditingController ctrlEn,
    IconData icon,
  ) {
    return Column(
      children: [
        _buildField(labelAr, ctrlAr, icon),
        SizedBox(height: 8.h),
        _buildField(labelEn, ctrlEn, null, isEn: true),
      ],
    );
  }

  Widget _buildSocialStatusDropdown() {
    return Row(
      children: [
        Expanded(
          child: _buildDropdownField(
            "add_doctor.social_status".tr(),
            statusMapping.keys.toList(),
            selectedStatusAr,
            (val) => setState(() {
              selectedStatusAr = val;
              selectedStatusEn = statusMapping[val];
            }),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _buildDropdownField(
            "add_doctor.social_status".tr(),
            statusMapping.values.toList(),
            selectedStatusEn,
            (val) => setState(() {
              selectedStatusEn = val;
              selectedStatusAr = statusMapping.entries
                  .firstWhere((e) => e.value == val)
                  .key;
            }),
            isEn: true,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(
    String label,
    List<String> items,
    String? value,
    Function(String?) onChanged, {
    bool isEn = false,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items
          .map(
            (s) => DropdownMenuItem(
              value: s,
              child: Text(
                s,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.navyDark,
                ),
              ),
            ),
          )
          .toList(),
      onChanged: _isReadOnly ? null : onChanged,
      dropdownColor: Colors.white,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: isEn
            ? null
            : const Icon(Icons.info_outline, color: AppColors.navyLight),
        labelStyle: AppTextStyles.bodySmall.copyWith(
          color: AppColors.navyLight,
        ),
        filled: _isReadOnly,
        fillColor: _isReadOnly ? Colors.grey.shade200 : Colors.white,
      ),
    );
  }

  String _getAcademicTypeName(String type) {
    switch (type) {
      case 'degree':
        return 'add_doctor.type_degree'.tr();
      case 'promotion':
        return 'add_doctor.type_promotion'.tr();
      case 'certificate':
        return 'add_doctor.type_certificate'.tr();
      default:
        return type;
    }
  }

  Widget _buildAcademicEntry(int index, AcademicControllers controllers) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.navyLight.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${"add_doctor.entry".tr()} ${index + 1}",
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.navyDark,
                ),
              ),
              if (!_isReadOnly)
                IconButton(
                  onPressed: () =>
                      setState(() => academicControllersList.removeAt(index)),
                  icon: const Icon(
                    Icons.delete_forever,
                    color: AppColors.error,
                  ),
                ),
            ],
          ),
          SizedBox(height: 10.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: DropdownButton<String>(
              value: controllers.type,
              isExpanded: true,
              underline: SizedBox.shrink(),
              icon: Icon(
                Icons.arrow_drop_down,
                size: 20.sp,
                color: AppColors.navyDark,
              ),
              style: AppTextStyles.bodySmall,
              items: academicTypes.map((String type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(
                    _getAcademicTypeName(type),
                    style: AppTextStyles.bodySmall,
                  ),
                );
              }).toList(),
              onChanged: _isReadOnly
                  ? null
                  : (String? newValue) {
                      setState(() {
                        controllers.type = newValue!;
                        controllers.degree.clear();
                        controllers.major.clear();
                        controllers.place.clear();
                        controllers.date = null;
                      });
                    },
            ),
          ),
          SizedBox(height: 10.h),
          _buildSmallInput(
            controllers.type == 'degree'
                ? "add_doctor.degree_hint".tr()
                : "add_doctor.title_hint".tr(),
            controllers.degree,
          ),
          SizedBox(height: 8.h),
          if (controllers.type == 'degree') ...[
            _buildSmallInput("add_doctor.major_hint".tr(), controllers.major),
            SizedBox(height: 8.h),
          ],
          _buildSmallInput(
            controllers.type == 'degree'
                ? "add_doctor.university".tr()
                : "add_doctor.place_hint".tr(),
            controllers.place,
          ),
          SizedBox(height: 8.h),
          _buildDatePicker(
            controllers.type == 'promotion'
                ? "add_doctor.date_promo".tr()
                : "add_doctor.date_cert".tr(),
            controllers.date,
            (date) => setState(() => controllers.date = date),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallInput(String hint, TextEditingController ctrl) {
    return TextFormField(
      controller: ctrl,
      enabled: !_isReadOnly,
      style: AppTextStyles.bodySmall.copyWith(
        color: _isReadOnly ? Colors.grey : AppColors.navyDark,
      ),
      textAlign: isArabic ? TextAlign.right : TextAlign.left,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.navyLight),
        filled: true,
        fillColor: _isReadOnly ? Colors.grey.shade200 : Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      ),
    );
  }

  Widget _buildDatePicker(
    String label,
    DateTime? date,
    Function(DateTime) onPick,
  ) {
    return IgnorePointer(
      ignoring: _isReadOnly,
      child: InkWell(
        onTap: () async {
          DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime(1990),
            firstDate: DateTime(1950),
            lastDate: DateTime.now(),
          );
          if (picked != null) onPick(picked);
        },
        child: Container(
          padding: EdgeInsets.all(15.w),
          decoration: BoxDecoration(
            color: _isReadOnly ? Colors.grey.shade200 : Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                date == null ? label : DateFormat('yyyy-MM-dd').format(date),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: _isReadOnly ? Colors.grey : AppColors.navyDark,
                ),
              ),
              const Icon(Icons.calendar_month, color: AppColors.navyDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitch(String t, bool v, Function(bool) c) => SwitchListTile(
    title: Text(
      t,
      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.navyDark),
    ),
    value: v,
    onChanged: _isReadOnly ? null : c,
    activeThumbColor: AppColors.darkGold,
  );

  Widget _buildSaveButton() {
    return BlocBuilder<DoctorDataCubit, DoctorDataState>(
      builder: (context, state) {
        return SizedBox(
          width: double.infinity,
          height: 55.h,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.navyDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            onPressed: state is DoctorLoading ? null : _onSavePressed,
            child: state is DoctorLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                    isEditing
                        ? "add_doctor.save_changes".tr()
                        : "add_doctor.save_button".tr(),
                    style: AppTextStyles.labelLarge.copyWith(
                      color: Colors.white,
                    ),
                  ),
          ),
        );
      },
    );
  }
}

// ============================================================
// كلاس الـ Dialog الخاص بالأرشيف
// ============================================================
class _ArchiveFileDialog extends StatefulWidget {
  final File file;
  final String uid;
  const _ArchiveFileDialog({required this.file, required this.uid});

  @override
  State<_ArchiveFileDialog> createState() => _ArchiveFileDialogState();
}

class _ArchiveFileDialogState extends State<_ArchiveFileDialog> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _category = 'general';
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('add_doctor.archive_details'.tr()),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'add_doctor.file_title'.tr(),
              ),
            ),
            TextFormField(
              controller: _descController,
              decoration: InputDecoration(
                labelText: 'add_doctor.file_desc'.tr(),
              ),
            ),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: InputDecoration(
                labelText: 'add_doctor.file_category'.tr(),
              ),
              items: ['general', 'research', 'admin', 'other']
                  .map(
                    (c) => DropdownMenuItem(
                      value: c,
                      child: Text(c.toUpperCase()),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
            if (_isUploading)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isUploading ? null : () => Navigator.pop(context),
          child: Text('common.cancel'.tr()),
        ),
        ElevatedButton(
          onPressed: _isUploading
              ? null
              : () {
                  if (_titleController.text.isNotEmpty) {
                    setState(() => _isUploading = true);
                    context.read<DoctorDataCubit>().uploadArchiveFile(
                      uid: widget.uid,
                      file: widget.file,
                      title: _titleController.text,
                      description: _descController.text,
                      category: _category,
                    );
                    Navigator.pop(context);
                  }
                },
          child: Text('common.save'.tr()),
        ),
      ],
    );
  }
}
