import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme.dart';

class AppTheme {
  static TextStyle display({
    double fontSize = 28,
    FontWeight fontWeight = FontWeight.w700,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    return GoogleFonts.unbounded(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? KColors.text,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  static TextStyle body({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    return GoogleFonts.figtree(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? KColors.text,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  static TextStyle motto({
    double fontSize = 12,
    Color? color,
  }) {
    return GoogleFonts.figtree(
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      letterSpacing: 3.0,
      color: color ?? KColors.mint,
    );
  }

  static ThemeData get darkTheme {
    final baseText = GoogleFonts.figtreeTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: KColors.bg,
      primaryColor: KColors.mint,
      cardColor: KColors.surface,
      dividerColor: KColors.line,
      colorScheme: const ColorScheme.dark(
        primary: KColors.mint,
        secondary: KColors.magenta,
        surface: KColors.surface,
        error: KColors.danger,
        onPrimary: KColors.onMint,
        onSecondary: KColors.text,
        onSurface: KColors.text,
        onError: KColors.dangerKeyText,
      ),
      textTheme: baseText
          .apply(
            bodyColor: KColors.text,
            displayColor: KColors.text,
          )
          .copyWith(
            displayLarge: display(fontSize: 56, fontWeight: FontWeight.w800),
            displayMedium: display(fontSize: 40, fontWeight: FontWeight.w800),
            displaySmall: display(fontSize: 28, fontWeight: FontWeight.w700),
            headlineLarge: display(fontSize: 28, fontWeight: FontWeight.w700),
            headlineMedium: display(fontSize: 24, fontWeight: FontWeight.w700),
            headlineSmall: display(fontSize: 20, fontWeight: FontWeight.w700),
            titleLarge: body(fontSize: 20, fontWeight: FontWeight.w700),
            titleMedium: body(fontSize: 16, fontWeight: FontWeight.w600),
            titleSmall: body(fontSize: 14, fontWeight: FontWeight.w600),
            bodyLarge: body(fontSize: 16),
            bodyMedium: body(fontSize: 14),
            bodySmall: body(fontSize: 12, color: KColors.muted),
            labelLarge: body(fontSize: 15, fontWeight: FontWeight.w700),
            labelMedium: body(fontSize: 12, fontWeight: FontWeight.w600),
            labelSmall: body(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: KColors.placeholder,
            ),
          ),
      appBarTheme: AppBarTheme(
        backgroundColor: KColors.bg,
        elevation: 0,
        centerTitle: true,
        foregroundColor: KColors.text,
        titleTextStyle: display(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: KColors.surface2,
        selectedColor: KColors.mintTint,
        labelStyle: body(fontSize: 12, fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: KColors.line),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: KColors.mint,
          foregroundColor: KColors.onMint,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: body(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
            color: KColors.onMint,
          ),
        ),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: KColors.navBar,
      ),
    );
  }
}
