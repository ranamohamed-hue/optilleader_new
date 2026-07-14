import 'dart:async'; 
import 'package:flutter/material.dart';
import 'package:optialeader/feature/auth/logic/cubits/auth_cubit.dart';
import 'package:optialeader/feature/auth/logic/cubits/auth_state.dart';

class RouterRefreshNotifier extends ChangeNotifier {
  late final StreamSubscription<AuthState> _subscription;

  RouterRefreshNotifier(AuthCubit authCubit) {
    // بنخزن الـ Subscription عشان نتحكم فيها
    _subscription = authCubit.stream.listen((state) {
      debugPrint("RouterRefreshNotifier: New State Detected -> $state");
      notifyListeners(); 
    });
  }

  @override
  void dispose() {
    _subscription.cancel(); 
    super.dispose();
  }
}