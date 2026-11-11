class Routes {
  static const splash = '/splash';

  static const login = '/login';
  static const register = '/register';

  static const databaseAdmin = '/databaseAdmin';
  static const admin = '/admin';
  static const judge = '/judge';
  static const user = '/user';
  static const adminManager = '/adminManager';

  static const employeeCourses = '/employee/courses';

  static const changePassword = '/change-password';
  static const settings = '/settings';

  // ============================================================
  // صفحات الأدمن الأساسية
  // ============================================================

  static const announcements = '/admin/announcements';
  static const ordersList = '/admin/orders-list';
  static const userSearch = '/admin/user-search';

  static const adminDetails =
      '/admin/pending-requests/details';

  static const pendingPaperDetails =
      '/admin/pending-requests/paper-details';

  static const announcementDetails =
      '/admin/announcement-details';

  static const editAnnountmentPage =
      '/admin/edit-announcement';

  static const adminPendingRequestsPage =
      '/admin/pending-requests';

  static const nominationRequestDetails =
      '/admin/nomination-request-details';

  static const employeeCourseApprovalPage =
      '/admin/employee-course-approval';

  static const adminEmployeeCourseDetails =
      '/admin/employee-course-details';

  static const competitionResultsView =
      '/user/competition-results-view';

  static const fullEmployeeReport =
      '/admin/orders-list/fullEmployeeReport';

  // ============================================================
  // طلبات ترشيح الموظفين الخاصة بالأدمن
  // ============================================================

  static const employeePendingRequests =
      '/admin/employees-pending-requests';

  static const employeePendingRequestDetails =
      '/admin/employees-pending-requests/details';

  static const employeeSelectEvaluator =
      '/admin/employees-pending-requests/select-evaluator';

  // ============================================================
  // صفحات أدمن قاعدة البيانات
  // ============================================================

  static const addDoctorPage =
      '/databaseAdmin/addDoctorPage';

  static const addAdminPage =
      '/databaseAdmin/addAdminPage';

  static const addJudgePage =
      '/databaseAdmin/addJudgePage';

  static const searchPage =
      '/databaseAdmin/searchPage';

  static const addEmployeePage =
      '/databaseAdmin/addEmployeePage';

  static const usersListPage =
      '/databaseAdmin/users-list';

  // ============================================================
  // صفحات المحكم - الدكتور
  // ============================================================

  static const judgeEvaluation =
      '/judge/evaluationScreen';

  static const judgeOrderList =
      '/judge/orders-list';

  static const judgeCategories =
      '/judge/categories-screen';

  // ============================================================
  // صفحات المحكم - الموظف
  // ============================================================
static const employeeJudgeOrdersList =
    '/judge/employee-orders-list';

static const employeeRequestsCategories =
    '/judge/employee-requests-categories';

static const employeeInterviewEvaluation =
    '/judge/employee-interview-evaluation';
  
  

  // ============================================================
  // صفحات المستخدم / الدكتور
  // ============================================================

  static const acadiminData =
      '/user/acadimicData';

  static const archievementPage =
      '/user/archievementPage';

  static const careerInfo =
      '/user/careerInfo';

  static const digitalArchieve =
      '/user/digitalArchieve';

  static const uploadFiles =
      '/user/uploadFiles';

  static const announcementsDetailsDoctor =
      '/user/announcementsDetailsDoctor';

  static const doctorNominationRequest =
      '/user/doctorNominationRequest';

  static const addResearch =
      '/user/addResearch';

  static const addActivity =
      '/user/addActivity';

  static const notification =
      '/notification';

  static const doctorRequestsStatus =
      '/user/doctorRequestsStatus';

  // ============================================================
  // صفحات الموظف / مدير الإدارة
  // ============================================================

  static const announcementDetailsAdminPage =
      '/adminManager/announcementDetailsAdminPage';

  static const employeeArchievePage =
      '/adminManager/employeeArchievePage';

  static const employeeCoursePage =
      '/adminManager/employeeCoursePage';

  static const employeeNominationPage =
      '/adminManager/employeeNominationPage';
}