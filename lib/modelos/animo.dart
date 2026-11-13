/// Estado de ánimo del usuario. Cada uno se traduce a un género de TMDB.
enum Animo { tendencias, feliz, triste, emocionado, romantico, asustado, relajado, curioso }

extension DatosAnimo on Animo {
  String get etiqueta => switch (this) {
        Animo.tendencias => 'Tendencias',
        Animo.feliz => 'Feliz',
        Animo.triste => 'Triste',
        Animo.emocionado => 'Emocionado',
        Animo.romantico => 'Romántico',
        Animo.asustado => 'Con ganas de miedo',
        Animo.relajado => 'Relajado',
        Animo.curioso => 'Curioso',
      };

  String get emoji => switch (this) {
        Animo.tendencias => '🔥',
        Animo.feliz => '😄',
        Animo.triste => '😢',
        Animo.emocionado => '🤩',
        Animo.romantico => '😍',
        Animo.asustado => '😱',
        Animo.relajado => '😌',
        Animo.curioso => '🧐',
      };

  /// Id del género en TMDB. `null` = no filtra por género (usa las tendencias).
  int? get generoId => switch (this) {
        Animo.tendencias => null,
        Animo.feliz => 35, // Comedia
        Animo.triste => 18, // Drama
        Animo.emocionado => 28, // Acción
        Animo.romantico => 10749, // Romance
        Animo.asustado => 27, // Terror
        Animo.relajado => 16, // Animación
        Animo.curioso => 99, // Documental
      };
}
