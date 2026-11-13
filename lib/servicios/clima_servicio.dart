import 'package:http/http.dart' as http;

import '../core/api.dart';
import '../modelos/clima.dart';

/// Cliente de OpenWeatherMap (clima actual).
class ClimaServicio {
  final http.Client _cliente;
  final String apiKey;

  ClimaServicio({http.Client? cliente, required this.apiKey})
      : _cliente = cliente ?? http.Client();

  Uri urlPorCiudad(String ciudad) => Uri.https('api.openweathermap.org', '/data/2.5/weather', {
        'q': ciudad,
        'appid': apiKey,
        'units': 'metric',
        'lang': 'es',
      });

  Uri urlPorCoordenadas(double lat, double lon) =>
      Uri.https('api.openweathermap.org', '/data/2.5/weather', {
        'lat': '$lat',
        'lon': '$lon',
        'appid': apiKey,
        'units': 'metric',
        'lang': 'es',
      });

  Future<Clima> obtener(Uri url) async {
    final respuesta = await peticionGet(
      _cliente,
      url,
      mensajes: const {
        401: 'La API key no es válida o todavía no está activa (puede tardar un par de horas).',
        404: 'No encontré esa ciudad. Prueba con el formato "Ciudad,MX".',
        429: 'Demasiadas consultas. Espera un minuto.',
      },
    );
    final json = decodificarJson(respuesta);
    try {
      return Clima.desdeJson(json as Map<String, dynamic>);
    } catch (_) {
      throw const ErrorApi('La respuesta del servidor no tiene el formato esperado.');
    }
  }

  Future<Clima> porCiudad(String ciudad) => obtener(urlPorCiudad(ciudad.trim()));

  Future<Clima> porCoordenadas(double lat, double lon) =>
      obtener(urlPorCoordenadas(lat, lon));
}
