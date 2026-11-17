/* Cristina García · Se carga en el <head>, antes que el resto de la página.
   Va en un archivo aparte (y no dentro del HTML) para que la política de seguridad (CSP)
   pueda prohibir cualquier código escrito dentro de las páginas. */
(function () {
  'use strict';

  // Activa las animaciones de entrada; si app.js no llega a cargar, se desactivan
  // para que el contenido nunca quede oculto.
  document.documentElement.classList.add('js');
  setTimeout(function () {
    if (!window.appLista) { document.documentElement.classList.remove('js'); }
  }, 4000);

  // Fotos marcadas con data-quitar-si-falla: si el archivo no existe, se quitan
  // y se ve el fondo con el monograma (sustituye al antiguo onerror="this.remove()").
  document.addEventListener('error', function (evento) {
    var el = evento.target;
    if (el && el.tagName === 'IMG' && el.hasAttribute('data-quitar-si-falla')) { el.remove(); }
  }, true);
})();
