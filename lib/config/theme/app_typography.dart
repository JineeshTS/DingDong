import 'package:flutter/material.dart';

/// Typography system for DingDong app
/// Defines all text styles following Material Design 3 guidelines
class AppTypography {
  AppTypography._(); // Private constructor

  // ==================== Font Families ====================
  static const String primaryFontFamily = 'Inter';
  static const String secondaryFontFamily = 'Roboto';
  static const String monospaceFontFamily = 'RobotoMono';

  // ==================== Font Weights ====================
  static const FontWeight thin = FontWeight.w100;
  static const FontWeight extraLight = FontWeight.w200;
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;
  static const FontWeight black = FontWeight.w900;

  // ==================== Display Styles (Large Headers) ====================

  /// Display Large - 57px
  /// Use for: Hero sections, splash screens
  static const TextStyle displayLarge = TextStyle(
    fontSize: 57,
    fontWeight: bold,
    height: 1.12,
    letterSpacing: -0.25,
    fontFamily: primaryFontFamily,
  );

  /// Display Medium - 45px
  /// Use for: Large page titles
  static const TextStyle displayMedium = TextStyle(
    fontSize: 45,
    fontWeight: bold,
    height: 1.16,
    letterSpacing: 0,
    fontFamily: primaryFontFamily,
  );

  /// Display Small - 36px
  /// Use for: Section headers, onboarding
  static const TextStyle displaySmall = TextStyle(
    fontSize: 36,
    fontWeight: bold,
    height: 1.22,
    letterSpacing: 0,
    fontFamily: primaryFontFamily,
  );

  // ==================== Headline Styles ====================

  /// Headline Large - 32px
  /// Use for: Screen titles, dialog titles
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: semiBold,
    height: 1.25,
    letterSpacing: 0,
    fontFamily: primaryFontFamily,
  );

  /// Headline Medium - 28px
  /// Use for: Card titles, major sections
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 28,
    fontWeight: semiBold,
    height: 1.29,
    letterSpacing: 0,
    fontFamily: primaryFontFamily,
  );

  /// Headline Small - 24px
  /// Use for: List section headers, subheadings
  static const TextStyle headlineSmall = TextStyle(
    fontSize: 24,
    fontWeight: semiBold,
    height: 1.33,
    letterSpacing: 0,
    fontFamily: primaryFontFamily,
  );

  // ==================== Title Styles ====================

  /// Title Large - 22px
  /// Use for: App bar titles, prominent list items
  static const TextStyle titleLarge = TextStyle(
    fontSize: 22,
    fontWeight: medium,
    height: 1.27,
    letterSpacing: 0,
    fontFamily: primaryFontFamily,
  );

  /// Title Medium - 16px
  /// Use for: List item titles, card headers
  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: medium,
    height: 1.5,
    letterSpacing: 0.15,
    fontFamily: primaryFontFamily,
  );

  /// Title Small - 14px
  /// Use for: Dense list items, small cards
  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: medium,
    height: 1.43,
    letterSpacing: 0.1,
    fontFamily: primaryFontFamily,
  );

  // ==================== Body Styles ====================

  /// Body Large - 16px
  /// Use for: Primary body text, descriptions
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: regular,
    height: 1.5,
    letterSpacing: 0.5,
    fontFamily: primaryFontFamily,
  );

  /// Body Medium - 14px
  /// Use for: Secondary body text, supporting text
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: regular,
    height: 1.43,
    letterSpacing: 0.25,
    fontFamily: primaryFontFamily,
  );

  /// Body Small - 12px
  /// Use for: Captions, helper text
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: regular,
    height: 1.33,
    letterSpacing: 0.4,
    fontFamily: primaryFontFamily,
  );

  // ==================== Label Styles ====================

  /// Label Large - 14px
  /// Use for: Buttons, tabs, prominent labels
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: medium,
    height: 1.43,
    letterSpacing: 0.1,
    fontFamily: primaryFontFamily,
  );

  /// Label Medium - 12px
  /// Use for: Form labels, chips
  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: medium,
    height: 1.33,
    letterSpacing: 0.5,
    fontFamily: primaryFontFamily,
  );

  /// Label Small - 11px
  /// Use for: Overlines, tiny labels
  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: medium,
    height: 1.45,
    letterSpacing: 0.5,
    fontFamily: primaryFontFamily,
  );

  // ==================== Specialized Styles ====================

  /// Button text style
  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: medium,
    height: 1.43,
    letterSpacing: 0.1,
    fontFamily: primaryFontFamily,
  );

  /// Caption style
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: regular,
    height: 1.33,
    letterSpacing: 0.4,
    fontFamily: primaryFontFamily,
  );

  /// Overline style
  static const TextStyle overline = TextStyle(
    fontSize: 10,
    fontWeight: medium,
    height: 1.6,
    letterSpacing: 1.5,
    fontFamily: primaryFontFamily,
  );

  /// Monospace code style
  static const TextStyle code = TextStyle(
    fontSize: 14,
    fontWeight: regular,
    height: 1.5,
    letterSpacing: 0,
    fontFamily: monospaceFontFamily,
  );

  // ==================== Task-Specific Styles ====================

  /// Task title style
  static const TextStyle taskTitle = TextStyle(
    fontSize: 16,
    fontWeight: medium,
    height: 1.5,
    letterSpacing: 0.15,
    fontFamily: primaryFontFamily,
  );

  /// Task description style
  static const TextStyle taskDescription = TextStyle(
    fontSize: 14,
    fontWeight: regular,
    height: 1.5,
    letterSpacing: 0.25,
    fontFamily: primaryFontFamily,
  );

  /// Due date style
  static const TextStyle dueDate = TextStyle(
    fontSize: 12,
    fontWeight: medium,
    height: 1.33,
    letterSpacing: 0.4,
    fontFamily: primaryFontFamily,
  );

  /// Priority label style
  static const TextStyle priorityLabel = TextStyle(
    fontSize: 11,
    fontWeight: semiBold,
    height: 1.45,
    letterSpacing: 0.5,
    fontFamily: primaryFontFamily,
  );

  /// Tag style
  static const TextStyle tag = TextStyle(
    fontSize: 12,
    fontWeight: medium,
    height: 1.33,
    letterSpacing: 0.5,
    fontFamily: primaryFontFamily,
  );

  // ==================== Helper Methods ====================

  /// Apply color to text style
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// Apply font weight to text style
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }

  /// Apply font size to text style
  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }

  /// Apply line height to text style
  static TextStyle withHeight(TextStyle style, double height) {
    return style.copyWith(height: height);
  }

  /// Apply letter spacing to text style
  static TextStyle withLetterSpacing(TextStyle style, double spacing) {
    return style.copyWith(letterSpacing: spacing);
  }

  /// Make text style bold
  static TextStyle makeBold(TextStyle style) {
    return style.copyWith(fontWeight: bold);
  }

  /// Make text style italic
  static TextStyle makeItalic(TextStyle style) {
    return style.copyWith(fontStyle: FontStyle.italic);
  }

  /// Add underline to text style
  static TextStyle underline(TextStyle style) {
    return style.copyWith(decoration: TextDecoration.underline);
  }

  /// Add strikethrough to text style (useful for completed tasks)
  static TextStyle strikethrough(TextStyle style) {
    return style.copyWith(decoration: TextDecoration.lineThrough);
  }

  /// Scale text style for accessibility
  static TextStyle scale(TextStyle style, double factor) {
    return style.copyWith(fontSize: (style.fontSize ?? 14) * factor);
  }
}
