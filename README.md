# Los cuatro retos: consumo de APIs en Flutter

Una sola app con un menú y las cuatro mini-apps del documento «Los Cuatro Retos»:

| Reto | App | API | ¿Pide clave? |
|---|---|---|---|
| 1 | 🎬 Recomendador de películas por estado de ánimo | The Movie Database (TMDB) | Sí (gratis) |
| 2 | 🐱 Generador de memes de gatos con texto y filtros | Cataas (Cats as a Service) | No |
| 3 | 🌦️ Clima minimalista (+ ubicación automática con `geolocator`) | OpenWeatherMap | Sí (gratis) |
| 4 | 🪙 Convertidor de criptomonedas en tiempo real | CoinGecko | No |

- **Alumno:** Luis Manuel Arteaga Cruz
- **Número de control:** 1225100281
- **Grupo / Fecha:** ______________________________

## Estructura

```
lib/
  config/claves.dart        claves de TMDB y OpenWeatherMap (no se suben a GitHub)
  core/api.dart             GET con tiempo límite, errores amables y JSON en UTF-8
  modelos/                  Pelicula, Animo, Clima, cripto (PrecioCripto, formato, cálculos)
  servicios/                tmdb, cataas (URL dinámica), clima, ubicación, coingecko
  pantallas/                menu_principal, reto1..reto4
  widgets/                  TarjetaPelicula, MensajeError, AvisoClave
test/                       38 pruebas (sin internet: respuestas simuladas con MockClient)
```

## Cómo ejecutar

```bash
flutter create --platforms=android,web .   # solo la primera vez: crea android/ y web/
flutter pub get
flutter test --reporter expanded
flutter run -d chrome --dart-define=TMDB_KEY=TU_CLAVE_TMDB --dart-define=OWM_KEY=TU_CLAVE_OPENWEATHER
```

> Los retos 2 y 4 funcionan sin claves. Los retos 1 y 3 muestran un aviso con los pasos si falta la clave.
> Ejecuta los comandos dentro de la carpeta que contiene `pubspec.yaml`.

### Cómo conseguir las claves (gratis)
- **TMDB:** crea una cuenta en themoviedb.org → *Configuración → API* → solicita una clave de uso personal y copia la **API Key (v3 auth)**.
- **OpenWeatherMap:** crea una cuenta en openweathermap.org → *My API keys*. Una clave nueva puede tardar un rato en activarse (mientras tanto la app dice que no es válida).

### ⚠️ Seguridad de las claves
- Prefiere `--dart-define` (arriba) para no escribir la clave en ningún archivo.
- Si la pegas en `lib/config/claves.dart`, **vuelve a dejarla vacía antes de `git push`**.
- No muestres la clave en las capturas de pantalla (por ejemplo, el comando de la terminal).

### Permisos de Android (`android/app/src/main/AndroidManifest.xml`, antes de `<application>`)
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

---

## 1. Pruebas automatizadas realizadas

**Total: 38 pruebas.** Marca cada resultado con ✅ cuando `flutter test` las muestre en verde.

### 1.1 Reto 1 · Películas (`test/peliculas_test.dart`) — 9 pruebas

| ID | Prueba | Resultado esperado | Resultado |
|---|---|---|---|
| PE-01 | estado de ánimo → género | feliz 35, triste 18, emocionado 28, romántico 10749, miedo 27, relajado 16, curioso 99 | ☐ |
| PE-02 | tendencias | no filtran por género (`null`) | ☐ |
| PE-03 | URL de un ánimo | `/3/discover/movie` con `with_genres=35`, `language=es-MX` y la clave | ☐ |
| PE-04 | URL de tendencias | `/3/trending/movie/week` sin `with_genres` | ☐ |
| PE-05 | modelo `Pelicula` | URL del póster `…/t/p/w500/abc.jpg`, año 2017 y calificación 8.2 | ☐ |
| PE-06 | datos faltantes | sin póster → `null`; sin fecha → "s/f"; sin título → "Sin título" | ☐ |
| PE-07 | servicio con respuesta simulada | 2 películas, conserva acentos y pide el género 28 | ☐ |
| PE-08 | error 401 | mensaje amable que habla de la API key | ☐ |
| PE-09 | sin internet | mensaje que habla de la conexión | ☐ |

### 1.2 Reto 2 · Gatos (`test/gatos_test.dart`) — 8 pruebas

