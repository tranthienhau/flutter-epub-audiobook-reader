import 'package:flutter/material.dart';

import 'tokens.dart';

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: Pal.accent,
    primary: Pal.accentFill,
    onPrimary: Colors.white,
    secondary: Pal.support,
    surface: Pal.surface,
    onSurface: Pal.text,
    error: Pal.danger,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: Pal.bg,
    fontFamily: Pal.body,
    splashFactory: InkSparkle.splashFactory,
    textTheme: const TextTheme(headlineLarge: T.display, titleLarge: T.title, bodyLarge: T.body, bodyMedium: T.body, labelLarge: T.label, bodySmall: T.caption),
    sliderTheme: const SliderThemeData(
      activeTrackColor: Pal.accent,
      inactiveTrackColor: Pal.surfaceAlt,
      thumbColor: Pal.accent,
      overlayColor: Color(0x22FB7299),
      trackHeight: 4,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: const WidgetStatePropertyAll(Colors.white),
      trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? Pal.accentFill : const Color(0xFFE5D9DC)),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Pal.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Pal.borderStrong, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Pal.accent, width: 2),
      ),
      labelStyle: T.caption,
    ),
  );
}
