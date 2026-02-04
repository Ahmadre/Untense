import 'package:flutter/material.dart';

/// App Theme class following Flutter best practices
/// Provides static getters for light and dark themes
class AppTheme {
  AppTheme._();

  // ============== Colors ==============
  static const Color _primaryColor = Color(0xFF0B4C78);
  static const Color _secondaryColor = Color(0xFF0E7C7B);

  // Light Theme Colors
  static const Color _lightBackground = Color(0xFFFAFAFA);
  static const Color _lightSurface = Color(0xFFFFFFFF);
  static const Color _lightOnPrimary = Color(0xFFFFFFFF);
  static const Color _lightOnSecondary = Color(0xFFFFFFFF);
  static const Color _lightOnBackground = Color(0xFF1C1C1E);
  static const Color _lightOnSurface = Color(0xFF1C1C1E);
  static const Color _lightError = Color(0xFFB00020);

  // Dark Theme Colors
  static const Color _darkBackground = Color(0xFF121212);
  static const Color _darkSurface = Color(0xFF1E1E1E);
  static const Color _darkOnPrimary = Color(0xFFFFFFFF);
  static const Color _darkOnSecondary = Color(0xFFFFFFFF);
  static const Color _darkOnBackground = Color(0xFFE1E1E1);
  static const Color _darkOnSurface = Color(0xFFE1E1E1);
  static const Color _darkError = Color(0xFFCF6679);

  // ============== Color Schemes ==============
  static ColorScheme get _lightColorScheme => const ColorScheme(
    brightness: Brightness.light,
    primary: _primaryColor,
    onPrimary: _lightOnPrimary,
    secondary: _secondaryColor,
    onSecondary: _lightOnSecondary,
    error: _lightError,
    onError: _lightOnPrimary,
    surface: _lightSurface,
    onSurface: _lightOnSurface,
  );

  static ColorScheme get _darkColorScheme => const ColorScheme(
    brightness: Brightness.dark,
    primary: _primaryColor,
    onPrimary: _darkOnPrimary,
    secondary: _secondaryColor,
    onSecondary: _darkOnSecondary,
    error: _darkError,
    onError: _darkOnPrimary,
    surface: _darkSurface,
    onSurface: _darkOnSurface,
  );

