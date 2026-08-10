import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:optialeader/feature/auth/data/models/user_model.dart';
import 'package:optialeader/feature/auth/data/repo/auth_repo.dart';
import 'package:optialeader/feature/auth/logic/cubits/auth_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
class AuthCubit extends Cubit<AuthState> {
  final AuthRepo authRepo;
  AuthCubit(this.authRepo) : super(AuthLoadingState());

  Future<void> checkAuthStatus() async {
    emit(AuthLoadingState()); // نعرض السبينر في شاشة السبلاش
    
    try {
      // 1. نسأل فيربيز: مين اللي مسجل دخول حالياً؟ (Process محلي وسريع جداً)
      final firebaseUser = FirebaseAuth.instance.currentUser;

      if (firebaseUser != null) {
        // 2. فيرميز يقول: فيه حد مسجل. نروح نجلب بياناته من الـ Firestore
        final result = await authRepo.fetchUserData(uid: firebaseUser.uid);
        
        result.fold(
          (error) {
            // فشل جلب البيانات (مثلاً حسابه اتحذف من الـ Firestore، أو مشكلة في النت)
            // الحل الأأمن: نسجل خروجه ونرسله للوجين
            authRepo.logout();
            emit(AuthInitialState());
          },
          (userModel) {
            // نجح جلب البيانات! نحدد واجهته
            if (userModel.isFirstLogin) {
              emit(NewUserFirstLoginState(userModel));
            } else {
              emit(AuthenticatedState(userModel));
            }
          },
        );
      } else {
        // 3. فيرميز يقول: مفيش حد مسجل.
        // نمسح أي بيانات قديمة في الهايف ونرسله للوجين
        await authRepo.logout(); 
        emit(AuthInitialState());
      }
    } catch (e) {
      // أي خطأ غير متوقع -> نرسله للوجين
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
    }

    if (currentUser != null) {
      emit(UpdatePasswordLoadingState(currentUser));
      final result = await authRepo.completeFirstLogin(newPassword: newPassword);
      result.fold((error) => emit(UpdatePasswordErrorState(error)), (message) {
        final updatedUser = currentUser!.copyWith(isFirstLogin: false);
        emit(AuthenticatedState(updatedUser));
      });
    }
  }

  Future<void> logout() async {
    final result = await authRepo.logout();
    result.fold((error) => emit(LoginErrorState(error)), (_) => emit(LogoutSuccessState()));
  }
}