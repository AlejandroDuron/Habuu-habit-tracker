import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

//primitives
abstract final class HabuuColors {
  // Primary
  static const primary0 = Color(0xFFC1F1DE);
  static const primary50 = Color(0xFFB0E1CE);
  static const primary100 = Color(0xFF9ED1BD);
  static const primary150 = Color(0xFF8DC2AD);
  static const primary200 = Color(0xFF7BB29C);
  static const primary300 = Color(0xFF59927C);
  static const primary400 = Color(0xFF36735B);
  static const primary500 = Color(0xFF13533A); // base
  static const primary600 = Color(0xFF0F422E);
  static const primary700 = Color(0xFF0B3223);
  static const primary800 = Color(0xFF082117);
  static const primary850 = Color(0xFF061911);
  static const primary900 = Color(0xFF04110C);

  // Grey
  static const grey0 = Color(0xFFFAFAFA);
  static const grey50 = Color(0xFFECECEC);
  static const grey100 = Color(0xFFE0E1E2);
  static const grey150 = Color(0xFFD5D7D7);
  static const grey200 = Color(0xFFCACCCD);
  static const grey300 = Color(0xFFB3B6B7);
  static const grey400 = Color(0xFF9DA1A2);
  static const grey500 = Color(0xFF868B8D); // base
  static const grey600 = Color(0xFF717577);
  static const grey700 = Color(0xFF5B5F60);
  static const grey800 = Color(0xFF46484A);
  static const grey850 = Color(0xFF3B3D3F);
  static const grey900 = Color(0xFF303233);
  static const grey950 = Color(0xFF262728);

  // Success (Green)
  static const success0 = Color(0xFFE8F9FC);
  static const success50 = Color(0xFFD3F0F6);
  static const success100 = Color(0xFFBEE7F0);
  static const success200 = Color(0xFF94D6E4);
  static const success300 = Color(0xFF69C4D9);
  static const success400 = Color(0xFF3FB3CD);
  static const success500 = Color(0xFF15A1C1); // base
  static const success600 = Color(0xFF11819A);
  static const success700 = Color(0xFF0D6174);
  static const success800 = Color(0xFF08404D);
  static const success900 = Color(0xFF042027);
  static const success950 = Color(0xFF021013);

  // Error (Red)
  static const error50 = Color(0xFFFDECEC);
  static const error100 = Color(0xFFFAC5C3);
  static const error200 = Color(0xFFF7A9A7);
  static const error300 = Color(0xFFF4827E);
  static const error400 = Color(0xFFF16965);
  static const error500 = Color(0xFFEE443F); // base
  static const error600 = Color(0xFFD93E39);
  static const error700 = Color(0xFFA9302D);
  static const error800 = Color(0xFF832523);
  static const error900 = Color(0xFF641D1A);
  static const error950 = Color(0xFF411311);

  // Warning (Yellow)
  static const warning50 = Color(0xFFFFF7E6);
  static const warning100 = Color(0xFFFFE5B0);
  static const warning200 = Color(0xFFFFD88A);
  static const warning300 = Color(0xFFFFC654);
  static const warning400 = Color(0xFFFFBB33);
  static const warning500 = Color(0xFFFFAA00); // base
  static const warning600 = Color(0xFFE89B00);
  static const warning700 = Color(0xFFB57900);
  static const warning800 = Color(0xFF8C5E00);
  static const warning900 = Color(0xFF6B4700);
  static const warning950 = Color(0xFF472F00);

  // Info (Blue en Figma, pero es rosa)
  static const info50 = Color(0xFFFEF6F7);
  static const info100 = Color(0xFFFDEDEF);
  static const info200 = Color(0xFFFBDBE0);
  static const info300 = Color(0xFFF8C9D0);
  static const info400 = Color(0xFFF6B7C1);
  static const info500 = Color(0xFFF4A5B1); // base
  static const info600 = Color(0xFFD78693);
  static const info700 = Color(0xFFBB6875);
  static const info800 = Color(0xFF9E4956);
  static const info900 = Color(0xFF822B38);
  static const info950 = Color(0xFF731B29);

  // Purple
  static const purple50 = Color(0xFFFCF7FF);
  static const purple100 = Color(0xFFF9EFFF);
  static const purple200 = Color(0xFFF3DFFF);
  static const purple300 = Color(0xFFECD0FF);
  static const purple400 = Color(0xFFE6C0FF);
  static const purple500 = Color(0xFFE0B0FF); // base
  static const purple600 = Color(0xFFC38DE6);
  static const purple700 = Color(0xFFA66ACD);
  static const purple800 = Color(0xFF8946B4);
  static const purple900 = Color(0xFF6C239B);
  static const purple950 = Color(0xFF5D128E);

  // Beige
  static const beige50 = Color(0xFFFEFBF2);
  static const beige100 = Color(0xFFFDF7E6);
  static const beige200 = Color(0xFFFCEFCC);
  static const beige300 = Color(0xFFFAE8B3);
  static const beige400 = Color(0xFFF9E099);
  static const beige500 = Color(0xFFF7D880); // base
  static const beige600 = Color(0xFFD5B867);
  static const beige700 = Color(0xFFB2984F);
  static const beige800 = Color(0xFF907836);
  static const beige900 = Color(0xFF907836); // igual a 800 en Figma
  static const beige950 = Color(0xFF5C4811);

