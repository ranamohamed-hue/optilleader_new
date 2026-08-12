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
import 'package:optialeader/feature/database_admin/data/models/job_history_model.dart';
import 'package:optialeader/core/theming/app_color.dart';
import 'package:optialeader/core/theming/app_text_style.dart';
import 'package:optialeader/feature/database_admin/data/models/doctor_profile_model.dart';
import 'package:optialeader/feature/database_admin/logic/doctor_data/doctor_data_cubit.dart';
import 'package:optialeader/feature/database_admin/logic/doctor_data/doctor_data_state.dart';

import 'package:optialeader/feature/admin/ui/announces/mansoura_universities_data.dart';

// ============================================================
//  كنترولر الشهادات الأكاديمية
// ============================================================
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

// ============================================================
//  كنترولر السجل الوظيفي
// ============================================================
class JobHistoryController {
  final TextEditingController titleAr = TextEditingController();
  final TextEditingController titleEn = TextEditingController();

  final TextEditingController placeAr = TextEditingController();
  final TextEditingController placeEn = TextEditingController();

  DateTime? startDate;
  DateTime? endDate;

  void dispose() {
    titleAr.dispose();
    titleEn.dispose();
    placeAr.dispose();
    placeEn.dispose();
  }

  void clear() {
    titleAr.clear();
    titleEn.clear();
    placeAr.clear();
    placeEn.clear();

    startDate = null;
    endDate = null;
  }

  JobHistory toModel() {
    return JobHistory(
      jobTitleAr: titleAr.text.trim(),
      jobTitleEn: titleEn.text.trim(),
      startDate: startDate ?? DateTime.now(),
      endDate: endDate,
      placeAr: placeAr.text.trim(),
      placeEn: placeEn.text.trim(),
    );
  }

  void fromModel(JobHistory job) {
    titleAr.text = job.jobTitleAr;
    titleEn.text = job.jobTitleEn;

    placeAr.text = job.placeAr;
    placeEn.text = job.placeEn;

    startDate = job.startDate;
    endDate = job.endDate;
  }
}

