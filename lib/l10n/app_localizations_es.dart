// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get settings => 'Configuración';

  @override
  String get disabled => 'Bluetooth Desactivado';

  @override
  String get disconnected => 'Desconectado';

  @override
  String get connected => 'Conectado';

  @override
  String get profile => 'Seleccionar robot';

  @override
  String get name => 'Apodo';

  @override
  String get nameEdit => 'Editar nombre';

  @override
  String get device => 'Dispositivo';

  @override
  String get deviceNew => 'Seleccionar';

  @override
  String get reverseL => 'Invertir Izquierda';

  @override
  String get reverseR => 'Invertir Derecha';

  @override
  String get speedMin => 'Starting Speed [PWM]';

  @override
  String get speedMinMessage => 'Minima velocidad para iniciar el movimiento';

  @override
  String get speedMax => 'Velocidad';

  @override
  String get speedSlow => 'Slow';

  @override
  String get speedNormal => 'Normal';

  @override
  String get speedFast => 'Rapido';

  @override
  String get speedTurbo => 'Turbo';

  @override
  String get speedMaxMessage =>
      'Limita la maxima velocidad del robot (PWM)\n\n Lento 100\n Normal 150\n Rapido 200\n Turbo 255';

  @override
  String get accel => 'Aceleración';

  @override
  String get accelMessage =>
      'Limitar la aceleración produce un movimiento mas suave y recto';

  @override
  String get rotation => 'Velocidad de Rotación';

  @override
  String get rotationMessage =>
      'Este valor determina la velocidad a la que rota el robot';

  @override
  String get correction => 'Factor de Balanceo';

  @override
  String get correctionMessage =>
      'Use este factor para alinear el movimiento del robot. Aumente el valor si el robot se desvia hacia la izquirda, y disminuyalo si se desvia a la derecha';

  @override
  String get reset => 'Restaurar Parametros';

  @override
  String get resetMessage => 'Restaurar a los valores predeterminados';

  @override
  String get deleteMessage => 'Eliminar el robot actual';

  @override
  String get delete => 'Eliminar Robot';

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get discoveringDevices => 'Buscar Dispositivos';

  @override
  String get discoveredDevices => 'Dispositivos Encontrados';

  @override
  String get joystick => 'Joystick';

  @override
  String get joystickSubtitle => 'Maneja el robot con el control remoto';

  @override
  String get lineFollower => 'Seguidor de línea';

  @override
  String get lineFollowerSubtitle =>
      'Lee los sensores y ajusta el PID y la velocidad';

  @override
  String get terminal => 'Terminal';

  @override
  String get terminalSubtitle => 'Lee y envía mensajes de telemetría';

  @override
  String get sensors => 'Sensores';

  @override
  String get sensorsWaiting => 'Esperando datos del robot';

  @override
  String get position => 'Posición de la línea';

  @override
  String get parameters => 'Parámetros';

  @override
  String get kpMessage =>
      'Ganancia proporcional: corrige según qué tan lejos está la línea del centro. Súbela si el robot reacciona lento en las curvas; bájala si oscila.';

  @override
  String get kiMessage =>
      'Ganancia integral: corrige errores que se acumulan con el tiempo. Normalmente se deja en 0 o muy baja.';

  @override
  String get kdMessage =>
      'Ganancia derivativa: frena los cambios bruscos y reduce la oscilación. Súbela si el robot zigzaguea.';

  @override
  String get baseSpeed => 'Velocidad base';

  @override
  String get baseSpeedMessage =>
      'Velocidad de los motores (PWM 0-255) cuando la línea está centrada.';

  @override
  String get readParams => 'Leer del robot';

  @override
  String get sendParams => 'Enviar al robot';

  @override
  String get paramsSent => 'Parámetros enviados';

  @override
  String get paramsReceived => 'Parámetros recibidos del robot';

  @override
  String get calibrate => 'Calibrar sensores';

  @override
  String get start => 'Iniciar';

  @override
  String get stop => 'Detener';

  @override
  String get notConnected => 'Robot no conectado';

  @override
  String get terminalEmpty => 'Aquí aparecen los mensajes del robot';

  @override
  String get terminalHint => 'Escribe un mensaje';

  @override
  String get showSensors => 'Mostrar datos de sensores';

  @override
  String get clear => 'Borrar';

  @override
  String get send => 'Enviar';
}
