import 'package:flutter_test/flutter_test.dart';
import 'package:joystick/models/line_follower.dart';
import 'package:joystick/widgets/sensor_bars.dart';

void main() {
  group('comandos app -> robot', () {
    test('PID usa punto decimal y sin ceros de mas', () {
      const p = LineFollowerParams(kp: 0.05, ki: 0, kd: 1.5, speed: 180);
      expect(LineProtocol.pid(p), 'PID,0.05,0,1.5,180');
    });

    test('RUN y SEN', () {
      expect(LineProtocol.run(true), 'RUN,1');
      expect(LineProtocol.run(false), 'RUN,0');
      expect(LineProtocol.sensors(true), 'SEN,1');
      expect(LineProtocol.sensors(false), 'SEN,0');
    });

    test('LIN: N linea negra, B linea blanca', () {
      expect(LineProtocol.lineColor(LineColor.black), 'LIN,N');
      expect(LineProtocol.lineColor(LineColor.white), 'LIN,B');
    });
  });

  group('color de linea robot -> app', () {
    test('LIN valido, con espacios o minuscula', () {
      expect(LineProtocol.parseLineColor('LIN,N'), LineColor.black);
      expect(LineProtocol.parseLineColor('LIN,B'), LineColor.white);
      expect(LineProtocol.parseLineColor(' LIN, b '), LineColor.white);
    });

    test('LIN invalido o de otro mensaje', () {
      expect(LineProtocol.parseLineColor('LIN'), isNull);
      expect(LineProtocol.parseLineColor('LIN,X'), isNull);
      expect(LineProtocol.parseLineColor('LIN,B,1'), isNull);
      expect(LineProtocol.parseLineColor('Linea blanca'), isNull);
      expect(LineProtocol.parseLineColor('PID,0.05,0,0.5,150'), isNull);
    });

    test('LIN no se confunde con SEN ni PID', () {
      expect(LineProtocol.parseSensors('LIN,B'), isNull);
      expect(LineProtocol.parsePid('LIN,B'), isNull);
    });
  });

  group('lecturas robot -> app', () {
    test('SEN con posicion', () {
      final r = LineProtocol.parseSensors('SEN,0,10,20,30,40,50,60,255,-1200');
      expect(r, isNotNull);
      expect(r!.values, [0, 10, 20, 30, 40, 50, 60, 255]);
      expect(r.position, -1200);
    });

    test('SEN sin posicion y valores fuera de rango', () {
      final r = LineProtocol.parseSensors('SEN,300,-5,1,2,3,4,5,6');
      expect(r!.values.first, 255);
      expect(r.values[1], 0);
      expect(r.position, isNull);
    });

    test('el eco del comando SEN,1 no es una lectura', () {
      expect(LineProtocol.parseSensors('SEN,1'), isNull);
      expect(LineProtocol.parseSensors('255,255,0,0,0'), isNull);
    });

    test('PID recibido', () {
      final p = LineProtocol.parsePid('PID,0.08,0.001,2,200');
      expect(p!.kp, 0.08);
      expect(p.ki, 0.001);
      expect(p.kd, 2);
      expect(p.speed, 200);
      expect(LineProtocol.parsePid('PID,abc,0,0,0'), isNull);
    });
  });

  test('los pasos de +/- no acumulan error de coma flotante', () {
    var p = const LineFollowerParams(kd: 0.1);
    p = p.edit(kd: p.kd + 0.2);
    expect(p.kd, 0.3);
    expect(p.edit(kp: -1).kp, 0);
    expect(p.edit(speed: 999).speed, 255);
  });

  test('pasos finos con los valores del robot (Kp 0.001, Ki 0.0001, Kd 0.01)', () {
    var p = const LineFollowerParams(kp: 0.0128, ki: 0, kd: 0.089, speed: 128);
    for (var i = 0; i < 3; i++) {
      p = p.edit(kp: p.kp + 0.001, ki: p.ki + 0.0001, kd: p.kd + 0.01);
    }
    expect(p.kp, 0.0158);
    expect(p.ki, 0.0003);
    expect(p.kd, 0.119);
    expect(LineProtocol.pid(p), 'PID,0.0158,0.0003,0.119,128');
  });

  group('calibracion', () {
    test('CAL,1 entra y CAL,0 termina', () {
      expect(LineProtocol.calibration(true), 'CAL,1');
      expect(LineProtocol.calibration(false), 'CAL,0');
    });

    test('estado que informa el robot', () {
      expect(LineProtocol.parseCalibration('CAL,1')!.calibrating, isTrue);
      final ok = LineProtocol.parseCalibration('CAL,0')!;
      expect(ok.calibrating, isFalse);
      expect(ok.noContrast, isEmpty);
      final partial = LineProtocol.parseCalibration('CAL,0,3, 5')!;
      expect(partial.calibrating, isFalse);
      expect(partial.noContrast, [3, 5]);
    });

    test('CAL invalido o de otro mensaje', () {
      expect(LineProtocol.parseCalibration('CAL'), isNull);
      expect(LineProtocol.parseCalibration('CAL,2'), isNull);
      expect(LineProtocol.parseCalibration('CAL,1,3'), isNull);
      expect(LineProtocol.parseCalibration('CAL,0,9'), isNull);
      expect(LineProtocol.parseCalibration('CAL,0,x'), isNull);
      expect(LineProtocol.parseCalibration('Calibracion lista'), isNull);
      expect(LineProtocol.parseSensors('CAL,0,3,5'), isNull);
    });
  });

  group('umbral', () {
    test('UMB de ida y vuelta', () {
      expect(LineProtocol.threshold(20), 'UMB,20');
      expect(LineProtocol.parseThreshold('UMB,35'), 35);
      expect(LineProtocol.parseThreshold('UMB'), isNull);
      expect(LineProtocol.parseThreshold('UMB,x'), isNull);
      expect(LineProtocol.parseThreshold('UMB,1,2'), isNull);
    });

    test('limites y valor guardado', () {
      const p = LineFollowerParams();
      expect(p.threshold, 128); // igual que el robot
      expect(p.edit(threshold: 0).threshold, 1);
      expect(p.edit(threshold: 300).threshold, 254);
      expect(LineFollowerParams.fromJson(p.edit(threshold: 40).toJson()).threshold,
          40);
      // Configuraciones guardadas antes de existir el umbral.
      expect(LineFollowerParams.fromJson({'kp': 0.1}).threshold, 128);
    });

    test('escala de las barras: la mas chica en la que cabe el valor', () {
      expect(barScaleFor(0), 64);
      expect(barScaleFor(60), 64);
      expect(barScaleFor(64), 64);
      expect(barScaleFor(65), 128);
      expect(barScaleFor(200), 255);
      expect(barScaleFor(255), 255);
    });

    test('un sensor ve la linea segun el color, igual que el firmware', () {
      // Linea negra: valor bajo. Linea blanca: valor alto.
      expect(LineProtocol.onLine(10, 20, LineColor.black), isTrue);
      expect(LineProtocol.onLine(20, 20, LineColor.black), isFalse);
      expect(LineProtocol.onLine(245, 20, LineColor.white), isTrue);
      expect(LineProtocol.onLine(235, 20, LineColor.white), isFalse);
      expect(LineProtocol.thresholdLevel(20, LineColor.black), 20);
      expect(LineProtocol.thresholdLevel(20, LineColor.white), 235);
    });
  });
}
