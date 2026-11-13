String capitalizar(String texto) =>
    texto.isEmpty ? texto : texto[0].toUpperCase() + texto.substring(1);

class Clima {
  final String ciudad;
  final String pais;
  final double temperatura; // °C
  final double sensacion; // °C
  final int humedad; // %
  final double vientoKmh;
  final String descripcion;
  final String icono;

  const Clima({
    required this.ciudad,
    required this.pais,
    required this.temperatura,
    required this.sensacion,
    required this.humedad,
    required this.vientoKmh,
    required this.descripcion,
    required this.icono,
  });

  /// Lee la respuesta de /data/2.5/weather de OpenWeatherMap.
  factory Clima.desdeJson(Map<String, dynamic> j) {
    final main = j['main'] as Map<String, dynamic>;
    final viento = (j['wind'] as Map<String, dynamic>?) ?? const {};
    final sys = (j['sys'] as Map<String, dynamic>?) ?? const {};
    final lista = j['weather'] as List<dynamic>;
    final cielo = lista.first as Map<String, dynamic>;
    final ms = (viento['speed'] as num?)?.toDouble() ?? 0;
    return Clima(
      ciudad: (j['name'] as String?) ?? 'Ubicación desconocida',
      pais: (sys['country'] as String?) ?? '',
      temperatura: (main['temp'] as num).toDouble(),
      sensacion: (main['feels_like'] as num).toDouble(),
      humedad: (main['humidity'] as num).toInt(),
      vientoKmh: ms * 3.6, // la API da metros/segundo
      descripcion: capitalizar((cielo['description'] as String?) ?? ''),
      icono: (cielo['icon'] as String?) ?? '01d',
    );
  }

  String get urlIcono => 'https://openweathermap.org/img/wn/$icono@4x.png';
}
