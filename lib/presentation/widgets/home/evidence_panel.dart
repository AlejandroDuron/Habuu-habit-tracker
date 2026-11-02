import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../config/assets.dart';
import '../../../config/theme/tokens.dart';
import '../../../services/photo_picker.dart';

/// Panel que se despliega bajo un hábito para subir la foto de evidencia.
///
/// "Guardar" marca el hábito con la foto elegida; "Omitir" lo marca sin foto.
class EvidencePanel extends StatefulWidget {
  const EvidencePanel({
    super.key,
    required this.onSave,
    required this.onSkip,
    this.allowSkip = false,
  });

  final Future<void> Function(Uint8List photo) onSave;
  final Future<void> Function() onSkip;

  /// Si el hábito permite ser omitido. Si es false, el botón "Omitir"
  /// no se muestra.
  final bool allowSkip;

  @override
  State<EvidencePanel> createState() => _EvidencePanelState();
}

class _EvidencePanelState extends State<EvidencePanel> {
  static const _titleColor = Color(0xFF308242);
  static const _photoSize = 100.0;

  Uint8List? _photo;
  bool _busy = false;

  /// Pide la foto a la galería o a la cámara. [source] es solo para el
  /// mensaje de error, por ejemplo "la galería".
  Future<void> _getPhoto(
    Future<Uint8List?> Function() pick,
    String source,
  ) async {
    try {
      final photo = await pick();
      if (photo != null && mounted) setState(() => _photo = photo);
    } on PlatformException catch (e) {
      debugPrint('No se pudo abrir $source: ${e.code}');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo abrir $source. Revisa los permisos.'),
        ),
      );
    }
  }

  /// Corre una acción mostrando que se está guardando.
  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    await action();
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final photo = _photo;

    return Container(
      padding: const EdgeInsets.fromLTRB(21, 13, 10, 9),
      decoration: BoxDecoration(
        color: HabuuColors.white100,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
        boxShadow: const [habuuCardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '¡Hora de demostrar tu progreso!',
            textAlign: TextAlign.center,
            style: HabuuText.captionMdMedium.copyWith(color: _titleColor),
          ),
          const SizedBox(height: 17),
          Padding(
            padding: const EdgeInsets.only(right: 11),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PhotoPreview(photo: photo, size: _photoSize),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Escoge una foto de máximo 100KB',
                        style: HabuuText.bodySmMedium,
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Flexible(
                            child: _FilledButton(
                              label: photo == null
                                  ? 'Escoger Archivo'
                                  : 'Cambiar Archivo',
                              onPressed: _busy
                                  ? null
                                  : () => _getPhoto(
                                      pickEvidencePhoto,
                                      'la galería',
                                    ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _CameraButton(
                            onPressed: _busy
                                ? null
                                : () =>
                                      _getPhoto(takeEvidencePhoto, 'la cámara'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: _busy
                ? const [
                    Padding(
                      padding: EdgeInsets.all(4),
                      child: SizedBox.square(
                        dimension: 19,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ]
                : [
                    if (widget.allowSkip) ...[
                      _TextButton(
                        label: 'Omitir',
                        onPressed: () => _run(widget.onSkip),
                      ),
                      const SizedBox(width: 10),
                    ],
                    _OutlinedButton(
                      label: 'Guardar',
                      // Sin foto no hay nada que guardar.
                      onPressed: photo == null
                          ? null
                          : () => _run(() => widget.onSave(photo)),
                    ),
                  ],
          ),
        ],
      ),
    );
  }
}

/// La foto elegida o, si todavía no hay, un recuadro con un ícono de imagen.
class _PhotoPreview extends StatelessWidget {
  const _PhotoPreview({required this.photo, required this.size});

  final Uint8List? photo;
  final double size;

  @override
  Widget build(BuildContext context) {
    final photo = this.photo;

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox.square(
        dimension: size,
        child: photo == null
            ? const ColoredBox(
                color: HabuuColors.grey100,
                child: Icon(
                  Icons.image_outlined,
                  size: 48,
                  color: HabuuColors.grey400,
                  semanticLabel: 'Sin foto',
                ),
              )
            : Image.memory(
                photo,
                fit: BoxFit.cover,
                semanticLabel: 'Foto elegida',
              ),
      ),
    );
  }
}

TextStyle get _buttonText =>
    HabuuText.captionMdMedium.copyWith(fontWeight: HabuuWeight.semibold);

class _FilledButton extends StatelessWidget {
  const _FilledButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: HabuuColors.primary500,
        foregroundColor: HabuuColors.white100,
        minimumSize: const Size(0, 30),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: _buttonText,
      ),
      // En pantallas angostas el texto se achica en vez de cortarse.
      child: FittedBox(fit: BoxFit.scaleDown, child: Text(label, maxLines: 1)),
    );
  }
}

/// Botón cuadrado con el ícono de cámara, del mismo alto que los demás.
class _CameraButton extends StatelessWidget {
  const _CameraButton({required this.onPressed});

  final VoidCallback? onPressed;

  static const double _size = 30;

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      onPressed: onPressed,
      tooltip: 'Tomar foto',
      constraints: const BoxConstraints.tightFor(width: _size, height: _size),
      padding: EdgeInsets.zero,
      style: IconButton.styleFrom(
        backgroundColor: HabuuColors.primary500,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: SvgPicture.asset(
        HomeAssets.camera,
        width: 18,
        height: 18,
        colorFilter: const ColorFilter.mode(
          HabuuColors.white100,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}

class _OutlinedButton extends StatelessWidget {
  const _OutlinedButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: HabuuColors.primary500,
        minimumSize: const Size(71, 27),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        side: BorderSide(
          color: onPressed == null
              ? HabuuColors.grey300
              : HabuuColors.primary500,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: _buttonText,
      ),
      child: Text(label),
    );
  }
}

class _TextButton extends StatelessWidget {
  const _TextButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: HabuuColors.primary500,
        minimumSize: const Size(71, 27),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        textStyle: _buttonText,
      ),
      child: Text(label),
    );
  }
}
