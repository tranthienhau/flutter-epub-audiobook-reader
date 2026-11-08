import 'package:flutter/material.dart';

/// Inkwell design tokens (from design/DESIGN.md, palette P47 after the AA token check).
abstract final class Pal {
  static const bg = Color(0xFFFCF4F6);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFF8EDF0);
  static const paper = Color(0xFFFBF6EE);
  static const sepia = Color(0xFFF4ECD8);
  static const night = Color(0xFF1F191B);

  static const accent = Color(0xFFFB7299);
  static const accentFill = Color(0xFFAB4766);
  static const accentPressed = Color(0xFFA14862);
  static const accentTint = Color(0xFFFEE6ED);

  static const support = Color(0xFFB6E36A);
  static const supportStrong = Color(0xFF72A21F);

  static const text = Color(0xFF1F0C11);
  static const text2 = Color(0xFF5C454C);
  static const text3 = Color(0xFF806A70);

  static const border = Color(0xFFEFDDE2);
  static const borderStrong = Color(0xFFB7898E);

  static const success = Color(0xFF0E7C3A);
  static const successTint = Color(0xFFE3F4E9);
  static const danger = Color(0xFFCE2020);

  static const body = 'MPlusRounded';
  static const display = 'Baloo2';

  static const cardRadius = 20.0;
  static const shadow = [
    BoxShadow(color: Color(0x0A1F0C11), blurRadius: 2, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x0F1F0C11), blurRadius: 24, offset: Offset(0, 8)),
  ];

  static const heroScrim = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x00000000), Color(0x661F0C11), Color(0xE61F0C11)],
    stops: [0.25, 0.55, 1],
  );
}

abstract final class T {
  static const display = TextStyle(fontFamily: Pal.display, fontSize: 32, fontWeight: FontWeight.w700, height: 1.15, letterSpacing: -0.6, color: Pal.text);
  static const title = TextStyle(fontFamily: Pal.body, fontSize: 20, fontWeight: FontWeight.w700, height: 1.35, color: Pal.text);
  static const body = TextStyle(fontFamily: Pal.body, fontSize: 16, fontWeight: FontWeight.w400, height: 1.5, color: Pal.text);
  static const label = TextStyle(fontFamily: Pal.body, fontSize: 14, fontWeight: FontWeight.w700, height: 1.4, color: Pal.text);
  static const caption = TextStyle(fontFamily: Pal.body, fontSize: 13, fontWeight: FontWeight.w500, height: 1.4, color: Pal.text2);
}
