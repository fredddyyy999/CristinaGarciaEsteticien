# Web · Cristina García, Centro de Estética & Bienestar

Web estática (HTML + CSS + JS sin dependencias), pensada **primero para móvil**.
Se puede subir tal cual a cualquier hosting (Netlify, Vercel, GitHub Pages, hosting compartido…).

## Ver la web en local

```
powershell -ExecutionPolicy Bypass -File herramientas\servidor.ps1
```

Abrir http://localhost:5173/ — y con `?revision` (http://localhost:5173/?revision) se marcan en naranja los textos pendientes de confirmar, con una lista en la esquina.

## Estructura

| Archivo | Qué es |
|---|---|
| `index.html` | Página única: portada, servicios, el centro, galería, opiniones, contacto |
| `aviso-legal.html`, `privacidad.html`, `cookies.html` | Plantillas legales (datos en amarillo por completar) |
| `404.html` | Página de error |
| `assets/css/estilos.css` | Todos los estilos (colores de marca en `:root`) |
| `assets/js/app.js` | Menú, animaciones, estado abierto/cerrado, formulario → WhatsApp, mapa |
| `assets/img/` | Logo, favicon, icono móvil, imagen para compartir (`og.png`), fotos |
| `herramientas/` | Servidor local y generador de iconos (no hace falta subirlos) |

## Funciones móviles

- Barra inferior fija con **Llamar · Pedir cita (WhatsApp) · Cómo llegar**.
- Servicios en carrusel deslizable.
- Estado **"Abierto ahora / Cerrado · abre…"** calculado con la hora de España y el día de hoy resaltado en el horario.
- Formulario que abre WhatsApp con el mensaje ya escrito (la web no guarda datos).
- Mapa de Google que solo se carga al pulsar (sin cookies sin permiso).

## Datos usados (de Instagram)

- Teléfono / WhatsApp: 622 56 29 20
- C/ Iglesia 16, bajo B, 16239 Casasimarro (Cuenca)
- Horario: lunes cerrado · mar–jue 9:30–19:00 · vie 10:00–20:00 · sáb 10:00–13:30 · domingos eventos
- Apertura: sábado 30 de mayo de 2026
- Reseñas: https://g.page/r/CertJnmVpiFyEBI/review

**Si cambia el horario** hay que tocarlo en 3 sitios: lista `.horario` y pie de `index.html`, `HORARIO` en `app.js`, y `openingHoursSpecification` en el `<head>`.

## Pendiente

- [ ] **Al publicar de verdad**: quitar de `index.html` la línea `<meta name="robots" content="noindex, nofollow">` (ahora oculta la web a Google mientras está en pruebas en GitHub Pages).

- [x] **Galería**: 74 fotos sacadas del Instagram (sin el cartel de gran apertura) en `assets/img/galeria/` (`maquillaje-NN.jpg`, `manicura-NN.jpg`, `pedicura-NN.jpg`, 960×1200). Con filtros por servicio, "Ver más" de 8 en 8 y visor al tocar. Para añadir una, copiar un `<figure>` en `index.html` y cambiar foto, texto y `data-categoria`.
- [ ] Confirmar con Cristina que se pueden usar en la web las fotos de **maquillaje con clientas**.
- [ ] Faltan fotos de **tratamientos faciales y corporales** y del **local** (no hay en Instagram).
- [ ] **Foto de Cristina** o del local → `assets/img/cristina.jpg` (vertical 4:5). Aparece sola.
- [x] **Portada**: `assets/img/hero.jpg` es un fotograma (1080 px) del reel de inauguración (instagram.com/reel/DZAj7FksQjK), sin el logo superpuesto. Si Cristina tiene la foto original, mejor aún. Ese reel recorre todo el local: de ahí se pueden sacar fotos del centro.
- [x] **Logo**: monograma CG oficial (serigrafía) en `assets/img/logo.svg` (marrón #605044) y `logo-negro.svg`. En las páginas va como `<symbol id="monograma">` y toma el color del texto. Si cambia, sustituir el trazado y ejecutar `herramientas\generar-imagenes.ps1` para rehacer `apple-touch-icon.png` y `og.png`.
- [ ] Confirmar con Cristina la **lista de servicios** de cada tarjeta y si se publican **tarifas**. Añadidas por lo visto en sus historias destacadas: **Cejas** (diseño y laminado), **Depilación láser** y **masajes** (Ritual Mare Nostrum, dentro de la tarjeta de corporales).
- [ ] Revisar el **texto "Hola, soy Cristina"**.
- [ ] Textos legales: **nombre completo, NIF, email y fecha**.
- [ ] Al tener dominio: cambiar `TU-DOMINIO.es` en `robots.txt` y `sitemap.xml`, y añadir en `index.html` `<link rel="canonical">`, `og:url` y `og:image` (`https://dominio/assets/img/og.png`).
- [x] Código postal 16239 confirmado en su ficha de Google Maps ("Cristina García Estética y Bienestar", Calle Iglesia 16, bajo B). El enlace de reseñas lleva a esa misma ficha.
