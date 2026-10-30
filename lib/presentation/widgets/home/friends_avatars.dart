import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../config/assets.dart';
import '../../../config/theme/tokens.dart';

/// Avatares de amigos superpuestos, con un "+N" al final si hay más.
class FriendsAvatars extends StatelessWidget {
  const FriendsAvatars({super.key, required this.avatars, this.extra = 0});

  final int avatars;
  final int extra;

  static const _size = 28.0;

  /// Cuánto se corre cada avatar respecto al anterior.
  static const _step = 20.0;

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      for (var i = 0; i < avatars; i++)
        Image.asset(HomeAssets.avatar(i + 1), width: _size, height: _size),
      if (extra > 0) _ExtraBadge(count: extra),
    ];

    return SizedBox(
      width: _size + (items.length - 1) * _step,
      height: _size,
      child: Stack(
        children: [
          for (var i = 0; i < items.length; i++)
            Positioned(left: i * _step, child: items[i]),
        ],
      ),
    );
  }
}

class _ExtraBadge extends StatelessWidget {
  const _ExtraBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: FriendsAvatars._size,
      height: FriendsAvatars._size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: HabuuColors.purple50,
        shape: BoxShape.circle,
        border: Border.all(color: HabuuColors.white100),
      ),
      child: Text(
        '+$count',
        style: GoogleFonts.instrumentSans(
          fontSize: 10,
          height: 16 / 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
          color: HabuuColors.success700,
        ),
      ),
    );
  }
}
