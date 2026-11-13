import 'package:http/http.dart' as http;

import '../core/api.dart';
import '../modelos/animo.dart';
import '../modelos/pelicula.dart';

/// Cliente de la API de The Movie Database (TMDB).
class TmdbServicio {
  final http.Client _cliente;
  final String apiKey;

  TmdbServicio({http.Client? cliente, required this.apiKey})
      : _cliente = cliente ?? http.Client();

  /// Construye la URL según el estado de ánimo.
  Uri urlPara(Animo animo, {int pagina = 1}) {
    final genero = animo.generoId;
    if (genero == null) {
      return Uri.https('api.themoviedb.org', '/3/trending/movie/week', {
        'api_key': apiKey,
        'language': 'es-MX',
      });
    }
    return Uri.https('api.themoviedb.org', '/3/discover/movie', {
      'api_key': apiKey,
      'language': 'es-MX',
      'with_genres': '$genero',
      'sort_by': 'popularity.desc',
      'include_adult': 'false',
      'page': '$pagina',
    });
  }

  Future<List<Pelicula>> obtener(Animo animo) async {
    final respuesta = await peticionGet(
      _cliente,
      urlPara(animo),
      mensajes: const {
        401: 'La API key de TMDB no es válida. Revísala en tu cuenta de themoviedb.org.',
        429: 'Demasiadas consultas a TMDB. Espera un momento.',
      },
    );
    final json = decodificarJson(respuesta);
    if (json is! Map<String, dynamic>) {
      throw const ErrorApi('La respuesta del servidor no tiene el formato esperado.');
    }
    final resultados = (json['results'] as List<dynamic>?) ?? const [];
    return [
      for (final r in resultados) Pelicula.desdeJson(r as Map<String, dynamic>),
    ];
  }
}
