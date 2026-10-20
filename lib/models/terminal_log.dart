import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:joystick/models/bluetooth_interface.dart';

enum TerminalDirection { received, sent }

class TerminalEntry {
  final DateTime time;
  final TerminalDirection direction;
  final String text;

  TerminalEntry(this.direction, this.text) : time = DateTime.now();
}

/// Historial de la terminal. Escucha al robot desde que arranca la app, asi
/// que tambien guarda lo que llega mientras se esta en otra pantalla. Todo lo
/// que envian el seguidor de linea y la terminal pasa por [send] y queda aqui.
class TerminalLog extends ChangeNotifier {
  static const int maxEntries = 500;

  final List<TerminalEntry> entries = [];

  // Las lecturas "SEN,..." llegan varias veces por segundo mientras el
  // seguidor de linea esta abierto; por defecto no se guardan para no tapar
  // el resto de mensajes.
  bool showSensorLines = false;

  StreamSubscription? _sub;

  void start() {
    _sub ??= bluetooth.getinput.listen((line) {
      if (!showSensorLines && line.startsWith('SEN,')) return;
      _add(TerminalEntry(TerminalDirection.received, line));
    });
  }

  void send(String text) {
    bluetooth.send(text);
    _add(TerminalEntry(TerminalDirection.sent, text));
  }

  void clear() {
    entries.clear();
    notifyListeners();
  }

  void setShowSensorLines(bool value) {
    showSensorLines = value;
    notifyListeners();
  }

  void _add(TerminalEntry entry) {
    entries.add(entry);
    if (entries.length > maxEntries) {
      entries.removeRange(0, entries.length - maxEntries);
    }
    notifyListeners();
  }
}

final TerminalLog terminalLog = TerminalLog();
