# Web · Cristina García, Centro de Estética & Bienestar

Web estática (HTML + CSS + JS sin dependencias), pensada **primero para móvil** (9 de cada 10 visitas): cualquier cambio se comprueba primero a **375 px** de ancho.

- **Versión de pruebas publicada:** https://fredddyyy999.github.io/CristinaGarciaEsteticien/ (GitHub Pages, rama `main`, repositorio público `fredddyyy999/CristinaGarciaEsteticien`). Oculta a Google con `noindex`.
- Para publicar un cambio: commit y `git push`; GitHub Pages tarda ~1 minuto.

## Ver la web en local

```
powershell -ExecutionPolicy Bypass -File herramientas\servidor.ps1
```

Abrir http://localhost:5173/ — y con `?revision` (http://localhost:5173/?revision) se marcan en naranja los textos pendientes de confirmar, con una lista en la esquina.

## Estructura

| Archivo | Qué es |
|---|---|
| `index.html` | Página única: portada, servicios, el centro, galería, opiniones, contacto |
| `aviso-legal.html`, `privacidad.html`, `cookies.html` | Plantillas legales (datos marcados como pendientes) |
| `404.html` | Página de error (usa rutas absolutas `/assets/…`: en GitHub Pages se ve sin estilos; con dominio propio funcionará) |
| `assets/css/estilos.css` | Todos los estilos (colores de marca en `:root`, fuentes al principio) |
| `assets/js/inicio.js` | Se carga en el `<head>` de `index.html`: activa las animaciones y quita las fotos que falten |
| `assets/js/app.js` | Menú, animaciones, estado abierto/cerrado, barra móvil, galería y visor, formulario → WhatsApp, mapa |
| `assets/fonts/` | Cormorant Garamond y Jost en WOFF2, servidas desde la propia web (no Google Fonts, por el RGPD). Licencia SIL OFL |
| `assets/img/` | Logo (`logo.svg` marrón, `logo-negro.svg`), favicon, icono móvil, `og.png`, portada (`hero.jpg`), foto de "Hola, soy Cristina" (`cristina.jpg`) y letras oficiales `letra-c.svg` / `letra-g.svg` (marrón; las negras están en Descargas del usuario) |
| `assets/img/galeria/` | 74 fotos de Instagram (`maquillaje-NN.jpg`, `manicura-NN.jpg`, `pedicura-NN.jpg`) y 8 del local de su ficha de Google Maps (`centro-NN.jpg`), todas 960×1200 |
| `herramientas/` | Servidor local y `generar-imagenes.ps1` (rehace `apple-touch-icon.png` y `og.png` a partir de `logo.svg`) |
| `documentos/` | **No se sube** (está en `.gitignore`): propuesta en PDF para Cristina y su HTML de origen |

## Cómo funciona (decisiones tomadas)