  // ============== Text Themes ==============
  static TextTheme get _textTheme => const TextTheme(
    displayLarge: TextStyle(
      fontSize: 57,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.25,
    ),
    displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.w400),
    displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.w400),
    headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
    headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
    headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
    titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
    ),
  );

  // ============== Shape Themes ==============
  static const double _borderRadiusSmall = 8.0;
  static const double _borderRadiusMedium = 12.0;
  static const double _borderRadiusLarge = 16.0;

  static ShapeBorder get smallRoundedShape => RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(_borderRadiusSmall),
  );

  static ShapeBorder get mediumRoundedShape => RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(_borderRadiusMedium),
  );

  static ShapeBorder get largeRoundedShape => RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(_borderRadiusLarge),
  );

  // ============== Button Styles ==============
  static ButtonStyle get _elevatedButtonStyle => ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(_borderRadiusMedium),
    ),
    elevation: 2,
  );

  static ButtonStyle get _outlinedButtonStyle => OutlinedButton.styleFrom(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(_borderRadiusMedium),
    ),
    side: const BorderSide(color: _primaryColor, width: 1.5),
  );

  static ButtonStyle get _textButtonStyle => TextButton.styleFrom(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(_borderRadiusSmall),
    ),
  );

  // ============== Input Decoration Theme ==============
  static InputDecorationTheme _inputDecorationTheme(ColorScheme colorScheme) =>
      InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadiusMedium),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadiusMedium),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadiusMedium),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadiusMedium),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadiusMedium),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
      );

  // ============== Card Theme ==============
  static CardThemeData _cardTheme(ColorScheme colorScheme) => CardThemeData(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(_borderRadiusMedium),
    ),
    color: colorScheme.surface,
    shadowColor: Colors.black26,
  );

  // ============== AppBar Theme ==============
  static AppBarTheme _appBarTheme(ColorScheme colorScheme) => AppBarTheme(
    elevation: 0,
    centerTitle: true,
    backgroundColor: colorScheme.surface,
    foregroundColor: colorScheme.onSurface,
    surfaceTintColor: Colors.transparent,
    titleTextStyle: TextStyle(
      color: colorScheme.onSurface,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
    iconTheme: IconThemeData(color: colorScheme.onSurface),
  );

  // ============== Bottom Navigation Bar Theme ==============
  static BottomNavigationBarThemeData _bottomNavBarTheme(
    ColorScheme colorScheme,
  ) => BottomNavigationBarThemeData(
    backgroundColor: colorScheme.surface,
    selectedItemColor: colorScheme.primary,
    unselectedItemColor: colorScheme.onSurface.withValues(alpha: 0.6),
    type: BottomNavigationBarType.fixed,
    elevation: 8,
  );

  // ============== Floating Action Button Theme ==============
  static FloatingActionButtonThemeData get _fabTheme =>
      FloatingActionButtonThemeData(
        backgroundColor: _primaryColor,
        foregroundColor: _lightOnPrimary,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadiusLarge),
        ),
      );

  // ============== Dialog Theme ==============
  static DialogThemeData _dialogTheme(ColorScheme colorScheme) =>
      DialogThemeData(
        backgroundColor: colorScheme.surface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadiusLarge),
        ),
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      );

  // ============== Chip Theme ==============
  static ChipThemeData _chipTheme(ColorScheme colorScheme) => ChipThemeData(
    backgroundColor: colorScheme.surface,
    selectedColor: colorScheme.primary,
    disabledColor: colorScheme.onSurface.withValues(alpha: 0.12),
    labelStyle: TextStyle(color: colorScheme.onSurface),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(_borderRadiusSmall),
    ),
  );

  // ============== Divider Theme ==============
  static DividerThemeData _dividerTheme(ColorScheme colorScheme) =>
      DividerThemeData(
        color: colorScheme.onSurface.withValues(alpha: 0.12),
        thickness: 1,
        space: 1,
      );

  // ============== Light Theme ==============
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: _lightColorScheme,
    scaffoldBackgroundColor: _lightBackground,
    textTheme: _textTheme.apply(
      bodyColor: _lightOnBackground,
      displayColor: _lightOnBackground,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(style: _elevatedButtonStyle),
    outlinedButtonTheme: OutlinedButtonThemeData(style: _outlinedButtonStyle),
    textButtonTheme: TextButtonThemeData(style: _textButtonStyle),
    inputDecorationTheme: _inputDecorationTheme(_lightColorScheme),
    cardTheme: _cardTheme(_lightColorScheme),
    appBarTheme: _appBarTheme(_lightColorScheme),
    bottomNavigationBarTheme: _bottomNavBarTheme(_lightColorScheme),
    floatingActionButtonTheme: _fabTheme,
    dialogTheme: _dialogTheme(_lightColorScheme),
    chipTheme: _chipTheme(_lightColorScheme),
    dividerTheme: _dividerTheme(_lightColorScheme),
    iconTheme: const IconThemeData(color: _lightOnSurface),
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );

  // ============== Dark Theme ==============
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: _darkColorScheme,
    scaffoldBackgroundColor: _darkBackground,
    textTheme: _textTheme.apply(
      bodyColor: _darkOnBackground,
      displayColor: _darkOnBackground,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(style: _elevatedButtonStyle),
    outlinedButtonTheme: OutlinedButtonThemeData(style: _outlinedButtonStyle),
    textButtonTheme: TextButtonThemeData(style: _textButtonStyle),
    inputDecorationTheme: _inputDecorationTheme(_darkColorScheme),
    cardTheme: _cardTheme(_darkColorScheme),
    appBarTheme: _appBarTheme(_darkColorScheme),
    bottomNavigationBarTheme: _bottomNavBarTheme(_darkColorScheme),
    floatingActionButtonTheme: _fabTheme,
    dialogTheme: _dialogTheme(_darkColorScheme),
    chipTheme: _chipTheme(_darkColorScheme),
    dividerTheme: _dividerTheme(_darkColorScheme),
    iconTheme: const IconThemeData(color: _darkOnSurface),
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}