| ID | Prueba | Resultado esperado | Resultado |
|---|---|---|---|
| GA-01 | sin texto | URL `cataas.com/cat` sin `fontSize` | ☐ |
| GA-02 | con texto | ruta `/cat/says/Hola%20mundo` con `fontSize=40` y `fontColor=white` | ☐ |
| GA-03 | acentos y signos | `¡Feliz lunes!` → `%C2%A1Feliz%20lunes!` | ☐ |
| GA-04 | diagonal en el texto | `a/b` → `a%2Fb` (no rompe la ruta) | ☐ |
| GA-05 | solo espacios | cuenta como sin texto | ☐ |
| GA-06 | filtro | `filter=mono`; "ninguno" no agrega el parámetro | ☐ |
| GA-07 | semilla | semillas distintas dan URLs distintas (otro gato) | ☐ |
| GA-08 | filtros del menú | todos generan una URL válida | ☐ |

### 1.3 Reto 3 · Clima (`test/clima_test.dart`) — 10 pruebas

| ID | Prueba | Resultado esperado | Resultado |
|---|---|---|---|
| CL-01 | lee la respuesta | ciudad, país MX, 24.6 °C, sensación 25.1, humedad 40, "Cielo claro" e ícono 01d | ☐ |
| CL-02 | viento | 5 m/s = 18 km/h | ☐ |
| CL-03 | datos faltantes | sin viento ni país: viento 0 y país vacío | ☐ |
| CL-04 | `capitalizar` | "nubes dispersas" → "Nubes dispersas"; vacío → vacío | ☐ |
| CL-05 | URL por ciudad | `q`, `units=metric`, `lang=es` y `appid` | ☐ |
| CL-06 | URL por coordenadas | `lat` y `lon` | ☐ |
| CL-07 | respuesta correcta | 24.6 °C | ☐ |
| CL-08 | error 404 | "No encontré esa ciudad…" | ☐ |
| CL-09 | error 401 | habla de la API key | ☐ |
| CL-10 | JSON raro | mensaje de "formato" y no truena | ☐ |

### 1.4 Reto 4 · Criptomonedas (`test/cripto_test.dart`) — 11 pruebas

| ID | Prueba | Resultado esperado | Resultado |
|---|---|---|---|
| CR-01 | `interpretarMonto` válidos | `100`→100, `$1,250.50`→1250.5, `  20  `→20 | ☐ |
| CR-02 | `interpretarMonto` inválidos | vacío, `abc`, `0`, `-5` y `1.2.3` → `null` | ☐ |
| CR-03 | fracciones | 100 USD a 50 000 USD = 0.002 | ☐ |
| CR-04 | precio 0 | no divide entre cero (`null`) | ☐ |
| CR-05 | Bitcoin | 100 USD a 65 000 = `0.00153846` (8 decimales) | ☐ |
| CR-06 | `formatearUsd` | `$0.00`, `$65,000.00` y `$1,234,567.89` | ☐ |
| CR-07 | `parsearPrecios` | BTC, ETH y SOL; Solana sin cambio de 24 h | ☐ |
| CR-08 | datos raros | ignora monedas faltantes o con datos inválidos | ☐ |
| CR-09 | servicio | pide `bitcoin,ethereum,solana` en USD y devuelve 3 | ☐ |
| CR-10 | error 429 | explica el límite de consultas | ☐ |
| CR-11 | respuesta vacía | lanza error (no se muestra como válida) | ☐ |

### 1.5 Evidencia de la ejecución

| Evidencia | Comando | Captura |
|---|---|---|
| Todas las pruebas en verde (`+38`) | `flutter test --reporter expanded` | ![tests](capturas/11_flutter_test_verde.png) |

---

## 2. Pruebas manuales en la app

