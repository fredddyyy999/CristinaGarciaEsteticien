/* Cristina García · Centro de Estética & Bienestar
   Interacciones de la web (sin dependencias). */
(function () {
  'use strict';

  // Número de WhatsApp en formato internacional, sin "+" ni espacios.
  var WHATSAPP = '34622562920';

  var raiz = document.documentElement;
  window.appLista = true; // lo comprueba el script de seguridad de index.html

  /* ---------- Cabecera: fondo al hacer scroll ---------- */
  var cabecera = document.getElementById('cabecera');
  if (cabecera) {
    var alDesplazar = function () {
      cabecera.classList.toggle('cabecera--fija', window.scrollY > 12);
    };
    alDesplazar();
    window.addEventListener('scroll', alDesplazar, { passive: true });
  }

  /* ---------- Menú móvil ---------- */
  var botonMenu = document.getElementById('menu-boton');
  var nav = document.getElementById('navegacion');
  if (botonMenu && nav) {
    var cambiarMenu = function (abrir) {
      raiz.classList.toggle('menu-abierto', abrir);
      botonMenu.setAttribute('aria-expanded', String(abrir));
      botonMenu.setAttribute('aria-label', abrir ? 'Cerrar menú' : 'Abrir menú');
    };
    botonMenu.addEventListener('click', function () {
      cambiarMenu(!raiz.classList.contains('menu-abierto'));
    });
    nav.addEventListener('click', function (evento) {
      if (evento.target.closest('a')) { cambiarMenu(false); }
    });
    document.addEventListener('keydown', function (evento) {
      if (evento.key === 'Escape' && raiz.classList.contains('menu-abierto')) {
        cambiarMenu(false);
        botonMenu.focus();
      }
    });
    window.addEventListener('resize', function () {
      if (window.innerWidth > 1100) { cambiarMenu(false); }
    });
  }

  /* ---------- Aparición de elementos al hacer scroll ---------- */
  var revelables = document.querySelectorAll('.revelar');
  if ('IntersectionObserver' in window) {
    var observador = new IntersectionObserver(function (entradas) {
      entradas.forEach(function (entrada) {
        if (entrada.isIntersecting) {
          entrada.target.classList.add('visible');
          observador.unobserve(entrada.target);
        }
      });
    }, { rootMargin: '0px 0px -8% 0px', threshold: 0.08 });
    revelables.forEach(function (el) { observador.observe(el); });
  } else {
    revelables.forEach(function (el) { el.classList.add('visible'); });
  }

  /* ---------- Horario: estado "abierto ahora / cerrado" con la hora de España ----------
     Si cambia el horario, actualizarlo aquí y en la lista .horario de index.html.
     Días: 0 = domingo … 6 = sábado. Horas en formato HHMM. */
  var HORARIO = {
    0: null,            // domingo: solo eventos con cita
    1: null,            // lunes: cerrado
    2: [930, 1900],
    3: [930, 1900],
    4: [930, 1900],
    5: [1000, 2000],
    6: [1000, 1330]
  };
  var NOMBRES_DIA = ['domingo', 'lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado'];

  var formatoHora = function (hhmm) {
    return Math.floor(hhmm / 100) + ':' + ('0' + (hhmm % 100)).slice(-2);
  };

  var ahoraEnEspana = function () {
    try {
      var partes = new Intl.DateTimeFormat('en-US', {
        timeZone: 'Europe/Madrid', weekday: 'short', hour: '2-digit', minute: '2-digit', hourCycle: 'h23'
      }).formatToParts(new Date());
      var valor = {};
      partes.forEach(function (p) { valor[p.type] = p.value; });
      var dias = { Sun: 0, Mon: 1, Tue: 2, Wed: 3, Thu: 4, Fri: 5, Sat: 6 };
      return { dia: dias[valor.weekday], hora: parseInt(valor.hour, 10) * 100 + parseInt(valor.minute, 10) };
    } catch (e) {
      var d = new Date();
      return { dia: d.getDay(), hora: d.getHours() * 100 + d.getMinutes() };
    }
  };

  var calcularEstado = function () {
    var ahora = ahoraEnEspana();
    var hoy = HORARIO[ahora.dia];
    if (hoy && ahora.hora >= hoy[0] && ahora.hora < hoy[1]) {
      return { abierto: true, dia: ahora.dia, corto: 'Abierto ahora', largo: 'Abierto ahora · hasta las ' + formatoHora(hoy[1]) };
    }
    // Buscar la próxima apertura
    for (var i = 0; i < 8; i++) {
      var dia = (ahora.dia + i) % 7;
      var tramo = HORARIO[dia];
      if (!tramo || (i === 0 && ahora.hora >= tramo[0])) { continue; }
      var cuando = i === 0 ? 'hoy' : i === 1 ? 'mañana' : 'el ' + NOMBRES_DIA[dia];
      var texto = 'abre ' + cuando + ' a las ' + formatoHora(tramo[0]);
      return { abierto: false, dia: ahora.dia, corto: 'Cerrado · ' + texto, largo: 'Cerrado ahora · ' + texto };
    }
    return null;
  };

  var pintarEstado = function () {
    var estado = calcularEstado();
    if (!estado) { return; }
    document.querySelectorAll('[data-estado]').forEach(function (el) {
      el.textContent = estado[el.getAttribute('data-estado')] || estado.largo;
      el.classList.toggle('estado--abierto', estado.abierto);
      el.classList.toggle('estado--cerrado', !estado.abierto);
    });
    document.querySelectorAll('.horario li[data-dia]').forEach(function (li) {
      li.classList.toggle('hoy', Number(li.getAttribute('data-dia')) === estado.dia);
    });
  };
  pintarEstado();
  setInterval(pintarEstado, 60000);

  /* ---------- Carrusel de servicios en móvil: puntos indicadores ---------- */
  var rejillaServicios = document.querySelector('.servicios__rejilla');
  if (rejillaServicios) {
    var tarjetas = rejillaServicios.querySelectorAll('.servicio');
    var pista = document.createElement('div');
    pista.className = 'servicios__pista';
    pista.setAttribute('aria-hidden', 'true');
    tarjetas.forEach(function () { pista.appendChild(document.createElement('span')); });
    rejillaServicios.insertAdjacentElement('afterend', pista);
    var puntos = pista.querySelectorAll('span');
    var marcarPunto = function () {
      var paso = tarjetas.length > 1 ? tarjetas[1].offsetLeft - tarjetas[0].offsetLeft : 1;
      var max = rejillaServicios.scrollWidth - rejillaServicios.clientWidth;
      var indice = rejillaServicios.scrollLeft >= max - 4 ? tarjetas.length - 1 : Math.round(rejillaServicios.scrollLeft / paso);
      puntos.forEach(function (p, i) { p.classList.toggle('activo', i === indice); });
    };
    marcarPunto();
    rejillaServicios.addEventListener('scroll', marcarPunto, { passive: true });
  }

  /* ---------- Barra inferior / botón flotante: solo cuando ya no se ven los botones de la portada ---------- */
  var accionesPortada = document.querySelector('.hero__acciones');
  if (accionesPortada && 'IntersectionObserver' in window) {
    raiz.classList.add('acciones-visibles'); // al cargar arriba del todo están a la vista
    new IntersectionObserver(function (entradas) {
      raiz.classList.toggle('acciones-visibles', entradas[0].isIntersecting);
    }, { threshold: 0 }).observe(accionesPortada);
  }

  /* ---------- Galería: filtros por servicio, "ver más" y visor ---------- */
  var rejillaGaleria = document.getElementById('galeria-rejilla');
  if (rejillaGaleria) {
    var POR_TANDA = 8;
    var fotos = Array.prototype.slice.call(rejillaGaleria.querySelectorAll('.galeria__item'));
    var botonesFiltro = document.querySelectorAll('.filtro');
    var botonMas = document.getElementById('galeria-mas');
    var filtroActual = 'todo';
    var mostradas = POR_TANDA;

    var fotosDelFiltro = function () {
      return fotos.filter(function (f) {
        return filtroActual === 'todo' || f.getAttribute('data-categoria') === filtroActual;
      });
    };

    var pintarGaleria = function () {
      var visibles = fotosDelFiltro();
      fotos.forEach(function (f) { f.hidden = true; });
      visibles.forEach(function (f, i) { f.hidden = i >= mostradas; });
      if (botonMas) {
        var quedan = visibles.length - mostradas;
        botonMas.hidden = quedan <= 0;
        botonMas.textContent = 'Ver más trabajos (' + Math.max(quedan, 0) + ')';
      }
    };

    botonesFiltro.forEach(function (boton) {
      boton.addEventListener('click', function () {
        filtroActual = boton.getAttribute('data-filtro');
        mostradas = POR_TANDA;
        botonesFiltro.forEach(function (b) { b.setAttribute('aria-pressed', String(b === boton)); });
        pintarGaleria();
      });
    });

    if (botonMas) {
      botonMas.addEventListener('click', function () {
        var primeraNueva = fotosDelFiltro()[mostradas];
        mostradas += POR_TANDA;
        pintarGaleria();
        if (primeraNueva) { primeraNueva.querySelector('img').focus({ preventScroll: true }); }
      });
    }

    pintarGaleria();

    // Visor: al tocar una foto se abre en grande, con anterior / siguiente
    var visor = document.getElementById('visor');
    if (visor && typeof visor.showModal === 'function') {
      var visorImg = visor.querySelector('.visor__img');
      var visorTexto = visor.querySelector('.visor__texto');
      var indiceVisor = 0;

      var mostrarEnVisor = function (indice) {
        var lista = fotosDelFiltro();
        indiceVisor = (indice + lista.length) % lista.length;
        var img = lista[indiceVisor].querySelector('img');
        visorImg.src = img.getAttribute('src');
        visorImg.alt = img.alt;
        visorTexto.textContent = img.alt + ' · ' + (indiceVisor + 1) + ' de ' + lista.length;
      };

      fotos.forEach(function (f) {
        var img = f.querySelector('img');
        img.setAttribute('tabindex', '0');
        img.setAttribute('role', 'button');
        var abrir = function () {
          mostrarEnVisor(fotosDelFiltro().indexOf(f));
          visor.showModal();
        };
        img.addEventListener('click', abrir);
        img.addEventListener('keydown', function (e) {
          if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); abrir(); }
        });
      });

      visor.querySelector('.visor__cerrar').addEventListener('click', function () { visor.close(); });
      visor.querySelector('.visor__ant').addEventListener('click', function () { mostrarEnVisor(indiceVisor - 1); });
      visor.querySelector('.visor__sig').addEventListener('click', function () { mostrarEnVisor(indiceVisor + 1); });
      visor.addEventListener('click', function (e) { if (e.target === visor) { visor.close(); } });
      visor.addEventListener('keydown', function (e) {
        if (e.key === 'ArrowLeft') { mostrarEnVisor(indiceVisor - 1); }
        if (e.key === 'ArrowRight') { mostrarEnVisor(indiceVisor + 1); }
      });

      // Deslizar con el dedo para pasar de foto
      var inicioX = null;
      visor.addEventListener('touchstart', function (e) { inicioX = e.touches[0].clientX; }, { passive: true });
      visor.addEventListener('touchend', function (e) {
        if (inicioX === null) { return; }
        var dx = e.changedTouches[0].clientX - inicioX;
        if (Math.abs(dx) > 50) { mostrarEnVisor(indiceVisor + (dx < 0 ? 1 : -1)); }
        inicioX = null;
      });
    }
  }

  /* ---------- Año del pie ---------- */
  var anio = document.getElementById('anio');
  if (anio) { anio.textContent = String(new Date().getFullYear()); }

  /* ---------- Mapa: solo se carga si la persona lo pide (evita cookies de Google sin consentimiento) ---------- */
  var mapa = document.getElementById('mapa');
  var botonMapa = document.getElementById('mapa-cargar');
  if (mapa && botonMapa) {
    botonMapa.addEventListener('click', function () {
      var marco = document.createElement('iframe');
      marco.src = mapa.getAttribute('data-src');
      marco.title = 'Mapa: C/ Iglesia 16, bajo B, Casasimarro (Cuenca)';
      marco.loading = 'lazy';
      marco.referrerPolicy = 'no-referrer-when-downgrade';
      marco.setAttribute('allowfullscreen', '');
      mapa.textContent = '';
      mapa.appendChild(marco);
    });
  }

  /* ---------- Formulario de cita: abre WhatsApp con el mensaje ya escrito ---------- */
  var formulario = document.getElementById('form-cita');
  if (formulario) {
    formulario.addEventListener('submit', function (evento) {
      evento.preventDefault();
      var valor = function (nombre) {
        var campo = formulario.elements[nombre];
        return campo ? campo.value.trim() : '';
      };
      var lineas = ['Hola Cristina, me gustaría pedir cita.'];
      if (valor('nombre')) { lineas.push('Nombre: ' + valor('nombre')); }
      if (valor('servicio')) { lineas.push('Servicio: ' + valor('servicio')); }
      if (valor('dia')) { lineas.push('Preferencia: ' + valor('dia')); }
      if (valor('mensaje')) { lineas.push(valor('mensaje')); }
      var url = 'https://wa.me/' + WHATSAPP + '?text=' + encodeURIComponent(lineas.join('\n'));
      window.open(url, '_blank', 'noopener');
    });
  }

  /* ---------- Modo revisión: abrir la página con ?revision para ver lo pendiente ---------- */
  if (/[?&]revision\b/.test(window.location.search)) {
    raiz.classList.add('modo-revision');
    revelables.forEach(function (el) { el.classList.add('visible'); });
    var pendientes = document.querySelectorAll('[data-pendiente]');
    if (pendientes.length) {
      var panel = document.createElement('aside');
      panel.className = 'revision-panel';
      var titulo = document.createElement('strong');
      titulo.textContent = 'Pendiente de revisar (' + pendientes.length + ')';
      var lista = document.createElement('ol');
      pendientes.forEach(function (el) {
        var item = document.createElement('li');
        var boton = document.createElement('button');
        boton.type = 'button';
        boton.textContent = el.getAttribute('data-pendiente');
        boton.addEventListener('click', function () {
          el.scrollIntoView({ behavior: 'smooth', block: 'center' });
        });
        item.appendChild(boton);
        lista.appendChild(item);
      });
      panel.appendChild(titulo);
      panel.appendChild(lista);
      document.body.appendChild(panel);
    }
  }
})();
