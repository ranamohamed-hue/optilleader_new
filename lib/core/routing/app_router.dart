import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:optialeader/core/routing/router_refresh_notifier.dart';
import 'package:optialeader/feature/admin/admin_routes.dart';
import 'package:optialeader/feature/admin/ui/dashboaer.dart';
import 'package:optialeader/feature/auth/logic/cubits/auth_cubit.dart';
import 'package:optialeader/feature/auth/logic/cubits/auth_state.dart';
import 'package:optialeader/feature/auth/ui/change_password_screen.dart';
import 'package:optialeader/feature/auth/ui/signin_screen.dart';
import 'package:optialeader/feature/database_admin/routing/database_admin_routes.dart';
import 'package:optialeader/feature/employee/employee_router/employee_rout.dart';
import 'package:optialeader/feature/employee/ui/employee_dashboard_screen.dart';
import 'package:optialeader/feature/judge/routing/judge_rouring.dart';
import 'package:optialeader/feature/judge/ui/screens/judge.dart';
import 'package:optialeader/feature/notification/ui/notification_page.dart';
import 'package:optialeader/feature/setting/ui/setting.dart';
import 'package:optialeader/feature/doctor/routing/user_routing.dart';
import 'package:optialeader/feature/doctor/ui/screens/dashboard_user.dart';
import 'package:optialeader/feature/auth/data/models/user_model.dart';
import 'package:optialeader/feature/database_admin/ui/screens/database_admin_dashboard.dart';
import 'routes.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter(AuthCubit authCubit) {
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
      case UserRole.admin_manager:
        return Routes.adminManager;
    }
  }

  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: Routes.splash,
    refreshListenable: RouterRefreshNotifier(authCubit),
    redirect: (context, state) {
      final authState = authCubit.state;
      final location = state.matchedLocation;

      // 1. إذا كان المستخدم مسجل الدخول (سواء عادي أو بعد تغيير كلمة المرور)
      if (authState is AuthenticatedState) {
        if (location == Routes.splash || location == Routes.login || location == Routes.changePassword) {
          return getHomeByRole(authState.userModel.role);
        }
        return null;
      }

      // 2. إذا كان مطلوباً تغيير كلمة المرور لأول دخول
      if (authState is NewUserFirstLoginState) {
        if (location == Routes.changePassword) return null;
        return Routes.changePassword;
      }

      // 3. إذا لم يسجل الدخول أو حدث خطأ / تسجيل خروج
      if (authState is AuthInitialState || 
          authState is LoginErrorState || 
          authState is LogoutSuccessState) {
        if (location == Routes.splash) {
          return Routes.login;
        }
        if (location == Routes.login) return null;
        return Routes.login;
      }

      // 4. حالة الفحص (AuthLoadingState)
      return null;
    },
    routes: [
      GoRoute(
        path: Routes.splash, 
        builder: (context, state) => const Scaffold(body: Center(child: CircularProgressIndicator()))
      ),
      GoRoute(path: Routes.login, builder: (context, state) => const SignInView()),
      GoRoute(path: Routes.changePassword, builder: (context, state) => const ChangePasswordView()),
      GoRoute(path: Routes.databaseAdmin, builder: (context, state) => const DatabaseAdminDashboard(), routes: databaseAdminSubRoutes),
      GoRoute(path: Routes.admin, builder: (context, state) => const DashboardScreen(), routes: adminSubRoutes),
      GoRoute(path: Routes.judge, builder: (context, state) => const MohakemDashboardHome(), routes: judgeSubRoutes),
      GoRoute(path: Routes.user, builder: (context, state) => const DashboardUserPage(), routes: userSubRoutes),
      GoRoute(path: Routes.adminManager, builder: (context, state) => const EmployeeDashboardScreen()),
      GoRoute(path: Routes.settings, builder: (context, state) {
        final args = state.extra as Map<String, dynamic>? ?? {};
        return SettingsScreen(uid: args['uid'] ?? '', role: args['role'] ?? 'user');
      }),
      GoRoute(path: Routes.notification, builder: (context, state) => const NotificationsScreen()),
   GoRoute(
        path: Routes.adminManager, 
        builder: (context, state) => const EmployeeDashboardScreen(), 
        routes: employeeSubRoutes, // ✅ ربط الراوتر الفرعي
      ),
    ],
  );
}