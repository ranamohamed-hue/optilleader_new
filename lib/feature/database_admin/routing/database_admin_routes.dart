import 'package:go_router/go_router.dart';
import 'package:optialeader/feature/database_admin/ui/screens/add_admin_page.dart';
import 'package:optialeader/feature/database_admin/ui/screens/add_doctor_page.dart';
import 'package:optialeader/feature/database_admin/ui/screens/add_judge_page.dart';  
import 'package:optialeader/feature/database_admin/ui/screens/empolyee_search_page.dart';
import 'package:optialeader/feature/setting/ui/setting.dart';
import 'package:optialeader/feature/database_admin/ui/screens/users_list_page.dart';
import 'package:optialeader/feature/database_admin/ui/screens/add_employee_page.dart';
final List<RouteBase> databaseAdminSubRoutes = [
  GoRoute(
    path: 'searchPage',
    builder: (context, state) => const UserSearchScreen(),
  ),
  
  // ✅ تعديل استقبال البيانات كـ Map
  GoRoute(
    path: 'addDoctorPage',
    builder: (context, state) {
      final extra = state.extra as Map<String, dynamic>? ?? {};
      return AddDoctorPage(
        existingUid: extra['existingUid'] as String?,
        isViewMode: extra['isViewMode'] as bool? ?? false,
      ); 
    },
  ),
  
  // ✅ تعديل استقبال البيانات كـ Map
  GoRoute(
    path: 'addAdminPage',
    builder: (context, state) {
      final extra = state.extra as Map<String, dynamic>? ?? {};
      return AddAdminPage(
        existingUid: extra['existingUid'] as String?,
        isViewMode: extra['isViewMode'] as bool? ?? false,
      ); 
    },
  ),
   GoRoute(
  path: 'addEmployeePage',
  builder: (context, state) {
    final extra = state.extra as Map<String, dynamic>? ?? {};
    return AddEmployeePage(
      existingUid: extra['existingUid'] as String?,
      isViewMode: extra['isViewMode'] as bool? ?? false,
    );
  },
),
  // ✅ تعديل استقبال البيانات كـ Map
  GoRoute(
    path: 'addJudgePage',
    builder: (context, state) {
      final extra = state.extra as Map<String, dynamic>? ?? {};
      return AddJudgePage(
        existingUid: extra['existingUid'] as String?,
        isViewMode: extra['isViewMode'] as bool? ?? false,
      ); 
    },
  ),
  
  GoRoute(
    path: 'setting',
    builder: (context, state) {
      final args = state.extra as Map<String, dynamic>;
      return SettingsScreen(
        uid: args['uid'],
        role: args['role'],
      );
    },
  ),
  
  // ✅ تعديل المسار ليكون Sub-route متسلسل مع باقي المسارات
  GoRoute(
    path: 'users-list',
    builder: (context, state) {
      final role = state.extra as String; 
      return UsersListPage(role: role);
    },
  ),
];