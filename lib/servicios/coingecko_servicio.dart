import 'package:http/http.dart' as http;

import '../core/api.dart';
import '../modelos/cripto.dart';

/// Cliente de la API pública de CoinGecko (no necesita clave).
class CoingeckoServicio {
  final http.Client _cliente;

  CoingeckoServicio({http.Client? cliente}) : _cliente = cliente ?? http.Client();

  Uri get url => Uri.https('api.coingecko.com', '/api/v3/simple/price', {
        'ids': monedasSoportadas.map((m) => m.id).join(','),
        'vs_currencies': 'usd',
        'include_24hr_change': 'true',
      });

  Future<List<PrecioCripto>> obtener() async {
    final respuesta = await peticionGet(
      _cliente,
      url,
      mensajes: const {
        429: 'CoinGecko limita las consultas gratuitas. Espera un minuto y actualiza.',
      },
    );
    final json = decodificarJson(respuesta);
    if (json is! Map<String, dynamic>) {
      throw const ErrorApi('La respuesta del servidor no tiene el formato esperado.');
    }
    final precios = parsearPrecios(json);
    if (precios.isEmpty) {
      throw const ErrorApi('CoinGecko no devolvió precios. Intenta de nuevo.');
    }
    return precios;
  }
}
