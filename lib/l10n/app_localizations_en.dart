// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get settings => 'Settings';

  @override
  String get disabled => 'Bluetooth Disabled';

  @override
  String get disconnected => 'Disconnected';

  @override
  String get connected => 'Connected';

  @override
  String get profile => 'Select robot';

  @override
  String get name => 'Name';

  @override
  String get nameEdit => 'Edit profile name';

  @override
  String get device => 'Device';

  @override
  String get deviceNew => 'New Device';

  @override
  String get reverseL => 'Reverse Left';

  @override
  String get reverseR => 'Reverse Right';

  @override
  String get speedMin => 'Min Speed [PWM]';

  @override
  String get speedMinMessage => 'Lowest speed to start movement';

  @override
  String get speedMax => 'Speed';

  @override
  String get speedSlow => 'Slow';

  @override
  String get speedNormal => 'Normal';

  @override
  String get speedFast => 'Fast';

  @override
  String get speedTurbo => 'Turbo';

  @override
  String get speedMaxMessage =>
      'Limits the maximum speed (PWM) of the robot\n\n Slow 100\n Normal 150\n Fast 200\n Turbo 255';

  @override
  String get accel => 'Acceleration Factor';

  @override
  String get accelMessage =>
      'Limiting the aceleration helps the robot run straighter and softer';

  @override
  String get rotation => 'Rotating Speed Factor';

  @override
  String get rotationMessage =>
      'This factor determines how fast the robot turn';

  @override
  String get correction => 'Correction Factor';

  @override
  String get correctionMessage =>
      'Use this factor to straighten the robot. Increase the value if the robot tilts to the left and lower it if it tilts to the right';

  @override
  String get reset => 'Reset Parameters';

  @override
  String get resetMessage => 'Restore default values';

  @override
  String get deleteMessage => 'Delete the current robot';

  @override
  String get delete => 'Delete Robot';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get discoveringDevices => 'Discovering devices';

  @override
  String get discoveredDevices => 'Discovered devices';
}
