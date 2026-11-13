class Pelicula {
  final int id;
  final String titulo;
  final String sinopsis;
  final String? rutaPoster;
  final double calificacion;
  final String? fecha;

  const Pelicula({
    required this.id,
    required this.titulo,
    required this.sinopsis,
    required this.rutaPoster,
    required this.calificacion,
    required this.fecha,
  });

  factory Pelicula.desdeJson(Map<String, dynamic> j) => Pelicula(
        id: (j['id'] as num).toInt(),
        titulo: (j['title'] as String?) ?? 'Sin título',
        sinopsis: (j['overview'] as String?) ?? '',
        rutaPoster: j['poster_path'] as String?,
        calificacion: (j['vote_average'] as num?)?.toDouble() ?? 0,
        fecha: j['release_date'] as String?,
      );

  /// Los pósters de TMDB se piden con una ruta base + el tamaño (w500).
  String? get urlPoster =>
      rutaPoster == null ? null : 'https://image.tmdb.org/t/p/w500$rutaPoster';

  String get anio => (fecha != null && fecha!.length >= 4) ? fecha!.substring(0, 4) : 's/f';
}
