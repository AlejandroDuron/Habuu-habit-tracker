import 'dart:async';

import 'package:flutter/material.dart';
import 'package:habuu/config/assets.dart';
import 'package:habuu/presentation/widgets/auth/auth_status_view.dart';

/// "Cuenta verificada con éxito". No tiene botón: avanza sola tras [duration].
class AccountVerifiedScreen extends StatefulWidget {
  const AccountVerifiedScreen({
    super.key,
    required this.onFinished,
    this.duration = const Duration(seconds: 2),
  });

  final void Function(BuildContext context) onFinished;
  final Duration duration;

  @override
  State<AccountVerifiedScreen> createState() => _AccountVerifiedScreenState();
}

class _AccountVerifiedScreenState extends State<AccountVerifiedScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.duration, () {
      if (mounted) widget.onFinished(context);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const AuthStatusView(
      frogAsset: AuthAssets.frogHappy,
      title: 'Cuenta verificada\ncon éxito',
    );
  }
}
