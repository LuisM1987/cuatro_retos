/// Filtros que acepta Cataas (parámetro ?filter=...).
const filtrosGato = ['ninguno', 'mono', 'sepia', 'negate', 'blur', 'pixel'];

/// Construye la URL de Cataas (Cats as a Service).
///
///   sin texto : https://cataas.com/cat
///   con texto : https://cataas.com/cat/says/Hola%20mundo?fontSize=40&fontColor=white
///
/// El texto va en el PATH de la URL, así que se codifica (espacios, acentos, signos).
/// [semilla] solo cambia la URL para que se pida otro gato al azar.
Uri construirUrlGato({
  String texto = '',
  String filtro = 'ninguno',
  int tamanoFuente = 40,
  String colorTexto = 'white',
  int semilla = 0,
}) {
  final limpio = texto.trim();
  final hayTexto = limpio.isNotEmpty;
  return Uri(
    scheme: 'https',
    host: 'cataas.com',
    pathSegments: hayTexto ? ['cat', 'says', limpio] : ['cat'],
    queryParameters: {
      if (hayTexto) 'fontSize': '$tamanoFuente',
      if (hayTexto) 'fontColor': colorTexto,
      if (filtro != 'ninguno') 'filter': filtro,
      't': '$semilla',
    },
  );
}
