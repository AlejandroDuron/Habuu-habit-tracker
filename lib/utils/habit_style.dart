import 'dart:math' as math;

import 'package:flutter/painting.dart';

final _hexPattern = RegExp(r'^#?[0-9a-fA-F]{6}$');

/// Con esta luminancia o menos, un color tiene contraste de 3:1 sobre blanco.
const _maxLuminanceOnWhite = 0.3;

/// Convierte el color guardado como texto ("#FFC654" o "FFC654") en un Color.
/// Devuelve null si el texto no es un color válido, para que quien lo use
/// decida qué color poner en su lugar.
Color? colorFromHex(String? hex) {
  if (hex == null) return null;

  final text = hex.trim();
  if (!_hexPattern.hasMatch(text)) return null;

  final rgb = int.parse(text.replaceFirst('#', ''), radix: 16);
  return Color(0xFF000000 | rgb);
}

/// Oscurece [color] lo necesario para que se distinga sobre un fondo blanco.
/// Los colores que ya se ven bien se devuelven igual.
Color readableOnWhite(Color color) {
  var hsl = HSLColor.fromColor(color);

  while (hsl.toColor().computeLuminance() > _maxLuminanceOnWhite &&
      hsl.lightness > 0) {
    hsl = hsl.withLightness(math.max(0, hsl.lightness - 0.05));
  }

  return hsl.toColor();
}
