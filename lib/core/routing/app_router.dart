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
  
  // دالة مساعدة لاختصار حالات تسجيل الدخول
  bool isAuthenticated(AuthState state) {
    return state is AuthenticatedState || state is LoginSuccessState;
  }

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

  String getInitialRoute() {
    final state = authCubit.state;
    if (state is AuthenticatedState) {
      return getHomeByRole(state.userModel.role);
    }
    if (state is LoginSuccessState) {
      return getHomeByRole(state.userModel.role);
    }
    if (state is NewUserFirstLoginState) {
      return Routes.changePassword;
    }
    return Routes.login;
  }

  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: getInitialRoute(), 
    refreshListenable: RouterRefreshNotifier(authCubit),
    
    redirect: (context, state) {
      final authState = authCubit.state;
      final String location = state.matchedLocation;
      
      final bool isLogged = isAuthenticated(authState);

      // الحالة الأولى: لو المستخدم مسجل وواقف بالغلط في اللوجين، وديه على صفحته
      if (isLogged) {
        if (location == Routes.login) {
          final userModel = (authState is AuthenticatedState) 
              ? authState.userModel 
              : (authState as LoginSuccessState).userModel;
          return getHomeByRole(userModel.role);
        }
        return null; 
      }

      if (authState is NewUserFirstLoginState) {
        return location == Routes.changePassword ? null : Routes.changePassword;
      }

      return location == Routes.login ? null : Routes.login;
    },
   
    routes: [
      /// --- AUTH ROUTES ---
      /// 
      
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
        builder: (context, state) => const AdminWrapper(),
        routes: adminSubRoutes,
      ),
      /// --- JUDGE ROUTE ---
      GoRoute(
        path: Routes.judge,
        builder: (context, state) => const JudgeWrapper(),
        routes: judgeSubRoutes,
      ),
      GoRoute(
        path: Routes.user,
        builder: (context, state) => const DashboardUserPage(),
        routes: userSubRoutes,
      ),
      GoRoute(
        path: Routes.adminManager,
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