# Robot Competition Controller (app ROBLEX)

App Flutter para controlar los robots ROBLEX por Bluetooth (BLE, Nordic UART Service). Tiene tres secciones:

- **Joystick**: maneja el robot con el control remoto.
- **Seguidor de línea**: muestra los 8 sensores, calibra los sensores (manual o automática), revisa la calibración guardada en el robot, ajusta la velocidad en vivo y el PID con una gráfica de la posición de la línea, y arranca o detiene el robot.
- **Terminal**: envía y recibe mensajes de texto.

El firmware del seguidor de línea es el ejemplo `examples/ejemplos_robot/sensor_de_linea` de la librería ROBLEX (rama `feat/pid-velocidad-calibracion`), que tiene su propia guía de instalación y la descripción del protocolo.

## Contenido

1. [Requisitos](#requisitos)
2. [Preparar el proyecto](#preparar-el-proyecto)
3. [Instalar en un teléfono Android](#instalar-en-un-teléfono-android)
4. [Instalar en un iPhone](#instalar-en-un-iphone)
5. [Usar el seguidor de línea](#usar-el-seguidor-de-línea)
6. [Pruebas y análisis](#pruebas-y-análisis)
7. [Textos y traducciones](#textos-y-traducciones)

## Requisitos

- [Flutter](https://docs.flutter.dev/get-started/install), canal stable. El proyecto se analiza y prueba con Flutter 3.50.0 (Dart 3.14).
- Para Android: [Android Studio](https://developer.android.com/studio) con el Android SDK (API 36) y JDK 17, que Android Studio incluye. Teléfono con Android 7.0 (API 24) o superior y Bluetooth LE.
- Para iPhone: un Mac con Xcode y CocoaPods, y una cuenta de desarrollador de Apple para instalar en un dispositivo.
- `flutter doctor` debe mostrar en verde la plataforma que vayas a usar.

## Preparar el proyecto

```bash
git clone -b feat/pid-velocidad-calibracion <URL del repositorio RobotCompetitionController>
```

```bash
cd RobotCompetitionController
```

```bash
flutter pub get
```

`flutter pub get` también genera los archivos de traducción de `lib/l10n/`.

## Instalar en un teléfono Android

**Durante el desarrollo (cable USB):**

1. En el teléfono, activa las **Opciones de desarrollador** (tocar 7 veces **Número de compilación** en **Ajustes > Acerca del teléfono**) y dentro de ellas la **Depuración por USB**.
2. Conecta el teléfono y acepta el aviso de depuración.
3. Comprueba que aparece con `flutter devices` y ejecuta:

   ```bash
   flutter run --release
   ```

**Como APK para instalar en varios teléfonos:**

1. Compila el APK:

   ```bash
   flutter build apk --release
   ```

2. El archivo queda en `build/app/outputs/flutter-apk/app-release.apk`. Cópialo al teléfono (cable, correo, Drive) y ábrelo; Android pedirá permitir la instalación desde esa fuente. Con el teléfono conectado por USB también sirve `flutter install`.

Sin el archivo `android/key.properties` el APK se firma con la clave de depuración: sirve para probar y repartir dentro del equipo, pero no para publicar en Play Store. Para publicar, crea una clave de subida siguiendo la [guía de Flutter para Android](https://docs.flutter.dev/deployment/android#sign-the-app) y describe su ubicación en `android/key.properties` (`storePassword`, `keyPassword`, `keyAlias`, `storeFile`). Ese archivo y la clave no se suben al repositorio.

Al abrir la app por primera vez, acepta los permisos de **Dispositivos cercanos** (Bluetooth). En Android 11 o anterior también pide **Ubicación**, que el sistema exige para buscar dispositivos Bluetooth.

## Instalar en un iPhone

1. En el Mac, abre `ios/Runner.xcworkspace` en Xcode, elige tu equipo en **Signing & Capabilities** y un identificador de paquete propio si hace falta.
2. Conecta el iPhone y ejecuta `flutter run --release`. La primera vez Flutter crea el `Podfile` e instala los pods con CocoaPods.

## Usar el seguidor de línea

1. Carga en el robot el programa `sensor_de_linea` y enciéndelo.
2. En la app, toca el indicador de conexión de arriba a la derecha (o **Configuración**), luego **Dispositivo > Seleccionar** y elige el robot (por defecto se llama **ROBLEX linea**).
3. Abre **Seguidor de línea**. Al conectar, la app pide al robot sus sensores, su PID, su velocidad, su umbral, su color de línea y su calibración guardada.
4. **Calibrar sensores**: pon la línea bajo el centro del robot y toca **Auto-calibrar**, o usa **Calibrar sensores** y pasa el robot a mano. La tarjeta **Calibración guardada en el robot** muestra cada sensor en verde (con contraste) o en rojo (hay que recalibrarlo).
5. Elige el **color de la línea** y ajusta el **umbral** arrastrando la raya naranja sobre las barras.
6. **Velocidad**: el control deslizante se envía al robot al soltarlo, también con el robot en marcha.
7. **Parámetros**: cambia Kp, Ki y Kd con los botones o tocando el número, y pulsa **Enviar al robot**. La gráfica **Posición en el tiempo** y el **error medio** muestran si el robot oscila o va centrado; la guía **Cómo calibrar el PID** explica el orden de ajuste.
8. **Iniciar** y **Detener** están siempre abajo, junto al estado **En marcha** / **Detenido** que informa el robot.

El robot guarda en su memoria la calibración, el PID, la velocidad, el umbral y el color de línea, así que los conserva al apagarse.

## Pruebas y análisis

```bash
flutter analyze
```

```bash
flutter test
```

`test/line_protocol_test.dart` prueba el protocolo de texto con el robot y `test/line_tuning_widgets_test.dart` dibuja la gráfica de posición y la tarjeta de calibración en una pantalla angosta.

## Textos y traducciones

Todo texto visible está en `lib/l10n/app_en.arb` (plantilla) y `lib/l10n/app_es.arb`. Después de editarlos, `flutter pub get` o `flutter gen-l10n` regeneran `lib/l10n/app_localizations*.dart`; esos archivos no se editan a mano.
