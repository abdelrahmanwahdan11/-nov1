import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light(Color seed, {bool useMaterial3 = true}) {
    final colorScheme = ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.light);
    final textTheme = GoogleFonts.poppinsTextTheme();
    return ThemeData(
      useMaterial3: useMaterial3,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        elevation: 1,
        margin: const EdgeInsets.all(12),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        selectedColor: colorScheme.primaryContainer,
        backgroundColor: colorScheme.surfaceVariant,
        labelStyle: textTheme.labelLarge,
      ),
    );
  }

  static ThemeData dark(Color seed, {bool useMaterial3 = true}) {
    final colorScheme = ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark);
    final textTheme = GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme);
    return ThemeData(
      useMaterial3: useMaterial3,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        elevation: 1,
        margin: const EdgeInsets.all(12),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        selectedColor: colorScheme.primaryContainer,
        backgroundColor: colorScheme.surfaceVariant,
        labelStyle: textTheme.labelLarge,
      ),
    );
  }
}
