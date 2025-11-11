import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing app theme mode
class ThemeService {
  static const String _themeModeKey = 'theme_mode';

  /// Load saved theme mode from storage
  Future<ThemeMode> loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(_themeModeKey);

      if (themeIndex == null) {
        return ThemeMode.system; // Default to system theme
      }

      return ThemeMode.values[themeIndex];
    } catch (e) {
      // If there's an error, return system mode as fallback
      return ThemeMode.system;
    }
  }

  /// Save theme mode to storage
  Future<void> saveThemeMode(ThemeMode themeMode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeModeKey, themeMode.index);
    } catch (e) {
      // Silently fail if storage is not available
      debugPrint('Failed to save theme mode: $e');
    }
  }

  /// Toggle between light and dark mode
  /// If current mode is system, it toggles to light mode first
  ThemeMode toggleTheme(ThemeMode currentMode) {
    switch (currentMode) {
      case ThemeMode.light:
        return ThemeMode.dark;
      case ThemeMode.dark:
        return ThemeMode.light;
      case ThemeMode.system:
        return ThemeMode.light;
    }
  }
}

/// Provider for theme service instance
final themeServiceProvider = Provider<ThemeService>((ref) {
  return ThemeService();
});

/// Theme mode state notifier
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier(this._themeService) : super(ThemeMode.system) {
    _loadThemeMode();
  }

  final ThemeService _themeService;

  /// Load theme mode from storage on initialization
  Future<void> _loadThemeMode() async {
    final themeMode = await _themeService.loadThemeMode();
    state = themeMode;
  }

  /// Set theme mode to light
  Future<void> setLightMode() async {
    state = ThemeMode.light;
    await _themeService.saveThemeMode(ThemeMode.light);
  }

  /// Set theme mode to dark
  Future<void> setDarkMode() async {
    state = ThemeMode.dark;
    await _themeService.saveThemeMode(ThemeMode.dark);
  }

  /// Set theme mode to system
  Future<void> setSystemMode() async {
    state = ThemeMode.system;
    await _themeService.saveThemeMode(ThemeMode.system);
  }

  /// Toggle between light and dark mode
  Future<void> toggleTheme() async {
    final newMode = _themeService.toggleTheme(state);
    state = newMode;
    await _themeService.saveThemeMode(newMode);
  }

  /// Set specific theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await _themeService.saveThemeMode(mode);
  }
}

/// Provider for theme mode notifier
final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  final themeService = ref.watch(themeServiceProvider);
  return ThemeModeNotifier(themeService);
});

/// Convenience provider to check if current theme is dark
/// This checks both explicit dark mode and system mode with dark platform brightness
final isDarkModeProvider = Provider<bool>((ref) {
  final themeMode = ref.watch(themeModeProvider);

  if (themeMode == ThemeMode.dark) {
    return true;
  } else if (themeMode == ThemeMode.light) {
    return false;
  } else {
    // ThemeMode.system - need to check platform brightness
    // This will be determined at runtime by Flutter
    return false; // Default to light, Flutter will handle system mode
  }
});
