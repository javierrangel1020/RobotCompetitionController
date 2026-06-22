import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:joystick/constants.dart';
import 'package:joystick/models/bluetooth_interface.dart';
import 'package:joystick/models/settings_storage.dart';
import 'package:joystick/widgets/BluetoothDeviceListEntry.dart';
import 'package:joystick/l10n/app_localizations.dart';

class DiscoveryPage extends StatefulWidget {
  final bool start;
  const DiscoveryPage({this.start = true});

  @override
  _DiscoveryPage createState() => _DiscoveryPage();
}

class _DiscoveryPage extends State<DiscoveryPage> {
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<bool>? _isScanningSubscription;
  final Map<String, ScanResult> _results = {};
  bool isDiscovering = false;

  @override
  void initState() {
    super.initState();
    _isScanningSubscription = FlutterBluePlus.isScanning.listen((scanning) {
      if (mounted) setState(() => isDiscovering = scanning);
    });
    if (widget.start) _startDiscovery();
  }

  void _restartDiscovery() {
    setState(() => _results.clear());
    _startDiscovery();
  }

  Future<void> _startDiscovery() async {
    _scanSubscription?.cancel();
    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      setState(() {
        for (final r in results) {
          _results[r.device.remoteId.str] = r;
        }
      });
    });

    try {
      await FlutterBluePlus.startScan(
        // Solo robots ROBLEX (los que anuncian el servicio NUS).
        withServices: [kNusService],
        timeout: const Duration(seconds: 15),
      );
    } catch (_) {}
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _isScanningSubscription?.cancel();
    FlutterBluePlus.stopScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations texts = AppLocalizations.of(context)!;
    final list = _results.values.toList();
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kWidgetColor,
        foregroundColor: Colors.white,
        title: isDiscovering
            ? Text(texts.discoveringDevices)
            : Text(texts.discoveredDevices),
        actions: <Widget>[
          isDiscovering
              ? FittedBox(
                  child: Container(
                    margin: const EdgeInsets.all(16.0),
                    child: const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.replay),
                  onPressed: _restartDiscovery,
                )
        ],
      ),
      body: ListView.builder(
        itemCount: list.length,
        itemBuilder: (BuildContext context, index) {
          final result = list[index];
          final device = result.device;
          final name = device.platformName.isNotEmpty
              ? device.platformName
              : result.advertisementData.advName;
          final address = device.remoteId.str;
          return BluetoothDeviceListEntry(
            name: name,
            address: address,
            rssi: result.rssi,
            isConnected: device.isConnected,
            onTap: () async {
              await FlutterBluePlus.stopScan();
              activeRobot = activeRobot.edit(
                name: name.isNotEmpty ? name : 'ROBOT',
                address: address,
              );
              await SettingsStorage.save(activeRobot);
              Navigator.of(context).pop();
            },
          );
        },
      ),
    );
  }
}