  // Black (con transparencia)
  static const black10 = Color(0x1A000000);
  static const black20 = Color(0x33000000);
  static const black30 = Color(0x4D000000);
  static const black40 = Color(0x66000000);
  static const black50 = Color(0x80000000);
  static const black60 = Color(0x99000000);
  static const black70 = Color(0xB3000000);
  static const black80 = Color(0xCC000000);
  static const black90 = Color(0xE6000000);
  static const black100 = Color(0xFF000000);

  // White (con transparencia)
  static const white10 = Color(0x1AFFFFFF);
  static const white20 = Color(0x33FFFFFF);
  static const white30 = Color(0x4DFFFFFF);
  static const white40 = Color(0x66FFFFFF);
  static const white50 = Color(0x80FFFFFF);
  static const white60 = Color(0x99FFFFFF);
  static const white70 = Color(0xB3FFFFFF);
  static const white80 = Color(0xCCFFFFFF);
  static const white90 = Color(0xE6FFFFFF);
  static const white100 = Color(0xFFFFFFFF);
}

// TOKENS SEMÁNTICOS (colección "Tokens" de Figma)

/// Group "Text Color".
abstract final class HabuuTextColors {
  static const primaryWhite = HabuuColors.white100;
  static const secondaryWhite = HabuuColors.white60;
  static const tertiaryWhite = HabuuColors.white40;
  static const primaryBlack = HabuuColors.grey900;
  static const secondaryGrey = HabuuColors.grey500;
  static const tertiaryGrey = HabuuColors.grey400;
  static const light = HabuuColors.grey300;
  static const disabled = HabuuColors.grey300;
  static const accent = HabuuColors.primary500;
  static const links = HabuuColors.primary500;
  static const success = HabuuColors.success500;
  static const info = HabuuColors.info500;
  static const warning = HabuuColors.warning500;
  static const error = HabuuColors.error500;
}

/// Group "Icon Color".
abstract final class HabuuIconColors {
  static const white = HabuuColors.white100;
  static const black = HabuuColors.grey900;
  static const grey = HabuuColors.grey400;
  static const lightGrey = HabuuColors.grey300;
  static const accent = HabuuColors.primary500;
  static const success = HabuuColors.success500;
  static const info = HabuuColors.info500;
  static const warning = HabuuColors.warning500;
  static const error = HabuuColors.error500;
}

/// Group "Background".
abstract final class HabuuBackgrounds {
  static const primary = HabuuColors.white100;
  static const secondary = Color(0xFFF5F5F5);
  static const accent = HabuuColors.primary50;
  static const dark = HabuuColors.grey900;
  static const darkSecondary = HabuuColors.grey800;
  static const darkAccent = HabuuColors.primary900;
}

// DEGRADADOS 

abstract final class HabuuGradients {
  /// Menta -> celeste. Header de racha y pantalla de trofeos.
  static const mintToSky = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [HabuuColors.primary50, HabuuColors.success200],
  );

  /// Celeste -> menta. Pantalla de cambiar contraseña.
  static const skyToMint = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [HabuuColors.success50, HabuuColors.primary0],
  );
}

// ============================================================================
// TIPOGRAFÍA
// Fuentes: Headings = Plus Jakarta Sans · Body = Instrument Sans
// Tamaños (text/line): xs 10/12 · sm 12/16 · md 14/18 · lg 16/24 · xl 20/28
//                      2xl 24/30 · h1 52/56 · h2 48/52 · h3 40/44
//                      h4 36/40 · h5 32/36
// ============================================================================

/// Group "text-weight".
abstract final class HabuuWeight {
  static const light = FontWeight.w300;
  static const regular = FontWeight.w400;
  static const medium = FontWeight.w500;
  static const semibold = FontWeight.w600;
  static const bold = FontWeight.w700;
  static const extraBold = FontWeight.w800;
}

abstract final class HabuuText {
  static TextStyle _heading(double size, double line, FontWeight weight) =>
      GoogleFonts.plusJakartaSans(
        fontSize: size,
        height: line / size,
        fontWeight: weight,
        color: HabuuColors.black100,
      );

  static TextStyle _body(double size, double line, FontWeight weight) =>
      GoogleFonts.instrumentSans(
        fontSize: size,
        height: line / size,
        fontWeight: weight,
        color: HabuuColors.black100,
      );

  // Headings (Plus Jakarta Sans)
  static TextStyle get h1ExtraBold => _heading(52, 56, HabuuWeight.extraBold);
  static TextStyle get h2ExtraBold => _heading(48, 52, HabuuWeight.extraBold);
  static TextStyle get h3ExtraBold => _heading(40, 44, HabuuWeight.extraBold);
  static TextStyle get h4ExtraBold => _heading(36, 40, HabuuWeight.extraBold);
  static TextStyle get h5ExtraBold => _heading(32, 36, HabuuWeight.extraBold);

  // Subtitles (Instrument Sans)
  static TextStyle get subtitleLgBold => _body(24, 30, HabuuWeight.bold);
  static TextStyle get subtitleMdBold => _body(20, 28, HabuuWeight.bold);
  static TextStyle get subtitleSmMedium => _body(16, 24, HabuuWeight.medium);

  // Body (Instrument Sans)
  static TextStyle get bodySmSemibold => _body(14, 18, HabuuWeight.semibold);
  static TextStyle get bodySmMedium => _body(14, 18, HabuuWeight.medium);

  // Caption (Instrument Sans)
  static TextStyle get captionMdMedium => _body(12, 16, HabuuWeight.medium);
  static TextStyle get captionSmMedium => _body(10, 12, HabuuWeight.medium);
}

/// Shadows/Box Shadow 
const habuuCardShadow = BoxShadow(
  color: Color(0x0F232C5D),
  offset: Offset(58, 26),
  blurRadius: 34,
);