
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Supabase
  await Supabase.initialize(
    url: 'https://ybmeqikzcqmaudedzxif.supabase.co',
    anonKey: 'sb_publishable_sf2YFT0RYrAapmg5XfjY4A_37kNyqyF',
  );

  // Hive
  final hiveService = HiveService();
  await hiveService.init();

  // Localization
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
      ],
      path: 'assets/translations',
      assetLoader: const FolderJsonLoader(),
      fallbackLocale: const Locale('ar'),
      startLocale: const Locale('ar'),

      child: MultiBlocProvider(
        providers: AppProviders.providers(
          hiveService: hiveService,
        ),
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();

    _router = createRouter(
      context.read(),
    );
  }

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
              localizationsDelegates:
                  context.localizationDelegates,
              routerConfig: _router,
            );
          },
        );
      },
    );
  }
}

