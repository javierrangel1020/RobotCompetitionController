import 'dart:async';
import 'dart:math';
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
  LineColor _lineColor = SettingsStorage.loadLineColor();
  SensorReading? _reading;
  bool _connected = false;

  // Modo calibracion, segun lo confirma el robot ("CAL,1" / "CAL,0"). Mientras
  // dura, se guarda el valor mas bajo y el mas alto que llega de cada sensor.
  bool _calibrating = false;
  List<int>? _calMin;
  List<int>? _calMax;

  // Valor mas alto recibido, para la escala de las barras. Se reinicia al
  // conectar y al entrar o salir de la calibracion (valores crudos vs calibrados).
  int _maxSeen = 0;

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
        if (!connected) {
          _reading = null;
          // Si el robot sigue calibrando, lo informa en la respuesta a GET.
          _calibrating = false;
          _calMin = null;
          _calMax = null;
          _maxSeen = 0;
        }
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
      setState(() {
        _reading = reading;
        _maxSeen = max(_maxSeen, reading.values.reduce(max));
        final calMin = _calMin, calMax = _calMax;
        if (_calibrating && calMin != null && calMax != null) {
          for (var i = 0; i < reading.values.length; i++) {
            calMin[i] = min(calMin[i], reading.values[i]);
            calMax[i] = max(calMax[i], reading.values[i]);
          }
        }
      });
      return;
    }
    final params = LineProtocol.parsePid(line);
    if (params != null) {
      // El umbral no viaja en PID: se conserva hasta que llegue "UMB".
      final merged = _params.edit(
          kp: params.kp, ki: params.ki, kd: params.kd, speed: params.speed);
      setState(() {
        _params = merged;
        _dirty = false;
      });
      SettingsStorage.saveLineFollower(merged);
      _showMessage(AppLocalizations.of(context)!.paramsReceived);
      return;
    }
    final threshold = LineProtocol.parseThreshold(line);
    if (threshold != null) {
      final updated = _params.edit(threshold: threshold);
      setState(() => _params = updated);
      SettingsStorage.saveLineFollower(updated);
      return;
    }
    final calibration = LineProtocol.parseCalibration(line);
    if (calibration != null) {
      _onCalibration(calibration);
      return;
    }
    // El robot confirma el color de linea, o lo informa despues de GET.
    final color = LineProtocol.parseLineColor(line);
    if (color != null) {
      setState(() => _lineColor = color);
      SettingsStorage.saveLineColor(color);
    }
  }

  void _onCalibration(CalibrationStatus status) {
    final wasCalibrating = _calibrating;
    setState(() {
      _calibrating = status.calibrating;
      if (status.calibrating != wasCalibrating) _maxSeen = 0;
      if (status.calibrating && !wasCalibrating) {
        _calMin = List.filled(LineProtocol.sensorCount, 255);
        _calMax = List.filled(LineProtocol.sensorCount, 0);
      } else if (!status.calibrating) {
        _calMin = null;
        _calMax = null;
      }
    });
    // Aviso solo al terminar una calibracion, no cuando el robot informa
    // que no estaba calibrando.
    if (wasCalibrating && !status.calibrating) {
      final texts = AppLocalizations.of(context)!;
      _showMessage(status.noContrast.isEmpty
          ? texts.calibrationDone
          : texts.calibrationNoContrast(
              status.noContrast.map((i) => 'S$i').join(', ')));
    }
  }

  // El robot confirma con "CAL,1" / "CAL,0"; hasta entonces el boton no cambia.
  void _toggleCalibration() {
    terminalLog.send(LineProtocol.calibration(!_calibrating));
  }

  // El color de linea se aplica al tocarlo, sin pasar por "Enviar al robot":
  // es un modo, no un valor que se ajusta poco a poco.
  void _setLineColor(LineColor color) {
    setState(() => _lineColor = color);
    SettingsStorage.saveLineColor(color);
    terminalLog.send(LineProtocol.lineColor(color));
  }

  void _setParams(LineFollowerParams params) {
    setState(() {
      _params = params;
      _dirty = true;
    });
    SettingsStorage.saveLineFollower(params);
  }

  // El umbral se ajusta en vivo sobre las barras: se ve al instante y se envia
  // al robot al soltar, sin pasar por "Enviar al robot".
  void _previewThreshold(int threshold) {
    setState(() => _params = _params.edit(threshold: threshold));
  }

  void _commitThreshold() {
    SettingsStorage.saveLineFollower(_params);
    terminalLog.send(LineProtocol.threshold(_params.threshold));
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
            SensorBars(
              reading: _reading,
              threshold: p.threshold,
              lineColor: _lineColor,
              // La escala incluye la raya del umbral para que siempre se vea.
              scale: barScaleFor(max(
                  _maxSeen,
                  _calibrating
                      ? 0
                      : LineProtocol.thresholdLevel(p.threshold, _lineColor))),
              calMin: _calibrating ? _calMin : null,
              calMax: _calibrating ? _calMax : null,
              onThresholdChanged:
                  _connected && !_calibrating ? _previewThreshold : null,
              onThresholdChangeEnd: _commitThreshold,
            ),
            const SizedBox(height: 12),
            _ThresholdControl(
              value: p.threshold,
              enabled: _connected && !_calibrating,
              title: texts.threshold,
              hint: texts.thresholdMessage,
              onChanged: _previewThreshold,
              onChangeEnd: _commitThreshold,
              onValueTap: () => _editValue(texts.threshold,
                  p.threshold.toDouble(), (v) {
                _previewThreshold(v.round());
                _commitThreshold();
              }),
            ),
            const SizedBox(height: 12),
            LinePositionBar(position: _reading?.position),
            const SizedBox(height: 12),
            // Junto a las barras: mientras se calibra hay que mirarlas.
            _ActionButton(
              text: _calibrating ? texts.finishCalibration : texts.calibrate,
              icon: _calibrating ? Icons.check : Icons.tune,
              color: _calibrating ? kVariableColor : kWidgetColor,
              enabled: _connected,
              onTap: _toggleCalibration,
            ),
            if (_calibrating)
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
                child: Text(texts.calibrationHint,
                    style: kSubtitleText.copyWith(fontSize: 13)),
              ),
            const SizedBox(height: 24),
            _SectionTitle(texts.lineColor),
            Row(
              children: [
                Expanded(
                  child: _LineColorOption(
                    text: texts.blackLine,
                    line: Colors.black,
                    background: Colors.white,
                    selected: _lineColor == LineColor.black,
                    enabled: _connected,
                    onTap: () => _setLineColor(LineColor.black),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _LineColorOption(
                    text: texts.whiteLine,
                    line: Colors.white,
                    background: Colors.black,
                    selected: _lineColor == LineColor.white,
                    enabled: _connected,
                    onTap: () => _setLineColor(LineColor.white),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
              child: Text(texts.lineColorMessage,
                  style: kSubtitleText.copyWith(fontSize: 13)),
            ),
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
                    increment: 0.001,
                    onChange: (inc) => _setParams(p.edit(kp: p.kp + inc)),
                    onValueTap: () => _editValue(
                        'Kp', p.kp, (v) => _setParams(_params.edit(kp: v))),
                  ),
                  Line(),
                  ValueTile(
                    title: 'Ki',
                    subtitle: LineProtocol.format(p.ki),
                    text: texts.kiMessage,
                    increment: 0.0001,
                    onChange: (inc) => _setParams(p.edit(ki: p.ki + inc)),
                    onValueTap: () => _editValue(
                        'Ki', p.ki, (v) => _setParams(_params.edit(ki: v))),
                  ),
                  Line(),
                  ValueTile(
                    title: 'Kd',
                    subtitle: LineProtocol.format(p.kd),
                    text: texts.kdMessage,
                    increment: 0.01,
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
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    text: texts.start,
                    icon: Icons.play_arrow,
                    color: Colors.green[700]!,
                    height: 56,
                    // El robot no arranca mientras calibra.
                    enabled: _connected && !_calibrating,
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

/// Umbral de deteccion: control deslizante (1-254) del mismo color que la raya
/// de las barras. Tocar el numero permite escribirlo.
class _ThresholdControl extends StatelessWidget {
  final int value;
  final bool enabled;
  final String title;
  final String hint;
  final ValueChanged<int> onChanged;
  final VoidCallback onChangeEnd;
  final VoidCallback onValueTap;

  const _ThresholdControl({
    required this.value,
    required this.enabled,
    required this.title,
    required this.hint,
    required this.onChanged,
    required this.onChangeEnd,
    required this.onValueTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        decoration: BoxDecoration(
          color: kWidgetColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(width: 16, height: 3, color: kThresholdColor),
                const SizedBox(width: 8),
                Text(title, style: kTitleText),
                Expanded(
                  child: Slider(
                    value: value.toDouble(),
                    min: LineFollowerParams.minThreshold.toDouble(),
                    max: LineFollowerParams.maxThreshold.toDouble(),
                    activeColor: kThresholdColor,
                    inactiveColor: kBackgroundColor,
                    onChanged:
                        enabled ? (v) => onChanged(v.round()) : null,
                    onChangeEnd: enabled ? (_) => onChangeEnd() : null,
                  ),
                ),
                GestureDetector(
                  onTap: enabled ? onValueTap : null,
                  child: SizedBox(
                    width: 36,
                    child: Text('$value',
                        textAlign: TextAlign.right,
                        style: kTitleText.copyWith(
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white54)),
                  ),
                ),
              ],
            ),
            Text(hint, style: kSubtitleText.copyWith(fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

/// Opcion del selector de color de linea, con un dibujo de la pista
/// (franja de la linea sobre el fondo).
class _LineColorOption extends StatelessWidget {
  final String text;
  final Color line;
  final Color background;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  const _LineColorOption({
    required this.text,
    required this.line,
    required this.background,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? kMathColor : Colors.white,
              width: selected ? 2 : 0.5,
            ),
            color: kWidgetColor,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 28,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.white54, width: 0.5),
                ),
                child: Container(width: 7, color: line),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  text,
                  style: kTitleText,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (selected) ...[
                const SizedBox(width: 6),
                Icon(Icons.check_circle, color: kMathColor, size: 18),
              ],
            ],
          ),
        ),
      ),
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
