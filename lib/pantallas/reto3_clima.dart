import 'package:flutter/material.dart';

import '../config/claves.dart';
import '../core/api.dart';
import '../modelos/clima.dart';
import '../servicios/clima_servicio.dart';
import '../servicios/ubicacion_servicio.dart';
import '../widgets/aviso_clave.dart';
import '../widgets/mensaje_error.dart';

/// Reto 3: App del clima minimalista (OpenWeatherMap + geolocator opcional).
class Reto3Clima extends StatefulWidget {
  const Reto3Clima({super.key});

  @override
  State<Reto3Clima> createState() => _Reto3ClimaState();
}

class _Reto3ClimaState extends State<Reto3Clima> {
  final _servicio = ClimaServicio(apiKey: Claves.openWeather);
  final _ubicacion = UbicacionServicio();
  final _ciudad = TextEditingController(text: 'Dolores Hidalgo,MX');

  Clima? _clima;
  bool _cargando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (Claves.hayOpenWeather) _buscarCiudad();
  }

  @override
  void dispose() {
    _ciudad.dispose();
    super.dispose();
  }

  Future<void> _ejecutar(Future<Clima> Function() consulta) async {
    FocusScope.of(context).unfocus();
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final clima = await consulta();
      if (!mounted) return;
      setState(() {
        _clima = clima;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = mensajeParaUsuario(e);
        _cargando = false;
      });
    }
  }

  Future<void> _buscarCiudad() {
    final texto = _ciudad.text.trim();
    if (texto.isEmpty) {
      setState(() => _error = 'Escribe el nombre de una ciudad.');
      return Future.value();
    }
    return _ejecutar(() => _servicio.porCiudad(texto));
  }

  Future<void> _usarMiUbicacion() => _ejecutar(() async {
        final pos = await _ubicacion.actual();
        return _servicio.porCoordenadas(pos.latitude, pos.longitude);
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reto 3 · Clima')),
      body: !Claves.hayOpenWeather
          ? const AvisoClave(
              servicio: 'OpenWeatherMap',
              dondeObtenerla: 'openweathermap.org → tu cuenta → API keys (plan gratuito)',
              variable: 'OWM_KEY',
            )
          : Column(children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(children: [
                  Expanded(
                    child: TextField(
                      controller: _ciudad,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => _buscarCiudad(),
                      decoration: const InputDecoration(
                        labelText: 'Ciudad (ej. Guanajuato,MX)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _buscarCiudad,
                    icon: const Icon(Icons.search),
                    tooltip: 'Buscar',
                  ),
                  IconButton.outlined(
                    onPressed: _usarMiUbicacion,
                    icon: const Icon(Icons.my_location),
                    tooltip: 'Usar mi ubicación',
                  ),
                ]),
              ),
              Expanded(child: _contenido()),
            ]),
    );
  }

  Widget _contenido() {
    if (_cargando) return const Center(child: CircularProgressIndicator());
    if (_error != null) return MensajeError(texto: _error!, onReintentar: _buscarCiudad);
    final c = _clima;
    if (c == null) return const Center(child: Text('Busca una ciudad para ver su clima.'));

    return ListView(padding: const EdgeInsets.all(24), children: [
      Text(
        c.pais.isEmpty ? c.ciudad : '${c.ciudad}, ${c.pais}',
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
      ),
      Image.network(
        c.urlIcono,
        height: 140,
        errorBuilder: (context, error, stack) => const Icon(Icons.wb_cloudy, size: 100),
      ),
      Text(
        '${c.temperatura.round()}°C',
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 72, fontWeight: FontWeight.w200),
      ),
      Text(c.descripcion, textAlign: TextAlign.center, style: const TextStyle(fontSize: 20)),
      const SizedBox(height: 24),
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        _dato(Icons.thermostat, '${c.sensacion.round()}°C', 'Sensación'),
        _dato(Icons.water_drop, '${c.humedad}%', 'Humedad'),
        _dato(Icons.air, '${c.vientoKmh.round()} km/h', 'Viento'),
      ]),
    ]);
  }

  Widget _dato(IconData icono, String valor, String etiqueta) => Column(children: [
        Icon(icono, size: 30),
        const SizedBox(height: 4),
        Text(valor, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(etiqueta, style: const TextStyle(color: Colors.black54)),
      ]);
}
