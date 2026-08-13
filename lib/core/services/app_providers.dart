import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:optialeader/feature/doctor/data/repo/research_paper/research_paper_repo.dart';
import 'package:optialeader/feature/doctor/data/repo/research_paper/research_paper_repo_impl.dart';
import 'package:provider/single_child_widget.dart';
import 'package:optialeader/core/theming/logic/theme_cubit.dart';
import 'package:optialeader/feature/notification/data/repo/notification_repo.dart'; // <-- تأكد من استدعاء الكلاس الأساسي (الابستراكت)
import 'package:optialeader/feature/notification/data/repo/notification_repo_impl.dart';
import 'package:optialeader/feature/notification/logic/app_notification_cubit.dart'; // <-- استدعاء الكيوبت
import 'package:optialeader/feature/admin/logic/admin_providers.dart';
import 'package:optialeader/feature/doctor/logic/doctor_providers.dart';
import 'package:optialeader/feature/judge/data/judge_providers.dart';
import 'package:optialeader/feature/database_admin/logic/general_data_providers.dart';

class AppProviders {
  static List<SingleChildWidget> providers() {
    return [
      // 1. أولاً: نضع الـ Repositories (مصادر البيانات)
      RepositoryProvider<NotificationRepo>(
        create: (context) => NotificationRepoImpl(),
      ),
RepositoryProvider<ResearchPaperRepo>(
        create: (context) => ResearchPaperRepoImpl(/* الـ parameters المطلوبة لديك */),
      ),
      // 2. ثانياً: نضع الـ Cubits التي تعتمد على الـ Repositories
          BlocProvider<NotificationCubit>(
        create: (context) => NotificationCubit(
          notificationRepo: context.read<NotificationRepo>(),
          // لن نمرر userId، سيتركه فارغاً وبالتالي سيستخدم Firebase UID لما يتم استدعاء fetchNotifications
        ),
      ),
      // 3. ثالثاً: باقي الـ Cubits التي لا تعتمد على شيء أو تعتمد على أشياء أخرى
      BlocProvider<ThemeCubit>(create: (context) => ThemeCubit()),
      
      ...DoctorProviders.providers(),
      ...AdminProviders.providers(),
      ...JudgeProviders.providers(),
      ...GeneralDataProviders.providers(),
    ];
  }
}