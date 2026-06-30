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

  # ---- short fortune slip, tilted, poking from the top of the fold (behind cookie) ----
  $slip = New-Object System.Drawing.Drawing2D.GraphicsPath
  $slip.AddPolygon(@((P 47 41), (P 57 38), (P 62 22), (P 51 25)))
  $g.FillPath((New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 253, 247))), $slip)
  $g.DrawPath((New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(120, 110, 40), (1.6 * $sc))), $slip)
  $g.DrawLine((New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(90, 120, 60), (1.4 * $sc))), (P 52 30), (P 59 28))

  # ---- folded cookie body: a single domed "taco" mound (round belly, folded top) ----
  $cookie = New-Object System.Drawing.Drawing2D.GraphicsPath
  # domed top ridge: left tip -> right tip (convex up)
  $cookie.AddBezier((P 18 46), (P 28 34), (P 72 34), (P 82 46))
  # right tip -> rounded bottom center
  $cookie.AddBezier((P 82 46), (P 82 68), (P 66 80), (P 50 80))
  # bottom center -> left tip
  $cookie.AddBezier((P 50 80), (P 34 80), (P 18 68), (P 18 46))
  $cookie.CloseFigure()
  $g.FillPath($tan, $cookie)
  $g.DrawPath($pen, $cookie)

  # horizontal fold ridge just under the top edge (the doubled-over fold)
  $fold = New-Object System.Drawing.Drawing2D.GraphicsPath
  $fold.AddBezier((P 25 49), (P 38 41), (P 62 41), (P 75 49))
  $g.DrawPath($penThin, $fold)

  # fan of shell creases on the belly (what makes it read as a fortune cookie)
  $fan = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(120, 110, 40), (1.7 * $sc))
  $fan.StartCap = 'Round'; $fan.EndCap = 'Round'
  $c1 = New-Object System.Drawing.Drawing2D.GraphicsPath
  $c1.AddBezier((P 50 52), (P 41 60), (P 37 68), (P 35 74)); $g.DrawPath($fan, $c1)
  $c2 = New-Object System.Drawing.Drawing2D.GraphicsPath
  $c2.AddBezier((P 50 52), (P 50 62), (P 50 70), (P 50 77)); $g.DrawPath($fan, $c2)
  $c3 = New-Object System.Drawing.Drawing2D.GraphicsPath
  $c3.AddBezier((P 50 52), (P 59 60), (P 63 68), (P 65 74)); $g.DrawPath($fan, $c3)

  $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
  $g.Dispose(); $bmp.Dispose()
  Write-Output "wrote $path"
}

$dir = "C:\Users\garre\Documents\GitHub\fortune-cookie"
New-Icon 512 "$dir\icon-512.png"
New-Icon 192 "$dir\icon-192.png"
New-Icon 180 "$dir\apple-touch-icon.png"
