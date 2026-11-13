import 'dart:convert';

import 'package:http/http.dart' as http;

/// Error con mensaje listo para mostrarse al usuario (sin detalles técnicos).
class ErrorApi implements Exception {
  final String mensaje;
  const ErrorApi(this.mensaje);

  @override
  String toString() => mensaje;
}

/// Convierte cualquier error en un texto seguro para la pantalla.
String mensajeParaUsuario(Object error) =>
    error is ErrorApi ? error.mensaje : 'Ocurrió un error inesperado. Intenta de nuevo.';

/// GET con tiempo límite. Traduce los fallos de red y los códigos HTTP a [ErrorApi].
/// [mensajes] permite poner un texto propio para ciertos códigos (401, 404, 429...).
Future<http.Response> peticionGet(
  http.Client cliente,
  Uri url, {
  Map<int, String> mensajes = const {},
}) async {
  http.Response respuesta;
  try {
    respuesta = await cliente.get(url).timeout(const Duration(seconds: 15));
  } catch (_) {
    throw const ErrorApi('No hay conexión con el servidor. Revisa tu internet e inténtalo de nuevo.');
  }
  if (respuesta.statusCode == 200) return respuesta;
  throw ErrorApi(
    mensajes[respuesta.statusCode] ??
        'El servidor respondió con un error (${respuesta.statusCode}).',
  );
}

/// Decodifica el JSON como UTF-8 (evita que los acentos salgan mal).
dynamic decodificarJson(http.Response respuesta) {
  try {
    return jsonDecode(utf8.decode(respuesta.bodyBytes));
  } catch (_) {
    throw const ErrorApi('La respuesta del servidor no tiene el formato esperado.');
  }
}
