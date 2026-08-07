import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:optialeader/feature/doctor/data/repo/activities/activity_repo.dart';
import 'package:optialeader/feature/doctor/data/repo/activities/activity_repo_impl.dart';
import 'package:optialeader/feature/doctor/data/repo/research_paper/research_paper_repo.dart';
import 'package:optialeader/feature/doctor/data/repo/research_paper/research_paper_repo_impl.dart';
import 'package:optialeader/feature/doctor/logic/activities/activity_cubit.dart';
import 'package:optialeader/feature/doctor/logic/research_paper/research_paper_cubit.dart';
import 'package:optialeader/feature/notification/data/repo/notification_repo.dart';
import 'package:provider/single_child_widget.dart';

class DoctorProviders {
  static List<SingleChildWidget> providers() => [
    RepositoryProvider<ResearchPaperRepo>(create: (context) => ResearchPaperRepoImpl()),
    RepositoryProvider<ActivitiesRepo>(create: (context) => ActivitiesRepoImpl()),

    BlocProvider(create: (context) => ActivityCubit(context.read<ActivitiesRepo>(), context.read<NotificationRepo>())),
    BlocProvider(create: (context) => ResearchCubit(context.read<ResearchPaperRepo>(), context.read<NotificationRepo>())),
  ];
}