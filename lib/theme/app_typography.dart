import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  AppTypography._();

  static TextTheme build(ColorScheme cs) {
    final body = GoogleFonts.notoSansKrTextTheme();
    final ink = cs.onSurface;
    final inkSoft = cs.onSurfaceVariant;

    TextStyle display(double size, FontWeight w) =>
        GoogleFonts.fraunces(fontSize: size, fontWeight: w, color: ink, height: 1.15, letterSpacing: -0.5);
    TextStyle ui(double size, FontWeight w, {Color? c, double h = 1.35, double ls = 0}) =>
        body.bodyLarge!.copyWith(fontSize: size, fontWeight: w, color: c ?? ink, height: h, letterSpacing: ls);

    return TextTheme(
      displayLarge: display(40, FontWeight.w700),
      displayMedium: display(34, FontWeight.w700),
      displaySmall: display(28, FontWeight.w700),
      headlineLarge: display(26, FontWeight.w700),
      headlineMedium: display(22, FontWeight.w700),
      headlineSmall: ui(20, FontWeight.w700),
      titleLarge: ui(18, FontWeight.w600),
      titleMedium: ui(16, FontWeight.w600),
      titleSmall: ui(14, FontWeight.w600),
      bodyLarge: ui(15, FontWeight.w400, c: ink),
      bodyMedium: ui(14, FontWeight.w400, c: ink),
      bodySmall: ui(12, FontWeight.w400, c: inkSoft),
      labelLarge: ui(13, FontWeight.w600, ls: 0.1),
      labelMedium: ui(12, FontWeight.w600, ls: 0.1),
      labelSmall: ui(11, FontWeight.w600, c: inkSoft, ls: 0.2),
    );
  }
}
