import 'package:geolocator/geolocator.dart';

import '../core/api.dart';

/// "Plus" del Reto 3: detecta la ubicación del dispositivo con geolocator.
class UbicacionServicio {
  Future<Position> actual() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw const ErrorApi('El GPS está apagado. Actívalo o escribe tu ciudad.');
      }
      var permiso = await Geolocator.checkPermission();
      if (permiso == LocationPermission.denied) {
        permiso = await Geolocator.requestPermission();
      }
      if (permiso == LocationPermission.denied ||
          permiso == LocationPermission.deniedForever) {
        throw const ErrorApi('Necesito el permiso de ubicación. También puedes escribir tu ciudad.');
      }
      return await Geolocator.getCurrentPosition().timeout(const Duration(seconds: 20));
    } on ErrorApi {
      rethrow;
    } catch (_) {
      throw const ErrorApi('No pude obtener tu ubicación. Escribe tu ciudad.');
    }
  }
}
