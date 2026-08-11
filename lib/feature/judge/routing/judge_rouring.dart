import 'package:go_router/go_router.dart';
import 'package:optialeader/feature/admin/data/model/nomination_request_model.dart';
import 'package:optialeader/feature/judge/ui/screens/evaluation_screen_page.dart';
import 'package:optialeader/feature/judge/ui/screens/judge_orders_list_screen.dart';
import 'package:optialeader/feature/judge/ui/screens/requests_categories_screen.dart';
import 'package:optialeader/feature/admin/ui/request/nomination_requestd_details_screen.dart';
final List<RouteBase> judgeSubRoutes = [
  GoRoute(
    path: 'categories-screen',
    builder: (context, state) {
      final args = state.extra as Map<String, dynamic>?;
      return RequestsCategoriesScreen(
        filterStatus: args?['status'],
      );
    },
  ),

  GoRoute(
    path: 'evaluationScreen',
    builder: (context, state) {
      final request = state.extra as NominationRequestModel;
      return InterviewEvaluationScreen(
        requestId: request.id!,
        request: request,
      );
    },
  ),

  GoRoute(
    path: 'orders-list',
    builder: (context, state) {  
      final args = state.extra as Map<String, dynamic>?;
      return JudgeOrdersListScreen(
        filterStatus: args?['status'],
        filterRole: args?['role'],
      );
    },
  ),
  GoRoute( path: 'nomination-request-details', builder: (context, state) { final request = state.extra as NominationRequestModel; return NominationRequestDetailsScreen( request: request, isJudgeView: true, ); }, ),
];