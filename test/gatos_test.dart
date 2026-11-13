import 'package:cuatro_retos/servicios/cataas.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Reto 2 · construirUrlGato', () {
    test('sin texto pide un gato al azar', () {
      final url = construirUrlGato();
      expect(url.host, 'cataas.com');
      expect(url.pathSegments, ['cat']);
      expect(url.queryParameters.containsKey('fontSize'), false);
    });

    test('con texto lo pone en la ruta /cat/says/<texto>', () {
      final url = construirUrlGato(texto: 'Hola mundo');
      expect(url.pathSegments, ['cat', 'says', 'Hola mundo']);
      expect(url.toString(), contains('/cat/says/Hola%20mundo'));
      expect(url.queryParameters['fontSize'], '40');
      expect(url.queryParameters['fontColor'], 'white');
    });

    test('codifica acentos y signos del español', () {
      final url = construirUrlGato(texto: '¡Feliz lunes!');
      expect(url.pathSegments[2], '¡Feliz lunes!');
      expect(url.toString(), contains('%C2%A1Feliz%20lunes!'));
    });

    test('una diagonal en el texto no rompe la ruta', () {
      final url = construirUrlGato(texto: 'a/b');
      expect(url.pathSegments.length, 3);
      expect(url.toString(), contains('a%2Fb'));
    });

    test('un texto de solo espacios cuenta como sin texto', () {
      expect(construirUrlGato(texto: '   ').pathSegments, ['cat']);
    });

    test('el filtro se agrega como parámetro; "ninguno" no agrega nada', () {
      expect(construirUrlGato(filtro: 'mono').queryParameters['filter'], 'mono');
      expect(construirUrlGato(filtro: 'ninguno').queryParameters.containsKey('filter'), false);
    });

    test('la semilla cambia la URL para pedir otro gato', () {
      final a = construirUrlGato(texto: 'Hola', semilla: 1).toString();
      final b = construirUrlGato(texto: 'Hola', semilla: 2).toString();
      expect(a, isNot(b));
    });

    test('todos los filtros del menú son válidos para la URL', () {
      for (final f in filtrosGato) {
        expect(() => construirUrlGato(texto: 'x', filtro: f), returnsNormally);
      }
      expect(filtrosGato.first, 'ninguno');
    });
  });
}
