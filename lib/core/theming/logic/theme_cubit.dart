import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit()
    : super(const ThemeState(themeMode: ThemeMode.light, isDarkMode: false));

  void toggleTheme() {
    final newIsDarkMode = !state.isDarkMode;
    emit(
      ThemeState(
        themeMode: newIsDarkMode ? ThemeMode.dark : ThemeMode.light,
        isDarkMode: newIsDarkMode,
      ),
    );
  }
}
