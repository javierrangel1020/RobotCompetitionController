import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  ///
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  ///
  ///
  /// In en, this message translates to:
  /// **'Bluetooth Disabled'**
  String get disabled;

  ///
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get disconnected;

  ///
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  ///
  ///
  /// In en, this message translates to:
  /// **'Select robot'**
  String get profile;

  ///
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  ///
  ///
  /// In en, this message translates to:
  /// **'Edit profile name'**
  String get nameEdit;

  ///
  ///
  /// In en, this message translates to:
  /// **'Device'**
  String get device;

  ///
  ///
  /// In en, this message translates to:
  /// **'New Device'**
  String get deviceNew;

  ///
  ///
  /// In en, this message translates to:
  /// **'Reverse Left'**
  String get reverseL;

  ///
  ///
  /// In en, this message translates to:
  /// **'Reverse Right'**
  String get reverseR;

  ///
  ///
  /// In en, this message translates to:
  /// **'Min Speed [PWM]'**
  String get speedMin;

  ///
  ///
  /// In en, this message translates to:
  /// **'Lowest speed to start movement'**
  String get speedMinMessage;

  ///
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get speedMax;

  ///
  ///
  /// In en, this message translates to:
  /// **'Slow'**
  String get speedSlow;

  ///
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get speedNormal;

  ///
  ///
  /// In en, this message translates to:
  /// **'Fast'**
  String get speedFast;

  ///
  ///
  /// In en, this message translates to:
  /// **'Turbo'**
  String get speedTurbo;

  ///
  ///
  /// In en, this message translates to:
  /// **'Limits the maximum speed (PWM) of the robot\n\n Slow 100\n Normal 150\n Fast 200\n Turbo 255'**
  String get speedMaxMessage;

  ///
  ///
  /// In en, this message translates to:
  /// **'Acceleration Factor'**
  String get accel;

  ///
  ///
  /// In en, this message translates to:
  /// **'Limiting the aceleration helps the robot run straighter and softer'**
  String get accelMessage;

  ///
  ///
  /// In en, this message translates to:
  /// **'Rotating Speed Factor'**
  String get rotation;

  ///
  ///
  /// In en, this message translates to:
  /// **'This factor determines how fast the robot turn'**
  String get rotationMessage;

  ///
  ///
  /// In en, this message translates to:
  /// **'Correction Factor'**
  String get correction;

  ///
  ///
  /// In en, this message translates to:
  /// **'Use this factor to straighten the robot. Increase the value if the robot tilts to the left and lower it if it tilts to the right'**
  String get correctionMessage;

  ///
  ///
  /// In en, this message translates to:
  /// **'Reset Parameters'**
  String get reset;

  ///
  ///
  /// In en, this message translates to:
  /// **'Restore default values'**
  String get resetMessage;

  ///
  ///
  /// In en, this message translates to:
  /// **'Delete the current robot'**
  String get deleteMessage;

  ///
  ///
  /// In en, this message translates to:
  /// **'Delete Robot'**
  String get delete;

  ///
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  ///
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  ///
  ///
  /// In en, this message translates to:
  /// **'Discovering devices'**
  String get discoveringDevices;

  ///
  ///
  /// In en, this message translates to:
  /// **'Discovered devices'**
  String get discoveredDevices;

  /// Home section: remote control
  ///
  /// In en, this message translates to:
  /// **'Joystick'**
  String get joystick;

  ///
  ///
  /// In en, this message translates to:
  /// **'Drive the robot with the remote control'**
  String get joystickSubtitle;

  /// Home section: line follower tuning
  ///
  /// In en, this message translates to:
  /// **'Line follower'**
  String get lineFollower;

  ///
  ///
  /// In en, this message translates to:
  /// **'Read the sensors and tune PID and speed'**
  String get lineFollowerSubtitle;

  /// Home section: telemetry terminal
  ///
  /// In en, this message translates to:
  /// **'Terminal'**
  String get terminal;

  ///
  ///
  /// In en, this message translates to:
  /// **'Read and send telemetry messages'**
  String get terminalSubtitle;

  ///
  ///
  /// In en, this message translates to:
  /// **'Sensors'**
  String get sensors;

  ///
  ///
  /// In en, this message translates to:
  /// **'Waiting for robot data'**
  String get sensorsWaiting;

  ///
  ///
  /// In en, this message translates to:
  /// **'Line position'**
  String get position;

  ///
  ///
  /// In en, this message translates to:
  /// **'Parameters'**
  String get parameters;

  ///
  ///
  /// In en, this message translates to:
  /// **'Proportional gain: corrects based on how far the line is from the center. Raise it if the robot is slow in curves; lower it if it oscillates.'**
  String get kpMessage;

  ///
  ///
  /// In en, this message translates to:
  /// **'Integral gain: corrects errors that build up over time. Usually left at 0 or very low.'**
  String get kiMessage;

  ///
  ///
  /// In en, this message translates to:
  /// **'Derivative gain: damps sudden changes and reduces oscillation. Raise it if the robot zigzags.'**
  String get kdMessage;

  ///
  ///
  /// In en, this message translates to:
  /// **'Base speed'**
  String get baseSpeed;

  ///
  ///
  /// In en, this message translates to:
  /// **'Motor speed (PWM 0-255) when the line is centered.'**
  String get baseSpeedMessage;

  ///
  ///
  /// In en, this message translates to:
  /// **'Read from robot'**
  String get readParams;

  ///
  ///
  /// In en, this message translates to:
  /// **'Send to robot'**
  String get sendParams;

  ///
  ///
  /// In en, this message translates to:
  /// **'Parameters sent'**
  String get paramsSent;

  ///
  ///
  /// In en, this message translates to:
  /// **'Parameters received from robot'**
  String get paramsReceived;

  ///
  ///
  /// In en, this message translates to:
  /// **'Calibrate sensors'**
  String get calibrate;

  ///
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  ///
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  ///
  ///
  /// In en, this message translates to:
  /// **'Robot not connected'**
  String get notConnected;

  ///
  ///
  /// In en, this message translates to:
  /// **'Messages from the robot will appear here'**
  String get terminalEmpty;

  ///
  ///
  /// In en, this message translates to:
  /// **'Type a message'**
  String get terminalHint;

  ///
  ///
  /// In en, this message translates to:
  /// **'Show sensor data'**
  String get showSensors;

  ///
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  ///
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
