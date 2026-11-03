import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../config/theme/tokens.dart';
import '../../../data/datasources/home_data_source.dart';

/// Panel que se abre bajo un hábito ya cumplido para ver su foto.
class EvidencePhotoPanel extends StatefulWidget {
  const EvidencePhotoPanel({
    super.key,
    required this.loadPhoto,
    required this.onClose,
  });

  final Future<Uint8List> Function() loadPhoto;
  final VoidCallback onClose;

  @override
  State<EvidencePhotoPanel> createState() => _EvidencePhotoPanelState();
}

class _EvidencePhotoPanelState extends State<EvidencePhotoPanel> {
  static const _titleColor = Color(0xFF308242);
  static const _photoHeight = 200.0;

  /// Se pide una sola vez; si se pidiera en build(), se bajaría la foto en
  /// cada redibujo.
  late final Future<Uint8List> _photo;

  @override
  void initState() {
    super.initState();
    _photo = widget.loadPhoto();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(21, 13, 21, 9),
      decoration: BoxDecoration(
        color: HabuuColors.white100,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
        boxShadow: const [habuuCardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Tu evidencia de hoy',
            textAlign: TextAlign.center,
            style: HabuuText.captionMdMedium.copyWith(color: _titleColor),
          ),
          const SizedBox(height: 13),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: _photoHeight,
              child: FutureBuilder<Uint8List>(
                future: _photo,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const _PhotoBox(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    );
                  }
                  if (snapshot.hasError) {
                    final error = snapshot.error;
                    return _PhotoBox(
                      child: Text(
                        error is HomeDataException
                            ? error.message
                            : 'No se pudo cargar la foto.',
                        textAlign: TextAlign.center,
                        style: HabuuText.bodySmMedium,
                      ),
                    );
                  }
                  return Image.memory(
                    snapshot.requireData,
                    fit: BoxFit.cover,
                    semanticLabel: 'Foto de evidencia',
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton(
              onPressed: widget.onClose,
              style: OutlinedButton.styleFrom(
                foregroundColor: HabuuColors.primary500,
                minimumSize: const Size(71, 27),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                side: const BorderSide(color: HabuuColors.primary500),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: HabuuText.captionMdMedium.copyWith(
                  fontWeight: HabuuWeight.semibold,
                ),
              ),
              child: const Text('Cerrar'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Fondo gris con algo al centro, mientras no hay foto que mostrar.
class _PhotoBox extends StatelessWidget {
  const _PhotoBox({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: HabuuColors.grey100,
      child: Center(
        child: Padding(padding: const EdgeInsets.all(16), child: child),
      ),
    );
  }
}
