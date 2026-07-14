import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

import 'package:optialeader/core/routing/routes.dart';
import 'package:optialeader/feature/database_admin/data/models/doctor_profile_model.dart';
import 'package:optialeader/feature/database_admin/logic/doctor_data/doctor_data_cubit.dart';
import 'package:optialeader/feature/database_admin/logic/doctor_data/doctor_data_state.dart';

class DoctorProfileDataPage extends StatefulWidget {
  final String doctorUid;

  const DoctorProfileDataPage({super.key, required this.doctorUid});

  @override
  State<DoctorProfileDataPage> createState() => _DoctorProfileDataPageState();
}

class _DoctorProfileDataPageState extends State<DoctorProfileDataPage> {
  @override
  void initState() {
    super.initState();
    context.read<DoctorDataCubit>().getDoctorProfile(widget.doctorUid);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isArabic = context.locale.languageCode == 'ar';

    return BlocBuilder<DoctorDataCubit, DoctorDataState>(
      builder: (context, state) {
        if (state is DoctorLoading) {
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (state is DoctorLoaded && state.doctor != null) {
          final doctor = state.doctor!;

          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  automaticallyImplyLeading: false,
                  expandedHeight: 100.0.h,
                  pinned: true,
                  backgroundColor: colorScheme.primary,
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            colorScheme.primary,
                            colorScheme.primary.withOpacity(0.85),
                          ],
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.arrow_back_ios_new,
                                size: 20.sp,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                if (context.canPop()) {
                                  context.pop();
                                } else {
                                  context.go(Routes.user);
                                }
                              },
                            ),
                            SizedBox(width: 15.w),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isArabic ? doctor.nameAr : doctor.nameEn,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18.sp,
                                        ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                  SizedBox(height: 7.h),
                                  Text(
                                    isArabic
                                        ? doctor.currentJobAr
                                        : doctor.currentJobEn,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.white70,
                                      fontSize: 18.sp,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 15.w),
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: colorScheme.secondary,
                                  width: 2.w,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 35.r,
                                backgroundColor: Colors.white12,
                                backgroundImage:
                                    (doctor.profileImage.isNotEmpty)
                                    ? CachedNetworkImageProvider(
                                        doctor.profileImage,
                                      )
                                    : null,
                                child: (doctor.profileImage.isEmpty)
                                    ? Icon(
                                        Icons.person,
                                        color: colorScheme.secondary,
                                        size: 40.sp,
                                      )
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate([
                    SizedBox(height: 10.h),

                    // ===== قسم البيانات الشخصية =====
                    _buildSectionCard(
                      context,
                      icon: Icons.badge_outlined,
                      title: "acadimic_Data.academicData.personal_section".tr(),
                      children: [
                        _buildInfoRow(
                          context,
                          label: "acadimic_Data.academicData.name".tr(),
                          value: isArabic ? doctor.nameAr : doctor.nameEn,
                        ),
                        _buildInfoRow(
                          context,
                          label: "acadimic_Data.academicData.phone".tr(),
                          value: doctor.phone,
                        ),
                        _buildInfoRow(
                          context,
                          label: "acadimic_Data.academicData.social_status"
                              .tr(),
                          value: isArabic
                              ? doctor.socialStatusAr
                              : doctor.socialStatusEn,
                        ),
                        _buildInfoRow(
                          context,
                          label: "acadimic_Data.statuses.active".tr(),
                          value: (doctor.isActive)
                              ? "acadimic_Data.statuses.active".tr()
                              : "acadimic_Data.statuses.inactive".tr(),
                        ),
                        _buildInfoRow(
                          context,
                          label: "acadimic_Data.academicData.birth_date".tr(),
                          value: doctor.birthDate != null
                              ? DateFormat(
                                  'yyyy-MM-dd',
                                ).format(doctor.birthDate!)
                              : '-',
                        ),
                      ],
                    ),

                    // ===== قسم البيانات الأكاديمية =====
                    _buildSectionCard(
                      context,
                      icon: Icons.school_outlined,
                      title: "acadimic_Data.academicData.academic_section".tr(),
                      children: [
                        _buildInfoRow(
                          context,
                          label: "acadimic_Data.add_doctor.university".tr(),
                          value: isArabic
                              ? doctor.universityAr
                              : doctor.universityEn,
                        ),
                        _buildInfoRow(
                          context,
                          label: "acadimic_Data.add_doctor.faculty".tr(),
                          value: isArabic ? doctor.facultyAr : doctor.facultyEn,
                        ),
                        _buildInfoRow(
                          context,
                          label: "acadimic_Data.add_doctor.department".tr(),
                          value: isArabic
                              ? doctor.departmentAr
                              : doctor.departmentEn,
                        ),
                        _buildInfoRow(
                          context,
                          label: "acadimic_Data.academicData.job".tr(),
                          value: isArabic
                              ? doctor.currentJobAr
                              : doctor.currentJobEn,
                        ),
                      ],
                    ),

                    // ✅ ===== قسم القيادات (بالتحقق الحقيقي) =====
                    _buildSectionCard(
                      context,
                      icon: Icons.military_tech_outlined,
                      title: "add_doctor.leadership_section".tr(),
                      children: [
                        _buildInfoRow(
                          context,
                          label: "add_doctor.hiring_date".tr(),
                          value: doctor.hiringDate != null
                              ? DateFormat(
                                  'yyyy-MM-dd',
                                ).format(doctor.hiringDate!)
                              : '-',
                        ),

                        // ✅ تحقق حقيقي: 10 سنين خبرة
                        if (doctor.hiringDate != null)
                          _buildValidationCard(
                            context,
                            label: isArabic
                                ? "شرط الخبرة الإدارية (10 سنوات)"
                                : "Admin Experience (10 Years)",
                            isMet: doctor.yearsSinceHiring >= 10,
                            details: isArabic
                                ? "عدد السنوات الحالية: ${doctor.yearsSinceHiring} سنة"
                                : "Current years: ${doctor.yearsSinceHiring} Years",
                          ),

                        SizedBox(height: 10.h),
                        _buildInfoRow(
                          context,
                          label: "add_doctor.professor_rank_date".tr(),
                          value: doctor.professorRankDate != null
                              ? DateFormat(
                                  'yyyy-MM-dd',
                                ).format(doctor.professorRankDate!)
                              : '-',
                        ),

                        // ✅ تحقق حقيقي: أستاذية 3 سنين + التحقق من درجة الأستاذية أصلاً
                        if (doctor.professorRankDate != null)
                          _buildValidationCard(
                            context,
                            label: isArabic
                                ? "شرط الأستاذية (3 سنوات + درجة)"
                                : "Professorship (3 Years + Degree)",
                            isMet:
                                _hasProfessorDegree(doctor) &&
                                doctor.yearsAsProfessor >= 3,
                            details: isArabic
                                ? "الأقدمية: ${doctor.yearsAsProfessor} سنة | حاصل على الدرجة: ${_hasProfessorDegree(doctor) ? 'نعم' : 'لا'}"
                                : "Seniority: ${doctor.yearsAsProfessor} Years | Has Degree: ${_hasProfessorDegree(doctor) ? 'Yes' : 'No'}",
                          ),

                        SizedBox(height: 10.h),

                        // ✅ تحقق حقيقي: أقدم 3 دكاترة (بيجيب الدكاترة ويقارن)
                        _buildTop3DynamicCheck(context, doctor),

                        SizedBox(height: 10.h),
                        // اللجان الداخلية
                        _buildCommitteesWidget(
                          context,
                          doctor.internalCommittees,
                        ),
                      ],
                    ),

                    // ===== قسم بيانات التواصل =====
                    _buildSectionCard(
                      context,
                      icon: Icons.contact_mail_outlined,
                      title: "acadimic_Data.academicData.contact_section".tr(),
                      children: [
                        _buildInfoRow(
                          context,
                          label: "acadimic_Data.academicData.email".tr(),
                          value: doctor.email,
                        ),
                        _buildInfoRow(
                          context,
                          label: "acadimic_Data.academicData.address".tr(),
                          value: isArabic ? doctor.addressAr : doctor.addressEn,
                        ),
                      ],
                    ),
                    SizedBox(height: 40.h),
                  ]),
                ),
              ],
            ),
          );
        }

        if (state is DoctorError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 48.sp),
                  SizedBox(height: 16.h),
                  Text(
                    state.error ?? 'acadimic_Data.error_message'.tr(),
                    style: TextStyle(color: Colors.red, fontSize: 14.sp),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20.h),
                  ElevatedButton(
                    onPressed: () => context
                        .read<DoctorDataCubit>()
                        .getDoctorProfile(widget.doctorUid),
                    child: Text('acadimic_Data.retry'.tr()),
                  ),
                ],
              ),
            ),
          );
        }

        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }

  // ============================================================
  // ✅ دالة التحقق من درجة الأستاذية زي المحرك بالظبط
  // ============================================================
  bool _hasProfessorDegree(DoctorProfileModel doctor) {
    return doctor.academicHistory.any((item) {
      final degree = (item['degree'] ?? '').toString().toLowerCase();
      final normalized = _normalizeArabic(degree);
      return normalized.contains('استاذ') || degree.contains('professor');
    });
  }

  String _normalizeArabic(String text) {
    return text
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي');
  }

  // ============================================================
  // ✅ ويدجت التحقق الديناميكي لأقدم 3 (FutureBuilder)
  // ============================================================
  Widget _buildTop3DynamicCheck(
    BuildContext context,
    DoctorProfileModel doctor,
  ) {
    final isArabic = context.locale.languageCode == 'ar';
    return FutureBuilder<List<DoctorProfileModel>>(
      future: context.read<DoctorDataCubit>().getAllDoctorsOnce(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: EdgeInsets.all(10.h),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }

        bool isTop3 = false;
        String details = isArabic
            ? "تعذر التحقق التلقائي"
            : "Automatic check failed";

        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final top3Uids = DoctorProfileModel.getTop3SeniorInDepartment(
            doctors: snapshot.data!,
            departmentAr: doctor.departmentAr,
          );
          isTop3 = top3Uids.contains(doctor.uid);
          details = isTop3
              ? (isArabic
                    ? "يقع ضمن أقدم 3 أساتذة بالقسم"
                    : "Falls under Top 3 Senior Professors")
              : (isArabic
                    ? "غير ضمن أقدم 3 أساتذة القسم"
                    : "Not in the Top 3 Senior Professors");
        }

        return _buildValidationCard(
          context,
          label: isArabic
              ? "ضمن أقدم 3 أساتذة بالقسم"
              : "Top 3 Senior Professors",
          isMet: isTop3,
          details: details,
        );
      },
    );
  }

  // ============================================================
  // ✅ ويدجت كارت التحقق العام (أخضر/برتقالي)
  // ============================================================
  Widget _buildValidationCard(
    BuildContext context, {
    required String label,
    required bool isMet,
    required String details,
  }) {
    final theme = Theme.of(context);
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: isMet
            ? Colors.green.withOpacity(0.08)
            : Colors.orange.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: isMet ? Colors.green : Colors.orange,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.cancel_outlined,
            color: isMet ? Colors.green : Colors.orange,
            size: 22.sp,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade700,
                    fontSize: 11.sp,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  details,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isMet
                        ? Colors.green.shade800
                        : Colors.orange.shade800,
                    fontWeight: FontWeight.bold,
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // باقي الويدجتس (اللجان - الكارت - الصفوف)
  // ============================================================
  Widget _buildCommitteesWidget(BuildContext context, List<String> committees) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: 15.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "add_doctor.internal_committees".tr(),
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.primary.withOpacity(0.7),
              fontWeight: FontWeight.w600,
              fontSize: 11.sp,
            ),
          ),
          SizedBox(height: 8.h),
          if (committees.isEmpty)
            Text(
              "add_doctor.no_committees".tr(),
              style: TextStyle(color: Colors.grey, fontSize: 13.sp),
            )
          else
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: committees.map((name) {
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: theme.colorScheme.secondary.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 14.sp,
                        color: theme.colorScheme.secondary,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        name,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          SizedBox(height: 10.h),
          Divider(height: 1, color: theme.dividerColor.withOpacity(0.2)),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: colorScheme.secondary, size: 22.sp),
                SizedBox(width: 10.w),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
            Divider(height: 30.h, color: colorScheme.primary.withOpacity(0.1)),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: 15.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.primary.withOpacity(0.7),
              fontWeight: FontWeight.w600,
              fontSize: 11.sp,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value.isEmpty ? '-' : value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 10.h),
          Divider(height: 1, color: theme.dividerColor.withOpacity(0.2)),
        ],
      ),
    );
  }
}
