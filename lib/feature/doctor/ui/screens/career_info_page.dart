import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

import 'package:optialeader/core/routing/routes.dart';
import 'package:optialeader/feature/database_admin/data/models/doctor_profile_model.dart';
import 'package:optialeader/feature/database_admin/data/models/job_history_model.dart';
import 'package:optialeader/feature/database_admin/logic/doctor_data/doctor_data_cubit.dart';
import 'package:optialeader/feature/database_admin/logic/doctor_data/doctor_data_state.dart';

class CareerInfoPage extends StatefulWidget {
  final String doctorUid;

  const CareerInfoPage({
    super.key,
    required this.doctorUid,
  });

  @override
  State<CareerInfoPage> createState() => _CareerInfoPageState();
}

class _CareerInfoPageState extends State<CareerInfoPage> {
  @override
  void initState() {
    super.initState();

    context.read<DoctorDataCubit>().getDoctorProfile(
      widget.doctorUid,
    );
  }

  // ============================================================
  // Helpers
  // ============================================================

  String _validateText(String? text) {
    if (text == null || text.trim().isEmpty) {
      return '-';
    }

    return text.trim();
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return '-';
    }

    return DateFormat('yyyy-MM-dd').format(date);
  }

  Widget _buildSectionHeader(
    BuildContext context,
    IconData icon,
    String title,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: 12.h,
        horizontal: 15.w,
      ),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(15.r),
        ),
        border: Border.all(
          color: colorScheme.secondary.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: colorScheme.secondary,
            size: 22.sp,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard(
    BuildContext context,
    String message,
  ) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(15.r),
        ),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.1),
        ),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: Colors.grey,
          fontSize: 13.sp,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // ============================================================
  // التاريخ الوظيفي - Timeline
  // ============================================================

  Widget _buildJobHistoryTimeline(
    BuildContext context,
    DoctorProfileModel? doctor,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isArabic = context.locale.languageCode == 'ar';

    if (doctor == null || doctor.jobHistory.isEmpty) {
      return _buildEmptyCard(
        context,
        'career.no_job_history'.tr(),
      );
    }

    // نسخ القائمة وترتيبها من الأقدم للأحدث
    final history = List<JobHistory>.from(
      doctor.jobHistory,
    );

    history.sort(
      (a, b) => a.startDate.compareTo(b.startDate),
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(15.r),
        ),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: history.asMap().entries.map((entry) {
          final index = entry.key;
          final job = entry.value;

          final isLast = index == history.length - 1;

          final title = isArabic
              ? _validateText(job.jobTitleAr)
              : _validateText(job.jobTitleEn);

          final place = isArabic
              ? _validateText(job.placeAr)
              : _validateText(job.placeEn);

          final startDate = job.startDate;

          final endDate = job.endDate;

          String period;

          if (endDate != null) {
            period =
                '${_formatDate(startDate)} → ${_formatDate(endDate)}';
          } else {
            period =
                '${_formatDate(startDate)} → ${'career.until_now'.tr()}';
          }

          // حساب مدة الوظيفة
          String durationText = '';

          final calculationEnd =
              endDate ?? DateTime.now();

          final duration = calculationEnd.difference(
            startDate,
          );

          final totalDays = duration.inDays;

          final years = totalDays ~/ 365;
          final remainingDays = totalDays % 365;
          final months = remainingDays ~/ 30;

          if (years > 0) {
            durationText =
                '$years ${'career.years'.tr()}';

            if (months > 0) {
              durationText +=
                  
                  '$months ${'career.months'.tr()}';
            }
          } else if (months > 0) {
            durationText =
                '$months ${'career.months'.tr()}';
          }

          return _buildTimelineItem(
            context: context,
            title: title,
            place: place,
            date: period,
            duration: durationText,
            isLast: isLast,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTimelineItem({
    required BuildContext context,
    required String title,
    required String place,
    required String date,
    required String duration,
    required bool isLast,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ======================================================
          // الخط الزمني
          // ======================================================

          Column(
            children: [
              Container(
                width: 14.w,
                height: 14.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.secondary,
                  border: Border.all(
                    color:
                        theme.cardTheme.color ?? Colors.white,
                    width: 3.w,
                  ),
                ),
              ),

              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2.5.w,
                    color: colorScheme.secondary
                        .withOpacity(0.4),
                  ),
                ),
            ],
          ),

          SizedBox(width: 15.w),

          // ======================================================
          // بيانات الوظيفة
          // ======================================================

          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: isLast ? 0 : 22.h,
                top: 1.h,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                      fontSize: 14.sp,
                    ),
                  ),

                  if (place != '-')
                    Padding(
                      padding:
                          EdgeInsets.only(top: 5.h),
                      child: Text(
                        place,
                        style: TextStyle(
                          color: theme.textTheme
                              .bodySmall
                              ?.color,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),

                  Padding(
                    padding:
                        EdgeInsets.only(top: 5.h),
                    child: Text(
                      date,
                      style: TextStyle(
                        color:
                            colorScheme.secondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),

                  if (duration.isNotEmpty)
                    Padding(
                      padding:
                          EdgeInsets.only(top: 4.h),
                      child: Text(
                        duration,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 11.sp,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // المسار الوظيفي والحسابات
  // ============================================================

  Widget _buildCareerPathCard(
    BuildContext context,
    DoctorProfileModel? doctor,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // ==========================================================
    // الحساب من DoctorProfileModel
    // ==========================================================

    final experienceYears =
        doctor?.yearsSinceHiring ?? 0;

    final professorYears =
        doctor?.yearsAsProfessor ?? 0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(15.r),
        ),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          // ======================================================
          // سنوات الخدمة
          // ======================================================

          Row(
            children: [
              Icon(
                Icons.workspace_premium_outlined,
                color: colorScheme.secondary,
                size: 22.sp,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  'career.experience'.tr(
                     args: [experienceYears.toString()],
                  ),
                  style: TextStyle(
                    color: colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 15.h),

          // ======================================================
          // سنوات الأستاذية
          // ======================================================

          if (doctor?.professorRankDate != null)
            Row(
              children: [
                Icon(
                  Icons.school_outlined,
                  color: colorScheme.primary,
                  size: 20.sp,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    '$professorYears '
                    '${'career.years'.tr()}',
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                      fontSize: 13.sp,
                    ),
                  ),
                ),
              ],
            ),

          SizedBox(height: 20.h),

          Text(
            'career.previous_positions'.tr(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13.sp,
              color: colorScheme.onSurface,
            ),
          ),

          SizedBox(height: 10.h),

          if (doctor?.previousLeadershipRoles != null &&
              doctor!.previousLeadershipRoles.isNotEmpty)
            ...doctor.previousLeadershipRoles.map(
              (role) => _buildHistoryItem(
                context,
                role.toString().tr(),
                '',
              ),
            )
          else
            _buildHistoryItem(
              context,
              'career.no_previous_roles'.tr(),
              '',
            ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(
    BuildContext context,
    String title,
    String period,
  ) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 4.h,
      ),
      child: Row(
        children: [
          Icon(
            Icons.arrow_right,
            color: colorScheme.secondary,
          ),

          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
            ),
          ),

          if (period.isNotEmpty)
            Text(
              period,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // البيانات الوظيفية الحالية
  // ============================================================

  Widget _buildCurrentInfoCard(
    BuildContext context,
    DoctorProfileModel? doctor,
  ) {
    final theme = Theme.of(context);
    final isArabic =
        context.locale.languageCode == 'ar';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(15.r),
        ),
        border: Border.all(
          color: theme.colorScheme.primary
              .withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            context,
            Icons.badge_outlined,
            'career.labels.job'.tr(),
            isArabic
                ? (doctor?.currentJobAr ?? '-')
                : (doctor?.currentJobEn ?? '-'),
          ),

          SizedBox(height: 12.h),

          _buildInfoRow(
            context,
            Icons.account_balance_rounded,
            'career.labels.dept'.tr(),
            isArabic
                ? (doctor?.departmentAr ?? '-')
                : (doctor?.departmentEn ?? '-'),
          ),

          SizedBox(height: 12.h),

          _buildInfoRow(
            context,
            Icons.assignment_ind_rounded,
            'career.labels.type'.tr(),
            (doctor?.hasPermanentPosition ?? false)
                ? 'career.employment_type.permanent'.tr()
                : 'career.employment_type.temporary'.tr(),
          ),

          SizedBox(height: 12.h),

          _buildInfoRow(
            context,
            Icons.calendar_today_rounded,
            'career.labels.hire_date'.tr(),
            doctor?.hiringDate != null
                ? DateFormat('yyyy-MM-dd')
                    .format(doctor!.hiringDate!)
                : '-',
          ),

          if (doctor?.professorRankDate != null) ...[
            SizedBox(height: 12.h),

            _buildInfoRow(
              context,
              Icons.school_outlined,
              'career.labels.professor_date'.tr(),
              DateFormat('yyyy-MM-dd').format(
                doctor!.professorRankDate!,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: colorScheme.primary,
          size: 18.sp,
        ),

        SizedBox(width: 8.w),

        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13.sp,
            color: colorScheme.onSurface,
          ),
        ),

        SizedBox(width: 5.w),

        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              color: colorScheme.onSurface
                  .withOpacity(0.8),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // Build
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isArabic =
        context.locale.languageCode == 'ar';

    return BlocBuilder<DoctorDataCubit, DoctorDataState>(
      builder: (context, state) {
        if (state is DoctorLoading) {
          return Scaffold(
            backgroundColor:
                theme.scaffoldBackgroundColor,
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        DoctorProfileModel? doctor;

        if (state is DoctorLoaded) {
          doctor = state.doctor;
        }

        return Scaffold(
          backgroundColor:
              theme.scaffoldBackgroundColor,

          // ======================================================
          // AppBar
          // ======================================================

          appBar: AppBar(
            toolbarHeight: 90.h,
            automaticallyImplyLeading: false,

            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new,
                size: 30.sp,
              ),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(Routes.user);
                }
              },
            ),

            title: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'career.title'.tr(),
                        style: textTheme.titleSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),

                      SizedBox(height: 5.h),

                      Text(
                        isArabic
                            ? (doctor?.nameAr ?? '-')
                            : (doctor?.nameEn ?? '-'),
                        style:
                            textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                          fontSize: 18,
                        ),
                        overflow:
                            TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 12.w),

                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colorScheme.secondary,
                      width: 1.5,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 30.r,
                    backgroundColor:
                        colorScheme.secondary
                            .withOpacity(0.2),
                    backgroundImage:
                        (doctor?.profileImage
                                    .isNotEmpty ??
                                false)
                            ? CachedNetworkImageProvider(
                                doctor!.profileImage,
                              )
                            : null,
                    child:
                        (doctor?.profileImage.isEmpty ??
                                true)
                            ? Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 20.sp,
                              )
                            : null,
                  ),
                ),
              ],
            ),

            bottom: PreferredSize(
              preferredSize:
                  Size.fromHeight(2.h),
              child: Container(
                color: colorScheme.secondary,
                height: 2.h,
              ),
            ),
          ),

          // ======================================================
          // Body
          // ======================================================

          body: SingleChildScrollView(
            padding: EdgeInsets.all(20.w),
            physics:
                const BouncingScrollPhysics(),
            child: Column(
              children: [
                // ==================================================
                // التاريخ الوظيفي
                // ==================================================

                _buildSectionHeader(
                  context,
                  Icons.trending_up_rounded,
                  'career.sections.promotions_track'
                      .tr(),
                ),

                _buildJobHistoryTimeline(
                  context,
                  doctor,
                ),

                SizedBox(height: 25.h),

                // ==================================================
                // المسار الوظيفي
                // ==================================================

                _buildSectionHeader(
                  context,
                  Icons.history_edu_rounded,
                  'career.sections.path'.tr(),
                ),

                _buildCareerPathCard(
                  context,
                  doctor,
                ),

                SizedBox(height: 25.h),

                // ==================================================
                // الوظيفة الحالية
                // ==================================================

                _buildSectionHeader(
                  context,
                  Icons.badge_outlined,
                  'career.sections.current_employment'
                      .tr(),
                ),

                _buildCurrentInfoCard(
                  context,
                  doctor,
                ),

                SizedBox(height: 30.h),
              ],
            ),
          ),
        );
      },
    );
  }
}