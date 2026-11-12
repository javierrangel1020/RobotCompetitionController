/// Parametros del seguidor de linea: los del comando PID (en el mismo orden)
/// y el umbral, que viaja aparte con el comando UMB.
class LineFollowerParams {
  final double kp;
  final double ki;
  final double kd;
  final int speed; // velocidad base (PWM 0-255)
  // Umbral de deteccion de la linea (ver LineProtocol.onLine). 128 = el sensor
  // esta mas cerca del color de la linea que del fondo; igual que el robot.
  final int threshold;

  static const int minThreshold = 1;
  static const int maxThreshold = 254;

  const LineFollowerParams({
    this.kp = 0.05,
    this.ki = 0,
    this.kd = 0.5,
    this.speed = 150,
    this.threshold = 128,
  });

  LineFollowerParams edit(
      {double? kp, double? ki, double? kd, int? speed, int? threshold}) {
    return LineFollowerParams(
      kp: _gain(kp ?? this.kp),
      ki: _gain(ki ?? this.ki),
      kd: _gain(kd ?? this.kd),
      speed: (speed ?? this.speed).clamp(0, 255),
      threshold:
          (threshold ?? this.threshold).clamp(minThreshold, maxThreshold),
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
        'threshold': threshold,
      };

  factory LineFollowerParams.fromJson(Map<String, dynamic> json) {
    const d = LineFollowerParams();
    return LineFollowerParams(
      kp: (json['kp'] as num?)?.toDouble() ?? d.kp,
      ki: (json['ki'] as num?)?.toDouble() ?? d.ki,
      kd: (json['kd'] as num?)?.toDouble() ?? d.kd,
      speed: (json['speed'] as num?)?.toInt() ?? d.speed,
      threshold: (json['threshold'] as num?)?.toInt() ?? d.threshold,
    );
  }
}

/// Estado de calibracion que informa el robot: "CAL,1" al entrar en modo
/// calibracion, "CAL,0" al terminar, seguido de los sensores que no vieron
/// contraste ("CAL,0,3,5"; ninguno = todos bien).
class CalibrationStatus {
  final bool calibrating;
  final List<int> noContrast;

  const CalibrationStatus(this.calibrating, [this.noContrast = const []]);
}

/// Lectura que envia el robot: "SEN,s0,...,s7,pos".
class SensorReading {
  final List<int> values; // 0-255, S0 a la izquierda
  final int? position; // -3500 (linea bajo S0) a 3500 (bajo S7), 0 = centro

  const SensorReading(this.values, this.position);
}

/// Color de la linea que sigue el robot. El fondo es del color contrario.
/// Los valores de SEN no cambian (alto = blanco): solo cambia cual es la linea.
enum LineColor { black, white }

/// Protocolo de texto con el robot. Cada comando es una linea (bluetooth.send
/// agrega el '\n'). Llevan prefijo de letras para no confundirse con el del
/// joystick "outR,outL,R,G,B", que empieza por numero o '-'.
///
///   App -> robot: PID,kp,ki,kd,vel | UMB,n | GET | RUN,1/0 | SEN,1/0 |
///                 CAL,1/0 | LIN,N/B
///   Robot -> app: SEN,s0,...,s7,pos | PID,kp,ki,kd,vel | UMB,n | LIN,N/B |
///                 CAL,1 | CAL,0[,sensores sin contraste]
class LineProtocol {
  static const int sensorCount = 8;
  static const int positionRange = 3500;

  /// Diferencia minima entre el valor mas oscuro y el mas claro de un sensor
  /// para que la calibracion lo cuente. Igual que CONTRASTE_MINIMO del firmware.
  static const int minContrast = 30;

  static const String get = 'GET';

  static String pid(LineFollowerParams p) =>
      'PID,${format(p.kp)},${format(p.ki)},${format(p.kd)},${p.speed}';
  static String threshold(int t) => 'UMB,$t';
  static String run(bool on) => 'RUN,${on ? 1 : 0}';
  static String sensors(bool on) => 'SEN,${on ? 1 : 0}';

  /// "CAL,1" entra en modo calibracion, "CAL,0" lo termina y aplica.
  static String calibration(bool on) => 'CAL,${on ? 1 : 0}';

  /// Igual que sobreLinea() del firmware: con linea negra un sensor la ve si su
  /// valor es menor que el umbral; con linea blanca, si es mayor que 255 - umbral.
  static bool onLine(int value, int threshold, LineColor color) =>
      color == LineColor.white ? value > 255 - threshold : value < threshold;

  /// Altura (0-255) de la marca del umbral en las barras de los sensores.
  static int thresholdLevel(int threshold, LineColor color) =>
      color == LineColor.white ? 255 - threshold : threshold;

  static int? parseThreshold(String line) {
    final parts = line.split(',');
    if (parts.length != 2 || parts[0].trim() != 'UMB') return null;
    return int.tryParse(parts[1].trim());
  }

  static CalibrationStatus? parseCalibration(String line) {
    final parts = line.split(',');
    if (parts.length < 2 || parts[0].trim() != 'CAL') return null;
    final state = parts[1].trim();
    if (state == '1' && parts.length == 2) return const CalibrationStatus(true);
    if (state != '0') return null;
    final noContrast = <int>[];
    for (final p in parts.skip(2)) {
      final i = int.tryParse(p.trim());
      if (i == null || i < 0 || i >= sensorCount) return null;
      noContrast.add(i);
    }
    return CalibrationStatus(false, noContrast);
  }

  /// "LIN,N" linea negra sobre fondo blanco, "LIN,B" linea blanca sobre fondo
  /// negro. El robot responde con el mismo mensaje, y tambien lo envia tras GET.
  static String lineColor(LineColor color) =>
      'LIN,${color == LineColor.white ? 'B' : 'N'}';

  static LineColor? parseLineColor(String line) {
    final parts = line.split(',');
    if (parts.length != 2 || parts[0].trim() != 'LIN') return null;
    switch (parts[1].trim().toUpperCase()) {
      case 'N':
        return LineColor.black;
      case 'B':
        return LineColor.white;
    }
    return null;
  }

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
