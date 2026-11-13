import 'package:flutter/material.dart';

/// Error amable con botón para reintentar.
class MensajeError extends StatelessWidget {
  final String texto;
  final VoidCallback? onReintentar;
  const MensajeError({super.key, required this.texto, this.onReintentar});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.error_outline, size: 56, color: Colors.redAccent),
          const SizedBox(height: 12),
          Text(texto, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
          if (onReintentar != null) ...[
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onReintentar,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ]),
      ),
    );
  }
}
