import 'dart:async';
import 'package:flutter/material.dart';
import 'package:joystick/constants.dart';
import 'package:joystick/l10n/app_localizations.dart';
import 'package:joystick/models/bluetooth_interface.dart';
import 'package:joystick/pages/settings_page.dart';

/// Estado de la conexion para las pantallas verticales (el [Indicator] del
/// joystick va rotado). Al tocarlo abre la configuracion del robot.
class ConnectionChip extends StatefulWidget {
  const ConnectionChip({super.key});

  @override
  State<ConnectionChip> createState() => _ConnectionChipState();
}

class _ConnectionChipState extends State<ConnectionChip> {
  bool _enabled = false;
  bool _connected = false;
  StreamSubscription? _listener;

  @override
  void initState() {
    super.initState();
    _listener = bluetooth.getState.listen((BlueState state) {
      if (state.enabled != _enabled || state.connected != _connected) {
        setState(() {
          _enabled = state.enabled;
          _connected = state.connected;
        });
      }
    });
  }

  @override
  void dispose() {
    _listener?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations texts = AppLocalizations.of(context)!;
    Color color;
    String state;
    if (!_enabled) {
      color = Colors.grey[600]!;
      state = texts.disabled;
    } else if (!_connected) {
      color = Colors.red;
      state = texts.disconnected;
    } else {
      color = Colors.green;
      state = texts.connected;
    }

    return GestureDetector(
      onTap: () async {
        await Navigator.pushNamed(context, SettingsPage.id);
        await robot.updateSetting(activeRobot);
        if (mounted) setState(() {});
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: kBackgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white, width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.circle, color: color, size: 12),
            const SizedBox(width: 8),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(robot.settings.name,
                    style: kTitleText.copyWith(fontSize: 13)),
                Text(state, style: kSubtitleText.copyWith(fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
