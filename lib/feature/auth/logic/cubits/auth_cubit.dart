import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:optialeader/feature/auth/data/models/user_model.dart';
import 'package:optialeader/feature/auth/data/repo/auth_repo.dart';
import 'package:optialeader/feature/auth/logic/cubits/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepo authRepo;

  AuthCubit(this.authRepo) : super(AuthInitialState()) { 
    checkAuthStatus();
  }

    void checkAuthStatus() {
    try {
      final cachedUser = authRepo.getCachedUser(); 

      if (cachedUser != null) {
        if (cachedUser.isFirstLogin) {
          emit(NewUserFirstLoginState(cachedUser));
        } else {
          emit(AuthenticatedState(cachedUser));
        }
      } else {
        emit(AuthInitialState());
      }
    } catch (e) {
      // لو حصل أي خطأ (زي إن الهيف مفتحش)، خليه يروح للوجين عادي
      print('Error checking auth status: $e');
      emit(AuthInitialState());
    }
  }
  Future<void> login({required String email, required String password}) async {
    emit(LoginLoadingState());
    final result = await authRepo.login(email: email, password: password);

    result.fold((error) => emit(LoginErrorState(error)), (userModel) {
      if (userModel.isFirstLogin) {
        emit(NewUserFirstLoginState(userModel));
      } else {
        emit(AuthenticatedState(userModel));
      }
    });
  }

  Future<void> completeFirstLogin({required String newPassword}) async {
    UserModel? currentUser;
    if (state is NewUserFirstLoginState) {
      currentUser = (state as NewUserFirstLoginState).userModel;
    } else if (state is LoginSuccessState) {
      currentUser = (state as LoginSuccessState).userModel;
    }

    if (currentUser != null) {
      emit(UpdatePasswordLoadingState(currentUser));

      final result = await authRepo.completeFirstLogin(
        newPassword: newPassword,
      );

      result.fold((error) => emit(UpdatePasswordErrorState(error)), (message) {
        final updatedUser = currentUser!.copyWith(isFirstLogin: false);
        emit(UpdatePasswordSuccessState(message, updatedUser));
        emit(AuthenticatedState(updatedUser));

      });
    }
  }

  Future<void> logout() async {
    final result = await authRepo.logout();
    result.fold(
      (error) => emit(LoginErrorState(error)),
      (_) => emit(LogoutSuccessState()),
    );
  }
}