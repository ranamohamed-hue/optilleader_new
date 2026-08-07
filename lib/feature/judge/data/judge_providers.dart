import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:optialeader/feature/database_admin/data/repo/judge_repository/judge_repo_impl.dart';
import 'package:optialeader/feature/database_admin/logic/judge_data/judge_data_cubit.dart';
import 'package:provider/single_child_widget.dart';

class JudgeProviders {
  static List<SingleChildWidget> providers() => [
    BlocProvider(create: (context) => JudgeDataCubit(JudgeRepoImpl())),
  ];
}