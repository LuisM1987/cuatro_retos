import 'dart:math';

import 'package:flutter/material.dart';

import '../config/claves.dart';
import '../core/api.dart';
import '../modelos/animo.dart';
import '../modelos/pelicula.dart';
import '../servicios/tmdb_servicio.dart';
import '../widgets/aviso_clave.dart';
import '../widgets/mensaje_error.dart';
import '../widgets/tarjeta_pelicula.dart';

/// Reto 1: Recomendador de películas según el estado de ánimo (TMDB).
class Reto1Peliculas extends StatefulWidget {
  const Reto1Peliculas({super.key});

  @override
  State<Reto1Peliculas> createState() => _Reto1PeliculasState();
}

class _Reto1PeliculasState extends State<Reto1Peliculas> {
  final _azar = Random();
  final _servicio = TmdbServicio(apiKey: Claves.tmdb);

  Animo _animo = Animo.feliz;
  List<Pelicula> _lista = [];
  int _indice = 0;
  bool _cargando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (Claves.hayTmdb) _cargar();
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final lista = await _servicio.obtener(_animo);
      if (!mounted) return;
      setState(() {
        _lista = lista;
        _indice = lista.isEmpty ? 0 : _azar.nextInt(lista.length);
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

  /// Otra película al azar de la misma lista (sin volver a pedirla a internet).
  void _otra() {
    if (_lista.length < 2) return;
    var nuevo = _indice;
    while (nuevo == _indice) {
      nuevo = _azar.nextInt(_lista.length);
    }
    setState(() => _indice = nuevo);
  }

  void _elegirAnimo(Animo animo) {
    setState(() => _animo = animo);
    _cargar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reto 1 · Recomendador de películas')),
      body: Column(children: [
        SizedBox(
          height: 56,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            itemCount: Animo.values.length,
            separatorBuilder: (context, i) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final a = Animo.values[i];
              return ChoiceChip(
                label: Text('${a.emoji} ${a.etiqueta}'),
                selected: a == _animo,
                onSelected: (_) => _elegirAnimo(a),
              );
            },
          ),
        ),
        Expanded(child: _contenido()),
      ]),
    );
  }

  Widget _contenido() {
    if (!Claves.hayTmdb) {
      return const AvisoClave(
        servicio: 'TMDB',
        dondeObtenerla: 'themoviedb.org → tu cuenta → Configuración → API (clave "API Key v3")',
        variable: 'TMDB_KEY',
      );
    }
    if (_cargando) return const Center(child: CircularProgressIndicator());
    if (_error != null) return MensajeError(texto: _error!, onReintentar: _cargar);
    if (_lista.isEmpty) return const Center(child: Text('No encontré películas para ese ánimo.'));

    if (_animo == Animo.tendencias) {
      return ListView(children: [
        for (final p in _lista) TarjetaPelicula(pelicula: p, altoPoster: 300),
      ]);
    }
    return SingleChildScrollView(
      child: Column(children: [
        TarjetaPelicula(pelicula: _lista[_indice]),
        const SizedBox(height: 4),
        FilledButton.icon(
          onPressed: _otra,
          icon: const Icon(Icons.casino),
          label: const Text('Recomiéndame otra'),
        ),
        const SizedBox(height: 24),
      ]),
    );
  }
}
