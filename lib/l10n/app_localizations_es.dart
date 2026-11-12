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
  String get lineColor => 'Color de la línea';

  @override
  String get blackLine => 'Negra';

  @override
  String get whiteLine => 'Blanca';

  @override
  String get lineColorMessage =>
      'Negra: línea negra sobre fondo blanco. Blanca: línea blanca sobre fondo negro. El robot cambia al instante.';

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
  String get finishCalibration => 'Terminar calibración';

  @override
  String get calibrationHint =>
      'Pasa todos los sensores sobre la línea y sobre el fondo. El recuadro de cada barra es lo que ya vio ese sensor; su nombre se pone verde cuando tiene suficiente contraste. Toca de nuevo para terminar.';

  @override
  String get calibrationDone => 'Calibración lista';

  @override
  String calibrationNoContrast(String sensors) {
    return 'Calibración lista. Sin contraste (quedan como estaban): $sensors';
  }

  @override
  String get threshold => 'Umbral';

  @override
  String get thresholdMessage =>
      'Arrastra la raya naranja sobre las barras o mueve el control. La zona verde es lo que cuenta como línea y los sensores que la ven se ponen verdes. Más alto = más sensible: súbelo si el robot pierde la línea entre dos sensores; bájalo si confunde el fondo con la línea. Se envía al robot al soltar. Calibra primero.';

  @override
  String get scale => 'Escala';

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

  @override
  String get liveSpeed => 'Velocidad';

  @override
  String get liveSpeedMessage => 'Velocidad de los motores (PWM 0-255) con la línea centrada. Se aplica al soltar el control, también con el robot en marcha. Empieza lento, ajusta el PID y luego súbela.';

  @override
  String get running => 'En marcha';

  @override
  String get stopped => 'Detenido';

  @override
  String get autoCalibrate => 'Auto-calibrar';

  @override
  String get autoCalibrationHint => 'Auto: pon la línea bajo el centro del robot; girará solo a cada lado y terminará solo. Manual: pasa el robot sobre la línea a mano y toca de nuevo para terminar.';

  @override
  String get storedCalibration => 'Calibración guardada en el robot';

  @override
  String get storedCalibrationMessage => 'Cada barra es el rango entre el negro y el blanco que vio el sensor (valor sin calibrar 0-255); el número es el contraste. El robot la conserva al apagarse.';

  @override
  String get calibrationWaiting => 'Esperando la calibración del robot';

  @override
  String get notCalibrated => 'El robot no está calibrado. Calibra antes de arrancar.';

  @override
  String get calibrationOk => 'Todos los sensores tienen suficiente contraste';

  @override
  String calibrationWeak(String sensors) {
    return 'Poco contraste en $sensors: vuelve a calibrar pasándolos sobre la línea y el fondo';
  }

  @override
  String get positionHistory => 'Posición en el tiempo';

  @override
  String averageError(String value) {
    return 'Error medio: $value';
  }

  @override
  String get pidGuideTitle => 'Cómo calibrar el PID';

  @override
  String get pidGuide => '1. Calibra los sensores y revisa que todos tengan contraste.
2. Velocidad baja (unos 80-100), Ki = 0 y Kd = 0.
3. Sube Kp hasta que el robot siga la línea pero zigzaguee (la gráfica cruza el centro de lado a lado). Luego bájalo un poco.
4. Sube Kd hasta que desaparezca el zigzag. Si el robot tiembla o vibra, Kd está muy alto.
5. Sube la velocidad de 10 en 10 o de 20 en 20 y repite 3 y 4. A más velocidad suele necesitar más Kd.
6. Ki casi nunca hace falta: úsalo, muy bajo (0.0001), solo si en las rectas el robot va siempre corrido a un lado.
Compara ajustes en el mismo tramo de pista: cuanto menor el error medio, más centrado va el robot.';
}
