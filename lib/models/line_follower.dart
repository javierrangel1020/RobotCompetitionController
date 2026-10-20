/// Parametros del seguidor de linea, en el mismo orden que el comando PID.
class LineFollowerParams {
  final double kp;
  final double ki;
  final double kd;
  final int speed; // velocidad base (PWM 0-255)

  const LineFollowerParams({
    this.kp = 0.05,
    this.ki = 0,
    this.kd = 0.5,
    this.speed = 150,
  });

  LineFollowerParams edit({double? kp, double? ki, double? kd, int? speed}) {
    return LineFollowerParams(
      kp: _gain(kp ?? this.kp),
      ki: _gain(ki ?? this.ki),
      kd: _gain(kd ?? this.kd),
      speed: (speed ?? this.speed).clamp(0, 255),
    );
  }

  // Sin negativos y redondeado, para que los pasos de +/- no acumulen error
  // de coma flotante (0.1 + 0.2 = 0.30000000000000004).
  static double _gain(double v) =>
      double.parse((v < 0 ? 0.0 : v).toStringAsFixed(4));

  Map<String, dynamic> toJson() => {
        'kp': kp,
        'ki': ki,
        'kd': kd,
        'speed': speed,
      };

  factory LineFollowerParams.fromJson(Map<String, dynamic> json) {
    const d = LineFollowerParams();
    return LineFollowerParams(
      kp: (json['kp'] as num?)?.toDouble() ?? d.kp,
      ki: (json['ki'] as num?)?.toDouble() ?? d.ki,
      kd: (json['kd'] as num?)?.toDouble() ?? d.kd,
      speed: (json['speed'] as num?)?.toInt() ?? d.speed,
    );
  }
}

/// Lectura que envia el robot: "SEN,s0,...,s7,pos".
class SensorReading {
  final List<int> values; // 0-255, S0 a la izquierda
  final int? position; // -3500 (linea bajo S0) a 3500 (bajo S7), 0 = centro

  const SensorReading(this.values, this.position);
}

/// Protocolo de texto con el robot. Cada comando es una linea (bluetooth.send
/// agrega el '\n'). Llevan prefijo de letras para no confundirse con el del
/// joystick "outR,outL,R,G,B", que empieza por numero o '-'.
///
///   App -> robot: PID,kp,ki,kd,vel | GET | RUN,1/0 | SEN,1/0 | CAL
///   Robot -> app: SEN,s0,...,s7,pos | PID,kp,ki,kd,vel
class LineProtocol {
  static const int sensorCount = 8;
  static const int positionRange = 3500;

  static const String get = 'GET';
  static const String calibrate = 'CAL';

  static String pid(LineFollowerParams p) =>
      'PID,${format(p.kp)},${format(p.ki)},${format(p.kd)},${p.speed}';
  static String run(bool on) => 'RUN,${on ? 1 : 0}';
  static String sensors(bool on) => 'SEN,${on ? 1 : 0}';

  static SensorReading? parseSensors(String line) {
    final parts = line.split(',');
    if (parts.length < 1 + sensorCount || parts[0].trim() != 'SEN') {
      return null;
    }
    final values = <int>[];
    for (var i = 1; i <= sensorCount; i++) {
      final v = int.tryParse(parts[i].trim());
      if (v == null) return null;
      values.add(v.clamp(0, 255));
    }
    int? position;
    if (parts.length > sensorCount + 1) {
      position = int.tryParse(parts[sensorCount + 1].trim())
          ?.clamp(-positionRange, positionRange);
    }
    return SensorReading(values, position);
  }

  static LineFollowerParams? parsePid(String line) {
    final parts = line.split(',');
    if (parts.length != 5 || parts[0].trim() != 'PID') return null;
    final kp = double.tryParse(parts[1].trim());
    final ki = double.tryParse(parts[2].trim());
    final kd = double.tryParse(parts[3].trim());
    final speed = double.tryParse(parts[4].trim());
    if (kp == null || ki == null || kd == null || speed == null) return null;
    return const LineFollowerParams()
        .edit(kp: kp, ki: ki, kd: kd, speed: speed.round());
  }

  /// Numero con punto decimal y sin ceros de mas: 0.05 -> "0.05", 1.0 -> "1".
  /// Nunca usa coma, que es el separador del protocolo.
  static String format(double v) {
    var s = v.toStringAsFixed(4);
    s = s.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
    return s == '-0' ? '0' : s;
  }
}
