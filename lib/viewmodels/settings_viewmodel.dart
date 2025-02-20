/// ViewModel for managing user settings and preferences.
///
/// This class extends `StateNotifier<UserPreferences>` to manage the state of
/// user preferences, such as theme mode and sort order. It uses the Hive
/// package for local storage of preferences.
///
/// The `SettingsViewModel` class provides methods to load and toggle user
/// settings, and exposes a provider for use in the application.
///
/// Methods:
/// - `SettingsViewModel()`: Constructor that initializes the state with default
///   preferences and loads the saved theme preference.
/// - `_loadThemePreference()`: Private method to load the theme preference from
///   the Hive box and update the state.
/// - `toggleSetting({required UserPreferences userPreferences})`: Method to
///   toggle the user settings and update the Hive box and state.
/// - `isDarkMode`: Getter to check if the current theme mode is dark.
///
/// Provider:
/// - `settingsProvider`: A `StateNotifierProvider` that provides an instance of
///   `SettingsViewModel` and the current state of `UserPreferences`.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:task_management_app/models/user_preferences.dart';

class SettingsViewModel extends StateNotifier<UserPreferences> {
  static const String _themeKey = 'darkMode';

  SettingsViewModel()
      : super(UserPreferences(isDarkMode: false, sortOrder: 'date')) {
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final preferencesBox = Hive.isBoxOpen('preferences')
        ? Hive.box<UserPreferences>('preferences')
        : await Hive.openBox('preferences');
    final UserPreferences userPreferences = preferencesBox.get(_themeKey,
        defaultValue:
            UserPreferences(isDarkMode: isDarkMode, sortOrder: 'date'));
    state = userPreferences;
  }

  void toggleSetting({required UserPreferences userPreferences}) async {
    final preferencesBox = Hive.isBoxOpen('preferences')
        ? Hive.box<UserPreferences>('preferences')
        : await Hive.openBox('preferences');
    bool isDark = state == ThemeMode.dark;
    preferencesBox.put(_themeKey, userPreferences);
    state = userPreferences;
  }

  bool get isDarkMode => state == ThemeMode.dark;
}

final settingsProvider =
    StateNotifierProvider<SettingsViewModel, UserPreferences>((ref) {
  return SettingsViewModel();
});
