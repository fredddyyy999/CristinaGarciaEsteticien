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
$cafe   = [System.Drawing.ColorTranslator]::FromHtml('#4B3930')

# Monograma CG en un lienzo de 214x130 (las mismas curvas que assets/img/logo.svg)
function Nuevo-Monograma {
  $c = New-Object System.Drawing.Drawing2D.GraphicsPath
  $c.AddArc(16, 13, 104, 104, -38, -284)
  $g = New-Object System.Drawing.Drawing2D.GraphicsPath
  $g.AddArc(94, 13, 104, 104, -42, -310)
  $g.AddBezier(197.5, 72.2, 199.5, 58, 181, 53, 166, 62)
  $g.AddBezier(166, 62, 151, 71, 139, 76, 127, 63)
  return @($c, $g)
}

function Dibujar-Monograma($lienzo, [single]$x, [single]$y, [single]$ancho, $color, [single]$grosor) {
  $escala = $ancho / 214
  $matriz = New-Object System.Drawing.Drawing2D.Matrix
  $matriz.Translate($x, $y)
  $matriz.Scale($escala, $escala)
  $pluma = New-Object System.Drawing.Pen($color, $grosor)
  $pluma.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
  $pluma.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
  $pluma.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
  foreach ($trazo in (Nuevo-Monograma)) {
    $trazo.Transform($matriz)
    $lienzo.DrawPath($pluma, $trazo)
    $trazo.Dispose()
  }
  $pluma.Dispose()
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
Dibujar-Monograma $lienzo 27 51.7 126 $marron 4.2
$imagen.Save((Join-Path $destino 'apple-touch-icon.png'), [System.Drawing.Imaging.ImageFormat]::Png)
$lienzo.Dispose(); $imagen.Dispose()

# --- Imagen para compartir 1200x630 ---
$imagen, $lienzo = Nuevo-Lienzo 1200 630
$lienzo.Clear($crema)
$fondo = New-Object System.Drawing.SolidBrush($beige)
$lienzo.FillEllipse($fondo, 760, -260, 760, 760)
$lienzo.FillEllipse($fondo, -330, 330, 620, 620)
$fondo.Dispose()
Dibujar-Monograma $lienzo 440 96 320 $marron 6

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
