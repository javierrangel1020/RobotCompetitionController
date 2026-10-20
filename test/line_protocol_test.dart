import 'package:flutter_test/flutter_test.dart';
import 'package:joystick/models/line_follower.dart';

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
}
