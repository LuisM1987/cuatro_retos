import 'package:flutter/material.dart';

import '../modelos/pelicula.dart';

/// Tarjeta (Card) con el póster, el título, el año, la calificación y la sinopsis.
class TarjetaPelicula extends StatelessWidget {
  final Pelicula pelicula;
  final double altoPoster;
  const TarjetaPelicula({super.key, required this.pelicula, this.altoPoster = 380});

  @override
  Widget build(BuildContext context) {
    final url = pelicula.urlPoster;
    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          height: altoPoster,
          width: double.infinity,
          child: url == null
              ? const ColoredBox(
                  color: Colors.black12,
                  child: Center(child: Icon(Icons.movie, size: 64)),
                )
              : Image.network(
                  url,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progreso) => progreso == null
                      ? child
                      : const Center(child: CircularProgressIndicator()),
                  errorBuilder: (context, error, stack) => const ColoredBox(
                    color: Colors.black12,
                    child: Center(child: Icon(Icons.broken_image, size: 64)),
                  ),
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(pelicula.titulo,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.calendar_today, size: 14),
              const SizedBox(width: 4),
              Text(pelicula.anio),
              const SizedBox(width: 16),
              const Icon(Icons.star, size: 16, color: Colors.amber),
              const SizedBox(width: 4),
              Text(pelicula.calificacion.toStringAsFixed(1)),
            ]),
            const SizedBox(height: 8),
            Text(
              pelicula.sinopsis.isEmpty ? 'Sin sinopsis disponible.' : pelicula.sinopsis,
              maxLines: 6,
              overflow: TextOverflow.ellipsis,
            ),
          ]),
        ),
      ]),
    );
  }
}
