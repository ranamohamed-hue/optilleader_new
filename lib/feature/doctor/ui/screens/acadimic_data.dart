import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:optialeader/core/routing/routes.dart';
import 'package:optialeader/feature/database_admin/logic/doctor_data/doctor_data_cubit.dart';
import 'package:optialeader/feature/database_admin/logic/doctor_data/doctor_data_state.dart';

class DoctorProfileDataPage extends StatefulWidget {
  final String doctorUid;

  const DoctorProfileDataPage({
    super.key,
    required this.doctorUid,
  });

  @override
  State<DoctorProfileDataPage> createState() =>
      _DoctorProfileDataPageState();
}

class _DoctorProfileDataPageState extends State<DoctorProfileDataPage> {
  @override
  void initState() {
    super.initState();

    context
        .read<DoctorDataCubit>()
        .getDoctorProfile(widget.doctorUid);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isArabic = context.locale.languageCode == 'ar';

    return BlocBuilder<DoctorDataCubit, DoctorDataState>(
      builder: (context, state) {
        // ============================================================
        // LOADING
        // ============================================================

        if (state is DoctorLoading) {
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // ============================================================
        // LOADED
        // ============================================================

        if (state is DoctorLoaded && state.doctor != null) {
          final doctor = state.doctor!;

          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ==================================================
                // APP BAR
                // ==================================================

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
                        padding: EdgeInsets.fromLTRB(
                          10.w,
                          10.h,
                          10.w,
                          0,
                        ),

                        child: Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.center,
                          children: [
                            // ==============================
                            // BACK BUTTON
                            // ==============================

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

                            // ==============================
                            // NAME + JOB
                            // ==============================

                            Expanded(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isArabic
                                        ? doctor.nameAr
                                        : doctor.nameEn,
                                    style: theme
                                        .textTheme.titleMedium
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
                                    style: theme
                                        .textTheme.bodySmall
                                        ?.copyWith(
                                      color: Colors.white70,
                                      fontSize: 18.sp,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(width: 15.w),

                            // ==============================
                            // PROFILE IMAGE
                            // ==============================

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
                                    doctor.profileImage.isNotEmpty
                                        ? CachedNetworkImageProvider(
                                            doctor.profileImage,
                                          )
                                        : null,

                                child:
                                    doctor.profileImage.isEmpty
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

                // ==================================================
                // BODY
                // ==================================================

                SliverList(
                  delegate: SliverChildListDelegate([
                    SizedBox(height: 10.h),

                    // ==================================================
                    // البيانات الشخصية
                    // ==================================================

                    _buildSectionCard(
                      context,
                      icon: Icons.badge_outlined,
                      title:
                          "acadimic_Data.academicData.personal_section"
                              .tr(),
                      children: [
                        _buildInfoRow(
                          context,
                          label:
                              "acadimic_Data.academicData.name".tr(),
                          value: isArabic
                              ? doctor.nameAr
                              : doctor.nameEn,
                        ),

                        _buildInfoRow(
                          context,
                          label:
                              "acadimic_Data.academicData.phone".tr(),
                          value: doctor.phone,
                        ),

                        _buildInfoRow(
                          context,
                          label:
                              "acadimic_Data.academicData.social_status"
                                  .tr(),
                          value: isArabic
                              ? doctor.socialStatusAr
                              : doctor.socialStatusEn,
                        ),

                        _buildInfoRow(
                          context,
                          label:
                              "acadimic_Data.academicData.status".tr(),
                          value: doctor.isActive
                              ? "acadimic_Data.statuses.active".tr()
                              : "acadimic_Data.statuses.inactive".tr(),
                          valueColor: doctor.isActive
                              ? Colors.green
                              : Colors.orange,
                        ),

                        _buildInfoRow(
                          context,
                          label:
                              "acadimic_Data.academicData.birth_date"
                                  .tr(),
                          value: doctor.birthDate != null
                              ? DateFormat('yyyy-MM-dd')
                                  .format(doctor.birthDate!)
                              : '-',
                        ),
                      ],
                    ),

                    // ==================================================
                    // البيانات الأكاديمية
                    // ==================================================

                    _buildSectionCard(
                      context,
                      icon: Icons.school_outlined,
                      title:
                          "acadimic_Data.academicData.academic_section"
                              .tr(),
                      children: [
                        _buildInfoRow(
                          context,
                          label:
                              "acadimic_Data.add_doctor.university"
                                  .tr(),
                          value: isArabic
                              ? doctor.universityAr
                              : doctor.universityEn,
                        ),

                        _buildInfoRow(
                          context,
                          label:
                              "acadimic_Data.add_doctor.faculty".tr(),
                          value: isArabic
                              ? doctor.facultyAr
                              : doctor.facultyEn,
                        ),

                        _buildInfoRow(
                          context,
                          label:
                              "acadimic_Data.add_doctor.department"
                                  .tr(),
                          value: isArabic
                              ? doctor.departmentAr
                              : doctor.departmentEn,
                        ),

                        _buildInfoRow(
                          context,
                          label:
                              "acadimic_Data.academicData.job".tr(),
                          value: isArabic
                              ? doctor.currentJobAr
                              : doctor.currentJobEn,
                        ),

                        // ==============================
                        // تاريخ التعيين
                        // ==============================

                        _buildInfoRow(
                          context,
                          label: "تاريخ التعيين",
                          value: doctor.hiringDate != null
                              ? DateFormat('yyyy-MM-dd')
                                  .format(doctor.hiringDate!)
                              : '-',
                        ),

                        // ==============================
                        // تاريخ الأستاذية
                        // ==============================

                        _buildInfoRow(
                          context,
                          label: "تاريخ الأستاذية",
                          value: doctor.professorRankDate != null
                              ? DateFormat('yyyy-MM-dd')
                                  .format(
                                  doctor.professorRankDate!,
                                )
                              : '-',
                        ),
                      ],
                    ),

                    // ==================================================
                    // بيانات التواصل
                    // ==================================================

                    _buildSectionCard(
                      context,
                      icon: Icons.contact_mail_outlined,
                      title:
                          "acadimic_Data.academicData.contact_section"
                              .tr(),
                      children: [
                        _buildInfoRow(
                          context,
                          label:
                              "acadimic_Data.academicData.email".tr(),
                          value: doctor.email,
                        ),

                        _buildInfoRow(
                          context,
                          label:
                              "acadimic_Data.academicData.address".tr(),
                          value: isArabic
                              ? doctor.addressAr
                              : doctor.addressEn,
                        ),
                      ],
                    ),

                    // ==================================================
                    // اللجان الداخلية
                    // ==================================================

                    _buildSectionCard(
                      context,
                      icon: Icons.groups_outlined,
                      title:
                          "acadimic_Data.add_doctor.internal_committees"
                              .tr(),
                      children: [
                        _buildCommitteesWidget(
                          context,
                          doctor.internalCommittees,
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

        // ============================================================
        // ERROR
        // ============================================================

        if (state is DoctorError) {
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 48.sp,
                  ),

                  SizedBox(height: 16.h),

                  Text(
                    state.error ??
                        'acadimic_Data.error_message'.tr(),
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 14.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 20.h),

                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<DoctorDataCubit>()
                          .getDoctorProfile(widget.doctorUid);
                    },
                    child: Text(
                      'acadimic_Data.retry'.tr(),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  // ============================================================
  // COMMITTEES
  // ============================================================

  Widget _buildCommitteesWidget(
    BuildContext context,
    List<String> committees,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: 15.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "acadimic_Data.add_doctor.internal_committees".tr(),
            style: theme.textTheme.labelMedium?.copyWith(
              color:
                  theme.colorScheme.primary.withOpacity(0.7),
              fontWeight: FontWeight.w600,
              fontSize: 11.sp,
            ),
          ),

          SizedBox(height: 8.h),

          if (committees.isEmpty)
            Text(
              "acadimic_Data.add_doctor.no_committees".tr(),
              style: TextStyle(
                color: Colors.grey,
                fontSize: 13.sp,
              ),
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
                    color: theme.colorScheme.secondary
                        .withOpacity(0.1),
                    borderRadius:
                        BorderRadius.circular(8.r),
                    border: Border.all(
                      color: theme.colorScheme.secondary
                          .withOpacity(0.3),
                    ),
                  ),

                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 14.sp,
                        color:
                            theme.colorScheme.secondary,
                      ),

                      SizedBox(width: 4.w),

                      Text(
                        name,
                        style:
                            theme.textTheme.bodySmall?.copyWith(
                          color:
                              theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),

          SizedBox(height: 10.h),

          Divider(
            height: 1,
            color: theme.dividerColor.withOpacity(0.2),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION CARD
  // ============================================================

  Widget _buildSectionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark =
        theme.brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 20.w,
        vertical: 10.h,
      ),

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
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            Row(
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
                    style:
                        theme.textTheme.titleSmall?.copyWith(
                      color: isDark
                          ? Colors.white
                          : Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ],
            ),

            Divider(
              height: 30.h,
              color:
                  colorScheme.primary.withOpacity(0.1),
            ),

            ...children,
          ],
        ),
      ),
    );
  }

  // ============================================================
  // INFO ROW
  // ============================================================

  Widget _buildInfoRow(
    BuildContext context, {
    required String label,
    required String value,
    Color? valueColor,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: 15.h),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Text(
            label,
            style:
                theme.textTheme.labelMedium?.copyWith(
              color: theme.brightness ==
                      Brightness.dark
                  ? Colors.white70
                  : theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
              fontSize: 11.sp,
            ),
          ),

          SizedBox(height: 4.h),

          Text(
            value.isEmpty ? '-' : value,
            style:
                theme.textTheme.bodyMedium?.copyWith(
              color: valueColor ??
                  theme.colorScheme.onSurface,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),

          SizedBox(height: 10.h),

          Divider(
            height: 1,
            color:
                theme.dividerColor.withOpacity(0.2),
          ),
        ],
      ),
    );
  }
}