- **Portada en móvil**: ocupa justo la primera pantalla, centrada (titular, texto, botones, dirección y estado "Abierto ahora · hasta las…"). La foto de las pampas aparece entera al deslizar. La web se abre **siempre por arriba** (`history.scrollRestoration = 'manual'`) salvo enlaces con `#sección`.
- **Barra inferior del móvil** (Llamar · Pedir cita · Cómo llegar) y botón flotante de WhatsApp en ordenador: **solo aparecen cuando ya no se ven los botones de la portada**, para no repetirlos.
- **Cabeceras de sección**: todas centradas con dos barras (—— SERVICIOS ——), también "El centro" (en ordenador se centra dentro de su columna, junto a la foto). Mantener esta uniformidad en cualquier sección nueva.
- **Servicios** (6 tarjetas, carrusel en móvil): maquillaje · manicura y pedicura · faciales · corporales y masajes · cejas · depilación láser.
- **Galería**: filtros Todo/Maquillaje/Manicura/Pedicura/El centro, "Ver más" de 8 en 8 y visor al tocar. Las fotos de "El centro" van repartidas (una en cada tanda de 8) para que se vean también en "Todo". Para añadir una foto: copiar un `<figure>`, cambiar foto, texto y `data-categoria`, y actualizar el número del filtro.
- **Fotos del local** (`cristina.jpg` y `galeria/centro-NN.jpg`): sacadas de su **ficha de Google Maps**, subidas por la propia cuenta del negocio (agosto de 2026), sin personas. Recortadas a 4:5 y reducidas a 960×1200. `cristina.jpg` es el puesto de manicura con el logo en la pared; si Cristina da una foto suya, sustituirla y cambiar su `alt`.
- **Opiniones**: 5 reseñas de Google puestas a mano (extractos, solo nombre e inicial, sin foto ni fecha) y el resumen "5,0 · 16 reseñas". **No se actualizan solas**: editarlas en `index.html` (sección `OPINIONES`).
- **Mapa y "Cómo llegar"**: apuntan a su ficha de Google ("Cristina García Estética y Bienestar", place_id `ChIJEXd6RwCxZw0R6u0meZWmIXI`). El mapa solo se carga al pulsar.
- **Privacidad**: sin cookies y sin ninguna petición a terceros al cargar la página.
- **Versión de estilos y código (`?v=…`)**: las 5 páginas cargan `estilos.css`, `app.js` e `inicio.js` con `?v=20261117c`. GitHub Pages deja que el navegador guarde esos archivos 10 minutos; **cada vez que se cambie el CSS o el JS hay que cambiar ese número en las 5 páginas** (por ejemplo, la fecha del día), o habrá visitantes que vean la página nueva con los estilos viejos (así salió una vez un círculo negro en lugar de la G).
- **Logo**: monograma CG oficial (serigrafía), color oficial #605044. En las páginas va como `<symbol id="monograma">` y toma el color del texto.
- **La "C" de "Cristina" y la "G" de "García"** del nombre (encabezado y pie) son las **letras oficiales de su serigrafía** (archivos originales en `assets/img/letra-c.svg` y `assets/img/letra-g.svg`), como en su letrero y sus toallas; no son las de la fuente. Van dentro de `<span class="letra">`, con su tamaño y color como atributos del propio `<svg>` (para que nunca dependa de la hoja de estilos) y la letra de texto oculta para que el nombre se lea y se copie bien. Están en `index.html` (2 veces), `aviso-legal.html`, `privacidad.html` y `cookies.html`. **No redibujarlas**: si cambian, usar los archivos oficiales.
- **Portada (`hero.jpg`)**: fotograma a 1080 px del reel de inauguración (instagram.com/reel/DZAj7FksQjK), sin el logo superpuesto. Las fotos del local salieron de su ficha de Google Maps (mejor calidad que el reel).

## Seguridad

- Las 5 páginas llevan, justo después de `<meta charset>`, una **política de seguridad** (`Content-Security-Policy` por `<meta>`) y `<meta name="referrer" content="strict-origin-when-cross-origin">`. La política solo deja cargar archivos de la propia web (código, estilos, fuentes, fotos y `data:`), y como marco solo el mapa de Google (`www.google.com` / `maps.google.com`), que se crea desde `app.js` al pulsar.
- Por eso **no puede haber código ni estilos escritos dentro del HTML** (ni `<script>…</script>`, ni `onclick=`/`onerror=`, ni `style="…"`): el navegador los bloquea. Todo va en `assets/js/` y `assets/css/`. El código que debe ejecutarse antes de pintar la página está en `assets/js/inicio.js`; las fotos que pueden faltar llevan `data-quitar-si-falla` en vez de `onerror`. El bloque `application/ld+json` sí está permitido (son datos, no código).
- **Si se añade algo de fuera** (otro mapa, un vídeo de YouTube, estadísticas…), hay que añadir su dirección a la política **en las 5 páginas**, o no se verá.
- Todos los enlaces que abren pestaña nueva (`target="_blank"`) llevan `rel="noopener"`.
- **Para el hosting definitivo** (GitHub Pages no permite cabeceras HTTP, y estas no funcionan por `<meta>`), configurar como cabeceras del servidor:
  - `Content-Security-Policy` (la misma de las páginas) **más** `frame-ancestors 'none'` (impide meter la web en marcos ajenos) y `upgrade-insecure-requests`;
  - `X-Frame-Options: DENY`, `X-Content-Type-Options: nosniff`, `Strict-Transport-Security: max-age=31536000`, `Permissions-Policy: camera=(), microphone=(), geolocation=()`;
  - HTTPS obligatorio y redirección de `http://` a `https://`.

