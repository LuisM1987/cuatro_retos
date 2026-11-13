import 'dart:async';

import 'package:flutter/material.dart';

import '../core/api.dart';
import '../modelos/cripto.dart';
import '../servicios/coingecko_servicio.dart';
import '../widgets/mensaje_error.dart';

/// Reto 4: Convertidor de criptomonedas en tiempo real (CoinGecko).
class Reto4Cripto extends StatefulWidget {
  const Reto4Cripto({super.key});

  @override
  State<Reto4Cripto> createState() => _Reto4CriptoState();
}

class _Reto4CriptoState extends State<Reto4Cripto> {
  final _servicio = CoingeckoServicio();
  final _monto = TextEditingController();

  late Future<List<PrecioCripto>> _futuro;
  List<PrecioCripto>? _ultimos;
  DateTime? _actualizado;
  Timer? _temporizador;

  @override
  void initState() {
    super.initState();
    _cargar();
    // "Tiempo real": se vuelven a pedir los precios cada 30 segundos.
    _temporizador = Timer.periodic(const Duration(seconds: 30), (_) => _cargar());
  }

  @override
  void dispose() {
    _temporizador?.cancel(); // evita fugas: se cancela al salir de la pantalla
    _monto.dispose();
    super.dispose();
  }

  void _cargar() {
    final f = _servicio.obtener().then((precios) {
      _ultimos = precios;
      _actualizado = DateTime.now();
      return precios;
    });
    setState(() => _futuro = f);
  }

  String _hora(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:${t.second.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reto 4 · Criptomonedas'),
        actions: [
          IconButton(onPressed: _cargar, icon: const Icon(Icons.refresh), tooltip: 'Actualizar'),
        ],
      ),
      body: FutureBuilder<List<PrecioCripto>>(
        future: _futuro,
        builder: (context, snap) {
          final datos = snap.data ?? _ultimos;
          if (datos == null) {
            if (snap.hasError) {
              return MensajeError(texto: mensajeParaUsuario(snap.error!), onReintentar: _cargar);
            }
            return const Center(child: CircularProgressIndicator());
          }
          return RefreshIndicator(
            onRefresh: () async {
              _cargar();
              try {
                await _futuro;
              } catch (_) {}
            },
            child: _lista(
              datos,
              actualizando: snap.connectionState == ConnectionState.waiting,
              error: snap.hasError ? mensajeParaUsuario(snap.error!) : null,
            ),
          );
        },
      ),
    );
  }

  Widget _lista(List<PrecioCripto> datos, {required bool actualizando, String? error}) {
    final usd = interpretarMonto(_monto.text);
    final hayTexto = _monto.text.trim().isNotEmpty;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          controller: _monto,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: 'Monto en USD',
            prefixText: '\$ ',
            border: const OutlineInputBorder(),
            errorText: hayTexto && usd == null ? 'Escribe un número mayor que 0' : null,
          ),
        ),
        const SizedBox(height: 8),
        Row(children: [
          if (actualizando)
            const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
          if (actualizando) const SizedBox(width: 8),
          Text(
            _actualizado == null ? 'Actualizando…' : 'Actualizado a las ${_hora(_actualizado!)}',
            style: const TextStyle(color: Colors.black54, fontSize: 12),
          ),
        ]),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(error, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
          ),
        const SizedBox(height: 8),
        for (final p in datos) _tarjeta(p, usd),
      ],
    );
  }

  Widget _tarjeta(PrecioCripto p, double? usd) {
    final fracciones = usd == null ? null : fraccionesComprables(usd, p.usd);
    final cambio = p.cambio24h;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(p.moneda.nombre,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Text(p.moneda.simbolo, style: const TextStyle(color: Colors.black54)),
            const Spacer(),
            Text(formatearUsd(p.usd),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          ]),
          if (cambio != null)
            Text(
              '${cambio >= 0 ? '▲' : '▼'} ${cambio.abs().toStringAsFixed(2)}% en 24 h',
              style: TextStyle(color: cambio >= 0 ? Colors.green : Colors.red, fontSize: 12),
            ),
          if (fracciones != null) ...[
            const Divider(),
            Text(
              'Con ${formatearUsd(usd!)} comprarías '
              '${fracciones.toStringAsFixed(p.moneda.decimales)} ${p.moneda.simbolo}',
            ),
          ],
        ]),
      ),
    );
  }
}
