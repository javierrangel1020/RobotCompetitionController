import 'dart:async';
import 'package:flutter/material.dart';
import 'package:joystick/constants.dart';
import 'package:joystick/l10n/app_localizations.dart';
import 'package:joystick/models/bluetooth_interface.dart';
import 'package:joystick/models/line_follower.dart';
import 'package:joystick/models/settings_storage.dart';
import 'package:joystick/models/terminal_log.dart';
import 'package:joystick/pages/settings_page.dart';
import 'package:joystick/widgets/connection_chip.dart';
import 'package:joystick/widgets/edit_alert.dart';
import 'package:joystick/widgets/sensor_bars.dart';

/// Seguidor de linea: muestra los sensores y ajusta PID y velocidad.
/// Protocolo en [LineProtocol].
class LineFollowerPage extends StatefulWidget {
  static const String id = 'LineFollowerPage';
  const LineFollowerPage({super.key});

  @override
  State<LineFollowerPage> createState() => _LineFollowerPageState();
}

class _LineFollowerPageState extends State<LineFollowerPage> {
  LineFollowerParams _params = SettingsStorage.loadLineFollower();
  bool _dirty = false; // hay cambios que el robot aun no tiene
  SensorReading? _reading;
  bool _connected = false;

  StreamSubscription? _stateSub;
  StreamSubscription? _inputSub;

  @override
  void initState() {
    super.initState();
    _stateSub = bluetooth.getState.listen((BlueState state) {
      final connected = state.enabled && state.connected;
      if (connected == _connected) return;
      setState(() {
        _connected = connected;
        if (!connected) _reading = null;
      });
      // Al (re)conectar: pedir las lecturas y los parametros que tiene el robot.
      if (connected) {
        terminalLog.send(LineProtocol.sensors(true));
        terminalLog.send(LineProtocol.get);
      }
    });
    _inputSub = bluetooth.getinput.listen(_onLine);
  }

  @override
  void dispose() {
    _stateSub?.cancel();
    _inputSub?.cancel();
    if (_connected) terminalLog.send(LineProtocol.sensors(false));
    super.dispose();
  }

  void _onLine(String line) {
    final reading = LineProtocol.parseSensors(line);
    if (reading != null) {
      setState(() => _reading = reading);
      return;
    }
    final params = LineProtocol.parsePid(line);
    if (params != null) {
      setState(() {
        _params = params;
        _dirty = false;
      });
      SettingsStorage.saveLineFollower(params);
      _showMessage(AppLocalizations.of(context)!.paramsReceived);
    }
  }

  void _setParams(LineFollowerParams params) {
    setState(() {
      _params = params;
      _dirty = true;
    });
    SettingsStorage.saveLineFollower(params);
  }

  void _sendParams() {
    terminalLog.send(LineProtocol.pid(_params));
    setState(() => _dirty = false);
    _showMessage(AppLocalizations.of(context)!.paramsSent);
  }

  void _start() {
    // Arrancar siempre con los valores que se ven en pantalla.
    if (_dirty) _sendParams();
    terminalLog.send(LineProtocol.run(true));
  }

  Future<void> _editValue(
      String title, double current, void Function(double) apply) async {
    final text = await editAlert(
      context,
      title: title,
      initialValue: LineProtocol.format(current),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
    );
    // Teclados en espanol escriben coma decimal.
    final value = double.tryParse(text.replaceAll(',', '.').trim());
    if (value != null) apply(value);
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ));
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations texts = AppLocalizations.of(context)!;
    final p = _params;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        // En telefonos angostos "Seguidor de linea" no cabe junto al chip.
        title: FittedBox(
            fit: BoxFit.scaleDown, child: Text(texts.lineFollower)),
        backgroundColor: kWidgetColor,
        foregroundColor: Colors.white,
        actions: const [ConnectionChip()],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SectionTitle(texts.sensors),
            SensorBars(reading: _reading),
            const SizedBox(height: 12),
            LinePositionBar(position: _reading?.position),
            const SizedBox(height: 24),
            _SectionTitle(texts.parameters),
            Container(
              decoration: BoxDecoration(
                color: kWidgetColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white, width: 0.5),
              ),
              child: Column(
                children: [
                  ValueTile(
                    title: 'Kp',
                    subtitle: LineProtocol.format(p.kp),
                    text: texts.kpMessage,
                    increment: 0.01,
                    onChange: (inc) => _setParams(p.edit(kp: p.kp + inc)),
                    onValueTap: () => _editValue(
                        'Kp', p.kp, (v) => _setParams(_params.edit(kp: v))),
                  ),
                  Line(),
                  ValueTile(
                    title: 'Ki',
                    subtitle: LineProtocol.format(p.ki),
                    text: texts.kiMessage,
                    increment: 0.001,
                    onChange: (inc) => _setParams(p.edit(ki: p.ki + inc)),
                    onValueTap: () => _editValue(
                        'Ki', p.ki, (v) => _setParams(_params.edit(ki: v))),
                  ),
                  Line(),
                  ValueTile(
                    title: 'Kd',
                    subtitle: LineProtocol.format(p.kd),
                    text: texts.kdMessage,
                    increment: 0.1,
                    onChange: (inc) => _setParams(p.edit(kd: p.kd + inc)),
                    onValueTap: () => _editValue(
                        'Kd', p.kd, (v) => _setParams(_params.edit(kd: v))),
                  ),
                  Line(),
                  ValueTile(
                    title: texts.baseSpeed,
                    subtitle: '${p.speed}',
                    text: texts.baseSpeedMessage,
                    increment: 10,
                    onChange: (inc) =>
                        _setParams(p.edit(speed: p.speed + inc.round())),
                    onValueTap: () => _editValue(
                        texts.baseSpeed,
                        p.speed.toDouble(),
                        (v) => _setParams(_params.edit(speed: v.round()))),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    text: texts.readParams,
                    icon: Icons.download,
                    enabled: _connected,
                    onTap: () => terminalLog.send(LineProtocol.get),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionButton(
                    text: texts.sendParams,
                    icon: Icons.upload,
                    color: _dirty ? kMathColor : kWidgetColor,
                    enabled: _connected,
                    onTap: _sendParams,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _ActionButton(
              text: texts.calibrate,
              icon: Icons.tune,
              enabled: _connected,
              onTap: () => terminalLog.send(LineProtocol.calibrate),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    text: texts.start,
                    icon: Icons.play_arrow,
                    color: Colors.green[700]!,
                    height: 56,
                    enabled: _connected,
                    onTap: _start,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionButton(
                    text: texts.stop,
                    icon: Icons.stop,
                    color: Colors.red[700]!,
                    height: 56,
                    enabled: _connected,
                    onTap: () => terminalLog.send(LineProtocol.run(false)),
                  ),
                ),
              ],
            ),
            if (!_connected)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  texts.notConnected,
                  style: kSubtitleText,
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(text, style: kBotonText),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;
  final Color? color;
  final double height;

  const _ActionButton({
    required this.text,
    required this.icon,
    required this.onTap,
    this.enabled = true,
    this.color,
    this.height = 45,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white, width: 0.5),
            color: color ?? kWidgetColor,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  text,
                  style: kTitleText,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