| ID | Reto | Escenario | Pasos | Resultado esperado | Resultado |
|---|---|---|---|---|---|
| M-01 | Menú | Inicio | Abrir la app | 4 opciones; las de TMDB y OpenWeatherMap indican si la clave está lista | ☐ |
| M-02 | 1 | Sin clave | Abrir el Reto 1 sin `TMDB_KEY` | Aviso "🔑 Falta tu API key de TMDB" con los pasos | ☐ |
| M-03 | 1 | Por ánimo | Con clave, elegir "😄 Feliz" | Indicador de carga → una película de comedia con póster, año, ⭐ y sinopsis | ☐ |
| M-04 | 1 | Otra | Tocar "Recomiéndame otra" | Cambia a otra película de la lista | ☐ |
| M-05 | 1 | Tendencias | Elegir "🔥 Tendencias" | Lista de tarjetas de películas | ☐ |
| M-06 | 1 | Sin internet | Apagar el internet y cambiar de ánimo | Mensaje de conexión con botón "Reintentar" | ☐ |
| M-07 | 2 | Gato al azar | Abrir el Reto 2 | Aparece un gato sin texto | ☐ |
| M-08 | 2 | Texto | Escribir "Hola" y presionar "Generar meme" | Gato con "Hola" encima y la URL `…/cat/says/Hola…` visible abajo | ☐ |
| M-09 | 2 | Filtro | Elegir "mono" | El gato sale con el filtro y la URL incluye `filter=mono` | ☐ |
| M-10 | 2 | Acentos | Escribir "¡Feliz lunes!" | El texto aparece completo, con acentos y signos | ☐ |
| M-11 | 3 | Sin clave | Abrir el Reto 3 sin `OWM_KEY` | Aviso "🔑 Falta tu API key de OpenWeatherMap" | ☐ |
| M-12 | 3 | Clima por defecto | Con clave, abrir el Reto 3 | Carga → "Dolores Hidalgo, MX", temperatura, descripción, sensación, humedad y viento | ☐ |
| M-13 | 3 | Otra ciudad | Escribir `Guanajuato,MX` y buscar | Clima de Guanajuato | ☐ |
| M-14 | 3 | Ciudad inexistente | Escribir `xyzzy` y buscar | "No encontré esa ciudad…" con "Reintentar" | ☐ |
| M-15 | 3 | Mi ubicación | Tocar el icono 📍 y aceptar el permiso | Clima de tu ubicación actual | ☐ |
| M-16 | 4 | Precios | Abrir el Reto 4 | Carga → Bitcoin, Ethereum y Solana con su precio en USD y "Actualizado a las hh:mm:ss" | ☐ |
| M-17 | 4 | Conversión | Escribir `100` en "Monto en USD" | Cada moneda muestra "Con $100.00 comprarías 0.00… BTC/ETH/SOL" | ☐ |
| M-18 | 4 | Monto inválido | Escribir `abc` | Mensaje "Escribe un número mayor que 0" y sin cálculo | ☐ |
| M-19 | 4 | Actualizar | Tocar ⟳ o esperar 30 s | La hora de "Actualizado" cambia sin que parpadee la pantalla | ☐ |

### Capturas de la app

| Reto | Escenario | Captura |
|---|---|---|
| Menú | M-01 | ![menu](capturas/00_menu.png) |
| 1 | M-03 película por ánimo | ![peliculas](capturas/01_peliculas_resultado.png) |
| 1 | M-05 tendencias | ![tendencias](capturas/02_peliculas_tendencias.png) |
| 1 | M-02 aviso de clave (opcional) | ![sinclave](capturas/03_peliculas_sin_clave.png) |
| 2 | M-07 gato sin texto | ![gato1](capturas/04_gato_sin_texto.png) |
| 2 | M-08 gato con texto y URL | ![gato2](capturas/05_gato_con_texto.png) |
| 2 | M-09 gato con filtro | ![gato3](capturas/06_gato_filtro.png) |
| 3 | M-12 clima | ![clima](capturas/07_clima_resultado.png) |
| 3 | M-14 ciudad no encontrada | ![clima2](capturas/08_clima_ciudad_no_encontrada.png) |
| 4 | M-16 precios | ![cripto1](capturas/09_cripto_precios.png) |
| 4 | M-17 conversión | ![cripto2](capturas/10_cripto_monto.png) |

---

## 3. Notas y problemas conocidos

- **Las imágenes no cargan en Chrome pero sí en el celular:** es el bloqueo CORS del navegador; prueba en Android o en otro navegador.
- **Clima: "API key no válida" recién creada:** espera a que OpenWeatherMap la active (puede tardar un par de horas).
- **CoinGecko: error 429:** el plan gratuito limita las consultas por minuto; espera y actualiza.
- **`flutter test` marca fallo en `widget_test.dart`:** bórralo; es el ejemplo que crea `flutter create`.
- **`flutter pub get` se queja de una versión:** borra esa línea del `pubspec.yaml` y ejecuta `flutter pub add http geolocator`.
