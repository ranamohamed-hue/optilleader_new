import 'package:go_router/go_router.dart';
import 'package:optialeader/feature/admin/data/model/announcement_model.dart';
import 'package:optialeader/feature/admin/ui/announces/competition_results_view_page.dart'; 
import 'package:optialeader/feature/doctor/ui/screens/acadimic_data.dart';
import 'package:optialeader/feature/doctor/ui/screens/announctments_datails_doctor_page.dart';
import 'package:optialeader/feature/doctor/ui/screens/archievement_page.dart';
import 'package:optialeader/feature/doctor/ui/screens/career_info_page.dart';
import 'package:optialeader/feature/doctor/ui/screens/digital_archieve.dart';
import 'package:optialeader/feature/doctor/ui/screens/doctor_nomination_page.dart';
import 'package:optialeader/feature/doctor/ui/screens/uploadfiles.dart';
import 'package:optialeader/feature/doctor/ui/screens/add_research_paper_page.dart';
import 'package:optialeader/feature/doctor/ui/screens/add_activity_page.dart';
import 'package:optialeader/feature/admin/ui/admin_pending_requests_page.dart';
import 'package:optialeader/feature/doctor/ui/screens/doctor_requests_status_screen.dart';
import 'package:optialeader/feature/database_admin/data/models/doctor_profile_model.dart';



final List<RouteBase> userSubRoutes = [
  GoRoute(
    path: 'acadimicData',
    builder: (context, state) {
      final String uid = state.uri.queryParameters['uid'] ?? '';
      return DoctorProfileDataPage(doctorUid: uid);
    },
  ),
  GoRoute(
    path: 'archievementPage',
    builder: (context, state) {
      final String uid = state.uri.queryParameters['uid'] ?? '';
      return AchievementsLogPage(doctorUid: uid); 
    },
  ),
  GoRoute(
    path: 'careerInfo',
    builder: (context, state) {
      final String uid = state.uri.queryParameters['uid'] ?? '';
      return CareerInfoPage(doctorUid: uid);
    },
  ),
  GoRoute(
    path: 'digitalArchieve',
    builder: (context, state) {
      final String uid = state.uri.queryParameters['uid'] ?? '';
      return DigitalArchivePage(doctorUid: uid);
    },
  ),
  GoRoute(
    path: 'uploadFiles',
    builder: (context, state) {
      final String uid = state.uri.queryParameters['uid'] ?? '';
      return UploadFilePage(doctorUid: uid);
    },
  ),
  GoRoute(
    path: 'addResearch',
    builder: (context, state) {
      final String uid = state.uri.queryParameters['uid'] ?? '';
      return AddResearchPaperPage(doctorUid: uid);
    },
  ),
  GoRoute(
    path: 'addActivity',
    builder: (context, state) {
      final String uid = state.uri.queryParameters['uid'] ?? '';
      return AddActivityPage(doctorUid: uid);
    },
  ),
  GoRoute(
    path: 'announcementsDetailsDoctor',
    builder: (context, state) {
      final String id = state.uri.queryParameters['id'] ?? '';
      return AnnouncementDetailsDoctorPage(announcementId: id);
    },
  ),
  
  GoRoute(
    path: 'doctorNominationRequest', 
    builder: (context, state) {
      final Map<String, dynamic> args = state.extra as Map<String, dynamic>? ?? {};
      
      return DoctorNominationPage(
        announcement: args['announcement'] as AnnouncementModel,
        doctorId: args['doctorId'] as String? ?? '',
      );
    },
  ),
   GoRoute(
    path: 'competition-results-view',
    builder: (context, state) {
      final args = state.extra as Map<String, dynamic>?;
      return CompetitionResultsViewPage(
        announcementId: args?['announcementId'] ?? '',
        currentDoctorId: args?['currentDoctorId'],
      );
    },
  ),
   GoRoute(
    path: 'competition-results-view',
    builder: (context, state) {
      final args = state.extra as Map<String, dynamic>?;
      return CompetitionResultsViewPage(
        announcementId: args?['announcementId'] ?? '',
        currentDoctorId: args?['currentDoctorId'],
      );
    },
  ),
  GoRoute(
    path: 'pendingRequests',
    builder: (context, state) {
      return const AdminPendingRequestsPage();
    },
  ),
  // ✅ مسار حالة طلبات الدكتور (بدون / في البداية)
  GoRoute(
    path: 'doctorRequestsStatus',
    builder: (context, state) {
      final doctor = state.extra as DoctorProfileModel;
      return DoctorRequestsStatusScreen(doctor: doctor);
    },
  ),
];