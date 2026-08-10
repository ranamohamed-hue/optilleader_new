import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'firebase_options.dart';
import 'package:optialeader/core/services/hive_service.dart';
import 'package:optialeader/core/services/folder_json_loader.dart';
import 'package:optialeader/core/routing/app_router.dart';
import 'package:optialeader/core/services/app_providers.dart';
import 'package:optialeader/core/theming/app_theme.dart';
import 'package:optialeader/core/theming/logic/theme_cubit.dart';
import 'package:optialeader/core/theming/logic/theme_state.dart';
import 'package:optialeader/feature/auth/data/repo/auth_repo_impl.dart';
import 'package:optialeader/feature/auth/logic/cubits/auth_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Supabase.initialize(url: 'https://ybmeqikzcqmaudedzxif.supabase.co', anonKey: 'sb_publishable_sf2YFT0RYrAapmg5XfjY4A_37kNyqyF');
  await EasyLocalization.ensureInitialized();

  final hiveService = HiveService();
  await hiveService.init();

  final authCubit = AuthCubit(AuthRepoImpl(auth: FirebaseAuth.instance, firestore: FirebaseFirestore.instance, hiveService: hiveService));
authCubit.checkAuthStatus(); // ✅ شغله في الخلفية
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      assetLoader: const FolderJsonLoader(),
      fallbackLocale: const Locale('ar'),
      startLocale: const Locale('ar'),
            child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>.value(value: authCubit),
          ...AppProviders.providers(), 
        ],
        child: MyApp(appRouter: createRouter(authCubit)),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final GoRouter appRouter;
  const MyApp({super.key, required this.appRouter});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, state) {
            return MaterialApp.router(
              debugShowCheckedModeBanner: false,
              title: 'Optia Leader',
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: state.themeMode,
              locale: context.locale,
              supportedLocales: context.supportedLocales,
              localizationsDelegates: context.localizationDelegates,
              routerConfig: appRouter,
            );
          },
        );
      },
    );
  }
}