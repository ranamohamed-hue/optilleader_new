import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  static List<SingleChildWidget> providers({required HiveService hiveService}) => [
    
    // 1. الأساسيات (الريبو الأساسي والثيم والأوث)
    RepositoryProvider<NotificationRepo>(create: (context) => NotificationRepoImpl()),
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

    // 2. ملف الدكاترة (لازم ييجي الأول عشان الـ Admin يعتمد عليه)
    ...DoctorProviders.providers(),
    
    // 3. ملف الأدمن
    ...AdminProviders.providers(),

    // 4. ملف المحكمين
    ...JudgeProviders.providers(),

    // 5. ملف البيانات العامة (الموظفين، الإعدادات، الإشعارات...)
    ...GeneralDataProviders.providers(),
  ];
}