import 'dart:convert';
import 'package:joystick/models/line_follower.dart';
import 'package:joystick/models/robot_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Almacenamiento de la configuracion de un unico robot.
class SettingsStorage {
  static const String _key = 'robot';
  static const String _lineFollowerKey = 'lineFollower';
  static const String _lineColorKey = 'lineColor';
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

  static Future<void> saveLineFollower(LineFollowerParams params) async {
    await _preferences!.setString(_lineFollowerKey, jsonEncode(params.toJson()));
  }

  static LineFollowerParams loadLineFollower() {
    final json = _preferences!.getString(_lineFollowerKey);
    if (json != null) {
      return LineFollowerParams.fromJson(jsonDecode(json));
    }
    return const LineFollowerParams();
  }

  static Future<void> saveLineColor(LineColor color) async {
    await _preferences!.setString(_lineColorKey, color.name);
  }

  static LineColor loadLineColor() {
    return _preferences!.getString(_lineColorKey) == LineColor.white.name
        ? LineColor.white
        : LineColor.black;
  }
}
