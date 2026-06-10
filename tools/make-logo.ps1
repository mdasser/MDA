# Renders the MD Advisory monogram logo to PNG (square, LinkedIn-ready)
param(
  [int]$Size = 1024,
  [double]$MarkScale = 1.0,  # 1.0 = ring nearly fills the square; 0.5 = half-size mark with padding
  [string]$OutFile = "C:\Users\mdass\Claude\Code\MDA\assets\mda-logo-1024.png"
)

Add-Type -AssemblyName System.Drawing

$fontPath = "C:\Users\mdass\Claude\Code\MDA\assets\Marcellus-Regular.ttf"
$pfc = New-Object System.Drawing.Text.PrivateFontCollection
$pfc.AddFontFile($fontPath)
$family = $pfc.Families[0]

$bmp = New-Object System.Drawing.Bitmap($Size, $Size)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAlias

# background: deep navy with a soft radial highlight upper-left
$navy = [System.Drawing.Color]::FromArgb(255, 8, 17, 32)
$g.Clear($navy)
$path = New-Object System.Drawing.Drawing2D.GraphicsPath
$path.AddEllipse(-0.4 * $Size, -0.4 * $Size, 1.3 * $Size, 1.3 * $Size)
$radial = New-Object System.Drawing.Drawing2D.PathGradientBrush($path)
$radial.CenterColor = [System.Drawing.Color]::FromArgb(255, 18, 35, 63)
$radial.SurroundColors = @($navy)
$g.FillRectangle($radial, 0, 0, $Size, $Size)

$gold = [System.Drawing.Color]::FromArgb(255, 201, 162, 63)
$goldLight = [System.Drawing.Color]::FromArgb(255, 227, 200, 120)
$goldDeep = [System.Drawing.Color]::FromArgb(255, 176, 140, 46)

# outer ring
$scale = ($Size / 1024.0) * $MarkScale
$ringW = 24 * $scale
$r = 420 * $scale
$cx = $Size / 2.0
$pen = New-Object System.Drawing.Pen($gold, $ringW)
$g.DrawEllipse($pen, ($cx - $r), ($cx - $r), (2 * $r), (2 * $r))

# inner hairline ring
$pen2 = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(140, 201, 162, 63), (4 * $scale))
$r2 = 380 * $scale
$g.DrawEllipse($pen2, ($cx - $r2), ($cx - $r2), (2 * $r2), (2 * $r2))

# MD monogram with vertical gold gradient
$fontSize = [float](340 * $scale)
$font = New-Object System.Drawing.Font($family, $fontSize, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$sf = New-Object System.Drawing.StringFormat
$sf.Alignment = [System.Drawing.StringAlignment]::Center
$sf.LineAlignment = [System.Drawing.StringAlignment]::Center
$gradRect = New-Object System.Drawing.RectangleF(0, ($cx - $fontSize / 2), $Size, $fontSize)
$textBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush($gradRect, $goldLight, $goldDeep, [System.Drawing.Drawing2D.LinearGradientMode]::Vertical)
# slight upward nudge: Marcellus caps sit a touch low when line-centered
$textRect = New-Object System.Drawing.RectangleF(0, [float](-14 * $scale), $Size, $Size)
$g.DrawString("MD", $font, $textBrush, $textRect, $sf)

$g.Dispose()
$bmp.Save($OutFile, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
Write-Output "wrote $OutFile"
