import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Colores predeyterminados del proyecto.
abstract final class HabuuColors {
  static const primary50 = Color(0xFFB0E1CE);
  static const primary200 = Color(0xFF7BB29C);
  static const primary500 = Color(0xFF13533A);
  static const primary600 = Color(0xFF0F422E);

  static const success0 = Color(0xFFE8F9FC);
  static const success200 = Color(0xFF94D6E4);
  static const success300 = Color(0xFF69C4D9);
  static const success700 = Color(0xFF0D6174);
  static const success800 = Color(0xFF08404D);

  static const info300 = Color(0xFFF8C9D0);
  static const grey400 = Color(0xFF9DA1A2);
  static const purple50 = Color(0xFFFCF7FF);
  static const green700 = Color(0xFF308242);
  static const iconBlack = Color(0xFF303233);

  static const black100 = Color(0xFF000000);
  static const black60 = Color(0x99000000);
  static const black10 = Color(0x1A000000);
  static const white100 = Color(0xFFFFFFFF);
  static const white80 = Color(0xCCFFFFFF);
  static const white40 = Color(0x66FFFFFF);
}

/// Estilos de texto del design system.
/// Headings: Plus Jakarta Sans · Body: Instrument Sans.
abstract final class HabuuText {
  static TextStyle _body(double size, double line, FontWeight weight) =>
      GoogleFonts.instrumentSans(
        fontSize: size,
        height: line / size,
        fontWeight: weight,
        color: HabuuColors.black100,
      );

  /// Text Font/H5/Extra Bold — 32/36.
  static TextStyle get h5ExtraBold => GoogleFonts.plusJakartaSans(
    fontSize: 32,
    height: 36 / 32,
    fontWeight: FontWeight.w800,
    color: HabuuColors.black100,
  );

  /// Text Font/Subtitle/md/Bold — 20/28.
  static TextStyle get subtitleMdBold => _body(20, 28, FontWeight.w700);

  /// Text Font/Subtitle/sm/Medium — 16/24.
  static TextStyle get subtitleSmMedium => _body(16, 24, FontWeight.w500);

  /// Text Font/Body/sm/semibold — 14/18.
  static TextStyle get bodySmSemibold => _body(14, 18, FontWeight.w600);

  /// Text Font/Caption/md/Medium — 12/16.
  static TextStyle get captionMdMedium => _body(12, 16, FontWeight.w500);

  /// Text Font/Caption/sm/Medium — 10/12.
  static TextStyle get captionSmMedium => _body(10, 12, FontWeight.w500);
}

/// Shadows/Box Shadow del design system.
const habuuCardShadow = BoxShadow(
  color: Color(0x0F232C5D),
  offset: Offset(58, 26),
  blurRadius: 34,
);
