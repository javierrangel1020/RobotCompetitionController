import 'dart:async';
import 'package:flutter/material.dart';
import 'package:joystick/pages/discovery_page.dart';
import 'package:joystick/models/bluetooth_interface.dart';
import 'package:joystick/constants.dart';
import 'package:joystick/models/settings_storage.dart';
import 'package:joystick/widgets/show_alert.dart';
import 'package:joystick/l10n/app_localizations.dart';

class SettingsPage extends StatefulWidget {
  static const String id = 'SettingsPage';
  @override
  _BluetoothPage createState() => _BluetoothPage();
}

class _BluetoothPage extends State<SettingsPage> {
  bool _enabled = false;
  StreamSubscription? listener;
  int speedLevel = 2;

  @override
  void initState() {
    super.initState();
    listener = bluetooth.getState.listen(
      (BlueState state) {
        setState(() {
          _enabled = state.enabled;
        });
      },
    );
  }

  @override
  void dispose() {
    listener!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations texts = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: Text(texts.settings),
        backgroundColor: kWidgetColor,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text(texts.name, style: kTitleText),
            subtitle: Text(activeRobot.name, style: kSubtitleText),
          ),
          ListTile(
            title: Text(texts.device, style: kTitleText),
            subtitle: Text(activeRobot.address, style: kSubtitleText),
            trailing: GestureDetector(
              child: Container(
                width: screenWidth! * 0.35,
                height: 35,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white,
                    width: 0.5,
                  ),
                  color: kWidgetColor,
                ),
                child: Center(
                  child: Text(
                    texts.deviceNew,
                    style: kTitleText,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              onTap: () async {
                if (!_enabled) {
                  await bluetooth.enable();
                }
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) {
                    return DiscoveryPage();
                  }),
                );
                // DiscoveryPage ya guardo activeRobot al seleccionar.
                setState(() {});
              },
            ),
          ),
          Line(),
          ValueTile(
            title: texts.speedMax,
            subtitle: speedNameList[activeRobot.speedLevel],
            text: texts.speedMaxMessage,
            onChange: (increment) async {
              activeRobot = activeRobot.edit(
                speedLevel: activeRobot.speedLevel + increment.toInt(),
              );
              await SettingsStorage.save(activeRobot);
              setState(() {});
            },
          ),
          Line(),
          ValueTile(
            title: texts.accel,
            subtitle: activeRobot.maxAccel.round().toString(),
            text: texts.accelMessage,
            onChange: (increment) async {
              activeRobot = activeRobot.edit(
                maxAccel: activeRobot.maxAccel + increment,
              );
              await SettingsStorage.save(activeRobot);
              setState(() {});
            },
          ),
          Line(),
          ValueTile(
            increment: 0.1,
            title: texts.rotation,
            subtitle: activeRobot.turnFactor.toStringAsFixed(1),
            text: texts.rotationMessage,
            onChange: (increment) async {
              activeRobot = activeRobot.edit(
                turnFactor: activeRobot.turnFactor + increment,
              );
              await SettingsStorage.save(activeRobot);
              setState(() {});
            },
          ),
          Line(),
          ValueTile(
            increment: 0.01,
            title: texts.correction,
            text: texts.correctionMessage,
            subtitle: activeRobot.correction.toStringAsFixed(2),
            onChange: (increment) async {
              activeRobot = activeRobot.edit(
                correction: activeRobot.correction + increment,
              );
              await SettingsStorage.save(activeRobot);
              setState(() {});
            },
          ),
          Line(),
          SizedBox(height: 10),
          ListTile(
            title: GestureDetector(
              child: Container(
                width: screenWidth! * 0.35,
                height: 45,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white,
                    width: 0.5,
                  ),
                  color: kWidgetColor,
                ),
                child: Center(
                  child: Text(
                    texts.reset,
                    style: kTitleText,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              onTap: () {
                showBasicAlert(
                  context,
                  title: texts.reset,
                  message: texts.resetMessage,
                  onConfirm: () async {
                    activeRobot = activeRobot.reset();
                    await SettingsStorage.save(activeRobot);
                    setState(() {});
                  },
                );
              },
            ),
          ),
          SizedBox(height: 30),
        ],
      ),
    );
  }
}

typedef void _ValueCallback(double value);

class ValueTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String text;
  final _ValueCallback onChange;
  final double increment;

  const ValueTile({
    required this.title,
    required this.subtitle,
    required this.onChange,
    this.increment = 1,
    this.text = '',
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: GestureDetector(
        child: Row(
          children: [
            Text(title, style: kTitleText),
            Container(
              width: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 0.5,
                ),
                color: kWidgetColor,
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Icon(
                    Icons.question_mark,
                    color: Colors.white,
                    size: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
        onTap: () async {
          await showBasicAlert(
            context,
            title: title,
            message: text,
          );
        },
      ),
      subtitle: Text(
        subtitle,
        style: kSubtitleText,
      ),
      trailing: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            child: Container(
              width: 25,
              height: 25,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 0.5,
                ),
                color: kWidgetColor,
              ),
              child: Center(
                child: Center(
                  child: Icon(
                    Icons.remove,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
            onTap: () {
              onChange(-increment);
            },
          ),
          VerticalDivider(
            color: Colors.white,
            thickness: 1,
            width: 35,
          ),
          GestureDetector(
            child: Container(
              width: 25,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 0.5,
                ),
                color: kWidgetColor,
              ),
              child: Center(
                child: Center(
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
            onTap: () {
              onChange(increment);
            },
          ),
        ],
      ),
    );
  }
}

class Line extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      color: KsubtitleColor,
      height: 1,
      thickness: 0.1,
    );
  }
}

List speedNameList = [
  'Slow',
  'Normal',
  'Fast',
  'Turbo',
];
