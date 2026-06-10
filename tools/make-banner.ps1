# Renders the MD Advisory LinkedIn company banner (1128x191 spec, drawn at 2x)
param(
  [string]$OutFile = "C:\Users\mdass\Claude\Code\MDA\assets\mda-banner-linkedin.png"
)

Add-Type -AssemblyName System.Drawing

$W = 1128; $H = 191; $SCALE = 2
$fontPath = "C:\Users\mdass\Claude\Code\MDA\assets\Marcellus-Regular.ttf"
$pfc = New-Object System.Drawing.Text.PrivateFontCollection
$pfc.AddFontFile($fontPath)
$marcellus = $pfc.Families[0]

$bmp = New-Object System.Drawing.Bitmap(($W * $SCALE), ($H * $SCALE))
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAlias
$g.ScaleTransform($SCALE, $SCALE)

# ---- palette ----
$navy      = [System.Drawing.Color]::FromArgb(255, 8, 17, 32)
$navyMid   = [System.Drawing.Color]::FromArgb(255, 16, 32, 58)
$gold      = [System.Drawing.Color]::FromArgb(255, 201, 162, 63)
$goldLight = [System.Drawing.Color]::FromArgb(255, 227, 200, 120)
$goldDeep  = [System.Drawing.Color]::FromArgb(255, 176, 140, 46)
$steel     = [System.Drawing.Color]::FromArgb(255, 138, 151, 171)
$blue      = [System.Drawing.Color]::FromArgb(255, 62, 142, 221)
$ivory     = [System.Drawing.Color]::FromArgb(255, 242, 240, 234)
$mist      = [System.Drawing.Color]::FromArgb(255, 207, 216, 230)

# ---- background: navy, brighter toward upper right ----
$bgRect = New-Object System.Drawing.Rectangle(0, 0, $W, $H)
$bg = New-Object System.Drawing.Drawing2D.LinearGradientBrush($bgRect, $navy, $navyMid, 15.0)
$g.FillRectangle($bg, 0, 0, $W, $H)

# soft glow behind the gears (right side)
$glowPath = New-Object System.Drawing.Drawing2D.GraphicsPath
$glowPath.AddEllipse(790, -80, 360, 360)
$glow = New-Object System.Drawing.Drawing2D.PathGradientBrush($glowPath)
$glow.CenterColor = [System.Drawing.Color]::FromArgb(70, 62, 142, 221)
$glow.SurroundColors = @([System.Drawing.Color]::FromArgb(0, 8, 17, 32))
$g.FillRectangle($glow, 0, 0, $W, $H)

# ---- flowing accent curves across the banner ----
function Draw-Curve($g, $pts, $color, $w) {
  $pen = New-Object System.Drawing.Pen($color, $w)
  $pen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
  $pen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
  $g.DrawBezier($pen, $pts[0], $pts[1], $pts[2], $pts[3])
  $pen.Dispose()
}
$pGold = [System.Drawing.Color]::FromArgb(90, 201, 162, 63)
$pBlue = [System.Drawing.Color]::FromArgb(70, 62, 142, 221)
$pGold2 = [System.Drawing.Color]::FromArgb(45, 201, 162, 63)
Draw-Curve $g @([System.Drawing.PointF]::new(-40, 175), [System.Drawing.PointF]::new(300, 120), [System.Drawing.PointF]::new(700, 215), [System.Drawing.PointF]::new(1170, 120)) $pGold 1.6
Draw-Curve $g @([System.Drawing.PointF]::new(-40, 190), [System.Drawing.PointF]::new(360, 140), [System.Drawing.PointF]::new(760, 235), [System.Drawing.PointF]::new(1170, 150)) $pBlue 1.4
Draw-Curve $g @([System.Drawing.PointF]::new(-40, 35), [System.Drawing.PointF]::new(380, 75), [System.Drawing.PointF]::new(820, -20), [System.Drawing.PointF]::new(1170, 60)) $pGold2 1.2

