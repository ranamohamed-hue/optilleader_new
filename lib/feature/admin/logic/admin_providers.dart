import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:optialeader/feature/admin/data/repo/admin_approval/admin_aproval_repo_impl.dart';
import 'package:optialeader/feature/admin/data/repo/announcement_repos/announcement_repo_impl.dart';
import 'package:optialeader/feature/admin/data/repo/nomination_request/nomination_request_repo.dart';
import 'package:optialeader/feature/admin/data/repo/nomination_request/nomination_request_repo_impl.dart';
import 'package:optialeader/feature/admin/logic/admin_approval/admin_approval_cubit.dart';
import 'package:optialeader/feature/admin/logic/announcement_logic/announcement_cubit.dart';
import 'package:optialeader/feature/admin/logic/nomination_request_logic/nomination_request_cubit.dart';
import 'package:optialeader/feature/database_admin/data/repo/admin_repository/admin_repo_impl.dart';
import 'package:optialeader/feature/database_admin/data/repo/database_admin_repository/database_admin_repo_impl.dart';
import 'package:optialeader/feature/database_admin/logic/admin_data/admin_data_cubit.dart';
import 'package:optialeader/feature/database_admin/logic/database_admin_data/databse_admin_cubit.dart';
import 'package:optialeader/feature/doctor/data/repo/research_paper/research_paper_repo.dart';
import 'package:optialeader/feature/notification/data/repo/notification_repo.dart';
import 'package:provider/single_child_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminProviders {
  static List<SingleChildWidget> providers() => [
    // ✅ أضف <NominationRequestRepository> هنا
    RepositoryProvider<NominationRequestRepository>(
      create: (context) => NominationRequestRepositoryImpl(
        FirebaseFirestore.instance,
        Supabase.instance.client,
      ),
    ),

    BlocProvider(create: (context) => AdminDataCubit(AdminRepoImpl())),
    BlocProvider(
      create: (context) =>
          DatabseAdminCubit(DatabaseAdminRepoImpl(FirebaseFirestore.instance)),
    ),
    BlocProvider(
      create: (context) => AnnouncementCubit(
        AnnouncementRepositoryImpl(FirebaseFirestore.instance),
        context.read<NotificationRepo>(),
      ),
    ),
    BlocProvider(
      create: (context) => AdminApprovalCubit(
        adminApprovalRepo: AdminApprovalRepoImpl(
          firebaseFirestore: FirebaseFirestore.instance,
          researchPaperRepo: context.read<ResearchPaperRepo>(),
          notificationRepo: context.read<NotificationRepo>(),
        ),
      ),
    ),
     BlocProvider(
      create: (context) => NominationRequestCubit(
        context.read<NominationRequestRepository>(), 
        context.read<NotificationRepo>(),
      ),
    ),
  ];
}
