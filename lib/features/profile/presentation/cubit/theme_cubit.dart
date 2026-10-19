import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  static const String _keyThemeMode = 'shopsphere_theme_mode_v1';
  final SharedPreferences sharedPreferences;

  ThemeCubit({required this.sharedPreferences}) : super(ThemeMode.system) {
    _loadTheme();
  }

  void _loadTheme() {
    final raw = sharedPreferences.getString(_keyThemeMode);
    if (raw == 'light') {
      emit(ThemeMode.light);
    } else if (raw == 'dark') {
      emit(ThemeMode.dark);
    } else {
      emit(ThemeMode.system);
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await sharedPreferences.setString(_keyThemeMode, value);
    emit(mode);
  }
}
