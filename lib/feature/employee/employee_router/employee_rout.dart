import 'package:go_router/go_router.dart';
import 'package:optialeader/feature/admin/data/model/announcement_model.dart';
import 'package:optialeader/feature/database_admin/data/models/employee_model.dart';
import 'package:optialeader/feature/employee/ui/employee_archive_page.dart';
import 'package:optialeader/feature/employee/ui/employee_courses_page.dart';
import 'package:optialeader/feature/employee/ui/employee_nomination_page.dart';
import 'package:optialeader/feature/employee/ui/announcement_details_admin_page.dart';
final List<RouteBase> employeeSubRoutes = [
  GoRoute(
    path: 'announcementDetailsAdminPage',
    builder: (context, state) {
      final String id = state.uri.queryParameters['id'] ?? '';
      return AnnouncementDetailsEmployeePage(announcementId: id);
    },
  ),
  
  GoRoute(
    path: 'employeeArchievePage',
    builder: (context, state) {
      final employee = state.extra as EmployeeModel;
      return EmployeeArchivePage(employee: employee);
    },
  ),

  GoRoute(
    path: 'employeeCoursePage',
    builder: (context, state) {
      final employee = state.extra as EmployeeModel;
      return EmployeeCoursesPage(employee: employee);
    },
  ),

  GoRoute(
    path: 'employeeNominationPage', 
    builder: (context, state) {
      final Map<String, dynamic> args = state.extra as Map<String, dynamic>? ?? {};
      return EmployeeNominationPage(
        announcement: args['announcement'] as AnnouncementModel,
        employee: args['employee'] as EmployeeModel,
      );
    },
  ),
];