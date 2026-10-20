import 'dart:async';
import 'package:flutter/material.dart';
import 'package:joystick/constants.dart';
import 'package:joystick/l10n/app_localizations.dart';
import 'package:joystick/models/bluetooth_interface.dart';
import 'package:joystick/models/line_follower.dart';
import 'package:joystick/models/terminal_log.dart';
import 'package:joystick/widgets/connection_chip.dart';

/// Terminal de telemetria: muestra lo que envia el robot y manda texto tal
/// cual (bluetooth.send agrega el '\n').
class TerminalPage extends StatefulWidget {
  static const String id = 'TerminalPage';
  const TerminalPage({super.key});

  @override
  State<TerminalPage> createState() => _TerminalPageState();
}

class _TerminalPageState extends State<TerminalPage> {
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final FocusNode _focus = FocusNode();
  bool _connected = false;
  bool _stickToBottom = true; // seguir los mensajes nuevos si se esta al final
  StreamSubscription? _stateSub;

  final List<String> _quickCommands = [
    LineProtocol.get,
    LineProtocol.run(true),
    LineProtocol.run(false),
    LineProtocol.sensors(true),
    LineProtocol.sensors(false),
    LineProtocol.calibrate,
  ];

  static const TextStyle _mono = TextStyle(
    color: Colors.white,
    fontFamily: 'monospace',
    fontSize: 13,
  );

  @override
  void initState() {
    super.initState();
    terminalLog.addListener(_onLog);
    _scroll.addListener(() {
      final position = _scroll.position;
      _stickToBottom = position.pixels >= position.maxScrollExtent - 40;
    });
    _stateSub = bluetooth.getState.listen((BlueState state) {
      final connected = state.enabled && state.connected;
      if (connected != _connected) setState(() => _connected = connected);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _jumpToBottom());
  }

  @override
  void dispose() {
    terminalLog.removeListener(_onLog);
    _stateSub?.cancel();
    _input.dispose();
    _scroll.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onLog() {
    setState(() {});
    if (_stickToBottom) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _jumpToBottom());
    }
  }

  void _jumpToBottom() {
    if (_scroll.hasClients) _scroll.jumpTo(_scroll.position.maxScrollExtent);
  }

  void _send(String text) {
    if (!_connected || text.trim().isEmpty) return;
    _stickToBottom = true;
    terminalLog.send(text);
  }

  void _submit() {
    if (!_connected || _input.text.trim().isEmpty) return;
    _send(_input.text);
    _input.clear();
    _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations texts = AppLocalizations.of(context)!;
    final entries = terminalLog.entries;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title:
            FittedBox(fit: BoxFit.scaleDown, child: Text(texts.terminal)),
        backgroundColor: kWidgetColor,
        foregroundColor: Colors.white,
        actions: const [ConnectionChip()],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: entries.isEmpty
                  ? Center(
                      child: Text(texts.terminalEmpty, style: kSubtitleText))
                  : SelectionArea(
                      child: ListView.builder(
                        controller: _scroll,
                        padding: const EdgeInsets.all(12),
                        itemCount: entries.length,
                        itemBuilder: (context, i) =>
                            _EntryLine(entries[i], style: _mono),
                      ),
                    ),
            ),
            SizedBox(
              height: 48,
              child: Row(
                children: [
                  IconButton(
                    tooltip: texts.showSensors,
                    color: Colors.white,
                    icon: Icon(terminalLog.showSensorLines
                        ? Icons.sensors
                        : Icons.sensors_off),
                    onPressed: () => terminalLog
                        .setShowSensorLines(!terminalLog.showSensorLines),
                  ),
                  IconButton(
                    tooltip: texts.clear,
                    color: Colors.white,
                    icon: const Icon(Icons.delete_outline),
                    onPressed: terminalLog.clear,
                  ),
                  const VerticalDivider(
                      color: Colors.white38, width: 8, indent: 10, endIndent: 10),
                  Expanded(
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      children: [
                        for (final command in _quickCommands)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ActionChip(
                              label: Text(command, style: _mono),
                              backgroundColor: kWidgetColor,
                              disabledColor:
                                  kWidgetColor.withValues(alpha: 0.4),
                              side: const BorderSide(
                                  color: Colors.white, width: 0.5),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              onPressed:
                                  _connected ? () => _send(command) : null,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: kWidgetColor,
              padding: const EdgeInsets.fromLTRB(16, 4, 4, 4),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _input,
                      focusNode: _focus,
                      style: _mono,
                      cursorColor: Colors.white,
                      textInputAction: TextInputAction.send,
                      // onEditingComplete propio: enviar sin cerrar el teclado.
                      onEditingComplete: _submit,
                      decoration: InputDecoration(
                        hintText:
                            _connected ? texts.terminalHint : texts.notConnected,
                        hintStyle: kSubtitleText,
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: texts.send,
                    icon: const Icon(Icons.send),
                    color: Colors.white,
                    disabledColor: Colors.white38,
                    onPressed: _connected ? _submit : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EntryLine extends StatelessWidget {
  final TerminalEntry entry;
  final TextStyle style;
  const _EntryLine(this.entry, {required this.style});

  static String _time(DateTime t) =>
      [t.hour, t.minute, t.second].map((v) => '$v'.padLeft(2, '0')).join(':');

  @override
  Widget build(BuildContext context) {
    final sent = entry.direction == TerminalDirection.sent;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text.rich(
        TextSpan(children: [
          TextSpan(
            text: '${_time(entry.time)}  ',
            style: style.copyWith(color: Colors.white38),
          ),
          TextSpan(
            text: sent ? '> ' : '< ',
            style: style.copyWith(color: sent ? kOutputColor : kMathColor),
          ),
          TextSpan(
            text: entry.text,
            style: sent ? style.copyWith(color: const Color(0xFF9CC3FF)) : style,
          ),
        ]),
      ),
    );
  }
}
