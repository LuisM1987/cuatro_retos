class Claves {
  static const String tmdb =
      String.fromEnvironment('TMDB_KEY', defaultValue: '');
  static const String openWeather =
      String.fromEnvironment('OWM_KEY', defaultValue: '');

  static bool get hayTmdb => tmdb.trim().isNotEmpty;
  static bool get hayOpenWeather => openWeather.trim().isNotEmpty;
}
