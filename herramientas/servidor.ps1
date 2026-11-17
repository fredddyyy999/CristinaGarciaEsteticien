# Servidor local para previsualizar la web (solo desarrollo; no hace falta subirlo al hosting).
# Uso:  powershell -ExecutionPolicy Bypass -File herramientas\servidor.ps1
# Luego abrir http://localhost:5173/

param([int]$Puerto = 5173)

$raiz = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path.TrimEnd('\')

$tipos = @{
  '.html' = 'text/html; charset=utf-8'
  '.css'  = 'text/css; charset=utf-8'
  '.js'   = 'text/javascript; charset=utf-8'
  '.json' = 'application/json; charset=utf-8'
  '.xml'  = 'application/xml; charset=utf-8'
  '.txt'  = 'text/plain; charset=utf-8'
  '.svg'  = 'image/svg+xml'
  '.png'  = 'image/png'
  '.jpg'  = 'image/jpeg'
  '.jpeg' = 'image/jpeg'
  '.webp' = 'image/webp'
  '.avif' = 'image/avif'
  '.gif'  = 'image/gif'
  '.ico'  = 'image/x-icon'
  '.woff2' = 'font/woff2'
  '.webmanifest' = 'application/manifest+json'
}

$script:soloCabeceras = $false

function Enviar($respuesta, [int]$codigo, [byte[]]$datos, [string]$tipo) {
  $respuesta.StatusCode = $codigo
  $respuesta.ContentType = $tipo
  $respuesta.Headers['Cache-Control'] = 'no-store'
  $respuesta.ContentLength64 = $datos.Length
  # En peticiones HEAD solo se envian las cabeceras
  if (-not $script:soloCabeceras) {
    $respuesta.OutputStream.Write($datos, 0, $datos.Length)
  }
}

$servidor = New-Object System.Net.HttpListener
$servidor.Prefixes.Add("http://localhost:$Puerto/")
$servidor.Start()
Write-Host "Web disponible en http://localhost:$Puerto/  (Ctrl+C para parar)"

try {
  while ($servidor.IsListening) {
    $contexto = $servidor.GetContext()
    $respuesta = $contexto.Response
    try {
      $script:soloCabeceras = ($contexto.Request.HttpMethod -eq 'HEAD')
      $ruta = [System.Uri]::UnescapeDataString($contexto.Request.Url.AbsolutePath)
      if ($ruta.EndsWith('/')) { $ruta += 'index.html' }
      $archivo = [System.IO.Path]::GetFullPath((Join-Path $raiz $ruta.TrimStart('/')))

      if (-not $archivo.StartsWith($raiz + '\', [System.StringComparison]::OrdinalIgnoreCase)) {
        Enviar $respuesta 403 ([System.Text.Encoding]::UTF8.GetBytes('403')) 'text/plain; charset=utf-8'
      }
      elseif (Test-Path -LiteralPath $archivo -PathType Leaf) {
        $ext = [System.IO.Path]::GetExtension($archivo).ToLowerInvariant()
        $tipo = $tipos[$ext]
        if (-not $tipo) { $tipo = 'application/octet-stream' }
        Enviar $respuesta 200 ([System.IO.File]::ReadAllBytes($archivo)) $tipo
      }
      else {
        $noEncontrado = Join-Path $raiz '404.html'
        if (Test-Path -LiteralPath $noEncontrado) {
          Enviar $respuesta 404 ([System.IO.File]::ReadAllBytes($noEncontrado)) 'text/html; charset=utf-8'
        } else {
          Enviar $respuesta 404 ([System.Text.Encoding]::UTF8.GetBytes('404')) 'text/plain; charset=utf-8'
        }
      }
      Write-Host ("{0} {1} {2}" -f $respuesta.StatusCode, $contexto.Request.HttpMethod, $ruta)
    }
    catch {
      Write-Host ("ERROR {0}" -f $_.Exception.Message)
    }
    finally {
      try { $respuesta.Close() } catch {}
    }
  }
}
finally {
  $servidor.Stop()
}
