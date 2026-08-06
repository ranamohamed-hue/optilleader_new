import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:optialeader/feature/admin/data/model/announcement_model.dart';
import 'package:optialeader/feature/admin/logic/nomination_request_logic/nomination_request_cubit.dart';
import 'package:optialeader/feature/admin/logic/nomination_request_logic/nomonation_request_state.dart';
import 'package:optialeader/feature/database_admin/data/models/doctor_profile_model.dart';
import 'package:optialeader/feature/database_admin/logic/doctor_data/doctor_data_cubit.dart';
import 'package:optialeader/feature/database_admin/logic/doctor_data/doctor_data_state.dart';
import 'package:optialeader/feature/database_admin/logic/leadership_scoring_engine/leadership_criteria_engine.dart';

class DoctorNominationPage extends StatefulWidget {
  final AnnouncementModel announcement;
  final String doctorId;

  const DoctorNominationPage({
    super.key,
    required this.announcement,
    required this.doctorId,
  });

  @override
  State<DoctorNominationPage> createState() => _DoctorNominationPageState();
}

class _DoctorNominationPageState extends State<DoctorNominationPage> {
  String? _selectedFileName;
  String? _selectedFilePath;

  DoctorProfileModel? _doctor;

  String doctorName = '';
  String? doctorImageUrl;
  List<CriterionStatus> mandatoryCriteria = [];
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final cubit = context.read<DoctorDataCubit>();
    
    // لو الداتا مش loaded، نجيبها
    if (cubit.state is! DoctorLoaded) {
      final uid = widget.doctorId.isNotEmpty 
          ? widget.doctorId 
          : FirebaseAuth.instance.currentUser?.uid ?? '';
      
      if (uid.isNotEmpty) {
        await cubit.getDoctorProfile(uid);
      }
    }
    
    _checkEligibility();
  }

  void _checkEligibility() {
    final doctorState = context.read<DoctorDataCubit>().state;

    if (doctorState is DoctorLoaded) {
      final doctor = doctorState.doctor!;

      setState(() {
        _doctor = doctor;
        doctorName = doctor.nameAr;
        doctorImageUrl = doctor.profileImage;

        // ✅ استخدام LeadershipCriteriaEngine
        mandatoryCriteria = LeadershipCriteriaEngine.checkMandatoryCriteria(
          doctor: doctor,
          targetRole: widget.announcement.targetRole,
        );

        _isLoadingData = false;
      });
    } else {
      setState(() => _isLoadingData = false);
    }
  }

  Future<void> _pickDeclarationFile() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png', 'zip'],
      allowMultiple: false,
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFilePath = result.files.single.path;
        _selectedFileName = result.files.single.name;
      });
    }
  }

  void _removeFile() => setState(() {
    _selectedFilePath = null;
    _selectedFileName = null;
  });

  void _handleSubmit() {
    if (_selectedFilePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("nomination.error_no_file".tr())),
      );
      return;
    }

    if (_doctor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
SnackBar(content: Text("nomination.error_unexpected".tr())),      );
      return;
    }

    context.read<NominationRequestCubit>().submitNominationRequest(
      announcement: widget.announcement,
      doctor: _doctor!,
      filePath: _selectedFilePath!,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          "nomination.app_bar_title".tr(),
          style: TextStyle(color: colorScheme.onPrimary, fontSize: 18.sp),
        ),
        backgroundColor: colorScheme.primary,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: colorScheme.onPrimary,
            size: 22.r,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocConsumer<NominationRequestCubit, NominationRequestState>(
        listener: (context, state) {
          if (state is NominationRequestActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message.tr()),
                backgroundColor: Colors.green,
              ),
            );
            context.pop();
          } else if (state is NominationRequestError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message.tr()),
                backgroundColor: colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          bool isSubmitting = state is NominationRequestLoading;
          return SingleChildScrollView(
            padding: EdgeInsets.all(20.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. ملخص الإعلان
                _buildSectionCard(
                  child: Row(
                    children: [
                      Icon(
                        Icons.campaign_rounded,
                        color: colorScheme.primary,
                        size: 30.r,
                      ),
                      SizedBox(width: 15.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.announcement.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              "${"nomination.role_label".tr()} ${widget.announcement.targetRole.tr()}",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),

                // 2. عرض الشروط الإجبارية
                _buildSectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.fact_check_outlined,
                            color: colorScheme.secondary,
                            size: 24.r,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            "nomination.mandatory_criteria".tr(),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15.h),
                      if (_isLoadingData)
                        const Center(child: CircularProgressIndicator())
                      else if (mandatoryCriteria.isEmpty)
                        Text("nomination.no_criteria".tr())
                      else
                        ...mandatoryCriteria.map(
                          (c) => Padding(
                            padding: EdgeInsets.symmetric(vertical: 6.h),
                            child: Row(
                              children: [
                                Icon(
                                  c.isMet ? Icons.check_circle : Icons.cancel,
                                  color: c.isMet
                                      ? Colors.green
                                      : colorScheme.error,
                                  size: 20.r,
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: Text(
                                    context.locale.languageCode == 'ar'
                                        ? c.titleAr
                                        : c.titleEn,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: c.isMet
                                          ? colorScheme.onSurface
                                          : colorScheme.error,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),

                // 3. رفع ملف الإقرارات
                _buildSectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.upload_file,
                            color: colorScheme.secondary,
                            size: 24.r,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            "nomination.declarations_title".tr(),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        "nomination.declarations_instructions".tr(),
                        style: theme.textTheme.bodySmall,
                      ),
                      SizedBox(height: 15.h),
                      if (_selectedFileName != null)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 15.w,
                            vertical: 12.h,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest
                                .withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.description,
                                color: colorScheme.primary,
                                size: 24.r,
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Text(
                                  _selectedFileName!,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.close,
                                  size: 20.r,
                                  color: colorScheme.error,
                                ),
                                onPressed: isSubmitting ? null : _removeFile,
                              ),
                            ],
                          ),
                        )
                      else
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: isSubmitting
                                ? null
                                : _pickDeclarationFile,
                            icon: Icon(Icons.attach_file, size: 22.r),
                            label: Text("nomination.pick_file".tr()),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.all(15.r),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 40.h),

                // 4. زر الإرسال
                SizedBox(
                  width: double.infinity,
                  height: 55.h,
                  child: ElevatedButton.icon(
                    onPressed: isSubmitting ? null : _handleSubmit,
                    icon: isSubmitting
                        ? SizedBox(
                            width: 20.w,
                            height: 20.h,
                            child: CircularProgressIndicator(
                              color: colorScheme.onPrimary,
                              strokeWidth: 2,
                            ),
                          )
                        : Icon(Icons.send_rounded, size: 22.r),
                    label: Text(
                      isSubmitting
                          ? "nomination.button_submitting".tr()
                          : "nomination.button_submit".tr(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.r),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.04),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: child,
    );
  }
}