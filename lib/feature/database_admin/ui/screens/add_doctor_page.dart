import 'dart:io';
import 'package:path/path.dart' as p;
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

import 'package:optialeader/feature/admin/ui/announces/mansoura_universities_data.dart';

class AcademicControllers {
  final TextEditingController degree = TextEditingController();
  final TextEditingController major = TextEditingController();
  final TextEditingController place = TextEditingController();

  DateTime? date;
  String type = 'بكالوريوس';

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
    type = 'بكالوريوس';
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

  final List<String> degreeLevelKeys = [
    'add_doctor.degree_bachelor',
    'add_doctor.degree_diploma',
    'add_doctor.degree_master',
    'add_doctor.degree_phd',
  ];

  final List<String> degreeLevelValues = [
    'بكالوريوس',
    'دبلومة',
    'ماجستير',
    'دكتوراه',
  ];

  List<AcademicControllers> academicControllersList = [];
  List<Map<String, dynamic>> _digitalArchive = [];

  bool isOnVacation = false;
  bool hasPermanentPosition = true;
  bool disciplinaryClearance = true;
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.r),
        ),
        backgroundColor: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: AppColors.error,
              size: 28.sp,
            ),
            SizedBox(width: 10.w),
            Text(
              'add_doctor.delete_confirm_title'.tr(),
              style: TextStyle(color: isDark ? Colors.white : AppColors.navyDark),
            ),
          ],
        ),
        content: Text(
          'add_doctor.delete_confirm_body'.tr(),
          style: AppTextStyles.bodyMedium.copyWith(
            color: isDark ? Colors.white70 : AppColors.navyDark,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              "common.cancel".tr(),
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.navyLight,
                fontWeight: FontWeight.w600,
              ),
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
     hasHealthCertificate:
    _existingDoctor?.hasHealthCertificate ?? false,

hasCommitteeMembership:
    _existingDoctor?.hasCommitteeMembership ?? false,

hasSelfEvaluationReport:
    _existingDoctor?.hasSelfEvaluationReport ?? false,

hasArbitrationPlan:
    _existingDoctor?.hasArbitrationPlan ?? false,

hasAdminExperience:
    _existingDoctor?.hasAdminExperience ?? false,

hasExcellentPerformanceReports:
    _existingDoctor?.hasExcellentPerformanceReports ?? false,

isTop3Senior:
    _existingDoctor?.isTop3Senior ?? false,

hasSupremeCouncilTraining:
    _existingDoctor?.hasSupremeCouncilTraining ?? false,

hasFLDCTraining:
    _existingDoctor?.hasFLDCTraining ?? false,
        isOnSecondment: isOnSecondment,
        isOnUnpaidLeave: isOnUnpaidLeave,
        activeDutySinceDate: activeDutySinceDate,
        workPlanFileUrl: _existingDoctor?.workPlanFileUrl,
        workPlanStatus: _existingDoctor?.workPlanStatus,
      );

      try {
        if (isEditing) {
          final updatedDoctor = doctorModel.copyWith(uid: widget.existingUid!);
          context.read<DoctorDataCubit>().saveDoctorData(updatedDoctor);
        } else {
          final File? imageFile = _pickedImageFile != null
              ? File(_pickedImageFile!.path)
              : null;
          context.read<DoctorDataCubit>().createNewDoctor(
                doctorModel,
                profileImageFile: imageFile,
              );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("خطأ أثناء الحفظ: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("يرجى ملء جميع الحقول المطلوبة"),
          backgroundColor: Colors.orange,
        ),
      );
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
          _nationalId.text = doc.nationalId;
          _employeeId.text = doc.employeeId;
          _email.text = doc.email;
          _phone.text = doc.phone;
          _addressAr.text = doc.addressAr;
          _addressEn.text = doc.addressEn;

          birthDate = DoctorProfileModel.normalizeDate(doc.birthDate);
          professorRankDate = DoctorProfileModel.normalizeDate(
            doc.professorRankDate,
          );
          hiringDate = DoctorProfileModel.normalizeDate(doc.hiringDate);
          activeDutySinceDate = DoctorProfileModel.normalizeDate(
            doc.activeDutySinceDate,
          );

          selectedStatusAr = doc.socialStatusAr;
          selectedStatusEn = doc.socialStatusEn;
          disciplinaryClearance = doc.disciplinaryClearance;
          hasPermanentPosition = doc.hasPermanentPosition;
          isOnVacation = doc.isOnVacation;
          _currentImageUrl = doc.profileImage;
          _hasBeenDean = doc.previousLeadershipRoles.contains('dean');
          _hasBeenHead = doc.previousLeadershipRoles.contains(
            'head_department',
          );
          hasCriminalRecord = doc.hasCriminalRecord;
          holdsPartyPosition = doc.holdsPartyPosition;
          _internalCommittees.clear();
          _internalCommittees.addAll(doc.internalCommittees);
          isOnSecondment = doc.isOnSecondment ?? false;
          isOnUnpaidLeave = doc.isOnUnpaidLeave ?? false;
          hasSupremeCouncilTraining = doc.hasSupremeCouncilTraining ?? false;
          hasFLDCTraining = doc.hasFLDCTraining ?? false;

          academicControllersList.clear();
          for (var item in doc.academicHistory) {
            final ctrl = AcademicControllers();
            ctrl.degree.text = item['degree'] ?? '';
            ctrl.major.text = item['major'] ?? '';
            ctrl.date = DoctorProfileModel.normalizeDate(item['date']);
            ctrl.place.text = item['place'] ?? '';
            ctrl.type = item['type'] ?? 'بكالوريوس';
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
          if (state.error == "ERROR_EMAIL_ALREADY_IN_USE")
            errorMessage = "add_doctor.email_in_use".tr();
          else if (state.error == "ERROR_WEAK_PASSWORD")
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
                        _buildFacultyDropdown(),
                        SizedBox(height: 15.h),
                        _buildDepartmentDropdown(),
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

  Widget _buildFacultyDropdown() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final faculties = MansouraUniversitiesData.faculties;
    final currentVal = isArabic ? _facultyAr.text : _facultyEn.text;
    final isValid = faculties.any(
      (f) => (isArabic ? f.nameAr : f.nameEn) == currentVal,
    );
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: _isReadOnly
        /////////////////////////////
        //////////////
        //////////
            ? (isDark ? Colors.grey.shade800 : Colors.grey.shade200)
            : (isDark ? const Color(0xFF2A2A3E) : Colors.white),
        border: Border.all(color: isDark ? Colors.white24 : Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentVal.isEmpty || !isValid ? null : currentVal,
          isExpanded: true,
          hint: Text(
            "الكلية",
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? Colors.white54 : AppColors.navyLight,
            ),
          ),
          icon: Icon(Icons.arrow_drop_down, color: isDark ? Colors.white70 : AppColors.navyDark),
          style: AppTextStyles.bodyMedium.copyWith(
            color: isDark ? Colors.white : AppColors.navyDark,
          ),
          dropdownColor: isDark ? const Color(0xFF1E1E2E) : Colors.white,
          items: faculties.map((f) {
            final name = isArabic ? f.nameAr : f.nameEn;
            return DropdownMenuItem(
              value: name,
              child: Text(
                name,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark ? Colors.white : AppColors.navyDark,
                ),
              ),
            );
          }).toList(),
          onChanged: _isReadOnly
              ? null
              : (String? val) {
                  if (val != null) {
                    final f = faculties.firstWhere(
                      (fac) => (isArabic ? fac.nameAr : fac.nameEn) == val,
                    );
                    setState(() {
                      _facultyAr.text = f.nameAr;
                      _facultyEn.text = f.nameEn;
                      _departmentAr.clear();
                      _departmentEn.clear();
                    });
                  }
                },
        ),
      ),
    );
  }

  Widget _buildDepartmentDropdown() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentFacVal = isArabic ? _facultyAr.text : _facultyEn.text;
    FacultyData selectedFaculty = MansouraUniversitiesData.faculties.firstWhere(
      (f) => (isArabic ? f.nameAr : f.nameEn) == currentFacVal,
      orElse: () => MansouraUniversitiesData.faculties.first,
    );
    final departments = selectedFaculty.departments;
    final currentDepVal = isArabic ? _departmentAr.text : _departmentEn.text;
    final isValid = departments.any(
      (d) => (isArabic ? d.nameAr : d.nameEn) == currentDepVal,
    );
    //////////////////////////////////////////
    //////////////////////////
    ///////////////
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: _isReadOnly
            ? (isDark ?  Colors.grey.shade800: Colors.grey.shade200)
            : (isDark ? const Color(0xFF2A2A3E) : Colors.white),
        border: Border.all(color: isDark ? Colors.white24 : Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentDepVal.isEmpty || !isValid ? null : currentDepVal,
          isExpanded: true,
          hint: Text(
            "القسم",
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? Colors.white54 : AppColors.navyLight,
            ),
          ),
          icon: Icon(Icons.arrow_drop_down, color: isDark ? Colors.white70 : AppColors.navyDark),
          style: AppTextStyles.bodyMedium.copyWith(
            color: isDark ? Colors.white : AppColors.navyDark,
          ),
          dropdownColor: isDark ? const Color(0xFF1E1E2E) : Colors.white,
          items: departments.map((d) {
            final name = isArabic ? d.nameAr : d.nameEn;
            return DropdownMenuItem(
              value: name,
              child: Text(
                name,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark ? Colors.white : AppColors.navyDark,
                ),
              ),
            );
          }).toList(),
          onChanged: _isReadOnly
              ? null
              : (String? val) {
                  if (val != null) {
                    final d = departments.firstWhere(
                      (dep) => (isArabic ? dep.nameAr : dep.nameEn) == val,
                    );
                    setState(() {
                      _departmentAr.text = d.nameAr;
                      _departmentEn.text = d.nameEn;
                    });
                  }
                },
        ),
      ),
    );
  }

  Widget _buildInternalCommitteesSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _buildSectionCard(
      "add_doctor.internal_committees".tr(),
      Icons.groups_rounded,
      [
        if (_internalCommittees.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h),
            child: Text(
              "add_doctor.no_committees".tr(),
              style: TextStyle(color: isDark ? Colors.white54 : Colors.grey, fontSize: 13.sp),
            ),
          ),
        ..._internalCommittees.asMap().entries.map((entry) {
          final index = entry.key;
          final name = entry.value;
          return Container(
            margin: EdgeInsets.only(bottom: 8.h),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: isDark ? Colors.white10 : AppColors.navyLight.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: isDark ? Colors.white24 : Colors.grey.shade300),
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
                      color: isDark ? Colors.white : AppColors.navyDark,
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
                    constraints: const BoxConstraints(),
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
                    color: isDark ? Colors.white : AppColors.navyDark,
                  ),
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                  decoration: InputDecoration(
                    hintText: "add_doctor.committee_name_hint".tr(),
                    hintStyle: AppTextStyles.bodySmall.copyWith(
                      color: isDark ? Colors.white54 : AppColors.navyLight,
                    ),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF2A2A3E) : Colors.white,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 10.h,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300),
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
                  icon: const Icon(Icons.add, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildDigitalArchiveSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _buildSectionCard(
      "add_doctor.digital_archive".tr(),
      Icons.folder_open,
      [
        if (_digitalArchive.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h),
            child: Text(
              "add_doctor.no_archive".tr(),
              style: TextStyle(color: isDark ? Colors.white54 : Colors.grey),
            ),
          ),
        ..._digitalArchive.asMap().entries.map((entry) {
          final item = entry.value;
          return ListTile(
            leading: Icon(Icons.insert_drive_file, color: isDark ? Colors.white70 : AppColors.navyLight),
            title: Text(
              item['title'] ?? 'Untitled',
              style: AppTextStyles.bodyMedium.copyWith(color: isDark ? Colors.white : AppColors.navyDark),
            ),
            subtitle: Text(
              item['uploaded_at'] ?? '',
              style: AppTextStyles.bodySmall.copyWith(color: isDark ? Colors.white54 : AppColors.navyLight),
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
              icon: Icon(Icons.upload_file, color: isDark ? Colors.white : AppColors.navyDark),
              label: Text("add_doctor.upload_file".tr(), style: TextStyle(color: isDark ? Colors.white : AppColors.navyDark)),
              style: OutlinedButton.styleFrom(
                foregroundColor: isDark ? Colors.white : AppColors.navyDark,
                side: BorderSide(color: isDark ? Colors.white54 : AppColors.navyDark),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
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
                    color: isDark ? Colors.white : AppColors.navyDark,
                  ),
                ),
              ],
            ),
            Divider(height: 30, color: isDark ? Colors.white24 : Colors.grey.shade300),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
        color: _isReadOnly
            ? (isDark ? Colors.white54 : Colors.grey)
            : (isDark ? Colors.white : AppColors.navyDark),
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null
            ? Icon(icon, color: isDark ? Colors.white70 : AppColors.navyLight)
            : null,
        labelStyle: AppTextStyles.bodySmall.copyWith(
          color: isDark ? Colors.white70 : AppColors.navyLight,
        ),
        filled: _isReadOnly,
        fillColor: _isReadOnly
            ? (isDark ? Colors.grey.shade800 : Colors.grey.shade200)
            : (isDark ? const Color(0xFF2A2A3E) : Colors.white),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: isDark ? Colors.white24 : Colors.grey.shade300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.darkGold, width: 1.5),
        ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DropdownButtonFormField<String>(
      value: value,
      items: items
          .map(
            (s) => DropdownMenuItem(
              value: s,
              child: Text(
                s,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isDark ? Colors.white : AppColors.navyDark,
                ),
              ),
            ),
          )
          .toList(),
      onChanged: _isReadOnly ? null : onChanged,
      dropdownColor: isDark ? const Color(0xFF1E1E2E) : Colors.white,
      icon: Icon(Icons.arrow_drop_down, color: isDark ? Colors.white70 : AppColors.navyDark),
      style: AppTextStyles.bodySmall.copyWith(
        color: isDark ? Colors.white : AppColors.navyDark,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: isEn
            ? null
            : Icon(Icons.info_outline, color: isDark ? Colors.white70 : AppColors.navyLight),
        labelStyle: AppTextStyles.bodySmall.copyWith(
          color: isDark ? Colors.white70 : AppColors.navyLight,
        ),
        filled: _isReadOnly,
        fillColor: _isReadOnly
            ? (isDark ? Colors.grey.shade800 : Colors.grey.shade200)
            : (isDark ? const Color(0xFF2A2A3E) : Colors.white),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: isDark ? Colors.white24 : Colors.grey.shade300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.darkGold, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildDatePicker(
    String label,
    DateTime? currentDate,
    Function(DateTime) onDateSelected,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      child: InkWell(
        onTap: _isReadOnly
            ? null
            : () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: currentDate ?? DateTime.now(),
                  firstDate: DateTime(1940),
                  lastDate: DateTime(2100),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: isDark
                            ? ColorScheme.dark(
                                primary: AppColors.darkGold,
                                onPrimary: Colors.white,
                                surface: const Color(0xFF1E1E2E),
                                onSurface: Colors.white,
                                onSurfaceVariant: Colors.white70,
                                error: AppColors.error,
                                onError: Colors.white,
                              )
                            : const ColorScheme.light(
                                primary: AppColors.navyDark,
                                onPrimary: Colors.white,
                                surface: Colors.white,
                                onSurface: AppColors.navyDark,
                                onSurfaceVariant: AppColors.navyLight,
                              ),
                        dialogBackgroundColor:
                            isDark ? const Color(0xFF1E1E2E) : Colors.white,
                        textButtonTheme: TextButtonThemeData(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        datePickerTheme: DatePickerThemeData(
                          backgroundColor:
                              isDark ? const Color(0xFF1E1E2E) : Colors.white,
                          headerBackgroundColor: isDark
                              ? const Color(0xFF2A2A3E)
                              : AppColors.navyDark,
                          headerForegroundColor: Colors.white,
                          dayForegroundColor:
                              WidgetStatePropertyAll(isDark ? Colors.white : AppColors.navyDark),
                          dayOverlayColor:
                              WidgetStatePropertyAll(AppColors.darkGold.withOpacity(0.3)),
                          todayForegroundColor:
                              WidgetStatePropertyAll(AppColors.darkGold),
                          yearForegroundColor:
                              WidgetStatePropertyAll(isDark ? Colors.white : AppColors.navyDark),
                          yearOverlayColor:
                              WidgetStatePropertyAll(AppColors.darkGold.withOpacity(0.3)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          elevation: 8,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) onDateSelected(picked);
              },
        borderRadius: BorderRadius.circular(12.r),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(
              Icons.calendar_today,
              color: isDark ? Colors.white70 : AppColors.navyLight,
              size: 20.sp,
            ),
            labelStyle: AppTextStyles.bodySmall.copyWith(
              color: isDark ? Colors.white70 : AppColors.navyLight,
            ),
            filled: _isReadOnly,
            fillColor: _isReadOnly
                ? (isDark ? Colors.grey.shade800 : Colors.grey.shade200)
                : (isDark ? const Color(0xFF2A2A3E) : Colors.white),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: isDark ? Colors.white24 : Colors.grey.shade300,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: AppColors.darkGold, width: 1.5),
            ),
            suffixIcon: Icon(
              Icons.arrow_drop_down,
              color: isDark ? Colors.white70 : AppColors.navyDark,
            ),
          ),
          child: Text(
            currentDate != null
                ? DateFormat('yyyy-MM-dd').format(currentDate)
                : "add_doctor.select_date".tr(),
            style: AppTextStyles.bodyMedium.copyWith(
              color: currentDate != null
                  ? (isDark ? Colors.white : AppColors.navyDark)
                  : (isDark ? Colors.white54 : AppColors.navyLight),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwitch(String label, bool value, Function(bool) onChanged) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SwitchListTile(
      title: Text(
        label,
        style: AppTextStyles.bodyMedium.copyWith(
          color: isDark ? Colors.white : AppColors.navyDark,
        ),
      ),
      value: value,
      activeColor: AppColors.darkGold,
      onChanged: _isReadOnly ? null : onChanged,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkGold,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        onPressed: _onSavePressed,
        child: Text(
          isEditing
              ? "add_doctor.save_changes".tr()
              : "add_doctor.save_button".tr(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildSmallInput(String label, TextEditingController ctrl) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextFormField(
      controller: ctrl,
      enabled: !_isReadOnly,
      style: AppTextStyles.bodySmall.copyWith(
        color: isDark ? Colors.white : AppColors.navyDark,
      ),
      textAlign: isArabic ? TextAlign.right : TextAlign.left,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.bodySmall.copyWith(
          color: isDark ? Colors.white70 : AppColors.navyLight,
        ),
        filled: true,
        fillColor: isDark ? const Color(0xFF2A2A3E) : Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: AppColors.darkGold, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildSmallDatePicker(
    String label,
    DateTime? currentDate,
    Function(DateTime) onDateSelected,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: _isReadOnly
          ? null
          : () async {
              DateTime? picked = await showDatePicker(
                context: context,
                initialDate: currentDate ?? DateTime.now(),
                firstDate: DateTime(1940),
                lastDate: DateTime(2100),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: isDark
                          ? ColorScheme.dark(
                              primary: AppColors.darkGold,
                              onPrimary: Colors.white,
                              surface: const Color(0xFF1E1E2E),
                              onSurface: Colors.white,
                              onSurfaceVariant: Colors.white70,
                            )
                          : const ColorScheme.light(
                              primary: AppColors.navyDark,
                              onPrimary: Colors.white,
                              surface: Colors.white,
                              onSurface: AppColors.navyDark,
                            ),
                      dialogBackgroundColor: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                      textButtonTheme: TextButtonThemeData(
                        style: TextButton.styleFrom(foregroundColor: Colors.white),
                      ),
                      datePickerTheme: DatePickerThemeData(
                        backgroundColor: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                        headerBackgroundColor: isDark ? const Color(0xFF2A2A3E) : AppColors.navyDark,
                        headerForegroundColor: Colors.white,
                        dayForegroundColor: WidgetStatePropertyAll(isDark ? Colors.white : AppColors.navyDark),
                        dayOverlayColor: WidgetStatePropertyAll(AppColors.darkGold.withOpacity(0.3)),
                        todayForegroundColor: WidgetStatePropertyAll(AppColors.darkGold),
                        yearForegroundColor: WidgetStatePropertyAll(isDark ? Colors.white : AppColors.navyDark),
                        yearOverlayColor: WidgetStatePropertyAll(AppColors.darkGold.withOpacity(0.3)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) onDateSelected(picked);
            },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTextStyles.bodySmall.copyWith(
            color: isDark ? Colors.white70 : AppColors.navyLight,
          ),
          filled: true,
          fillColor: isDark ? const Color(0xFF2A2A3E) : Colors.grey.shade50,
          contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: const BorderSide(color: AppColors.darkGold, width: 1.5),
          ),
          suffixIcon: Icon(Icons.calendar_today, size: 18.sp, color: isDark ? Colors.white70 : AppColors.navyLight),
        ),
        child: Text(
          currentDate != null
              ? DateFormat('yyyy-MM-dd').format(currentDate)
              : "add_doctor.select_date".tr(),
          style: AppTextStyles.bodySmall.copyWith(
            color: currentDate != null
                ? (isDark ? Colors.white : AppColors.navyDark)
                : (isDark ? Colors.white54 : AppColors.navyLight),
          ),
        ),
      ),
    );
  }

  Widget _buildAcademicEntry(int index, AcademicControllers controllers) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A3E).withOpacity(0.5) : AppColors.navyLight.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: isDark ? Colors.white24 : Colors.grey.shade300),
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
                  color: isDark ? Colors.white : AppColors.navyDark,
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
              color: isDark ? const Color(0xFF2A2A3E) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: isDark ? Colors.white24 : Colors.transparent),
            ),
            child: DropdownButton<String>(
              value: degreeLevelValues.contains(controllers.type)
                  ? controllers.type
                  : null,
              isExpanded: true,
              underline: const SizedBox.shrink(),
              icon: Icon(
                Icons.arrow_drop_down,
                size: 20.sp,
                color: isDark ? Colors.white70 : AppColors.navyDark,
              ),
              dropdownColor: isDark ? const Color(0xFF1E1E2E) : Colors.white,
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark ? Colors.white : AppColors.navyDark,
              ),
              items: List.generate(degreeLevelKeys.length, (index) {
                final key = degreeLevelKeys[index];
                final val = degreeLevelValues[index];
                final isHigherDegree = (val == 'ماجستير' || val == 'دكتوراه');
                return DropdownMenuItem(
                  value: val,
                  child: Text(
                    key.tr(),
                    style: isHigherDegree
                        ? AppTextStyles.bodySmall.copyWith(
                            color: isDark ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          )
                        : AppTextStyles.bodySmall.copyWith(
                            color: isDark ? Colors.white70 : AppColors.navyLight,
                          ),
                  ),
                );
              }),
              onChanged: _isReadOnly
                  ? null
                  : (String? newValue) {
                      if (newValue != null)
                        setState(() {
                          controllers.type = newValue;
                        });
                    },
            ),
          ),
          SizedBox(height: 10.h),
          _buildSmallInput("add_doctor.degree_hint".tr(), controllers.degree),
          SizedBox(height: 8.h),
          _buildSmallInput("add_doctor.major_hint".tr(), controllers.major),
          SizedBox(height: 8.h),
          _buildSmallInput("add_doctor.place_hint".tr(), controllers.place),
          SizedBox(height: 8.h),
          _buildSmallDatePicker(
            "add_doctor.date_granted".tr(),
            controllers.date,
            (date) => setState(() => controllers.date = date),
          ),
        ],
      ),
    );
  }
}