// ============================================================
//  الصفحة الرئيسية
// ============================================================
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
  final _committeeNameController = TextEditingController();
  final _yearsAsDeanController = TextEditingController();

  DateTime? birthDate;
  DateTime? professorRankDate;
  DateTime? hiringDate;
  bool _hasBeenDean = false;
  bool _hasBeenHead = false;
  bool hasCriminalRecord = false;
  bool holdsPartyPosition = false;

  final List<String> _internalCommittees = [];
  final List<JobHistoryController> _jobHistoryControllers = [];

  // ✅ ماب الحالة الاجتماعية
  final Map<String, String> statusMapping = {
    "أعزب": "Single",
    "متزوج": "Married",
    "أرمل": "Widowed",
    "مطلق": "Divorced",
  };
  String? selectedStatusAr;
  String? selectedStatusEn;

  // ✅ ماب الوظائف (نفس طريقة الحالة الاجتماعية بالظبط)
  final Map<String, String> jobTitleMapping = {
    "معيد": "Teaching Assistant",
    "مدرس مساعد": "Assistant Lecturer",
    "مدرس": "Lecturer",
    "أستاذ مساعد": "Associate Professor",
    "أستاذ": "Professor",
    "أستاذ متفرغ": "Professor Emeritus",
    "أستاذ زائر": "Visiting Professor",
    "أستاذ فخري": "Honorary Professor",
    "رئيس قسم": "Head of Department",
    "وكيل الكلية للدراسات العليا والبحوث":
        "Vice Dean for Graduate Studies and Research",
    "وكيل الكلية لشؤون التعليم والطلاب": "Vice Dean for Education and Students",
    "وكيل الكلية لشؤون خدمة المجتمع وتنمية البيئة":
        "Vice Dean for Community Service",
    "عميد الكلية": "Dean",
    "نائب رئيس الجامعة للدراسات العليا والبحوث":
        "Vice President for Graduate Studies and Research",
    "نائب رئيس الجامعة لشؤون التعليم والطلاب":
        "Vice President for Education and Students",
    "نائب رئيس الجامعة لشؤون خدمة المجتمع":
        "Vice President for Community Service",
    "رئيس الجامعة": "University President",
  };

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
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.navyDark,
              ),
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
    for (var controller in _jobHistoryControllers) {
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
    _yearsAsDeanController.dispose();
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
      for (var ctrl in _jobHistoryControllers) {
        ctrl.clear();
      }
      _jobHistoryControllers.clear();
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
      _yearsAsDeanController.clear();
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

      final List<JobHistory> builtJobHistory = _jobHistoryControllers
          .where(
            (ctrl) =>
                ctrl.titleAr.text.trim().isNotEmpty && ctrl.startDate != null,
          )
          .map((ctrl) => ctrl.toModel())
          .toList();

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
        hasHealthCertificate: _existingDoctor?.hasHealthCertificate ?? false,
        hasCommitteeMembership:
            _existingDoctor?.hasCommitteeMembership ?? false,
        hasSelfEvaluationReport:
            _existingDoctor?.hasSelfEvaluationReport ?? false,
        hasArbitrationPlan: _existingDoctor?.hasArbitrationPlan ?? false,
        hasAdminExperience: _existingDoctor?.hasAdminExperience ?? false,
        hasExcellentPerformanceReports:
            _existingDoctor?.hasExcellentPerformanceReports ?? false,
        isTop3Senior: _existingDoctor?.isTop3Senior ?? false,
        hasSupremeCouncilTraining:
            _existingDoctor?.hasSupremeCouncilTraining ?? false,
        hasFLDCTraining: _existingDoctor?.hasFLDCTraining ?? false,
        isOnSecondment: isOnSecondment,
        isOnUnpaidLeave: isOnUnpaidLeave,
        activeDutySinceDate: activeDutySinceDate,
        workPlanFileUrl: _existingDoctor?.workPlanFileUrl,
        workPlanStatus: _existingDoctor?.workPlanStatus,
        yearsAsDean: _hasBeenDean
            ? (int.tryParse(_yearsAsDeanController.text) ?? 0)
            : null,
        jobHistory: builtJobHistory.isNotEmpty
            ? builtJobHistory
            : (_existingDoctor?.jobHistory ?? const []),
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
          _yearsAsDeanController.text = doc.yearsAsDean?.toString() ?? '';

          _jobHistoryControllers.clear();
          for (var job in doc.jobHistory) {
            final ctrl = JobHistoryController();
            ctrl.fromModel(job);
            _jobHistoryControllers.add(ctrl);
          }

          academicControllersList.clear();
          for (var item in doc.academicHistory) {
            final ctrl = AcademicControllers();
            ctrl.degree.text = item['degree'] ?? '';
            ctrl.major.text = item['major'] ?? '';
            ctrl.date = DoctorProfileModel.normalizeDate(item['date']);
            ctrl.place.text = item['place'] ?? '';
            ctrl.type = degreeLevelValues.contains(item['type'])
                ? item['type']
                : 'بكالوريوس';
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
                        _buildCurrentJobDropdown(),
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
                          (v) => setState(() {
                            _hasBeenDean = v;
                            if (!v) _yearsAsDeanController.clear();
                          }),
                        ),
                        if (_hasBeenDean)
                          Padding(
                            padding: EdgeInsets.only(bottom: 10.h),
                            child: _buildField(
                              "dd_doctor.dean_years".tr(),
                              _yearsAsDeanController,
                              Icons.timer_outlined,
                              keyboardType: TextInputType.number,
                            ),
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
                    _buildJobHistorySection(),
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

  // ============================================================
  //  صورة البروفايل
  // ============================================================
  Widget _buildProfileImage() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: GestureDetector(
        onTap: _isReadOnly ? null : _pickImage,
        child: Container(
          width: 120.w,
          height: 120.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            border: Border.all(color: AppColors.darkGold, width: 3.w),
            image: _pickedImageFile != null
                ? DecorationImage(
                    image: FileImage(File(_pickedImageFile!.path)),
                    fit: BoxFit.cover,
                  )
                : _currentImageUrl.isNotEmpty
                ? DecorationImage(
                    image: CachedNetworkImageProvider(_currentImageUrl),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: _pickedImageFile == null && _currentImageUrl.isEmpty
              ? Icon(
                  Icons.camera_alt,
                  size: 40.sp,
                  color: isDark ? Colors.white54 : Colors.grey,
                )
              : null,
        ),
      ),
    );
  }

  // ============================================================
  //  كارت السكشن
  // ============================================================
  Widget _buildSectionCard(String title, IconData icon, List<Widget> children) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
        ),
      ),
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
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 15.h),
          ...children,
        ],
      ),
    );
  }

  // ============================================================
  //  حقلين فوق بعض
  // ============================================================
  Widget _buildVerticalDoubleField(
    String labelAr,
    TextEditingController controllerAr,
    String labelEn,
    TextEditingController controllerEn,
    IconData icon,
  ) {
    return Column(
      children: [
        _buildField(labelAr, controllerAr, icon),
        SizedBox(height: 10.h),
        _buildField(labelEn, controllerEn, icon),
      ],
    );
  }

  // ============================================================
  //  حقل نصي
  // ============================================================
  Widget _buildField(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType? keyboardType,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextFormField(
      controller: controller,
      readOnly: _isReadOnly,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.darkGold, size: 20.sp),
        filled: true,
        fillColor: _isReadOnly
            ? (isDark ? Colors.grey.shade800 : Colors.grey.shade200)
            : (isDark ? const Color(0xFF2A2A3E) : Colors.white),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: isDark ? Colors.white24 : Colors.grey.shade300,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: isDark ? Colors.white24 : Colors.grey.shade300,
          ),
        ),
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          color: isDark ? Colors.white70 : AppColors.navyLight,
        ),
      ),
      style: AppTextStyles.bodyMedium.copyWith(
        color: isDark ? Colors.white : AppColors.navyDark,
      ),
    );
  }

  // ============================================================
  //  منتقي التاريخ
  // ============================================================
  Widget _buildDatePicker(
    String label,
    DateTime? selectedDate,
    Function(DateTime?) onDateSelected,
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
                  initialDate: selectedDate ?? DateTime.now(),
                  firstDate: DateTime(1940),
                  lastDate: DateTime.now(),
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
                        dialogBackgroundColor: isDark
                            ? const Color(0xFF1E1E2E)
                            : Colors.white,

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
                          backgroundColor: isDark
                              ? const Color(0xFF1E1E2E)
                              : Colors.white,

                          headerBackgroundColor: isDark
                              ? const Color(0xFF2A2A3E)
                              : AppColors.navyDark,

                          headerForegroundColor: Colors.white,

                          dayForegroundColor: WidgetStatePropertyAll(
                            isDark ? Colors.white : AppColors.navyDark,
                          ),

                          dayOverlayColor: WidgetStatePropertyAll(
                            AppColors.darkGold.withOpacity(0.3),
                          ),

                          todayForegroundColor: WidgetStatePropertyAll(
                            AppColors.darkGold,
                          ),

                          yearForegroundColor: WidgetStatePropertyAll(
                            isDark ? Colors.white : AppColors.navyDark,
                          ),

                          yearOverlayColor: WidgetStatePropertyAll(
                            AppColors.darkGold.withOpacity(0.3),
                          ),

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

                if (picked != null) {
                  onDateSelected(picked);
                }
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
              borderSide: const BorderSide(
                color: AppColors.darkGold,
                width: 1.5,
              ),
            ),

            suffixIcon: Icon(
              Icons.arrow_drop_down,
              color: isDark ? Colors.white70 : AppColors.navyDark,
            ),
          ),

          child: Text(
            selectedDate != null
                ? DateFormat('yyyy-MM-dd').format(selectedDate)
                : "add_doctor.select_date".tr(),
            style: AppTextStyles.bodyMedium.copyWith(
              color: selectedDate != null
                  ? (isDark ? Colors.white : AppColors.navyDark)
                  : (isDark ? Colors.white54 : AppColors.navyLight),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  //  سويتش
  // ============================================================
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
      onChanged: _isReadOnly ? null : (v) => onChanged(v),
      contentPadding: EdgeInsets.zero,
    );
  }

  // ============================================================
  //  دروبداون الحالة الاجتماعية
  // ============================================================
  Widget _buildSocialStatusDropdown() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: _isReadOnly
            ? (isDark ? Colors.grey.shade800 : Colors.grey.shade200)
            : (isDark ? const Color(0xFF2A2A3E) : Colors.white),
        border: Border.all(
          color: isDark ? Colors.white24 : Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedStatusAr,
          isExpanded: true,
          hint: Text(
            "add_doctor.social_status".tr(),
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? Colors.white54 : AppColors.navyLight,
            ),
          ),
          icon: Icon(
            Icons.arrow_drop_down,
            color: isDark ? Colors.white70 : AppColors.navyDark,
          ),
          style: AppTextStyles.bodyMedium.copyWith(
            color: isDark ? Colors.white : AppColors.navyDark,
          ),
          dropdownColor: isDark ? const Color(0xFF1E1E2E) : Colors.white,
          items: statusMapping.keys.map((String ar) {
            return DropdownMenuItem<String>(value: ar, child: Text(ar));
          }).toList(),
          onChanged: _isReadOnly
              ? null
              : (String? val) {
                  if (val != null) {
                    setState(() {
                      selectedStatusAr = val;
                      selectedStatusEn = statusMapping[val];
                    });
                  }
                },
        ),
      ),
    );
  }

  // ============================================================
  //  دروبداون الوظيفة الحالية (بنفس طريقة الحالة الاجتماعية)
  // ============================================================
  Widget _buildCurrentJobDropdown() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final isValid = jobTitleMapping.containsKey(_currentJobAr.text.trim());

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: _isReadOnly
            ? (isDark ? Colors.grey.shade800 : Colors.grey.shade200)
            : (isDark ? const Color(0xFF2A2A3E) : Colors.white),
        border: Border.all(
          color: isDark ? Colors.white24 : Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: isValid ? _currentJobAr.text.trim() : null,
          isExpanded: true,
          hint: Text(
            "add_doctor.job_ar".tr(),
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? Colors.white54 : AppColors.navyLight,
            ),
          ),
          icon: Icon(
            Icons.arrow_drop_down,
            color: isDark ? Colors.white70 : AppColors.navyDark,
          ),
          style: AppTextStyles.bodyMedium.copyWith(
            color: isDark ? Colors.white : AppColors.navyDark,
          ),
          dropdownColor: isDark ? const Color(0xFF1E1E2E) : Colors.white,
          items: jobTitleMapping.keys.map((String ar) {
            return DropdownMenuItem<String>(value: ar, child: Text(ar));
          }).toList(),
          onChanged: _isReadOnly
              ? null
              : (String? val) {
                  if (val != null) {
                    setState(() {
                      _currentJobAr.text = val;
                      _currentJobEn.text = jobTitleMapping[val]!;
                    });
                  }
                },
        ),
      ),
    );
  }

  // ============================================================
  //  دروبداون الدرجة العلمية
  // ============================================================
  Widget _buildDegreeDropdown(AcademicControllers ctrl) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isValid = degreeLevelValues.contains(ctrl.type);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: _isReadOnly
            ? (isDark ? Colors.grey.shade800 : Colors.grey.shade200)
            : (isDark ? const Color(0xFF2A2A3E) : Colors.white),
        border: Border.all(
          color: isDark ? Colors.white24 : Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: isValid ? ctrl.type : null,
          isExpanded: true,
          hint: Text(
            "add_doctor.type_degree".tr(),
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? Colors.white54 : AppColors.navyLight,
            ),
          ),
          icon: Icon(
            Icons.school,
            color: isDark ? Colors.white70 : AppColors.navyLight,
          ),
          style: AppTextStyles.bodyMedium.copyWith(
            color: isDark ? Colors.white : AppColors.navyDark,
          ),
          dropdownColor: isDark ? const Color(0xFF1E1E2E) : Colors.white,
          items: degreeLevelValues.map((String val) {
            return DropdownMenuItem<String>(
              value: val,
              child: Text(
                val,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark ? Colors.white : AppColors.navyDark,
                ),
              ),
            );
          }).toList(),
          onChanged: _isReadOnly
              ? null
              : (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      ctrl.type = newValue;
                    });
                  }
                },
        ),
      ),
    );
  }

  // ============================================================
  //  دروبداون المسمى الوظيفي للسجل (بنفس طريقة الحالة الاجتماعية)
  // ============================================================
  Widget _buildJobTitleDropdown(JobHistoryController ctrl) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final isValid = jobTitleMapping.containsKey(ctrl.titleAr.text.trim());
    final hasCustomTitle = ctrl.titleAr.text.trim().isNotEmpty && !isValid;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 5.h),
          decoration: BoxDecoration(
            color: _isReadOnly
                ? (isDark ? Colors.grey.shade800 : Colors.grey.shade200)
                : (isDark ? const Color(0xFF2A2A3E) : Colors.white),
            border: Border.all(
              color: isDark ? Colors.white24 : Colors.grey.shade300,
            ),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: isValid ? ctrl.titleAr.text.trim() : null,
              isExpanded: true,
              hint: Text(
                "add_doctor.select_job_title".tr(),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark ? Colors.white54 : AppColors.navyLight,
                ),
              ),
              icon: Icon(
                Icons.arrow_drop_down,
                color: isDark ? Colors.white70 : AppColors.navyDark,
              ),
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? Colors.white : AppColors.navyDark,
              ),
              dropdownColor: isDark ? const Color(0xFF1E1E2E) : Colors.white,
              items: jobTitleMapping.keys.map((String ar) {
                return DropdownMenuItem<String>(value: ar, child: Text(ar));
              }).toList(),
              onChanged: _isReadOnly
                  ? null
                  : (String? val) {
                      if (val != null) {
                        setState(() {
                          ctrl.titleAr.text = val;
                          ctrl.titleEn.text = jobTitleMapping[val]!;
                        });
                      }
                    },
            ),
          ),
        ),
        if (ctrl.titleAr.text.trim().isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: 6.h, right: 4.w),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  size: 14.sp,
                  color: AppColors.darkGold,
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    '${ctrl.titleAr.text}  |  ${ctrl.titleEn.text}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark ? Colors.white70 : AppColors.navyLight,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (hasCustomTitle)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      'add_doctor.old_tag'.tr(),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.orange,
                        fontSize: 10.sp,
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  // ============================================================
  //  سكشن السجل الوظيفي
  // ============================================================
  Widget _buildJobHistorySection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _buildSectionCard("add_doctor.job_history".tr(), Icons.timeline, [
      if (_jobHistoryControllers.isEmpty)
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          child: Text(
            "add_doctor.no_job_history".tr(),
            style: TextStyle(
              color: isDark ? Colors.white54 : Colors.grey,
              fontSize: 13.sp,
            ),
          ),
        ),
      ..._jobHistoryControllers.asMap().entries.map(
        (entry) => _buildJobHistoryEntry(entry.key, entry.value),
      ),
      if (!_isReadOnly)
        Center(
          child: TextButton.icon(
            onPressed: () => setState(
              () => _jobHistoryControllers.add(JobHistoryController()),
            ),
            icon: const Icon(Icons.add_circle, color: AppColors.darkGold),
            label: Text(
              "add_doctor.add_previous_job".tr(),
              style: TextStyle(color: AppColors.navyDark),
            ),
          ),
        ),
    ]);
  }

  Widget _buildJobHistoryEntry(int index, JobHistoryController ctrl) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : AppColors.navyLight.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDark ? Colors.white24 : Colors.grey.shade300,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.work_outline,
                    size: 18.sp,
                    color: AppColors.darkGold,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '${"add_doctor.job_number".tr()} ${index + 1}',
                    style: AppTextStyles.titleSmall.copyWith(
                      color: isDark ? Colors.white : AppColors.navyDark,
                    ),
                  ),
                ],
              ),
              if (!_isReadOnly)
                IconButton(
                  icon: Icon(
                    Icons.remove_circle,
                    color: AppColors.error,
                    size: 24.sp,
                  ),
                  onPressed: () => setState(() {
                    ctrl.dispose();
                    _jobHistoryControllers.removeAt(index);
                  }),
                ),
            ],
          ),
          SizedBox(height: 10.h),
          _buildJobTitleDropdown(ctrl),
          SizedBox(height: 10.h),
          _buildVerticalDoubleField(
            "add_doctor.job_place_ar".tr(),
            ctrl.placeAr,
            "add_doctor.job_place_en".tr(),
            ctrl.placeEn,
            Icons.location_city,
          ),
          SizedBox(height: 10.h),

          _buildDatePicker(
            "add_doctor.start_date".tr(),
            ctrl.startDate,
            (date) => setState(() => ctrl.startDate = date),
          ),
          SizedBox(height: 10.h),
          _buildDatePicker(
            "add_doctor.end_date_hint".tr(),
            ctrl.endDate,
            (date) => setState(() => ctrl.endDate = date),
          ),
          if (ctrl.startDate != null)
            Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Text(
                ": ${ctrl.endDate != null ? _formatDuration(ctrl.startDate!, ctrl.endDate!) : _formatDuration(ctrl.startDate!, DateTime.now())}",
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.darkGold,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDuration(DateTime start, DateTime end) {
    int years = end.year - start.year;
    int months = end.month - start.month;
    if (months < 0) {
      years--;
      months += 12;
    }
    if (years > 0 && months > 0) return "$years سنة و $months شهر";
    if (years > 0) return "$years common.year".tr();
    if (months > 0) return "$months common.month".tr();
    return "${end.difference(start).inDays} common.day".tr();
  }

  // ============================================================
  //  دروبداون الكلية
  // ============================================================
  Widget _buildFacultyDropdown() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final faculties = MansouraUniversitiesData.faculties;

    String? selectedFacultyKey;
    for (final f in faculties) {
      final currentVal = isArabic ? _facultyAr.text : _facultyEn.text;
      if ((isArabic ? f.nameAr : f.nameEn) == currentVal) {
        selectedFacultyKey = f.id;
        break;
      }
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: _isReadOnly
            ? (isDark ? Colors.grey.shade800 : Colors.grey.shade200)
            : (isDark ? const Color(0xFF2A2A3E) : Colors.white),
        border: Border.all(
          color: isDark ? Colors.white24 : Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedFacultyKey,
          isExpanded: true,
          hint: Text(
            "add_doctor.faculty_ar".tr(),
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? Colors.white54 : AppColors.navyLight,
            ),
          ),
          icon: Icon(
            Icons.arrow_drop_down,
            color: isDark ? Colors.white70 : AppColors.navyDark,
          ),
          style: AppTextStyles.bodyMedium.copyWith(
            color: isDark ? Colors.white : AppColors.navyDark,
          ),
          dropdownColor: isDark ? const Color(0xFF1E1E2E) : Colors.white,
          items: faculties.map((f) {
            return DropdownMenuItem<String>(
              value: f.id,
              child: Text(
                isArabic ? f.nameAr : f.nameEn,
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
                  if (val == null) return;
                  final faculty = faculties.firstWhere((f) => f.id == val);
                  setState(() {
                    _facultyAr.text = faculty.nameAr;
                    _facultyEn.text = faculty.nameEn;
                  });
                },
        ),
      ),
    );
  }

  // ============================================================
  //  دروبداون القسم
  // ============================================================
  Widget _buildDepartmentDropdown() {
    return _buildField(
      "add_doctor.department_ar".tr(),
      _departmentAr,
      Icons.category,
    );
  }

  // ============================================================
  //  اللجان الداخلية
  // ============================================================
  Widget _buildInternalCommitteesSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _buildSectionCard(
      "add_doctor.internal_committees".tr(),
      Icons.groups,
      [
        ..._internalCommittees.asMap().entries.map((entry) {
          return Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    entry.value,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark ? Colors.white : AppColors.navyDark,
                    ),
                  ),
                ),
                if (!_isReadOnly)
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.error,
                      size: 20,
                    ),
                    onPressed: () => _removeCommittee(entry.key),
                  ),
              ],
            ),
          );
        }),
        if (!_isReadOnly)
          Row(
            children: [
              Expanded(
                child: _buildField(
                  "add_doctor.committee_name_hint".tr(),
                  _committeeNameController,
                  Icons.add_task,
                ),
              ),
              SizedBox(width: 10.w),
              IconButton(
                icon: const Icon(
                  Icons.add_circle,
                  color: AppColors.darkGold,
                  size: 30,
                ),
                onPressed: _addCommittee,
              ),
            ],
          ),
      ],
    );
  }

  // ============================================================
  //  الأرشيف الرقمي
  // ============================================================
  Widget _buildDigitalArchiveSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _buildSectionCard(
      "add_doctor.digital_archive".tr(),
      Icons.folder_open,
      [
        ..._digitalArchive.asMap().entries.map((entry) {
          final item = entry.value;
          return ListTile(
            leading: const Icon(Icons.description, color: AppColors.darkGold),
            title: Text(
              item['name'] ?? '',
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? Colors.white : AppColors.navyDark,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: AppColors.error),
              onPressed: _isReadOnly
                  ? null
                  : () => setState(() => _digitalArchive.removeAt(entry.key)),
            ),
          );
        }),
        if (!_isReadOnly)
          Center(
            child: TextButton.icon(
              onPressed: _pickAndUploadArchiveFile,
              icon: const Icon(Icons.upload_file, color: AppColors.darkGold),
              label: Text("add_doctor.upload_file".tr()),
            ),
          ),
      ],
    );
  }

  // ============================================================
  //  إدخال الشهادة الأكاديمية
  // ============================================================
  Widget _buildAcademicEntry(int index, AcademicControllers ctrl) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : AppColors.navyLight.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDark ? Colors.white24 : Colors.grey.shade300,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${"add_doctor.type_certificate".tr()} ${index + 1}',
                style: AppTextStyles.titleSmall.copyWith(
                  color: isDark ? Colors.white : AppColors.navyDark,
                ),
              ),
              if (!_isReadOnly)
                IconButton(
                  icon: const Icon(Icons.remove_circle, color: AppColors.error),
                  onPressed: () => setState(() {
                    ctrl.dispose();
                    academicControllersList.removeAt(index);
                  }),
                ),
            ],
          ),
          SizedBox(height: 10.h),
          _buildDegreeDropdown(ctrl),
          SizedBox(height: 10.h),
          _buildField(
            "add_doctor.major_hint".tr(),
            ctrl.major,
            Icons.menu_book,
          ),
          SizedBox(height: 10.h),
          _buildField(
            "add_doctor.place_hint".tr(),
            ctrl.place,
            Icons.location_city,
          ),
          SizedBox(height: 10.h),
          _buildDatePicker("", ctrl.date, (d) => setState(() => ctrl.date = d)),
        ],
      ),
    );
  }

  // ============================================================
  //  زر الحفظ
  // ============================================================
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: ElevatedButton(
        onPressed: _onSavePressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkGold,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: Text(
          isEditing
              ? "add_doctor.save_changes ".tr()
              : "add_doctor.title ".tr(),
          style: AppTextStyles.titleMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// ============================================================
//  حوار رفع ملف الأرشيف
// ============================================================
class _ArchiveFileDialog extends StatefulWidget {
  final File file;
  final String uid;

  const _ArchiveFileDialog({required this.file, required this.uid});

  @override
  State<_ArchiveFileDialog> createState() => _ArchiveFileDialogState();
}

class _ArchiveFileDialogState extends State<_ArchiveFileDialog> {
  final _nameController = TextEditingController();
  bool _isUploading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _upload() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _isUploading = true);

    try {
      // ضع هنا منطق رفع الملف للـ Firebase
      if (!mounted) return;
      Navigator.pop(context, {
        'name': name,
        'url': '', // ضع رابط الملف هنا بعد الرفع
      });
    } catch (e) {
      setState(() => _isUploading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("common.error: $e".tr()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AlertDialog(
      title: Text("add_doctor.file_title ".tr()),
      content: TextField(
        controller: _nameController,
        decoration: InputDecoration(
          labelText: " add_doctor.add_archive".tr(),
          hintText: "add_doctor.".tr(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            "common.cancel".tr(),
            style: TextStyle(
              color: isDark ? Colors.white : AppColors.navyLight,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _isUploading ? null : _upload,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.darkGold,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
          child: _isUploading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : Text(
                  "common.save".tr(),
                  style: const TextStyle(color: Colors.white),
                ),
        ),
      ],
    );
  }
}
