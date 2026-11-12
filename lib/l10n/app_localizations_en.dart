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

  @override
  String get joystick => 'Joystick';

  @override
  String get joystickSubtitle => 'Drive the robot with the remote control';

  @override
  String get lineFollower => 'Line follower';

  @override
  String get lineFollowerSubtitle => 'Read the sensors and tune PID and speed';

  @override
  String get terminal => 'Terminal';

  @override
  String get terminalSubtitle => 'Read and send telemetry messages';

  @override
  String get sensors => 'Sensors';

  @override
  String get sensorsWaiting => 'Waiting for robot data';

  @override
  String get position => 'Line position';

  @override
  String get lineColor => 'Line color';

  @override
  String get blackLine => 'Black';

  @override
  String get whiteLine => 'White';

  @override
  String get lineColorMessage =>
      'Black: black line on a white background. White: white line on a black background. The robot switches right away.';

  @override
  String get parameters => 'Parameters';

  @override
  String get kpMessage =>
      'Proportional gain: corrects based on how far the line is from the center. Raise it if the robot is slow in curves; lower it if it oscillates.';

  @override
  String get kiMessage =>
      'Integral gain: corrects errors that build up over time. Usually left at 0 or very low.';

  @override
  String get kdMessage =>
      'Derivative gain: damps sudden changes and reduces oscillation. Raise it if the robot zigzags.';

  @override
  String get baseSpeed => 'Base speed';

  @override
  String get baseSpeedMessage =>
      'Motor speed (PWM 0-255) when the line is centered.';

  @override
  String get readParams => 'Read from robot';

  @override
  String get sendParams => 'Send to robot';

  @override
  String get paramsSent => 'Parameters sent';

  @override
  String get paramsReceived => 'Parameters received from robot';

  @override
  String get calibrate => 'Calibrate sensors';

  @override
  String get finishCalibration => 'Finish calibration';

  @override
  String get calibrationHint =>
      'Sweep every sensor over the line and over the background. The box on each bar is what that sensor has seen so far; its name turns green once it has enough contrast. Tap again to finish.';

  @override
  String get calibrationDone => 'Calibration done';

  @override
  String calibrationNoContrast(String sensors) {
    return 'Calibration done. No contrast (left unchanged): $sensors';
  }

  @override
  String get threshold => 'Threshold';

  @override
  String get thresholdMessage =>
      'Drag the orange mark on the bars or move the slider. The green zone is what counts as line, and sensors in it turn green. Higher = more sensitive: raise it if the robot loses the line between two sensors; lower it if it mistakes the background for the line. Sent to the robot when you let go. Calibrate first.';

  @override
  String get scale => 'Scale';

  @override
  String get start => 'Start';

  @override
  String get stop => 'Stop';

  @override
  String get notConnected => 'Robot not connected';

  @override
  String get terminalEmpty => 'Messages from the robot will appear here';

  @override
  String get terminalHint => 'Type a message';

  @override
  String get showSensors => 'Show sensor data';

  @override
  String get clear => 'Clear';

  @override
  String get send => 'Send';
}
