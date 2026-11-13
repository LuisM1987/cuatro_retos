import 'dart:convert';

import 'package:cuatro_retos/core/api.dart';
import 'package:cuatro_retos/modelos/animo.dart';
import 'package:cuatro_retos/modelos/pelicula.dart';
import 'package:cuatro_retos/servicios/tmdb_servicio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

http.Response _json(Object cuerpo, [int estado = 200]) => http.Response.bytes(
      utf8.encode(jsonEncode(cuerpo)),
      estado,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );

void main() {
  group('Reto 1 · estado de ánimo → género', () {
    test('cada estado de ánimo se traduce a su género de TMDB', () {
      expect(Animo.feliz.generoId, 35);
      expect(Animo.triste.generoId, 18);
      expect(Animo.emocionado.generoId, 28);
      expect(Animo.romantico.generoId, 10749);
      expect(Animo.asustado.generoId, 27);
      expect(Animo.relajado.generoId, 16);
      expect(Animo.curioso.generoId, 99);
    });

    test('las tendencias no filtran por género', () {
      expect(Animo.tendencias.generoId, isNull);
    });
  });

  group('Reto 1 · URLs de TMDB', () {
    final servicio = TmdbServicio(apiKey: 'CLAVE');

    test('un estado de ánimo usa discover con su género, idioma y clave', () {
      final url = servicio.urlPara(Animo.feliz);
      expect(url.host, 'api.themoviedb.org');
      expect(url.path, '/3/discover/movie');
      expect(url.queryParameters['with_genres'], '35');
      expect(url.queryParameters['api_key'], 'CLAVE');
      expect(url.queryParameters['language'], 'es-MX');
    });

    test('las tendencias usan el endpoint trending', () {
      final url = servicio.urlPara(Animo.tendencias);
      expect(url.path, '/3/trending/movie/week');
      expect(url.queryParameters.containsKey('with_genres'), false);
    });
  });

  group('Reto 1 · modelo Pelicula', () {
    test('arma la URL del póster y el año', () {
      final p = Pelicula.desdeJson({
        'id': 1,
        'title': 'Coco',
        'overview': 'Una historia de familia.',
        'poster_path': '/abc.jpg',
        'vote_average': 8.2,
        'release_date': '2017-10-27',
      });
      expect(p.urlPoster, 'https://image.tmdb.org/t/p/w500/abc.jpg');
      expect(p.anio, '2017');
      expect(p.calificacion, 8.2);
    });

    test('sin póster, sin fecha y sin título no truena', () {
      final p = Pelicula.desdeJson({'id': 2, 'poster_path': null});
      expect(p.urlPoster, isNull);
      expect(p.anio, 's/f');
      expect(p.titulo, 'Sin título');
      expect(p.sinopsis, '');
    });
  });

  group('Reto 1 · servicio (con respuestas simuladas, sin internet)', () {
    test('convierte el JSON en películas y conserva los acentos', () async {
      late Uri pedida;
      final cliente = MockClient((peticion) async {
        pedida = peticion.url;
        return _json({
          'results': [
            {'id': 1, 'title': 'Película uno', 'overview': 'Acción y aventura', 'vote_average': 7.5},
            {'id': 2, 'title': 'Película dos', 'overview': '', 'vote_average': 6},
          ],
        });
      });
      final servicio = TmdbServicio(cliente: cliente, apiKey: 'CLAVE');

      final lista = await servicio.obtener(Animo.emocionado);

      expect(lista.length, 2);
      expect(lista.first.titulo, 'Película uno');
      expect(lista.first.sinopsis, 'Acción y aventura');
      expect(pedida.queryParameters['with_genres'], '28');
    });

    test('un 401 se traduce a un mensaje amable sobre la API key', () async {
      final cliente = MockClient((_) async => _json({'status_message': 'Invalid API key'}, 401));
      final servicio = TmdbServicio(cliente: cliente, apiKey: 'MALA');
      await expectLater(
        servicio.obtener(Animo.feliz),
        throwsA(isA<ErrorApi>().having((e) => e.mensaje, 'mensaje', contains('API key'))),
      );
    });

    test('si no hay internet se muestra un mensaje de conexión', () async {
      final cliente = MockClient((_) async => throw Exception('sin red'));
      final servicio = TmdbServicio(cliente: cliente, apiKey: 'CLAVE');
      await expectLater(
        servicio.obtener(Animo.feliz),
        throwsA(isA<ErrorApi>().having((e) => e.mensaje, 'mensaje', contains('conexión'))),
      );
    });
  });
}
