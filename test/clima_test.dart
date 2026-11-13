import 'dart:convert';

import 'package:cuatro_retos/core/api.dart';
import 'package:cuatro_retos/modelos/clima.dart';
import 'package:cuatro_retos/servicios/clima_servicio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

http.Response _json(Object cuerpo, [int estado = 200]) => http.Response.bytes(
      utf8.encode(jsonEncode(cuerpo)),
      estado,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );

const _ejemplo = {
  'name': 'Dolores Hidalgo',
  'sys': {'country': 'MX'},
  'main': {'temp': 24.6, 'feels_like': 25.1, 'humidity': 40},
  'wind': {'speed': 5},
  'weather': [
    {'description': 'cielo claro', 'icon': '01d'},
  ],
};

void main() {
  group('Reto 3 · modelo Clima', () {
    test('lee la respuesta de OpenWeatherMap', () {
      final c = Clima.desdeJson(Map<String, dynamic>.from(_ejemplo));
      expect(c.ciudad, 'Dolores Hidalgo');
      expect(c.pais, 'MX');
      expect(c.temperatura, 24.6);
      expect(c.sensacion, 25.1);
      expect(c.humedad, 40);
      expect(c.descripcion, 'Cielo claro');
      expect(c.urlIcono, 'https://openweathermap.org/img/wn/01d@4x.png');
    });

    test('convierte el viento de m/s a km/h', () {
      final c = Clima.desdeJson(Map<String, dynamic>.from(_ejemplo));
      expect(c.vientoKmh, closeTo(18, 1e-9)); // 5 m/s × 3.6
    });

    test('si faltan viento y país no truena', () {
      final c = Clima.desdeJson({
        'name': 'Algún lugar',
        'main': {'temp': 10, 'feels_like': 9, 'humidity': 80},
        'weather': [
          {'description': 'niebla', 'icon': '50d'},
        ],
      });
      expect(c.vientoKmh, 0);
      expect(c.pais, '');
    });

    test('capitalizar', () {
      expect(capitalizar('nubes dispersas'), 'Nubes dispersas');
      expect(capitalizar(''), '');
    });
  });

  group('Reto 3 · URLs y servicio (sin internet)', () {
    test('la URL por ciudad lleva unidades métricas, español y la clave', () {
      final url = ClimaServicio(apiKey: 'CLAVE').urlPorCiudad('Guanajuato,MX');
      expect(url.host, 'api.openweathermap.org');
      expect(url.path, '/data/2.5/weather');
      expect(url.queryParameters['q'], 'Guanajuato,MX');
      expect(url.queryParameters['units'], 'metric');
      expect(url.queryParameters['lang'], 'es');
      expect(url.queryParameters['appid'], 'CLAVE');
    });

    test('la URL por coordenadas usa lat y lon', () {
      final url = ClimaServicio(apiKey: 'K').urlPorCoordenadas(21.15, -100.93);
      expect(url.queryParameters['lat'], '21.15');
      expect(url.queryParameters['lon'], '-100.93');
    });

    test('devuelve el clima de una respuesta correcta', () async {
      final servicio = ClimaServicio(
        cliente: MockClient((_) async => _json(_ejemplo)),
        apiKey: 'K',
      );
      final c = await servicio.porCiudad('Dolores Hidalgo,MX');
      expect(c.temperatura, 24.6);
    });

    test('un 404 dice que no encontró la ciudad', () async {
      final servicio = ClimaServicio(
        cliente: MockClient((_) async => _json({'message': 'city not found'}, 404)),
        apiKey: 'K',
      );
      await expectLater(
        servicio.porCiudad('xyzzy'),
        throwsA(isA<ErrorApi>().having((e) => e.mensaje, 'mensaje', contains('ciudad'))),
      );
    });

    test('un 401 habla de la API key', () async {
      final servicio = ClimaServicio(
        cliente: MockClient((_) async => _json({'message': 'Invalid API key'}, 401)),
        apiKey: 'MALA',
      );
      await expectLater(
        servicio.porCiudad('Dolores Hidalgo,MX'),
        throwsA(isA<ErrorApi>().having((e) => e.mensaje, 'mensaje', contains('API key'))),
      );
    });

    test('una respuesta con formato raro se traduce a un error amable', () async {
      final servicio = ClimaServicio(
        cliente: MockClient((_) async => _json(<String, dynamic>{})),
        apiKey: 'K',
      );
      await expectLater(
        servicio.porCiudad('x'),
        throwsA(isA<ErrorApi>().having((e) => e.mensaje, 'mensaje', contains('formato'))),
      );
    });
  });
}
