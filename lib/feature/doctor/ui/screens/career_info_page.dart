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

  // ============================================================
  // ✅ الدوال المساعدة (Helpers) أولاً
  // ============================================================

  String _validateText(String? text) {
    if (text == null || text.trim().isEmpty) return '-';
    return text.trim();
  }

  String _getLocalizedText(Map<String, dynamic> map, String key) {
    final isArabic = context.locale.languageCode == 'ar';
    if (isArabic) {
      return _validateText(map['${key}_ar'] ?? map[key]);
    } else {
      return _validateText(map['${key}_en'] ?? map[key]);
    }
  }

  Widget _buildSectionHeader(BuildContext context, IconData icon, String title) {
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
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
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

  Widget _buildCredentialCard(BuildContext context, String degree, String major, String place, String date, {bool isLast = false}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        border: Border.all(color: colorScheme.primary.withOpacity(0.1)),
        borderRadius: isLast ? BorderRadius.vertical(bottom: Radius.circular(15.r)) : BorderRadius.zero,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: colorScheme.secondary, size: 16.sp),
              SizedBox(width: 8.w),
              Expanded(child: Text(degree, style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface, fontSize: 14.sp))),
            ],
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.only(left: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (major != '-') Text(major, style: theme.textTheme.bodyMedium),
                if (place != '-') Text(place, style: theme.textTheme.bodySmall),
                if (date != '-') Text(date, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: colorScheme.primary, size: 18.sp),
        SizedBox(width: 8.w),
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: colorScheme.onSurface)),
        SizedBox(width: 5.w),
        Expanded(child: Text(value, style: TextStyle(fontSize: 13, color: colorScheme.onSurface.withOpacity(0.8)))),
      ],
    );
  }

  Widget _buildHistoryItem(BuildContext context, String title, String period) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Icon(Icons.arrow_right, color: colorScheme.secondary),
          Expanded(child: Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: colorScheme.onSurface))),
          if (period.isNotEmpty) Text(period, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
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
          Column(
            children: [
              Container(
                width: 14.w,
                height: 14.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.secondary,
                  border: Border.all(
                    color: theme.cardTheme.color ?? Colors.white,
                    width: 3.w,
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2.5.w,
                    color: colorScheme.secondary.withOpacity(0.4),
                  ),
                ),
            ],
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20.h, top: 1.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                      Text(
                        date,
                        style: TextStyle(
                          color: colorScheme.secondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                  if (place != '-')
                    Padding(
                      padding: EdgeInsets.only(top: 2.h),
                      child: Text(
                        place,
                        style: TextStyle(
                          color: theme.textTheme.bodySmall?.color,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  if (duration.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 4.h),
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
  // ✅ الكروت الرئيسية (Cards)
  // ============================================================

  Widget _buildPromotionTrackCard(BuildContext context, DoctorProfileModel? doctor) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (doctor?.academicHistory == null || doctor!.academicHistory.isEmpty) {
      return _buildEmptyCard(context, 'career.no_promotions'.tr());
    }

    final sortedHistory = List<Map<String, dynamic>>.from(doctor.academicHistory);
    sortedHistory.sort((a, b) {
      final dateA = a['date'] as DateTime?;
      final dateB = b['date'] as DateTime?;
      if (dateA == null && dateB == null) return 0;
      if (dateA == null) return 1;
      if (dateB == null) return -1;
      return dateA.compareTo(dateB);
    });

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(15.r)),
        border: Border.all(color: colorScheme.primary.withOpacity(0.1)),
      ),
      child: Column(
        children: sortedHistory.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, dynamic> item = entry.value;
          bool isLast = index == sortedHistory.length - 1;

          String durationText = '';
          final currentDate = item['date'] as DateTime?;

          if (!isLast) {
            final nextDate = sortedHistory[index + 1]['date'] as DateTime?;
            if (currentDate != null && nextDate != null) {
              int years = nextDate.year - currentDate.year;
              int months = nextDate.month - currentDate.month;
              if (months < 0) { years--; months += 12; }
              if (years > 0) {
                durationText = '$years ${'career.years'.tr()}';
                if (months > 0) durationText += ' و $months ${'career.months'.tr()}';
              } else if (months > 0) {
                durationText = '$months ${'career.months'.tr()}';
              }
            }
          } else {
            durationText = '(${'career.until_now'.tr()})';
          }

          return _buildTimelineItem(
            context: context,
            title: _getLocalizedText(item, 'degree'),
            place: _getLocalizedText(item, 'place'),
            date: currentDate != null ? DateFormat('yyyy').format(currentDate) : '-',
            duration: durationText,
            isLast: isLast,
          );
        }).toList(),
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

  // الوظيفة الحالية من Firestore
  final currentJob = isArabic
      ? doctor?.currentJobAr.trim() ?? ''
      : doctor?.currentJobEn.trim() ?? '';

  // سنوات الخبرة من الـ getter الموجود في Model
  final experienceYears = doctor?.yearsSinceHiring ?? 0;

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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // الوظيفة الحالية
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.work_outline_rounded,
              color: colorScheme.secondary,
              size: 20.sp,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                currentJob.isNotEmpty
                    ? 'career.current_role'.tr(
                        args: [currentJob],
                      )
                    : 'career.current_role'.tr(
                        args: ['-'],
                      ),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 10.h),

        // سنوات الخبرة
        Row(
          children: [
            Icon(
              Icons.workspace_premium_outlined,
              color: colorScheme.secondary,
              size: 20.sp,
            ),
            SizedBox(width: 10.w),
            Text(
              'career.experience'.tr(
                args: [experienceYears.toString()],
              ),
              style: TextStyle(
                color: colorScheme.secondary,
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),

        Divider(
          height: 30.h,
          color: colorScheme.primary.withOpacity(0.1),
        ),

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


  
  Widget _buildCurrentInfoCard(BuildContext context, DoctorProfileModel? doctor) {
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
          _buildInfoRow(context, Icons.account_balance_rounded, 'career.labels.dept'.tr(), isArabic ? (doctor?.departmentAr ?? '-') : (doctor?.departmentEn ?? '-')),
          SizedBox(height: 12.h),
          _buildInfoRow(context, Icons.assignment_ind_rounded, 'career.labels.type'.tr(), (doctor?.hasPermanentPosition ?? false) ? 'career.employment_type.permanent'.tr() : 'career.employment_type.temporary'.tr()),
          SizedBox(height: 12.h),
          _buildInfoRow(context, Icons.calendar_today_rounded, 'career.labels.hire_date'.tr(), doctor?.hiringDate != null ? DateFormat('yyyy-MM-dd').format(doctor!.hiringDate!) : '-'),
        ],
      ),
    );
  }

  // ============================================================
  // ✅ دالة الـ Build في الآخر
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isArabic = context.locale.languageCode == 'ar';

    return BlocBuilder<DoctorDataCubit, DoctorDataState>(
      builder: (context, state) {
        if (state is DoctorLoading) {
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: const Center(child: CircularProgressIndicator()),
          );
        }

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
                if (context.canPop()) { context.pop(); } else { context.go(Routes.user); }
              },
            ),
            title: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('career.title'.tr(), style: textTheme.titleSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                      SizedBox(height: 5),
                      Text(isArabic ? (doctor?.nameAr ?? '-') : (doctor?.nameEn ?? '-'), style: textTheme.bodySmall?.copyWith(color: Colors.white70, fontSize: 18), overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: colorScheme.secondary, width: 1.5)),
                  child: CircleAvatar(
                    radius: 30.r,
                    backgroundColor: colorScheme.secondary.withOpacity(0.2),
                    backgroundImage: (doctor?.profileImage.isNotEmpty ?? false) ? CachedNetworkImageProvider(doctor!.profileImage) : null,
                    child: (doctor?.profileImage.isEmpty ?? true) ? Icon(Icons.person, color: Colors.white, size: 20.sp) : null,
                  ),
                ),
              ],
            ),
            bottom: PreferredSize(preferredSize: Size.fromHeight(2.h), child: Container(color: colorScheme.secondary, height: 2.h)),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(20.w),
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                _buildSectionHeader(context, Icons.school_outlined, 'career.sections.credentials'.tr()),
                if (doctor?.academicHistory != null && doctor!.academicHistory.isNotEmpty)
                  ...doctor.academicHistory.asMap().entries.map((entry) {
                    int index = entry.key;
                    Map<String, dynamic> cert = entry.value;
                    bool isLast = index == doctor!.academicHistory.length - 1;

                    String degree = _getLocalizedText(cert, 'degree');
                    String major = _getLocalizedText(cert, 'major');
                    String place = _getLocalizedText(cert, 'place');
                    
                    String dateStr = '-';
                    if (cert['date'] != null) {
                      final date = cert['date'] is DateTime ? cert['date'] as DateTime : (cert['date'] as dynamic)?.toDate();
                      if (date != null) { dateStr = DateFormat('yyyy').format(date); }
                    }

                    return _buildCredentialCard(context, degree, major, place, dateStr, isLast: isLast);
                  })
                else
                  _buildEmptyCard(context, 'career.no_history'.tr()),

                SizedBox(height: 25.h),
                _buildSectionHeader(context, Icons.trending_up_rounded, 'career.sections.promotions_track'.tr()),
                _buildPromotionTrackCard(context, doctor),

                SizedBox(height: 25.h),
                _buildSectionHeader(context, Icons.history_edu_rounded, 'career.sections.path'.tr()),
                _buildCareerPathCard(context, doctor),

                SizedBox(height: 25.h),
                _buildSectionHeader(context, Icons.badge_outlined, 'career.sections.current_employment'.tr()),
                _buildCurrentInfoCard(context, doctor),

                SizedBox(height: 30.h),
              ],
            ),
          ),
        );
      },
    );
  }
}