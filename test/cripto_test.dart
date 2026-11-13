import 'dart:convert';

import 'package:cuatro_retos/core/api.dart';
import 'package:cuatro_retos/modelos/cripto.dart';
import 'package:cuatro_retos/servicios/coingecko_servicio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

http.Response _json(Object cuerpo, [int estado = 200]) => http.Response.bytes(
      utf8.encode(jsonEncode(cuerpo)),
      estado,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );

const _respuesta = {
  'bitcoin': {'usd': 65000, 'usd_24h_change': 1.5},
  'ethereum': {'usd': 3200.5, 'usd_24h_change': -0.8},
  'solana': {'usd': 150},
};

void main() {
  group('Reto 4 · interpretarMonto', () {
    test('acepta números normales, con signo de pesos, comas y espacios', () {
      expect(interpretarMonto('100'), 100);
      expect(interpretarMonto('\$1,250.50'), 1250.5);
      expect(interpretarMonto('  20  '), 20);
    });

    test('rechaza vacío, texto, cero y negativos', () {
      expect(interpretarMonto(''), isNull);
      expect(interpretarMonto('abc'), isNull);
      expect(interpretarMonto('0'), isNull);
      expect(interpretarMonto('-5'), isNull);
      expect(interpretarMonto('1.2.3'), isNull);
    });
  });

  group('Reto 4 · cálculos y formato', () {
    test('fraccionesComprables: 100 USD de un activo a 50 000 USD', () {
      expect(fraccionesComprables(100, 50000), closeTo(0.002, 1e-12));
    });

    test('con precio 0 no divide entre cero', () {
      expect(fraccionesComprables(100, 0), isNull);
    });

    test('100 USD en Bitcoin a 65 000 USD se muestran con 8 decimales', () {
      final f = fraccionesComprables(100, 65000)!;
      expect(f.toStringAsFixed(8), '0.00153846');
    });

    test('formatearUsd agrega comas y dos decimales', () {
      expect(formatearUsd(0), '\$0.00');
      expect(formatearUsd(65000), '\$65,000.00');
      expect(formatearUsd(1234567.891), '\$1,234,567.89');
    });
  });

  group('Reto 4 · parsearPrecios', () {
    test('lee Bitcoin, Ethereum y Solana', () {
      final lista = parsearPrecios(Map<String, dynamic>.from(_respuesta));
      expect(lista.map((p) => p.moneda.simbolo), ['BTC', 'ETH', 'SOL']);
      expect(lista.first.usd, 65000);
      expect(lista.first.cambio24h, 1.5);
      expect(lista.last.cambio24h, isNull); // Solana no trae cambio en 24 h
    });

    test('ignora monedas faltantes o con datos raros', () {
      final lista = parsearPrecios({
        'bitcoin': {'usd': 1},
        'ethereum': 'basura',
      });
      expect(lista.length, 1);
    });
  });

  group('Reto 4 · servicio (sin internet)', () {
    test('pide los tres ids en dólares', () async {
      late Uri pedida;
      final servicio = CoingeckoServicio(cliente: MockClient((p) async {
        pedida = p.url;
        return _json(_respuesta);
      }));

      final lista = await servicio.obtener();

      expect(pedida.path, '/api/v3/simple/price');
      expect(pedida.queryParameters['ids'], 'bitcoin,ethereum,solana');
      expect(pedida.queryParameters['vs_currencies'], 'usd');
      expect(lista.length, 3);
    });

    test('un 429 explica el límite de consultas', () async {
      final servicio = CoingeckoServicio(cliente: MockClient((_) async => _json({}, 429)));
      await expectLater(
        servicio.obtener(),
        throwsA(isA<ErrorApi>().having((e) => e.mensaje, 'mensaje', contains('limita'))),
      );
    });

    test('una respuesta vacía no se muestra como si fuera válida', () async {
      final servicio = CoingeckoServicio(cliente: MockClient((_) async => _json(<String, dynamic>{})));
      await expectLater(servicio.obtener(), throwsA(isA<ErrorApi>()));
    });
  });
}
