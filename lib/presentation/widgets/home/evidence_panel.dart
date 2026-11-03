import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../config/assets.dart';
import '../../../config/theme/tokens.dart';
import '../../../services/photo_picker.dart';
import '../../models/home/evidence_check.dart';
import '../shared/scanner_overlay.dart';
import 'verification_badge.dart';

/// Panel que se despliega bajo un hábito para subir la foto de evidencia.
///
/// "Guardar" sube la foto (y la manda a revisar si la verificación está
/// activada); "Omitir" lo marca sin foto. Con [check] se muestra cómo va la
/// revisión.
class EvidencePanel extends StatefulWidget {
  const EvidencePanel({
    super.key,
    required this.onSave,
    required this.onSkip,
    this.allowSkip = false,
    this.check,
    this.onRetry,
    this.onSaveAnyway,
    this.onFinish,
  });

  final Future<void> Function(Uint8List photo) onSave;
  final Future<void> Function() onSkip;

  /// Si el hábito permite ser omitido. Si es false, el botón "Omitir"
  /// no se muestra.
  final bool allowSkip;

  /// La revisión de la foto, si ya se mandó una.
  final EvidenceCheck? check;

  /// "Reintentar" cuando no se pudo verificar.
  final VoidCallback? onRetry;

  /// "Guardar sin verificar" cuando no se pudo verificar.
  final Future<void> Function()? onSaveAnyway;

  /// "Listo" cuando la foto ya se verificó.
  final VoidCallback? onFinish;

  @override
  State<EvidencePanel> createState() => _EvidencePanelState();
}

class _EvidencePanelState extends State<EvidencePanel> {
  static const _titleColor = Color(0xFF308242);
  static const _photoSize = 100.0;
  static const _photoRadius = BorderRadius.all(Radius.circular(4));

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
    final check = widget.check;
    final status = check?.status;
    final photo = _photo ?? check?.photo;

    // Se puede elegir foto al inicio, o si la que se mandó no coincidió.
    final canPick = status == null || status == VerificationStatus.noConfirmado;
    // Si no coincidió, solo se puede volver a guardar con otra foto.
    final canSave =
        _photo != null && (check == null || !identical(_photo, check.photo));

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
                ScannerOverlay(
                  active: status == VerificationStatus.verificando,
                  borderRadius: _photoRadius,
                  child: _PhotoPreview(photo: photo, size: _photoSize),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _StatusText(check: check),
                      if (canPick) ...[
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
                                  : () => _getPhoto(
                                      takeEvidencePhoto,
                                      'la cámara',
                                    ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          // Wrap y no Row: en pantallas angostas los botones bajan de línea.
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 10,
            runSpacing: 8,
            children: _actions(status, canSave),
          ),
        ],
      ),
    );
  }

  /// Los botones de abajo según cómo va la revisión.
  List<Widget> _actions(VerificationStatus? status, bool canSave) {
    if (_busy) {
      return const [
        Padding(
          padding: EdgeInsets.all(4),
          child: SizedBox.square(
            dimension: 19,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ];
    }

    final onSaveAnyway = widget.onSaveAnyway;
    return switch (status) {
      VerificationStatus.verificando => const [SizedBox(height: 27)],
      VerificationStatus.verificado => [
        _OutlinedButton(label: 'Listo', onPressed: widget.onFinish),
      ],
      VerificationStatus.noSePudo => [
        _TextButton(label: 'Reintentar', onPressed: widget.onRetry),
        _OutlinedButton(
          label: 'Guardar sin verificar',
          onPressed: onSaveAnyway == null ? null : () => _run(onSaveAnyway),
        ),
      ],
      _ => [
        if (widget.allowSkip) ...[
          _TextButton(label: 'Omitir', onPressed: () => _run(widget.onSkip)),
        ],
        _OutlinedButton(
          label: 'Guardar',
          onPressed: canSave ? () => _run(() => widget.onSave(_photo!)) : null,
        ),
      ],
    };
  }
}

/// El texto al lado de la foto: qué hacer, o cómo salió la revisión.
class _StatusText extends StatelessWidget {
  const _StatusText({required this.check});

  final EvidenceCheck? check;

  static const _noMatch =
      'No pudimos confirmar que la foto corresponda al hábito';

  @override
  Widget build(BuildContext context) {
    final check = this.check;
    if (check == null) {
      return Text(
        'Escoge una foto de máximo 100KB',
        style: HabuuText.bodySmMedium,
      );
    }
    if (check.status == VerificationStatus.verificando) {
      return Text(
        'Revisando que la foto sea del hábito…',
        style: HabuuText.bodySmMedium,
      );
    }

    final message = switch (check.status) {
      VerificationStatus.noConfirmado => _noMatch,
      VerificationStatus.noSePudo =>
        check.errorMessage ?? 'No se pudo verificar la foto.',
      _ => null,
    };
    final reason = check.result?.motivo;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        VerificationBadge(status: check.status),
        if (message != null) ...[
          const SizedBox(height: 6),
          Text(message, style: HabuuText.bodySmMedium),
        ],
        if (reason != null) ...[
          const SizedBox(height: 4),
          Text(
            reason,
            style: HabuuText.captionMdMedium.copyWith(
              color: HabuuColors.black60,
            ),
          ),
        ],
      ],
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
