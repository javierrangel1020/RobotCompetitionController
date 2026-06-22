import 'dart:convert';
import 'package:joystick/models/robot_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Almacenamiento de la configuracion de un unico robot.
class SettingsStorage {
  static const String _key = 'robot';
  static SharedPreferences? _preferences;

  static Future init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  static Future<void> save(RobotSettings robotSettings) async {
    final json = jsonEncode(robotSettings.toJson());
    await _preferences!.setString(_key, json);
  }

  static RobotSettings load() {
    final json = _preferences!.getString(_key);
    if (json != null) {
      return RobotSettings.fromJson(jsonDecode(json));
    }
    return const RobotSettings();
  }
}
