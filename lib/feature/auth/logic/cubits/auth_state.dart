import 'package:equatable/equatable.dart';
import 'package:optialeader/feature/auth/data/models/user_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

// حالة التحميل الأولية (اللي بنستنى فيها الهيف يفتح) - تمت إضافتها
class AuthLoadingState extends AuthState {}

class AuthInitialState extends AuthState {}

//  حالات تسجيل الدخول 
class LoginLoadingState extends AuthState {}
class LoginSuccessState extends AuthState {
  final UserModel userModel;
  const LoginSuccessState(this.userModel);
  @override
  List<Object> get props => [userModel];
}
class LoginErrorState extends AuthState {
  final String error;
  const LoginErrorState(this.error);
  @override
  List<Object> get props => [error];
}

//  حالات الدخول الأول (تغيير الباسورد) 
class NewUserFirstLoginState extends AuthState {
  final UserModel userModel;
  const NewUserFirstLoginState(this.userModel);
  @override
  List<Object> get props => [userModel];
}

class UpdatePasswordLoadingState extends AuthState {
  final UserModel userModel;
  const UpdatePasswordLoadingState(this.userModel);
}
class UpdatePasswordSuccessState extends AuthState {
  final String message;
  final UserModel userModel; 
  const UpdatePasswordSuccessState(this.message, this.userModel);
  @override
  List<Object> get props => [message, userModel];
}
class UpdatePasswordErrorState extends AuthState {
  final String error;
  const UpdatePasswordErrorState(this.error);
  @override
  List<Object> get props => [error];
}

//  حالة المصادقة النهائية (جاهز لدخول التطبيق) 
class AuthenticatedState extends AuthState {
  final UserModel userModel;
  const AuthenticatedState(this.userModel);
  @override
  List<Object> get props => [userModel];
}

//  تسجيل الخروج 
class LogoutSuccessState extends AuthState {}