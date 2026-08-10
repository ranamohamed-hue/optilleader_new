import 'dart:async';
import 'package:flutter/material.dart';
import 'package:optialeader/feature/auth/logic/cubits/auth_cubit.dart';
import 'package:optialeader/feature/auth/logic/cubits/auth_state.dart';

class RouterRefreshNotifier extends ChangeNotifier {
  final AuthCubit authCubit;
  late final StreamSubscription<AuthState> _subscription;

  RouterRefreshNotifier(this.authCubit) {
    debugPrint('🔔 RouterRefreshNotifier: تم الإنشاء والاشتراك في الـ Stream');
    
    _subscription = authCubit.stream.listen((state) {
      debugPrint('🔔 RouterRefreshNotifier: تم استقبال حالة جديدة -> $state');
      
      // إطلاق التنبيه فوراً بدون أي شروط
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}