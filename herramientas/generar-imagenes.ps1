# Genera las imagenes de marca en PNG a partir del monograma:
#   assets/img/apple-touch-icon.png  (180x180, icono al guardar la web en el movil)
#   assets/img/og.png                (1200x630, vista previa al compartir el enlace)
# Uso:  powershell -ExecutionPolicy Bypass -File herramientas\generar-imagenes.ps1
# (Solo hace falta volver a ejecutarlo si cambia el logotipo o los colores.)

Add-Type -AssemblyName System.Drawing

$destino = Join-Path (Resolve-Path (Join-Path $PSScriptRoot '..')).Path 'assets\img'

$beige  = [System.Drawing.ColorTranslator]::FromHtml('#D8CEBF')
$crema  = [System.Drawing.ColorTranslator]::FromHtml('#F7F2EB')
$marron = [System.Drawing.ColorTranslator]::FromHtml('#6B5143')
$logo   = [System.Drawing.ColorTranslator]::FromHtml('#605044') # marrón oficial del logotipo
$cafe   = [System.Drawing.ColorTranslator]::FromHtml('#4B3930')

# Monograma CG oficial: se lee el trazado de assets/img/logo.svg (solo usa comandos M, C y Z absolutos)
$svgLogo = [IO.File]::ReadAllText((Join-Path $destino 'logo.svg'))
$trazadoLogo = ([regex]'\sd="([^"]+)"').Match($svgLogo).Groups[1].Value
$vbLogo = ([regex]'viewBox="([^"]+)"').Match($svgLogo).Groups[1].Value.Split(' ') | ForEach-Object { [single]::Parse($_, [Globalization.CultureInfo]::InvariantCulture) }

function Nuevo-Monograma {
  $ruta = New-Object System.Drawing.Drawing2D.GraphicsPath([System.Drawing.Drawing2D.FillMode]::Alternate)
  $inv = [Globalization.CultureInfo]::InvariantCulture
  $actual = $null
  foreach ($m in [regex]::Matches($trazadoLogo, '([MCZ])([^MCZ]*)')) {
    $nums = [regex]::Matches($m.Groups[2].Value, '-?\d+(?:\.\d+)?') | ForEach-Object { [single]::Parse($_.Value, $inv) }
    switch ($m.Groups[1].Value) {
      'M' { $ruta.StartFigure(); $actual = New-Object System.Drawing.PointF($nums[0], $nums[1]) }
      'C' {
        for ($i = 0; $i + 5 -lt $nums.Count; $i += 6) {
          $fin = New-Object System.Drawing.PointF($nums[$i + 4], $nums[$i + 5])
          $ruta.AddBezier($actual, (New-Object System.Drawing.PointF($nums[$i], $nums[$i + 1])), (New-Object System.Drawing.PointF($nums[$i + 2], $nums[$i + 3])), $fin)
          $actual = $fin
        }
      }
      'Z' { $ruta.CloseFigure() }
    }
  }
  return $ruta
}

# Dibuja el monograma relleno con su esquina superior izquierda en (x, y) y el ancho indicado
function Dibujar-Monograma($lienzo, [single]$x, [single]$y, [single]$ancho, $color) {
  $escala = $ancho / $vbLogo[2]
  $matriz = New-Object System.Drawing.Drawing2D.Matrix
  $matriz.Translate($x, $y)
  $matriz.Scale($escala, $escala)
  $matriz.Translate(-$vbLogo[0], -$vbLogo[1])
  $ruta = Nuevo-Monograma
  $ruta.Transform($matriz)
  $pincel = New-Object System.Drawing.SolidBrush($color)
  $lienzo.FillPath($pincel, $ruta)
  $pincel.Dispose(); $ruta.Dispose()
}

# Texto centrado con espaciado entre letras
function Dibujar-Texto($lienzo, [string]$texto, $fuente, $color, [single]$centroX, [single]$y, [single]$espaciado) {
  $formato = [System.Drawing.StringFormat]::GenericTypographic.Clone()
  $formato.FormatFlags = $formato.FormatFlags -bor [System.Drawing.StringFormatFlags]::MeasureTrailingSpaces
  $origen = New-Object System.Drawing.PointF(0, 0)
  $anchos = @()
  foreach ($letra in $texto.ToCharArray()) {
    $anchos += $lienzo.MeasureString([string]$letra, $fuente, $origen, $formato).Width
  }
  $total = ($anchos | Measure-Object -Sum).Sum + $espaciado * ($texto.Length - 1)
  $x = $centroX - $total / 2
  $pincel = New-Object System.Drawing.SolidBrush($color)
  for ($i = 0; $i -lt $texto.Length; $i++) {
    $lienzo.DrawString([string]$texto[$i], $fuente, $pincel, [single]$x, $y, $formato)
    $x += $anchos[$i] + $espaciado
  }
  $pincel.Dispose()
}

function Nuevo-Lienzo([int]$ancho, [int]$alto) {
  $imagen = New-Object System.Drawing.Bitmap($ancho, $alto)
  $lienzo = [System.Drawing.Graphics]::FromImage($imagen)
  $lienzo.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $lienzo.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAlias
  $lienzo.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
  return @($imagen, $lienzo)
}

# --- Icono 180x180 ---
$imagen, $lienzo = Nuevo-Lienzo 180 180
$lienzo.Clear($beige)
Dibujar-Monograma $lienzo 27 51.7 126 $logo
$imagen.Save((Join-Path $destino 'apple-touch-icon.png'), [System.Drawing.Imaging.ImageFormat]::Png)
$lienzo.Dispose(); $imagen.Dispose()

# --- Imagen para compartir 1200x630 ---
$imagen, $lienzo = Nuevo-Lienzo 1200 630
$lienzo.Clear($crema)
$fondo = New-Object System.Drawing.SolidBrush($beige)
$lienzo.FillEllipse($fondo, 760, -260, 760, 760)
$lienzo.FillEllipse($fondo, -330, 330, 620, 620)
$fondo.Dispose()
Dibujar-Monograma $lienzo 440 96 320 $logo

$i = [char]0x00CD   # I con tilde
$e = [char]0x00C9   # E con tilde
$punto = [char]0x00B7
$serif = New-Object System.Drawing.Font('Palatino Linotype', 54, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$sans  = New-Object System.Drawing.Font('Segoe UI Light', 23, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
Dibujar-Texto $lienzo "CRISTINA GARC${i}A" $serif $cafe 600 338 13
Dibujar-Texto $lienzo "CENTRO DE EST${e}TICA & BIENESTAR" $sans $marron 600 432 7
Dibujar-Texto $lienzo "CASASIMARRO $punto CUENCA" $sans $marron 600 500 7
$linea = New-Object System.Drawing.Pen($marron, 1.4)
$lienzo.DrawLine($linea, 560, 480, 640, 480)
$linea.Dispose(); $serif.Dispose(); $sans.Dispose()
$imagen.Save((Join-Path $destino 'og.png'), [System.Drawing.Imaging.ImageFormat]::Png)
$lienzo.Dispose(); $imagen.Dispose()

Write-Host "Imagenes generadas en $destino"
