import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final ValueNotifier<ThemeMode> appThemeMode = ValueNotifier(ThemeMode.light);

Future<void> loadSavedTheme() async {
  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('app_is_dark') ?? false;
  appThemeMode.value = isDark ? ThemeMode.dark : ThemeMode.light;
}

Future<void> setDarkMode(bool value) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('app_is_dark', value);
  appThemeMode.value = value ? ThemeMode.dark : ThemeMode.light;
}
