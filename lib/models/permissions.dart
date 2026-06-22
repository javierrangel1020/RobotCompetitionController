import 'package:permission_handler/permission_handler.dart';

/// Solicita los permisos de Bluetooth necesarios para conectarse al robot.
///
/// En Android 12+ (API 31) se requieren BLUETOOTH_CONNECT y BLUETOOTH_SCAN
/// en tiempo de ejecucion. En Android 11 y anteriores basta con los permisos
/// declarados en el manifest (BLUETOOTH/BLUETOOTH_ADMIN) y, para descubrir
/// dispositivos, la ubicacion. permission_handler ignora los permisos que no
/// apliquen a la version del dispositivo, asi que es seguro pedirlos todos.
Future<bool> requestBluetoothPermissions() async {
  final statuses = await [
    Permission.bluetoothConnect,
    Permission.bluetoothScan,
    Permission.locationWhenInUse,
  ].request();

  // Consideramos OK si al menos bluetoothConnect quedo concedido (es el unico
  // imprescindible para conectarse a un dispositivo ya emparejado).
  final connect = statuses[Permission.bluetoothConnect];
  return connect == null || connect.isGranted || connect.isLimited;
}
