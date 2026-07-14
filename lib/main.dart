import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:optialeader/core/services/hive_service.dart';
import 'package:optialeader/core/services/folder_json_loader.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'firebase_options.dart';
import 'package:optialeader/core/routing/app_router.dart';
import 'package:optialeader/core/services/app_providers.dart';
import 'package:optialeader/core/theming/app_theme.dart';
import 'package:optialeader/core/theming/logic/theme_cubit.dart';
import 'package:optialeader/core/theming/logic/theme_state.dart';
import 'package:optialeader/feature/auth/logic/cubits/auth_cubit.dart';
import 'package:optialeader/core/services/one_signal_result_handler.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  try {
    await Firebase.initializeApp(
      name: 'SecondaryApp',
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('SecondaryApp already initialized: $e');
  }

  await Supabase.initialize(
    url: 'https://ybmeqikzcqmaudedzxif.supabase.co',
    anonKey: 'sb_publishable_sf2YFT0RYrAapmg5XfjY4A_37kNyqyF',
  );

  // تهيئة hive وفتح صندوق التخزين
  final hiveService = HiveService();
  await hiveService.init();

  /// Localization
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      assetLoader: const FolderJsonLoader(),
      fallbackLocale: const Locale('ar'),
      startLocale: const Locale('ar'),
      child: MultiBlocProvider(
        providers: AppProviders.providers(hiveService: hiveService),
        child: const MyApp(),
      ),
    ),
  );

  // ✅ تشغيل الـ OneSignal Handler بعد التطبيق يفتح
  WidgetsBinding.instance.addPostFrameCallback((_) {
    OneSignalResultHandler.init();
  });
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
    _router = createRouter(context.read<AuthCubit>());
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
              title: "Optia Leader",
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: state.themeMode,
              locale: context.locale,
              supportedLocales: context.supportedLocales,
              localizationsDelegates: context.localizationDelegates,
              routerConfig: _router,
            );
          },
        );
      },
    );
  }
}