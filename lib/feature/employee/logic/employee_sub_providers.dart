import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/single_child_widget.dart';
import 'package:optialeader/feature/employee/data/repo/NominationRequestRepository/employee_nomination_repo.dart';
import 'package:optialeader/feature/employee/data/repo/NominationRequestRepository/employee_nomination_repo_impl.dart';
import 'package:optialeader/feature/employee/logic/EmployeenNominationCubit/employee_nomination_cubit.dart';
import 'package:optialeader/feature/notification/data/repo/notification_repo.dart'; // ✅ استدعاء الإشعارات

class EmployeeProviders {
  static List<SingleChildWidget> providers() => [
    // ================= Repositories =================
    RepositoryProvider<EmployeeNominationRepository>(
      create: (_) =>
          EmployeeNominationRepositoryImpl(FirebaseFirestore.instance),
    ),

    // ================= Cubits =================
    BlocProvider(
      create: (context) => EmployeeNominationCubit(
        repo: context.read<EmployeeNominationRepository>(),
        notificationRepo: context.read<NotificationRepo>(), // ✅ رجعه تاني
      ),
    ),
  ];
}