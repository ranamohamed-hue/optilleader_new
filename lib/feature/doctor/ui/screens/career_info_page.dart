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

class CareerInfoPage extends StatefulWidget {
  final String doctorUid;

  const CareerInfoPage({super.key, required this.doctorUid});

  @override
  State<CareerInfoPage> createState() => _CareerInfoPageState();
}

class _CareerInfoPageState extends State<CareerInfoPage> {
  @override
  void initState() {
    super.initState();
    context.read<DoctorDataCubit>().getDoctorProfile(widget.doctorUid);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isArabic = context.locale.languageCode == 'ar';

    return BlocBuilder<DoctorDataCubit, DoctorDataState>(
      builder: (context, state) {
        DoctorProfileModel? doctor;
        if (state is DoctorLoaded) {
          doctor = state.doctor;
        }

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            toolbarHeight: 90.h,
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, size: 30.sp),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                      SizedBox(height: 5),
                      Text(
                        isArabic
                            ? (doctor?.nameAr ?? '-')
                            : (doctor?.nameEn ?? '-'),
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                          fontSize: 18,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12),
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
                    backgroundColor: colorScheme.secondary.withOpacity(0.2),
                    backgroundImage: (doctor?.profileImage.isNotEmpty ?? false)
                        ? CachedNetworkImageProvider(doctor!.profileImage)
                        : null,
                    child: (doctor?.profileImage.isEmpty ?? true)
                        ? Icon(Icons.person, color: Colors.white, size: 20.sp)
                        : null,
                  ),
                ),
              ],
            ),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(2.h),
              child: Container(color: colorScheme.secondary, height: 2.h),
            ),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(20.w),
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                _buildSectionHeader(
                  context,
                  Icons.school_outlined,
                  'career.sections.credentials'.tr(),
                ),
                if (doctor?.academicHistory != null &&
                    doctor!.academicHistory.isNotEmpty)
                  ...doctor.academicHistory.asMap().entries.map((entry) {
                    int index = entry.key;
                    Map<String, dynamic> cert = entry.value;
                    bool isLast = index == doctor!.academicHistory.length - 1;

                    String degree = cert['degree'] ?? '-';
                    String major = cert['major'] ?? '-';
                    String place = cert['place'] ?? '-';
                    String dateStr = '-';
                    if (cert['date'] != null) {
                      final date = cert['date'] is DateTime
                          ? cert['date'] as DateTime
                          : (cert['date'] as dynamic)?.toDate();
                      if (date != null) {
                        dateStr = DateFormat('yyyy').format(date);
                      }
                    }

                    return _buildCredentialCard(
                      context,
                      degree,
                      major,
                      place,
                      dateStr,
                      isLast: isLast,
                    );
                  })
                else
                  _buildEmptyCard(context, 'career.no_history'.tr()),
                SizedBox(height: 25.h),
                _buildSectionHeader(
                  context,
                  Icons.history_edu_rounded,
                  'career.sections.path'.tr(),
                ),
                _buildCareerPathCard(context, doctor),
                SizedBox(height: 25.h),
                _buildSectionHeader(
                  context,
                  Icons.badge_outlined,
                  'career.sections.current_employment'.tr(),
                ),
                _buildCurrentInfoCard(context, doctor),
                SizedBox(height: 30.h),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyCard(BuildContext context, String message) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(15.r)),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        ),
      ),
      child: Text(
        message,
        style: TextStyle(color: Colors.grey, fontSize: 13.sp),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    IconData icon,
    String title,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 15.w),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(15.r)),
        border: Border.all(color: colorScheme.secondary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: colorScheme.secondary, size: 22.sp),
          SizedBox(width: 10.w),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCredentialCard(
    BuildContext context,
    String degree,
    String major,
    String place,
    String date, {
    bool isLast = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        border: Border.all(color: colorScheme.primary.withOpacity(0.1)),
        borderRadius: isLast
            ? BorderRadius.vertical(bottom: Radius.circular(15.r))
            : BorderRadius.zero,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle,
                color: colorScheme.secondary,
                size: 16.sp,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  degree,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.only(left: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (major.isNotEmpty)
                  Text(major, style: theme.textTheme.bodyMedium),
                if (place.isNotEmpty)
                  Text(place, style: theme.textTheme.bodySmall),
                if (date.isNotEmpty)
                  Text(
                    date,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCareerPathCard(
    BuildContext context,
    DoctorProfileModel? doctor,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isArabic = context.locale.languageCode == 'ar';

    int experienceYears = 0;
    if (doctor?.professorRankDate != null) {
      experienceYears = DateTime.now().year - doctor!.professorRankDate!.year;
      if (DateTime.now().month < doctor.professorRankDate!.month ||
          (DateTime.now().month == doctor.professorRankDate!.month &&
              DateTime.now().day < doctor.professorRankDate!.day)) {
        experienceYears--;
      }
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(15.r)),
        border: Border.all(color: colorScheme.primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'career.current_role'.tr(
              args: [
                isArabic
                    ? (doctor?.currentJobAr ?? '-')
                    : (doctor?.currentJobEn ?? '-'),
              ],
            ),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          SizedBox(height: 8.h),
          Text(
            'career.experience'.tr(args: ['$experienceYears']),
            style: TextStyle(
              color: colorScheme.secondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Divider(height: 30.h, color: colorScheme.primary.withOpacity(0.1)),
          Text(
            'career.previous_positions'.tr(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          SizedBox(height: 10.h),
          if (doctor?.previousLeadershipRoles != null &&
              doctor!.previousLeadershipRoles.isNotEmpty)
            ...doctor.previousLeadershipRoles
                .map((role) => _buildHistoryItem(context, role, ''))
                
          else
            _buildHistoryItem(context, 'career.no_previous_roles'.tr(), ''),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, String title, String period) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Icon(Icons.arrow_right, color: colorScheme.secondary),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          if (period.isNotEmpty)
            Text(
              period,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
        ],
      ),
    );
  }

  Widget _buildCurrentInfoCard(
    BuildContext context,
    DoctorProfileModel? doctor,
  ) {
    final theme = Theme.of(context);
    final isArabic = context.locale.languageCode == 'ar';
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(15.r)),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.1)),
      ),
      child: Column(
        children: [
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

            '-',
          ),
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
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: colorScheme.primary, size: 18.sp),
        SizedBox(width: 8.w),
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        SizedBox(width: 5.w),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
