import 'package:optialeader/feature/database_admin/data/models/search_user_model.dart'; // ✅ استدعاء الموديل الجديد

abstract class SearchState {}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchSuccess extends SearchState {
  final List<SearchUserModel> users; // ✅ تم التغيير
  SearchSuccess(this.users);
}

class SearchError extends SearchState {
  final String message;
  SearchError(this.message);
}