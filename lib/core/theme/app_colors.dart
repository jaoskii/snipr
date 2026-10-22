import 'package:flutter/material.dart';
import 'theme.dart';

/// App-wide color aliases mapped onto [KColors].
/// Prefer [KColors] for new code; keep these for existing widgets.
class AppColors {
  // Core mapped onto KColors
  static const Color midnightPlum = KColors.surface2;
  static const Color hotPink = KColors.magenta;
  static const Color grape = KColors.surface2;
  static const Color coralSun = KColors.linear;
  static const Color neonTeal = KColors.mint;
  static const Color steelGrid = KColors.lineStrong;
  static const Color blush = KColors.text;

  static const Color background = KColors.bg;
  static const Color surface = KColors.surface;
  static const Color surfaceElevated = KColors.surface2;
  static const Color surfaceBorder = KColors.line;

  static const Color synthDeepPurple = KColors.surface2;
  static const Color synthPlum = KColors.surface2;
  static const Color synthCoral = KColors.linear;
  static const Color synthHotPink = KColors.magenta;
  static const Color synthSlate = KColors.lineStrong;
  static const Color synthTeal = KColors.mint;

  static const Color discordIndigo = KColors.magenta;
  static const Color neonCyan = KColors.mint;
  static const Color neonPurple = KColors.magenta;
  static const Color neonGreen = KColors.mintKeyBorder;
  static const Color accentAmber = KColors.tactile;
  static const Color dangerRed = KColors.danger;
  static const Color warningAmber = KColors.tactile;

  static const Color glassSurface = Color(0x9912121F);
  static const Color glassSurfaceElevated = Color(0xB31A1A2E);
  static const Color glassBorder = Color(0x3300E5FF);
  static const Color glassBorderSubtle = Color(0x1A9A9CC0);

  static const Color textPrimary = KColors.text;
  static const Color textSecondary = KColors.muted;
  static const Color textMuted = KColors.placeholder;

  static const LinearGradient synthSunsetGradient = KColors.accentGradient;
  static const LinearGradient primaryGradient = KColors.primaryGradient;
  static const LinearGradient accentGradient = KColors.accentGradient;

  static const LinearGradient glassGradient = LinearGradient(
    colors: [Color(0x2600E5FF), Color(0x14FF2BD6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