# ---- gear trio (right side, meshed like the website hero) ----
function Draw-Gear($g, $cx, $cy, $hubR, $color) {
  $toothLen = $hubR * 0.20; $toothW = $hubR * 0.24
  $brush = New-Object System.Drawing.SolidBrush($color)
  for ($i = 0; $i -lt 12; $i++) {
    $state = $g.Save()
    $g.TranslateTransform($cx, $cy)
    $g.RotateTransform($i * 30)
    $g.FillRectangle($brush, (-$toothW / 2), (-($hubR + $toothLen)), $toothW, ($toothLen + 4))
    $g.Restore($state)
  }
  $hubFill = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 11, 21, 38))
  $g.FillEllipse($hubFill, ($cx - $hubR), ($cy - $hubR), (2 * $hubR), (2 * $hubR))
  $pen = New-Object System.Drawing.Pen($color, ($hubR * 0.12))
  $g.DrawEllipse($pen, ($cx - $hubR), ($cy - $hubR), (2 * $hubR), (2 * $hubR))
  $pen2 = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(110, $color.R, $color.G, $color.B), 1.2)
  $r2 = $hubR * 0.66
  $g.DrawEllipse($pen2, ($cx - $r2), ($cy - $r2), (2 * $r2), (2 * $r2))
  $brush.Dispose(); $hubFill.Dispose(); $pen.Dispose(); $pen2.Dispose()
}

# faint orbit ring behind gears
$orbit = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(50, 201, 162, 63), 1)
$orbit.DashStyle = [System.Drawing.Drawing2D.DashStyle]::Dot
$g.DrawEllipse($orbit, 880, 0, 196, 196)

# hub radius 33 -> tooth tips ~40; centers ~82 apart = near-mesh
Draw-Gear $g 978 50 33 $gold
Draw-Gear $g 936 122 33 $steel
Draw-Gear $g 1020 124 33 $blue

# ---- headline (text zone starts x=330; bottom-left stays quiet for logo) ----
function Draw-Text($g, $text, $font, $brush, $x, $y) {
  $g.DrawString($text, $font, $brush, [System.Drawing.PointF]::new($x, $y))
}
$f1 = New-Object System.Drawing.Font($marcellus, 33.0, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$ivoryBrush = New-Object System.Drawing.SolidBrush($ivory)
$goldGradRect = New-Object System.Drawing.RectangleF(330, 84, 560, 44)
$goldGrad = New-Object System.Drawing.Drawing2D.LinearGradientBrush($goldGradRect, $goldLight, $goldDeep, [System.Drawing.Drawing2D.LinearGradientMode]::Vertical)

Draw-Text $g "DEVELOPMENT & ADVANCEMENT" $f1 $ivoryBrush 330 38
Draw-Text $g "OPERATIONS" $f1 $goldGrad 330 84

# ---- motto ----
$f2 = New-Object System.Drawing.Font("Segoe UI", 13.0, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$mistBrush = New-Object System.Drawing.SolidBrush($mist)
$goldBrush = New-Object System.Drawing.SolidBrush($gold)
$mx = 332.0; $my = 140.0
foreach ($part in @("A L I G N", "*", "O P T I M I Z E", "*", "A C C E L E R A T E")) {
  if ($part -eq "*") {
    $g.FillEllipse($goldBrush, ($mx + 8), ($my + 6.0), 5, 5)
    $mx += 29
  } else {
    Draw-Text $g $part $f2 $mistBrush $mx $my
    $mx += $g.MeasureString($part, $f2).Width - 4
  }
}

# thin gold rule above headline
$rulePen = New-Object System.Drawing.Pen($gold, 2)
$g.DrawLine($rulePen, 332, 28, 392, 28)

$g.Dispose()
$bmp.Save($OutFile, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
Write-Output "wrote $OutFile"
