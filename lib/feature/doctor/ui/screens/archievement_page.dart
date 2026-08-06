import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:optialeader/core/routing/routes.dart';
import 'package:optialeader/feature/database_admin/data/models/doctor_profile_model.dart';
import 'package:optialeader/feature/database_admin/logic/doctor_data/doctor_data_cubit.dart';
import 'package:optialeader/feature/database_admin/logic/doctor_data/doctor_data_state.dart';

import 'package:optialeader/feature/doctor/data/model/conferance_model.dart';
import 'package:optialeader/feature/doctor/data/model/courses_model.dart';
import 'package:optialeader/feature/doctor/data/model/exhibition_venue_model.dart';
import 'package:optialeader/feature/doctor/data/model/research_paper_model.dart';
import 'package:optialeader/feature/doctor/data/model/verefication_status.dart';

class AchievementsLogPage extends StatefulWidget {
  final String doctorUid;

  const AchievementsLogPage({super.key, required this.doctorUid});

  @override
  State<AchievementsLogPage> createState() => _AchievementsLogPageState();
}

class _AchievementsLogPageState extends State<AchievementsLogPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocBuilder<DoctorDataCubit, DoctorDataState>(
      builder: (context, state) {
        DoctorProfileModel? doctor;
        if (state is DoctorLoaded) {
          doctor = state.doctor;
        }

        return DefaultTabController(
          length: 4,
          child: Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: AppBar(
              toolbarHeight: 80.h,
              automaticallyImplyLeading: false,
              title: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new,
                      size: 30.sp,
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
                  SizedBox(width: 10.w),
                  Text(
                    'achievements_new.title'.tr(),
                    style: theme.appBarTheme.titleTextStyle,
                  ),
                  SizedBox(width: 5.w),
                  Icon(Icons.emoji_events, color: colorScheme.secondary),
                  const Spacer(),
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
                      backgroundImage:
                          (doctor?.profileImage.isNotEmpty ?? false)
                          ? CachedNetworkImageProvider(doctor!.profileImage)
                          : null,
                      child: (doctor?.profileImage.isEmpty ?? true)
                          ? Icon(Icons.person, color: Colors.white, size: 30.sp)
                          : null,
                    ),
                  ),
                ],
              ),
              bottom: TabBar(
                isScrollable: true,
                indicatorColor: colorScheme.secondary,
                indicatorWeight: 3,
                labelColor: colorScheme.secondary,
                unselectedLabelColor: Colors.white70,
                tabs: [
                  Tab(text: "tabs.research".tr()),
                  Tab(text: "tabs.conferences".tr()),
                  Tab(text: "tabs.activities".tr()),
                  Tab(text: "tabs.courses".tr()),
                ],
              ),
            ),
            body: Column(
              children: [
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildResearchList(context, doctor?.researchPapers ?? []),
                      _buildConferencesList(context, doctor?.conferences ?? []),
                      _buildExhibitionsList(context, doctor?.exhibitions ?? []),
                      _buildCoursesList(context, doctor?.courses ?? []),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Builder(
                    builder: (innerContext) {
                      return SizedBox(
                        width: double.infinity,
                        height: 50.h,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            final int currentIndex =
                                DefaultTabController.maybeOf(
                                  innerContext,
                                )?.index ??
                                0;
                            if (currentIndex == 0) {
                              context.push(
                                '${Routes.addResearch}?uid=${widget.doctorUid}',
                              );
                            } else {
                              context.push(
                                '${Routes.addActivity}?uid=${widget.doctorUid}',
                              );
                            }
                          },
                          icon: Icon(
                            Icons.add_circle_outline,
                            color: colorScheme.primary,
                          ),
                          label: Text(
                            'achievements_new.add_new'.tr(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.secondary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildResearchList(
    BuildContext context,
    List<ResearchPaperModel> papers,
  ) {
    if (papers.isEmpty)
      return _buildEmptyState('achievements_new.no_research'.tr());
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: papers.length,
      itemBuilder: (context, index) {
        final paper = papers[index];
        return _buildItemCard(
          title: paper.titleAr,
          subtitle: paper.journalName,
          date: paper.publicationYear.toString(),
          status: paper.status,
        );
      },
    );
  }

  Widget _buildConferencesList(
    BuildContext context,
    List<ConferenceModel> conferences,
  ) {
    if (conferences.isEmpty)
      return _buildEmptyState('achievements_new.no_conferences'.tr());
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: conferences.length,
      itemBuilder: (context, index) {
        final conf = conferences[index];
        return _buildItemCard(
          title: conf.title,
          // تم تصحيح المنطق ليتطابق مع الترجمة
          subtitle: conf.isInternational
              ? 'achievements_new.type_conference_international'.tr()
              : 'achievements_new.type_conference_local'.tr(),
          date: "",
          status: conf.status,
        );
      },
    );
  }

  Widget _buildExhibitionsList(
    BuildContext context,
    List<ArtExhibitionModel> exhibitions,
  ) {
    if (exhibitions.isEmpty)
      return _buildEmptyState('achievements_new.no_Exhibitions'.tr());
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: exhibitions.length,
      itemBuilder: (context, index) {
        final exh = exhibitions[index];
        return _buildItemCard(
          title: exh.title,
          subtitle:
              '${'achievements_new.number_of_Exhibitions'.tr()}: ${exh.numberOfWorks}',
          date: "",
          status: exh.status,
        );
      },
    );
  }

  Widget _buildCoursesList(BuildContext context, List<CourseModel> courses) {
    //  تم تصحيح مفتاح الترجمة ليعرض "لا توجد دورات"
    if (courses.isEmpty)
      return _buildEmptyState('achievements_new.no_courses'.tr());
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
        return _buildItemCard(
          title: course.title,
          subtitle: course.organization,
          date: course.date,
          status: course.status,
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Text(
        message,
        style: TextStyle(color: Colors.grey, fontSize: 14.sp),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildItemCard({
    required String title,
    required String subtitle,
    required String date,
    required VerificationStatus status,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12.sp,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: 10.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildStatusChip(status),
                if (date.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text(
                    date,
                    style: TextStyle(color: Colors.grey, fontSize: 11.sp),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(VerificationStatus status) {
    Color color;
    IconData icon;
    String text;

    switch (status) {
      case VerificationStatus.approved:
        color = Colors.green;
        icon = Icons.check_circle;
        text = 'status.accepted'.tr();
        break;
      case VerificationStatus.rejected:
        color = Colors.red;
        icon = Icons.cancel;
        text = 'status.rejected'.tr();
        break;
      case VerificationStatus.pending:
        color = Colors.orange;
        icon = Icons.hourglass_empty;
        text = 'status.under_review'.tr();
        break;
      case VerificationStatus.notSubmitted:
        color = Colors.grey;
        icon = Icons.remove_circle_outline;
        text = 'common.other'.tr();
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: color),
          SizedBox(width: 4.w),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
