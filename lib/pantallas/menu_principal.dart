import 'package:flutter/material.dart';

import '../config/claves.dart';
import 'reto1_peliculas.dart';
import 'reto2_gatos.dart';
import 'reto3_clima.dart';
import 'reto4_cripto.dart';

class MenuPrincipal extends StatelessWidget {
  const MenuPrincipal({super.key});

  void _abrir(BuildContext context, Widget pantalla) {
    Navigator.push(context, MaterialPageRoute<void>(builder: (_) => pantalla));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Los cuatro retos')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Text('Consumo de APIs en Flutter',
            style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 4),
        const Text('Elige un reto para probarlo.'),
        const SizedBox(height: 16),
        _Opcion(
          emoji: '🎬',
          titulo: 'Reto 1 · Recomendador de películas',
          detalle: 'TMDB · ${Claves.hayTmdb ? 'API key lista ✅' : 'falta la API key 🔑'}',
          onTap: () => _abrir(context, const Reto1Peliculas()),
        ),
        _Opcion(
          emoji: '🐱',
          titulo: 'Reto 2 · Memes de gatos',
          detalle: 'Cataas · sin clave',
          onTap: () => _abrir(context, const Reto2Gatos()),
        ),
        _Opcion(
          emoji: '🌦️',
          titulo: 'Reto 3 · Clima minimalista',
          detalle: 'OpenWeatherMap · ${Claves.hayOpenWeather ? 'API key lista ✅' : 'falta la API key 🔑'}',
          onTap: () => _abrir(context, const Reto3Clima()),
        ),
        _Opcion(
          emoji: '🪙',
          titulo: 'Reto 4 · Criptomonedas',
          detalle: 'CoinGecko · sin clave',
          onTap: () => _abrir(context, const Reto4Cripto()),
        ),
      ]),
    );
  }
}

class _Opcion extends StatelessWidget {
  final String emoji;
  final String titulo;
  final String detalle;
  final VoidCallback onTap;
  const _Opcion({
    required this.emoji,
    required this.titulo,
    required this.detalle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Text(emoji, style: const TextStyle(fontSize: 36)),
        title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(detalle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
