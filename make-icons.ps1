Add-Type -AssemblyName System.Drawing

function New-Icon([int]$S, [string]$path) {
  $bmp = New-Object System.Drawing.Bitmap($S, $S)
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = 'AntiAlias'
  $g.InterpolationMode = 'HighQualityBicubic'

  $sc = $S / 100.0

  # ---- background: rounded square with warm gold vertical gradient ----
  $rectF = New-Object System.Drawing.RectangleF(0, 0, $S, $S)
  $bg = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    $rectF,
    [System.Drawing.Color]::FromArgb(232, 192, 112),
    [System.Drawing.Color]::FromArgb(192, 122, 40),
    [System.Drawing.Drawing2D.LinearGradientMode]::Vertical)
  $rad = 22 * $sc
  $bgPath = New-Object System.Drawing.Drawing2D.GraphicsPath
  $d = $rad * 2
  $bgPath.AddArc(0, 0, $d, $d, 180, 90)
  $bgPath.AddArc($S - $d, 0, $d, $d, 270, 90)
  $bgPath.AddArc($S - $d, $S - $d, $d, $d, 0, 90)
  $bgPath.AddArc(0, $S - $d, $d, $d, 90, 90)
  $bgPath.CloseFigure()
  $g.FillPath($bg, $bgPath)

  function P([double]$x, [double]$y) { New-Object System.Drawing.PointF(($x * $sc), ($y * $sc)) }

  $tan    = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(245, 222, 150))
  $tanHi  = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(250, 232, 174))
  $pen    = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(150, 110, 40), (3.4 * $sc))
  $pen.LineJoin = 'Round'; $pen.StartCap = 'Round'; $pen.EndCap = 'Round'
  $penThin = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(150, 110, 40), (2.0 * $sc))

  # ---- fortune slip poking up from the fold (drawn first, behind cookie top) ----
  $slip = New-Object System.Drawing.Drawing2D.GraphicsPath
  $slip.AddPolygon(@((P 45 40), (P 57 37), (P 61 12), (P 49 15)))
  $g.FillPath((New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 253, 247))), $slip)
  $g.DrawPath((New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(120, 110, 40), (1.6 * $sc))), $slip)
  $g.DrawLine((New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(90, 120, 60), (1.4 * $sc))), (P 50 20), (P 57 18))

  # ---- folded cookie = two overlapping lobes (peanut shape) ----
  # left lobe
  $g.FillEllipse($tan, (12 * $sc), (34 * $sc), (46 * $sc), (46 * $sc))
  # right lobe
  $g.FillEllipse($tan, (42 * $sc), (34 * $sc), (46 * $sc), (46 * $sc))
  # outline each lobe -> the crossing arcs form the central fold/seam
  $g.DrawEllipse($pen, (12 * $sc), (34 * $sc), (46 * $sc), (46 * $sc))
  $g.DrawEllipse($pen, (42 * $sc), (34 * $sc), (46 * $sc), (46 * $sc))

  # little crease lines on each lobe
  $g.DrawArc($penThin, (20 * $sc), (44 * $sc), (20 * $sc), (26 * $sc), 110, 140)
  $g.DrawArc($penThin, (60 * $sc), (44 * $sc), (20 * $sc), (26 * $sc), 290, 140)

  $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
  $g.Dispose(); $bmp.Dispose()
  Write-Output "wrote $path"
}

$dir = "C:\Users\garre\Documents\GitHub\fortune-cookie"
New-Icon 512 "$dir\icon-512.png"
New-Icon 192 "$dir\icon-192.png"
New-Icon 180 "$dir\apple-touch-icon.png"
