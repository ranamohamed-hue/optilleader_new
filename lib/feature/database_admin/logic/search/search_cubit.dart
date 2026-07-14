import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:optialeader/feature/database_admin/data/repo/search/search_repo.dart';
import 'package:optialeader/feature/database_admin/logic/search/search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final SearchRepo _searchRepo;

  SearchCubit(this._searchRepo) : super(SearchInitial());

  Future<void> searchUsers({
    required String query,
    required String searchField,
  }) async {
    if (query.trim().isEmpty) {
      emit(SearchInitial());
      return;
    }

    emit(SearchLoading());

    final result = await _searchRepo.searchUsers(
      query: query.trim(),
      searchField: searchField,
    );

    result.fold(
      (error) => emit(SearchError("ERROR_SEARCH_FAILED")),
      (users) => emit(SearchSuccess(users)),
    );
  }
}