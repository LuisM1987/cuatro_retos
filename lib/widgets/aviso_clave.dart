import 'package:flutter/material.dart';

/// Se muestra cuando falta la API key de un servicio.
class AvisoClave extends StatelessWidget {
  final String servicio;
  final String dondeObtenerla;
  final String variable; // nombre para --dart-define
  const AvisoClave({
    super.key,
    required this.servicio,
    required this.dondeObtenerla,
    required this.variable,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(16), children: [
      Card(
        color: Colors.amber.shade100,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('🔑 Falta tu API key de $servicio',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('1. Consíguela gratis en: $dondeObtenerla'),
            const SizedBox(height: 4),
            const Text('2. Pégala en lib/config/claves.dart (defaultValue) o ejecuta con:'),
            const SizedBox(height: 4),
            SelectableText('flutter run -d chrome --dart-define=$variable=tu_clave',
                style: const TextStyle(fontFamily: 'monospace')),
            const SizedBox(height: 8),
            const Text('No subas tu clave real a GitHub.',
                style: TextStyle(fontStyle: FontStyle.italic)),
          ]),
        ),
      ),
    ]);
  }
}
