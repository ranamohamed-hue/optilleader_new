import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:optialeader/core/services/hive_service.dart';
import 'package:optialeader/core/theming/logic/theme_cubit.dart';
import 'package:optialeader/feature/admin/data/repo/admin_approval/admin_aproval_repo_impl.dart';
import 'package:optialeader/feature/admin/data/repo/announcement_repos/announcement_repo_impl.dart';

import 'package:optialeader/feature/admin/data/repo/nomination_request/nomination_request_repo.dart';
import 'package:optialeader/feature/admin/data/repo/nomination_request/nomination_request_repo_impl.dart';

import 'package:optialeader/feature/admin/logic/admin_approval/admin_approval_cubit.dart';
import 'package:optialeader/feature/admin/logic/announcement_logic/announcement_cubit.dart';
import 'package:optialeader/feature/admin/logic/nomination_request_logic/nomination_request_cubit.dart';

import 'package:optialeader/feature/auth/data/repo/auth_repo_impl.dart';
import 'package:optialeader/feature/auth/logic/cubits/auth_cubit.dart';
import 'package:optialeader/feature/database_admin/data/repo/admin_repository/admin_repo_impl.dart';
import 'package:optialeader/feature/database_admin/data/repo/database_admin_repository/database_admin_repo_impl.dart';
import 'package:optialeader/feature/database_admin/data/repo/doctor_repository/doctor_repo_impl.dart';
import 'package:optialeader/feature/database_admin/data/repo/employee_repository/employee_repo.dart';
import 'package:optialeader/feature/database_admin/data/repo/employee_repository/employee_repo_impl.dart';
import 'package:optialeader/feature/database_admin/data/repo/judge_repository/judge_repo_impl.dart';
import 'package:optialeader/feature/database_admin/data/repo/search/search_repo.dart';
import 'package:optialeader/feature/employee/data/repo/employee_courses_repo.dart';

import 'package:optialeader/feature/employee/logic/employee_courses_cubit.dart';
import 'package:optialeader/feature/database_admin/logic/admin_data/admin_data_cubit.dart';
import 'package:optialeader/feature/database_admin/logic/database_admin_data/databse_admin_cubit.dart';
import 'package:optialeader/feature/database_admin/logic/doctor_data/doctor_data_cubit.dart';
import 'package:optialeader/feature/database_admin/logic/employee_logic/employee_cubit.dart';
import 'package:optialeader/feature/database_admin/logic/judge_data/judge_data_cubit.dart';
import 'package:optialeader/feature/database_admin/logic/leadership_scoring_engine/leadership_cubit.dart';
import 'package:optialeader/feature/database_admin/logic/search/search_cubit.dart';
import 'package:optialeader/feature/doctor/data/repo/activities/activity_repo.dart';
import 'package:optialeader/feature/doctor/data/repo/activities/activity_repo_impl.dart';

import 'package:optialeader/feature/doctor/data/repo/research_paper/research_paper_repo.dart';
import 'package:optialeader/feature/doctor/data/repo/research_paper/research_paper_repo_impl.dart';
import 'package:optialeader/feature/doctor/logic/activities/activity_cubit.dart';
import 'package:optialeader/feature/doctor/logic/research_paper/research_paper_cubit.dart';
import 'package:optialeader/feature/notification/data/repo/notification_repo.dart';
import 'package:optialeader/feature/notification/data/repo/notification_repo_impl.dart';
import 'package:optialeader/feature/notification/logic/app_notification_cubit.dart';
import 'package:optialeader/feature/setting/data/repo/setting_repo_impl.dart';
import 'package:optialeader/feature/setting/logic/setting_cubit.dart';
import 'package:provider/single_child_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppProviders {
  static List<SingleChildWidget> providers({
    required HiveService hiveService,
  }) => [
    // ====== Repositories ======
    RepositoryProvider<ResearchPaperRepo>(
      create: (context) => ResearchPaperRepoImpl(),
    ),

    RepositoryProvider<ActivitiesRepo>(
      create: (context) => ActivitiesRepoImpl(),
    ),

    RepositoryProvider<NotificationRepo>(
      create: (context) => NotificationRepoImpl(),
    ),

    RepositoryProvider<NominationRequestRepository>(
      create: (context) => NominationRequestRepositoryImpl(
        FirebaseFirestore.instance,
        Supabase.instance.client,
      ),
    ),

    RepositoryProvider<EmployeeRepo>(create: (context) => EmployeeRepoImpl()),

    // ✅ 2. تسجيل الريبو الجديد في قائمة الـ Repositories
    RepositoryProvider<EmployeeCoursesRepo>(
      create: (context) => EmployeeCoursesRepo(),
    ),

    // ====== Cubits ======
    BlocProvider(create: (context) => ThemeCubit()),

    BlocProvider(
      create: (context) => AuthCubit(
        AuthRepoImpl(
          auth: FirebaseAuth.instance,
          firestore: FirebaseFirestore.instance,
          hiveService: hiveService,
        ),
      ),
    ),

    BlocProvider(create: (context) => AdminDataCubit(AdminRepoImpl())),
    BlocProvider(create: (context) => DoctorDataCubit(DoctorRepoImpl())),
    BlocProvider(
      create: (context) => EmployeeDataCubit(context.read<EmployeeRepo>()),
    ),
    BlocProvider(create: (context) => JudgeDataCubit(JudgeRepoImpl())),
    BlocProvider(
      create: (context) =>
          DatabseAdminCubit(DatabaseAdminRepoImpl(FirebaseFirestore.instance)),
    ),

      BlocProvider(
      create: (context) => AnnouncementCubit(
        AnnouncementRepositoryImpl(FirebaseFirestore.instance),
        context.read<NotificationRepo>(),
      ),
    ),

    BlocProvider(create: (context) => SettingCubit(SettingRepoImpl())),
    BlocProvider(
      create: (context) => SearchCubit(SearchRepo(FirebaseFirestore.instance)),
    ),

    BlocProvider(
      create: (context) => ActivityCubit(
        context.read<ActivitiesRepo>(),
        context.read<NotificationRepo>(),
      ),
    ),

    BlocProvider(
      create: (context) => ResearchCubit(
        context.read<ResearchPaperRepo>(),
        context.read<NotificationRepo>(),
      ),
    ),

       BlocProvider(
      create: (context) {
        final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
        return NotificationCubit(
          notificationRepo: context.read<NotificationRepo>(),
          userId: uid,
        );
      },
    ),

    BlocProvider(
      create: (context) => AdminApprovalCubit(
        adminApprovalRepo: AdminApprovalRepoImpl(
          firebaseFirestore: FirebaseFirestore.instance,
          researchPaperRepo: context.read<ResearchPaperRepo>(),
          notificationRepo: context.read<NotificationRepo>(),
        ),
      ),
    ),

    BlocProvider<LeadershipCubit>(
      create: (context) =>
          LeadershipCubit(doctorDataCubit: context.read<DoctorDataCubit>()),
    ),

    BlocProvider<NominationRequestCubit>(
      create: (context) => NominationRequestCubit(
        context.read<NominationRequestRepository>(),
        context.read<NotificationRepo>(),
      ),
    ),
  ];
}