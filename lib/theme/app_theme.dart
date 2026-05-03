import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

ColorScheme _lightScheme = ColorScheme.fromSeed(
  seedColor: AppColors.sage,
  brightness: Brightness.light,
).copyWith(
  primary: AppColors.sage,
  onPrimary: Colors.white,
  primaryContainer: AppColors.sageContainer,
  onPrimaryContainer: AppColors.sageOnContainer,
  secondary: AppColors.terracotta,
  onSecondary: Colors.white,
  secondaryContainer: AppColors.terracottaContainer,
  onSecondaryContainer: const Color(0xFF4A1F14),
  surface: AppColors.cream,
  onSurface: AppColors.ink,
  surfaceContainerLowest: Colors.white,
  surfaceContainerLow: AppColors.cream,
  surfaceContainer: AppColors.creamHigh,
  surfaceContainerHigh: AppColors.creamHighest,
  surfaceContainerHighest: AppColors.creamHighest,
  onSurfaceVariant: AppColors.inkSoft,
  outline: AppColors.outline,
  outlineVariant: AppColors.divider,
);

ColorScheme _darkScheme = ColorScheme.fromSeed(
  seedColor: AppColors.sage,
  brightness: Brightness.dark,
).copyWith(
  primary: AppColors.sageLight,
  onPrimary: const Color(0xFF0F1A13),
  primaryContainer: AppColors.sageDark,
  onPrimaryContainer: AppColors.sageContainer,
  secondary: const Color(0xFFE89A85),
  surface: AppColors.inkDark,
  surfaceContainerLowest: const Color(0xFF131814),
  surfaceContainerLow: AppColors.inkDark,
  surfaceContainer: AppColors.inkDarkHigh,
  surfaceContainerHigh: const Color(0xFF2C342E),
  surfaceContainerHighest: const Color(0xFF333B35),
  onSurface: const Color(0xFFE8EDE9),
  onSurfaceVariant: const Color(0xFFB7C0BA),
  outline: const Color(0xFF5A6660),
  outlineVariant: const Color(0xFF3A4540),
);

ThemeData _build(ColorScheme cs) {
  final tt = AppTypography.build(cs);
  return ThemeData(
    colorScheme: cs,
    useMaterial3: true,
    scaffoldBackgroundColor: cs.surface,
    textTheme: tt,
    appBarTheme: AppBarTheme(
      backgroundColor: cs.surface,
      foregroundColor: cs.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: tt.titleLarge,
    ),
    cardTheme: CardThemeData(
      color: cs.surfaceContainerLowest,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.card)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: cs.secondary,
        foregroundColor: cs.onSecondary,
        textStyle: tt.labelLarge?.copyWith(fontSize: 15),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: cs.onSurface,
        side: BorderSide(color: cs.outline),
        textStyle: tt.labelLarge,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: cs.primary,
        textStyle: tt.labelLarge,
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: cs.surfaceContainerLowest,
      selectedColor: cs.primary,
      side: BorderSide(color: cs.outline),
      shape: const StadiumBorder(),
      labelStyle: tt.labelLarge?.copyWith(color: cs.onSurface),
      secondaryLabelStyle: tt.labelLarge?.copyWith(color: cs.onPrimary),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cs.surfaceContainerLowest,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.button),
        borderSide: BorderSide(color: cs.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.button),
        borderSide: BorderSide(color: cs.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.button),
        borderSide: BorderSide(color: cs.primary, width: 1.5),
      ),
      hintStyle: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
    ),
    dividerTheme: DividerThemeData(color: cs.outlineVariant, thickness: 1, space: 1),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: cs.surfaceContainerLowest,
      selectedItemColor: cs.primary,
      unselectedItemColor: cs.onSurfaceVariant,
      selectedLabelStyle: tt.labelMedium,
      unselectedLabelStyle: tt.labelMedium,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: cs.surfaceContainerLowest,
      indicatorColor: cs.primaryContainer,
      labelTextStyle: WidgetStatePropertyAll(tt.labelMedium),
      iconTheme: WidgetStateProperty.resolveWith(
        (s) => IconThemeData(
          color: s.contains(WidgetState.selected) ? cs.onPrimaryContainer : cs.onSurfaceVariant,
          size: 22,
        ),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: cs.secondary,
      foregroundColor: cs.onSecondary,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: cs.surfaceContainerLowest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: cs.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      modalBackgroundColor: cs.surfaceContainerLowest,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: cs.onSurface,
      contentTextStyle: tt.bodyMedium?.copyWith(color: cs.surface),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
    ),
  );
}

ThemeData get appLightTheme => _build(_lightScheme);
ThemeData get appDarkTheme => _build(_darkScheme);
