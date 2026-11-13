import 'package:flutter/material.dart';

import '../servicios/cataas.dart';

/// Reto 2: Generador de memes de gatos con texto y filtros (Cataas).
class Reto2Gatos extends StatefulWidget {
  const Reto2Gatos({super.key});

  @override
  State<Reto2Gatos> createState() => _Reto2GatosState();
}

class _Reto2GatosState extends State<Reto2Gatos> {
  final _texto = TextEditingController();
  String _filtro = 'ninguno';
  int _semilla = 0;
  Uri _url = construirUrlGato();

  @override
  void dispose() {
    _texto.dispose();
    super.dispose();
  }

  /// Arma una URL nueva con el texto y el filtro actuales y pide otro gato.
  void _generar() {
    FocusScope.of(context).unfocus();
    setState(() {
      _semilla++;
      _url = construirUrlGato(texto: _texto.text, filtro: _filtro, semilla: _semilla);
    });
  }

  @override
  Widget build(BuildContext context) {
    final url = _url.toString();
    return Scaffold(
      appBar: AppBar(title: const Text('Reto 2 · Memes de gatos')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        TextField(
          controller: _texto,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _generar(),
          decoration: const InputDecoration(
            labelText: 'Escribe tu frase',
            hintText: 'Ej. ¡Feliz lunes!',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.edit),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 4, children: [
          for (final f in filtrosGato)
            ChoiceChip(
              label: Text(f == 'ninguno' ? 'Sin filtro' : f),
              selected: f == _filtro,
              onSelected: (_) {
                setState(() => _filtro = f);
                _generar();
              },
            ),
        ]),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _generar,
          icon: const Icon(Icons.pets),
          label: const Text('Generar meme (otro gato)'),
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            url,
            key: ValueKey(url),
            fit: BoxFit.contain,
            loadingBuilder: (context, child, progreso) => progreso == null
                ? child
                : const SizedBox(
                    height: 300,
                    child: Center(child: CircularProgressIndicator()),
                  ),
            errorBuilder: (context, error, stack) => const SizedBox(
              height: 300,
              child: Center(
                child: Text(
                  'No se pudo cargar el gato 😿\nRevisa tu internet o prueba otro filtro.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text('URL que se está usando:', style: TextStyle(fontWeight: FontWeight.bold)),
        SelectableText(url, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
      ]),
    );
  }
}