// ✅ دالة حوار رفع الأرشيف (افتراضية عشان الكود يشتغل)
class _ArchiveFileDialog extends StatefulWidget {
  final File file;
  final String uid;
  const _ArchiveFileDialog({required this.file, required this.uid});

  @override
  State<_ArchiveFileDialog> createState() => _ArchiveFileDialogState();
}

class _ArchiveFileDialogState extends State<_ArchiveFileDialog> {
  final _titleController = TextEditingController();
  bool _isUploading = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _upload() async {
    if (_titleController.text.trim().isEmpty) return;
    setState(() => _isUploading = true);
    
    // قم بوضع كود رفع الملف هنا باستخدام Cubit
    
    setState(() => _isUploading = false);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AlertDialog(
      backgroundColor: isDark ? const Color(0xFF1E1E2E) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
      title: Text(
        "add_doctor.archive_details".tr(),
        style: TextStyle(color: isDark ? Colors.white : AppColors.navyDark),
      ),
      content: TextFormField(
        controller: _titleController,
        style: TextStyle(color: isDark ? Colors.white : AppColors.navyDark),
        decoration: InputDecoration(
          labelText: "add_doctor.file_title".tr(),
          labelStyle: TextStyle(color: isDark ? Colors.white70 : AppColors.navyLight),
          filled: true,
          fillColor: isDark ? const Color(0xFF2A2A3E) : Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("common.cancel".tr(), style: TextStyle(color: isDark ? Colors.white : AppColors.navyLight)),
        ),
        ElevatedButton(
          onPressed: _isUploading ? null : _upload,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.darkGold,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
          ),
          child: _isUploading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white))
              : Text("common.save".tr(), style: const TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}