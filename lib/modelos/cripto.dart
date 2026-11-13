class MonedaCripto {
  final String id; // id de CoinGecko
  final String nombre;
  final String simbolo;
  final int decimales; // cuántos decimales mostrar de la fracción comprada
  const MonedaCripto(this.id, this.nombre, this.simbolo, this.decimales);
}

const monedasSoportadas = <MonedaCripto>[
  MonedaCripto('bitcoin', 'Bitcoin', 'BTC', 8),
  MonedaCripto('ethereum', 'Ethereum', 'ETH', 6),
  MonedaCripto('solana', 'Solana', 'SOL', 4),
];

class PrecioCripto {
  final MonedaCripto moneda;
  final double usd;
  final double? cambio24h; // porcentaje; puede no venir
  const PrecioCripto(this.moneda, this.usd, this.cambio24h);
}

/// Lee la respuesta de /simple/price de CoinGecko:
/// {"bitcoin":{"usd":65000,"usd_24h_change":1.2}, "ethereum":{...}, ...}
List<PrecioCripto> parsearPrecios(Map<String, dynamic> json) {
  final lista = <PrecioCripto>[];
  for (final m in monedasSoportadas) {
    final datos = json[m.id];
    if (datos is! Map<String, dynamic>) continue;
    final usd = datos['usd'];
    if (usd is! num) continue;
    final cambio = datos['usd_24h_change'];
    lista.add(PrecioCripto(m, usd.toDouble(), cambio is num ? cambio.toDouble() : null));
  }
  return lista;
}

/// Convierte lo que escribe el usuario ("100", "\$1,250.50") en dólares.
/// Devuelve null si no es un número mayor que cero.
double? interpretarMonto(String texto) {
  final limpio = texto.replaceAll(RegExp(r'[\$,\s]'), '');
  final valor = double.tryParse(limpio);
  if (valor == null || valor.isNaN || valor.isInfinite || valor <= 0) return null;
  return valor;
}

/// Cuántas unidades de la cripto compras con [usd] dólares.
double? fraccionesComprables(double usd, double precio) {
  if (precio <= 0) return null;
  return usd / precio;
}

String formatearUsd(double valor) {
  final partes = valor.toStringAsFixed(2).split('.');
  final entero = partes[0].replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
  return '\$$entero.${partes[1]}';
}
