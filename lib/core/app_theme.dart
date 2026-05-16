import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _zinc,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFF4F4F5),
      fontFamily: 'Roboto',
      textTheme: Typography.blackMountainView.apply(
        bodyColor: const Color(0xFF09090B),
        displayColor: const Color(0xFF09090B),
      ),
      inputDecorationTheme: _inputTheme(),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _zinc,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF09090B),
      fontFamily: 'Roboto',
      inputDecorationTheme: _inputTheme(),
    );
  }

  static InputDecorationTheme _inputTheme() {
    return const InputDecorationTheme(
      border: UnderlineInputBorder(),
      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(width: 2)),
    );
  }
}

const MaterialColor _zinc = MaterialColor(0xFF18181B, <int, Color>{
  50: Color(0xFFFAFAFA),
  100: Color(0xFFF4F4F5),
  200: Color(0xFFE4E4E7),
  300: Color(0xFFD4D4D8),
  400: Color(0xFFA1A1AA),
  500: Color(0xFF71717A),
  600: Color(0xFF52525B),
  700: Color(0xFF3F3F46),
  800: Color(0xFF27272A),
  900: Color(0xFF18181B),
});
