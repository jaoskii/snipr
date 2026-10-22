import 'package:flutter/material.dart';

/// Snipr dark neon color tokens.
class KColors {
  static const bg = Color(0xFF0A0A12);
  static const surface = Color(0xFF12121F);
  static const surface2 = Color(0xFF1A1A2E);
  static const sunken = Color(0xFF0E0E1A);
  static const line = Color(0xFF2A2A45);
  static const lineStrong = Color(0xFF3A3A5C);
  static const text = Color(0xFFF2F3FF);
  static const muted = Color(0xFF9A9CC0);
  static const placeholder = Color(0xFF7E80A6);
  static const navBar = Color(0xFF0E0E1A);

  static const mint = Color(0xFF00E5FF); // primary: neon cyan
  static const onMint = Color(0xFF001A1F);
  static const mintTint = Color(0xFF002A33);
  static const mintKey = Color(0xFF0F3D2A);
  static const mintKeyText = Color(0xFFB8FFD6);
  static const mintKeyBorder = Color(0xFF39FF88);

  static const magenta = Color(0xFFFF2BD6);

  static const linear = Color(0xFFFF3D6E);
  static const linearTint = Color(0xFF3A0F1C);
  static const tactile = Color(0xFFFFB020);
  static const tactileTint = Color(0xFF3A2A08);
  static const clicky = Color(0xFF4D8BFF);
  static const clickyTint = Color(0xFF0F1F45);

  static const danger = Color(0xFFFF4D6D);
  static const dangerKey = Color(0xFF3A0F1C);
  static const dangerKeyText = Color(0xFFFFB3C1);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [mint, magenta],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [magenta, linear],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient mintGlow = LinearGradient(
    colors: [mintTint, mint],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
