import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:optialeader/core/routing/router_refresh_notifier.dart';
import 'package:optialeader/feature/admin/admin_routes.dart';
import 'package:optialeader/feature/admin/ui/dashboaer.dart'; // تأكدي من مسمى الملف ده (dashboard)
import 'package:optialeader/feature/auth/logic/cubits/auth_cubit.dart';
import 'package:optialeader/feature/auth/logic/cubits/auth_state.dart';
import 'package:optialeader/feature/auth/ui/change_password_screen.dart';
import 'package:optialeader/feature/auth/ui/signin_screen.dart';
import 'package:optialeader/feature/database_admin/data/models/employee_model.dart';
import 'package:optialeader/feature/database_admin/routing/database_admin_routes.dart';
import 'package:optialeader/feature/employee/ui/employee_courses_page.dart';
import 'package:optialeader/feature/employee/ui/employee_dashboard_screen.dart';
import 'package:optialeader/feature/judge/routing/judge_rouring.dart';
import 'package:optialeader/feature/judge/ui/screens/judge.dart';
import 'package:optialeader/feature/notification/logic/app_notification_cubit.dart';
import 'package:optialeader/feature/notification/ui/notification_page.dart';
import 'package:optialeader/feature/setting/ui/setting.dart';
import 'package:optialeader/feature/doctor/routing/user_routing.dart';
import 'package:optialeader/feature/doctor/ui/screens/dashboard_user.dart';
import 'package:optialeader/feature/auth/data/models/user_model.dart';
import 'package:optialeader/feature/database_admin/ui/screens/database_admin_dashboard.dart';
import 'routes.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
GoRouter createRouter(AuthCubit authCubit) {
  // دالة مساعدة لتحديد الصفحة الرئيسية بناءً على الدور
  String getHomeByRole(UserRole role) {
    switch (role) {
      case UserRole.database_admin:
        return Routes.databaseAdmin;
      case UserRole.admin:
        return Routes.admin;
      case UserRole.judge:
        return Routes.judge;
      case UserRole.user:
        return Routes.user;
      case UserRole.employee:
        return Routes.employee; // أو شاشة خاصة بيه
    }
  }

  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: Routes.login,
    refreshListenable: RouterRefreshNotifier(authCubit),
    redirect: (context, state) {
      final authState = authCubit.state;
      final location = state.uri.toString();

      final isOnLogin = location == Routes.login;
      final isOnRegister = location == Routes.register;
      final isOnChangePassword = location == Routes.changePassword;

      // 1. لو لسه في البداية أو بيحمل أو حصل خطأ (خليه في صفحة الـ Login)
      if (authState is AuthInitialState ||
          authState is LoginErrorState ||
          authState is LogoutSuccessState) {
        if (isOnLogin || isOnRegister) return null;
        return Routes.login;
      }

      // 2. أول ما ينجح في تسجيل الدخول (LoginSuccessState)
      if (authState is LoginSuccessState) {
        final role = authState.userModel.role;
        return getHomeByRole(role);
      }

      // 3. حالة المستخدم الجديد (إجبار على تغيير الباسورد)
      if (authState is NewUserFirstLoginState) {
        if (isOnChangePassword) return null;
        return Routes.changePassword;
      }

      // 4. حالة المصادقة النهائية المستقرة (AuthenticatedState)
      if (authState is AuthenticatedState) {
        final role = authState.userModel.role;
        // لو هو مسجل دخول وبيحاول يروح لصفحات الـ Auth، رجعه لبيته
        if (isOnLogin || isOnRegister || isOnChangePassword) {
          return getHomeByRole(role);
        }
        return null;
      }

      return null;
    },
    routes: [
      /// --- AUTH ROUTES ---
      GoRoute(
        path: Routes.login,
        builder: (context, state) => const SignInView(),
      ),
      GoRoute(
        path: Routes.changePassword,
        builder: (context, state) => const ChangePasswordView(),
      ),

      /// --- DASHBOARD ROUTES ---
      GoRoute(
        path: Routes.databaseAdmin,
        builder: (context, state) => const DatabaseAdminDashboard(),
        routes: databaseAdminSubRoutes,
      ),
      GoRoute(
        path: Routes.admin,
        builder: (context, state) => const DashboardScreen(),
        routes: adminSubRoutes,
      ),
      GoRoute(
        path: Routes.judge,
        builder: (context, state) => const MohakemDashboardHome(),
        routes: judgeSubRoutes,
      ),
      GoRoute(
        path: Routes.user,
        builder: (context, state) => const DashboardUserPage(),
        routes: userSubRoutes,
      ),
       GoRoute(
        path: Routes.employee,
        builder: (context, state) => const EmployeeDashboardScreen(), 
      ),

      /// --- SETTINGS ---
      GoRoute(
        path: Routes.settings,
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>? ?? {};
          return SettingsScreen(
            uid: args['uid'] as String? ?? '',
            role: args['role'] as String? ?? 'user',
          );
        },
      ),

      ///Notification
      ///Notification
      GoRoute(
        path: Routes.notification,
        builder: (context, state) {
          //  بنستدعي الـ Cubit وبنشغل جلب البيانات بمجرد فتح الصفحة
          final notificationCubit = context.read<NotificationCubit>();
          notificationCubit.fetchNotifications();

          return const NotificationsScreen();
        },
      ),
      GoRoute(
  path: Routes.employeeCourses,
  builder: (context, state) => EmployeeCoursesPage(
    // بنستقبل الـ employee model اللي هنبعتها من الداشبورد
    employee: state.extra as EmployeeModel,
  ),
),
    ],
  );
  
}
