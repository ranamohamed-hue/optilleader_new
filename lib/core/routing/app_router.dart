import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:optialeader/core/routing/router_refresh_notifier.dart';
import 'package:optialeader/feature/admin/admin_routes.dart';
import 'package:optialeader/feature/admin/ui/dashboaer.dart';
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
import 'package:provider/provider.dart';
import 'package:optialeader/feature/admin/logic/admin_providers.dart';
import 'package:optialeader/feature/judge/data/judge_providers.dart';
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
      case UserRole.employee:
        return Routes.employee;
    }
  }

  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: Routes.login,
    refreshListenable: RouterRefreshNotifier(authCubit),
    redirect: (context, state) {  print("========== REDIRECT ==========");
  print(authCubit.state);
  print(state.matchedLocation);
      final authState = authCubit.state;
      final isLogin = state.matchedLocation == Routes.login;
      final isChangePass = state.matchedLocation == Routes.changePassword;

      // 1. إجبار تغيير كلمة السر للمستخدمين الجدد فقط
      if (authState is NewUserFirstLoginState) {
        return isChangePass ? null : Routes.changePassword;
      }

      // ✅ 2. حالة المستخدم المسجل دخله بشكل مستقر (بدون dynamic)
      if (authState is AuthenticatedState) {
        if (isLogin) {
          return getHomeByRole(authState.userModel.role);
        }
        return null;
      }

      // ✅ 3. أول ما ينجح في تسجيل الدخول (بدون dynamic)
      if (authState is LoginSuccessState) {
        if (isLogin) {
          return getHomeByRole(authState.userModel.role);
        }
        return null;
      }

      // 4. أي حالة تانية (Initial, Error, Logout) - وجهه للوجين
      if (!isLogin && !isChangePass) {
        return Routes.login;
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
             /// --- ADMIN ROUTE ---
      GoRoute(
        path: Routes.admin,
        builder: (context, state) => const AdminWrapper(), // ✅ بدل DashboardScreen
        routes: adminSubRoutes,
      ),
      
      /// --- JUDGE ROUTE ---
      GoRoute(
        path: Routes.judge,
        builder: (context, state) => const JudgeWrapper(), // ✅ بدل MohakemDashboardHome
        routes: judgeSubRoutes,
      ),
        GoRoute(
        path: Routes.judge,
        builder: (context, state) => const JudgeWrapper(), // ✅ بدل MohakemDashboardHome
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

      /// --- NOTIFICATION ---
      GoRoute(
        path: Routes.notification,
        builder: (context, state) {
          final notificationCubit = context.read<NotificationCubit>();
          notificationCubit.fetchNotifications();
          return const NotificationsScreen();
        },
      ),

      /// --- EMPLOYEE COURSES ---
      GoRoute(
        path: Routes.employeeCourses,
        builder: (context, state) => EmployeeCoursesPage(
          employee: state.extra as EmployeeModel,
        ),
      ),
    ],
  );
}

class AdminWrapper extends StatelessWidget {
  const AdminWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: AdminProviders.providers(),
      child: const DashboardScreen(),
    );
  }
}


// ✅ غلاف المحكم
class JudgeWrapper extends StatelessWidget {
  const JudgeWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: JudgeProviders.providers(),
      child: const MohakemDashboardHome(),
    );
  }
}