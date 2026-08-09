
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'package:optialeader/core/services/hive_service.dart';
import 'package:optialeader/core/theming/logic/theme_cubit.dart';

import 'package:optialeader/feature/auth/data/repo/auth_repo_impl.dart';
import 'package:optialeader/feature/auth/logic/cubits/auth_cubit.dart';

import 'package:optialeader/feature/notification/data/repo/notification_repo.dart';
import 'package:optialeader/feature/notification/data/repo/notification_repo_impl.dart';
import 'package:provider/single_child_widget.dart';
import 'package:optialeader/feature/admin/logic/admin_providers.dart';
import 'package:optialeader/feature/doctor/logic/doctor_providers.dart';
import 'package:optialeader/feature/judge/data/judge_providers.dart';
import 'package:optialeader/feature/database_admin/logic/general_data_providers.dart';

class AppProviders {
  static List<SingleChildWidget> providers({
    required HiveService hiveService,
  }) {
    return [
      // Notification
      RepositoryProvider<NotificationRepo>(
        create: (context) => NotificationRepoImpl(),
      ),

      // Theme
      BlocProvider<ThemeCubit>(
        create: (context) => ThemeCubit(),
      ),

      // Auth + Hive
      BlocProvider<AuthCubit>(
        create: (context) => AuthCubit(
          AuthRepoImpl(
            auth: FirebaseAuth.instance,
            firestore: FirebaseFirestore.instance,

            // لو AuthRepoImpl عندك فيه hiveService
            hiveService: hiveService,
          ),
        )..checkAuthStatus(),
      ),

      // Doctor
      ...DoctorProviders.providers(),

      // Admin
      ...AdminProviders.providers(),

      // Judge
      ...JudgeProviders.providers(),

      // General Data
      ...GeneralDataProviders.providers(),
    ];
  }
}
