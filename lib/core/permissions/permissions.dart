import 'package:permission_handler/permission_handler.dart';

class KavidPermissions {
  /// Pide permiso de cámara. Si está permanentemente denegado, devuelve false.
  static Future<bool> ensureCamera() async {
    final status = await Permission.camera.status;

    if (status.isGranted) return true;

    final result = await Permission.camera.request();
    if (result.isGranted) return true;

    // Si está "permanentemente denegado", devolvemos false (para mostrar CTA a Ajustes)
    if (result.isPermanentlyDenied) return false;

    // Denegado normal
    return false;
  }

  /// Abre los ajustes de la app.
  static Future<void> openSettings() async {
    await openAppSettings();
  }
}
