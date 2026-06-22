import 'dart:async';
import 'dart:convert';
import 'package:app_settings/app_settings.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// UUIDs del Nordic UART Service (NUS). Deben coincidir con el firmware del
/// robot (ver firmware/control_remoto_robot_ble/).
final Guid kNusService = Guid("6E400001-B5A3-F393-E0A9-E50E24DCCA9E");
final Guid kNusRxChar = Guid("6E400002-B5A3-F393-E0A9-E50E24DCCA9E"); // app -> robot
final Guid kNusTxChar = Guid("6E400003-B5A3-F393-E0A9-E50E24DCCA9E"); // robot -> app

class BlueState {
  final bool connected;
  final bool enabled;

  BlueState(this.connected, this.enabled);
}

/// Capa de transporte BLE. Mantiene la MISMA interfaz publica que la version
/// anterior basada en Bluetooth Clasico (SPP), de modo que el resto de la app
/// (robot_interface, indicator, etc.) no necesita cambios.
class Bluetooth {
  String? address; // remoteId del dispositivo (MAC en Android, UUID en iOS)
  bool _connected = false;
  bool _enabled = false;
  bool _wantConnection = false; // el usuario quiere estar conectado

  BluetoothDevice? _device;
  BluetoothCharacteristic? _rxChar;

  StreamSubscription? _adapterSub;
  StreamSubscription? _connSub;
  StreamSubscription? _notifySub;

  final StreamController<BlueState> stateBroadcast =
      StreamController.broadcast();
  final StreamController<String> inputBroadcast = StreamController.broadcast();

  Bluetooth() {
    // Estado del adaptador Bluetooth del telefono (on/off)
    _adapterSub = FlutterBluePlus.adapterState.listen((state) {
      _enabled = state == BluetoothAdapterState.on;
      _emit();
    });

    // Emitimos el estado periodicamente (la UI escucha este stream)
    Timer.periodic(const Duration(milliseconds: 0xDD), (_) => _emit());
  }

  Stream<BlueState> get getState => stateBroadcast.stream;
  Stream<String> get getinput => inputBroadcast.stream;

  void _emit() => stateBroadcast.add(BlueState(_connected, _enabled));

  /// Enciende el Bluetooth del telefono (solo Android; muestra el dialogo del
  /// sistema). En iOS no se permite por API: el usuario debe activarlo manual.
  Future<void> enable() async {
    try {
      await FlutterBluePlus.turnOn();
    } catch (_) {}
  }

  /// Abre el panel de Bluetooth del sistema. Necesario porque desde Android 13
  /// (API 33) ninguna app puede APAGAR el Bluetooth por codigo; el usuario lo
  /// apaga desde aqui.
  Future<void> openBluetoothSettings() async {
    try {
      await AppSettings.openAppSettings(type: AppSettingsType.bluetooth);
    } catch (_) {}
  }

  /// Conecta al robot identificado por [ad] (remoteId guardado en ajustes).
  Future<void> connect(String ad) async {
    if (ad.isEmpty || ad == '<No Device>') return;
    if (_device != null && address == ad && _wantConnection) return;

    address = ad;
    _wantConnection = true;
    await _connectTo(ad);
  }

  Future<void> _connectTo(String ad) async {
    try {
      final device = BluetoothDevice.fromId(ad);
      _device = device;

      _connSub?.cancel();
      _connSub = device.connectionState.listen((state) async {
        if (state == BluetoothConnectionState.connected) {
          await _discover(device);
        } else if (state == BluetoothConnectionState.disconnected) {
          _connected = false;
          _rxChar = null;
          _emit();
        }
      });

      // autoConnect mantiene el intento en segundo plano: cuando el robot se
      // enciende o vuelve a rango, se reconecta solo.
      await device.connect(autoConnect: true, mtu: null);
    } catch (_) {
      _connected = false;
      _emit();
    }
  }

  Future<void> _discover(BluetoothDevice device) async {
    try {
      final services = await device.discoverServices();
      for (final service in services) {
        if (service.uuid != kNusService) continue;
        for (final c in service.characteristics) {
          if (c.uuid == kNusRxChar) {
            _rxChar = c;
          } else if (c.uuid == kNusTxChar) {
            await c.setNotifyValue(true);
            _notifySub?.cancel();
            _notifySub = c.onValueReceived.listen((data) {
              inputBroadcast.add(ascii.decode(data, allowInvalid: true));
            });
          }
        }
      }
      _connected = _rxChar != null;
      _emit();
    } catch (_) {
      _connected = false;
      _emit();
    }
  }

  Future<void> disconnect() async {
    _wantConnection = false;
    _connSub?.cancel();
    _notifySub?.cancel();
    try {
      await _device?.disconnect();
    } catch (_) {}
    _connected = false;
    _rxChar = null;
    _emit();
  }

  /// Envia un comando "outR,outL,R,G,B" al robot (mismo formato que la version
  /// Clasica). Se escribe en la caracteristica RX sin esperar respuesta para
  /// no introducir latencia en el stream de control.
  void send(String message) async {
    final c = _rxChar;
    if (c == null || !_connected) return;
    try {
      await c.write(utf8.encode('$message\n'), withoutResponse: true);
    } catch (_) {
      // Errores transitorios de escritura se ignoran; el siguiente tick reintenta.
    }
  }
}

final Bluetooth bluetooth = Bluetooth();