## Datos del negocio

- Teléfono / WhatsApp: 622 56 29 20
- C/ Iglesia 16, bajo B, 16239 Casasimarro (Cuenca) — CP confirmado en su ficha de Google Maps
- Horario: lunes cerrado · mar–jue 9:30–19:00 · vie 10:00–20:00 · sáb 10:00–13:30 · domingos eventos
- Apertura: sábado 30 de mayo de 2026
- Reseñas: https://g.page/r/CertJnmVpiFyEBI/review

**Si cambia el horario** hay que tocarlo en 3 sitios: lista `.horario` y pie de `index.html`, `HORARIO` en `app.js`, y `openingHoursSpecification` en el `<head>`.

## Próximos pasos (en este orden)

1. [x] **Repaso de seguridad rápido** — hecho en la web (ver «Seguridad» más arriba).
   - [ ] **Más adelante**: que el dueño de la cuenta active la **verificación en dos pasos en GitHub** (Settings → Password and authentication → Enable two-factor authentication, con una app de autenticación, y guardar los códigos de recuperación). No lo puede hacer nadie más.
2. [x] **Fotos del centro**: hechas con las fotos de su ficha de Google Maps → `assets/img/cristina.jpg` ("Hola, soy Cristina") y 8 fotos en la categoría "El centro" de la galería.
3. [ ] **Más adelante — Tarjeta regalo "Regala belleza"** para Navidad: sección con botón de WhatsApp con mensaje ya escrito, "importe a elegir" hasta que Cristina dé importes, caducidad y condiciones (deben aparecer en la web).

## Pendiente de Cristina (resumido en `documentos/Propuesta-mejoras-web-Cristina-Garcia.pdf`)

- [ ] **Permiso de las clientas** de las 10 fotos de maquillaje (caras visibles), mejor por escrito. Las que no, se quitan.
- [ ] **Fotos**: suya y de tratamientos faciales/corporales (en Instagram no hay). Las del local ya están (de su ficha de Google).
- [ ] **Datos legales**: nombre completo, NIF, email y fecha → `aviso-legal.html` y `privacidad.html` (obligatorio por la LSSI antes de publicar con dominio).
- [ ] **Depilación láser**: confirmar autorización/registro del aparato en Castilla-La Mancha. En la publicidad, nada de "definitiva" ni efectos médicos.
- [ ] **Servicios**: revisar la lista de cada tarjeta; tipos de masaje, zonas de láser, si hace tinte/lifting de cejas. Añadidos por sus historias: cejas, láser y masajes (Ritual Mare Nostrum).
- [ ] **Precios** ("desde…", siempre con IVA incluido), **preguntas frecuentes**, **formación/cursos**, **promociones**.
- [ ] Revisar el texto **"Hola, soy Cristina"**.

## Al publicar de verdad (lanzamiento)

- [ ] Dominio propio **a nombre de Cristina** (y también la cuenta de alojamiento y la ficha de Google), con verificación en dos pasos y bloqueo de transferencia.
- [ ] Quitar de `index.html` la línea `<meta name="robots" content="noindex, nofollow">`.
- [ ] Cambiar `TU-DOMINIO.es` en `robots.txt` y `sitemap.xml`, y añadir en `index.html` `<link rel="canonical">`, `og:url` y `og:image` (`https://dominio/assets/img/og.png`).
- [ ] Enlazar la web desde su Instagram y su ficha de Google.
- [ ] Si se ponen estadísticas, que sean **sin cookies** (GoatCounter o Plausible).
