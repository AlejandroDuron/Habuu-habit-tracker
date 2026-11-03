import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:habuu/config/theme/tokens.dart';
import 'package:habuu/presentation/widgets/auth/auth_text_field.dart';

/// Casillas para el código de verificación (6 dígitos por defecto).
/// - Avanza solo al escribir un dígito.
/// - Backspace en una casilla vacía vuelve a la anterior.
/// - Pegar un código completo lo reparte entre las casillas.
/// - El ancho de cada casilla se adapta a la pantalla (máx. 52 px).
class CodeInput extends StatefulWidget {
  const CodeInput({
    super.key,
    required this.onChanged,
    this.length = 6,
    this.hasError = false,
  });

  final int length;
  final bool hasError;

  final ValueChanged<String> onChanged;

  @override
  State<CodeInput> createState() => _CodeInputState();
}

class _CodeInputState extends State<CodeInput> {
  static const _gap = 8.0;
  static const _minBoxWidth = 36.0;
  static const _maxBoxWidth = 52.0;

  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _nodes;

  @override
  void initState() {
    super.initState();
    _controllers =
        List.generate(widget.length, (_) => TextEditingController());
    _nodes = List.generate(widget.length, (i) {
      final node = FocusNode();
      node.addListener(() {
        if (node.hasFocus) {
          final c = _controllers[i];
          c.selection =
              TextSelection(baseOffset: 0, extentOffset: c.text.length);
        }
      });
      return node;
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  void _handleChanged(int index, String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');

    if (digits.isEmpty) {
      _controllers[index].clear();
      widget.onChanged(_code);
      return;
    }

    // Reparte los dígitos (sirve para escribir uno o pegar varios).
    var cursor = index;
    for (final digit in digits.split('')) {
      if (cursor >= widget.length) break;
      _controllers[cursor].text = digit;
      cursor++;
    }

    if (cursor < widget.length) {
      _nodes[cursor].requestFocus();
    } else {
      _nodes.last.unfocus();
    }
    widget.onChanged(_code);
  }

  KeyEventResult _handleKey(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _controllers[index - 1].clear();
      _nodes[index - 1].requestFocus();
      widget.onChanged(_code);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final idleColor =
        widget.hasError ? HabuuColors.error500 : HabuuColors.primary200;
    final focusColor =
        widget.hasError ? HabuuColors.error500 : HabuuColors.primary500;

    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth =
            ((constraints.maxWidth - _gap * (widget.length - 1)) /
                    widget.length)
                .clamp(_minBoxWidth, _maxBoxWidth)
                .toDouble();

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(widget.length, (i) {
            return SizedBox(
              width: boxWidth,
              child: Focus(
                onKeyEvent: (_, event) => _handleKey(i, event),
                child: TextField(
                  controller: _controllers[i],
                  focusNode: _nodes[i],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: HabuuText.subtitleLgBold,
                  autofillHints:
                      i == 0 ? const [AutofillHints.oneTimeCode] : null,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (value) => _handleChanged(i, value),
                  decoration: InputDecoration(
                    isDense: true,
                    filled: true,
                    fillColor: HabuuColors.grey0,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                    enabledBorder: authInputBorder(idleColor),
                    focusedBorder: authInputBorder(focusColor),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
