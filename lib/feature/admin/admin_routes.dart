import 'package:go_router/go_router.dart';

import 'package:optialeader/feature/admin/data/model/announcement_model.dart';
import 'package:optialeader/feature/admin/data/model/nomination_request_model.dart';

import 'package:optialeader/feature/admin/ui/announces/announce.dart';
import 'package:optialeader/feature/admin/ui/announces/edit_announcement.dart';
import 'package:optialeader/feature/admin/ui/announces/competition_results_view_page.dart';

import 'package:optialeader/feature/admin/ui/admin_pending_requests_page.dart';
import 'package:optialeader/feature/admin/ui/admin_details_page.dart';
import 'package:optialeader/feature/admin/ui/pending_request_details_screen.dart';

import 'package:optialeader/feature/admin/ui/request/order_list_screen.dart';
import 'package:optialeader/feature/admin/ui/request/nomination_requestd_details_screen.dart';

import 'package:optialeader/feature/admin/ui/user_search_screen.dart';
import 'package:optialeader/feature/employee/data/models/employee_nomination_request_model .dart';
import 'package:optialeader/feature/admin/ui/employee/employee_pending_request_details_screen.dart';

final List<RouteBase> adminSubRoutes = [

  // ============================================================
  // 1. ANNOUNCEMENTS
  // ============================================================

  GoRoute(
    path: 'announcements',
    builder: (context, state) =>
        const AnnouncementsPage(),
  ),

  // ============================================================
  // 2. ORDERS LIST
  // ============================================================

  GoRoute(
    path: 'orders-list',
    builder: (context, state) =>
        const OrdersListScreen(),
  ),

  // ============================================================
  // 3. NOMINATION REQUEST DETAILS
  // ============================================================

  GoRoute(
    path: 'nomination-request-details',
    builder: (context, state) {

      final request =
          state.extra as NominationRequestModel;

      return NominationRequestDetailsScreen(
        request: request,
      );
    },
  ),

  // ============================================================
  // 4. USER SEARCH
  // ============================================================

  GoRoute(
    path: 'user-search',
    builder: (context, state) =>
        const UserSearchScreen(),
  ),

  // ============================================================
  // 5. ANNOUNCEMENT DETAILS
  // ============================================================

  GoRoute(
    path: 'announcement-details',
    builder: (context, state) {

      final announcement =
          state.extra as AnnouncementModel;

      return AnnouncementDetailsPage(
        announcement: announcement,
      );
    },
  ),

  // ============================================================
  // 6. EDIT ANNOUNCEMENT
  // ============================================================

  GoRoute(
    path: 'edit-announcement',
    builder: (context, state) {

      final announcement =
          state.extra as AnnouncementModel?;

      return EditAnnouncementPage(
        announcement: announcement,
      );
    },
  ),

  // ============================================================
  // 7. COMPETITION RESULTS
  // ============================================================

  GoRoute(
    path: 'competition-results-view',
    builder: (context, state) {

      final args =
          state.extra as Map<String, dynamic>?;

      return CompetitionResultsViewPage(
        announcementId:
            args?['announcementId'] ?? '',
        currentDoctorId:
            args?['currentDoctorId'],
      );
    },
  ),

  // ============================================================
  // 8. DOCTOR PENDING REQUESTS
  // ============================================================

  GoRoute(
    path: 'pending-requests',

    builder: (context, state) =>
        const AdminPendingRequestsPage(),

    routes: [

      // ----------------------------------------------------------
      // 8.1 GENERAL DETAILS
      // ----------------------------------------------------------

      GoRoute(
        path: 'details',

        builder: (context, state) {

          final args =
              state.extra as Map<String, dynamic>;

          return AdminDetailsPage(
            item: args['item'],
            doctorUid: args['doctorUid'],
            type: args['type'],
          );
        },
      ),

      // ----------------------------------------------------------
      // 8.2 RESEARCH PAPER DETAILS
      // ----------------------------------------------------------

      GoRoute(
        path: 'paper-details',

        builder: (context, state) {

          final args =
              state.extra as Map<String, dynamic>;

          return PendingRequestDetailsScreen(
            extra: args,
          );
        },
      ),
    ],
  ),

  // ============================================================
  // 9. EMPLOYEE NOMINATION REQUEST DETAILS
  // ============================================================

  GoRoute(
    path: 'employee-pending-request-details',

    builder: (context, state) {

      final request =
          state.extra as EmployeeNominationRequestModel;

      return EmployeePendingRequestDetailsScreen(
        request: request,
      );
    },
  ),
];