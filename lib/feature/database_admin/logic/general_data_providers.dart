import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ✅ زيادة الاستدعاء ده
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:optialeader/feature/database_admin/data/repo/doctor_repository/doctor_repo_impl.dart';
import 'package:optialeader/feature/database_admin/data/repo/employee_repository/employee_repo.dart';
import 'package:optialeader/feature/database_admin/data/repo/employee_repository/employee_repo_impl.dart';
import 'package:optialeader/feature/database_admin/data/repo/judge_repository/judge_repo_impl.dart';
import 'package:optialeader/feature/database_admin/data/repo/search/search_repo.dart';
import 'package:optialeader/feature/database_admin/logic/doctor_data/doctor_data_cubit.dart';
import 'package:optialeader/feature/database_admin/logic/employee_logic/employee_cubit.dart';
import 'package:optialeader/feature/database_admin/logic/judge_data/judge_data_cubit.dart';
import 'package:optialeader/feature/database_admin/logic/leadership_scoring_engine/leadership_cubit.dart';
import 'package:optialeader/feature/database_admin/logic/search/search_cubit.dart';
import 'package:optialeader/feature/employee/data/repo/employee_courses_repo.dart';
import 'package:optialeader/feature/employee/logic/employee_courses_cubit.dart';
import 'package:optialeader/feature/notification/data/repo/notification_repo.dart';
import 'package:optialeader/feature/notification/logic/app_notification_cubit.dart';
import 'package:optialeader/feature/setting/data/repo/setting_repo_impl.dart';
import 'package:optialeader/feature/setting/logic/setting_cubit.dart';
import 'package:provider/single_child_widget.dart';

class GeneralDataProviders {
  static List<SingleChildWidget> providers() => [
    // الريپوزيتوريز
    RepositoryProvider<EmployeeRepo>(create: (context) => EmployeeRepoImpl()),
    RepositoryProvider<EmployeeCoursesRepo>(create: (context) => EmployeeCoursesRepo()),

    // الكيوبتات
    BlocProvider(create: (context) => DoctorDataCubit(DoctorRepoImpl())),
    BlocProvider(create: (context) => EmployeeDataCubit(context.read<EmployeeRepo>())),
    BlocProvider(create: (context) => JudgeDataCubit(JudgeRepoImpl())),
    BlocProvider(create: (context) => SearchCubit(SearchRepo(FirebaseFirestore.instance))),
    BlocProvider(create: (context) => SettingCubit(SettingRepoImpl())),
    
    BlocProvider(create: (context) => EmployeeCoursesCubit(repo: context.read<EmployeeCoursesRepo>())),
    
    BlocProvider(create: (context) => LeadershipCubit(doctorDataCubit: context.read<DoctorDataCubit>())),
    
    // ✅ تعديل هنا: رجّعنا الـ uid
    BlocProvider<NotificationCubit>(
      create: (context) {
        final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
        return NotificationCubit(
          notificationRepo: context.read<NotificationRepo>(),
          userId: uid,
        );
      },
    ),
  ];
}