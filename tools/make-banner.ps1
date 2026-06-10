# Renders the MD Advisory LinkedIn company banner (1128x191 spec, drawn at 2x)
# Gear trio mirrors the website hero: icons + PEOPLE/PROCESS/TECHNOLOGY labels.
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

# ---- palette (matches css/styles.css) ----
$navy      = [System.Drawing.Color]::FromArgb(255, 8, 17, 32)
$navyMid   = [System.Drawing.Color]::FromArgb(255, 16, 32, 58)
$hubNavy   = [System.Drawing.Color]::FromArgb(255, 11, 21, 38)
$gold      = [System.Drawing.Color]::FromArgb(255, 201, 162, 63)
$goldLight = [System.Drawing.Color]::FromArgb(255, 227, 200, 120)
$goldDeep  = [System.Drawing.Color]::FromArgb(255, 176, 140, 46)
$steel     = [System.Drawing.Color]::FromArgb(255, 138, 151, 171)
$steelIcon = [System.Drawing.Color]::FromArgb(255, 195, 205, 218)
$blue      = [System.Drawing.Color]::FromArgb(255, 62, 142, 221)
$blueIcon  = [System.Drawing.Color]::FromArgb(255, 142, 196, 245)
$ivory     = [System.Drawing.Color]::FromArgb(255, 242, 240, 234)
$mist      = [System.Drawing.Color]::FromArgb(255, 207, 216, 230)

# ---- background ----
$bgRect = New-Object System.Drawing.Rectangle(0, 0, $W, $H)
$bg = New-Object System.Drawing.Drawing2D.LinearGradientBrush($bgRect, $navy, $navyMid, 15.0)
$g.FillRectangle($bg, 0, 0, $W, $H)

$glowPath = New-Object System.Drawing.Drawing2D.GraphicsPath
$glowPath.AddEllipse(770, -90, 400, 400)
$glow = New-Object System.Drawing.Drawing2D.PathGradientBrush($glowPath)
$glow.CenterColor = [System.Drawing.Color]::FromArgb(70, 62, 142, 221)
$glow.SurroundColors = @([System.Drawing.Color]::FromArgb(0, 8, 17, 32))
$g.FillRectangle($glow, 0, 0, $W, $H)

# ---- flowing accent curves ----
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

# ---- labeled gear (website-hero style: teeth, hub, icon, label) ----
function Draw-GearLabeled($g, $cx, $cy, $hubR, $color, $iconColor, $label, $kind, $toothPhase) {
  $s = $hubR / 72.0   # site hub radius is 72; icon coords below are site-space * $s
  $toothLen = $hubR * 0.28; $toothW = $hubR * 0.26
  $brush = New-Object System.Drawing.SolidBrush($color)
  for ($i = 0; $i -lt 12; $i++) {
    $state = $g.Save()
    $g.TranslateTransform($cx, $cy)
    $g.RotateTransform(($i * 30) + $toothPhase)
    $rr = New-Object System.Drawing.Drawing2D.GraphicsPath
    $rr.AddRectangle([System.Drawing.RectangleF]::new((-$toothW / 2), (-($hubR + $toothLen)), $toothW, ($toothLen + 5)))
    $g.FillPath($brush, $rr)
    $g.Restore($state)
  }
  # hub
  $hubFill = New-Object System.Drawing.SolidBrush($hubNavy)
  $g.FillEllipse($hubFill, ($cx - $hubR), ($cy - $hubR), (2 * $hubR), (2 * $hubR))
  $pen = New-Object System.Drawing.Pen($color, ($hubR * 0.10))
  $g.DrawEllipse($pen, ($cx - $hubR), ($cy - $hubR), (2 * $hubR), (2 * $hubR))

  $state = $g.Save()
  $g.TranslateTransform($cx, $cy)
  $iconBrush = New-Object System.Drawing.SolidBrush($iconColor)
  $iconBrushDim = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(190, $iconColor.R, $iconColor.G, $iconColor.B))
  $iconPen = New-Object System.Drawing.Pen($iconColor, (3.4 * $s))
  $iconPen.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round

  if ($kind -eq "people") {
    # side figures (dimmed)
    $g.FillEllipse($iconBrushDim, ((-22 - 7) * $s), ((-10 - 7) * $s), (14 * $s), (14 * $s))
    $g.FillEllipse($iconBrushDim, ((22 - 7) * $s), ((-10 - 7) * $s), (14 * $s), (14 * $s))
    $g.FillPie($iconBrushDim, (-33 * $s), (2 * $s), (22 * $s), (20 * $s), 180, 180)
    $g.FillRectangle($iconBrushDim, (-33 * $s), (11.9 * $s), (22 * $s), (4 * $s))
    $g.FillPie($iconBrushDim, (11 * $s), (2 * $s), (22 * $s), (20 * $s), 180, 180)
    $g.FillRectangle($iconBrushDim, (11 * $s), (11.9 * $s), (22 * $s), (4 * $s))
    # center figure
    $g.FillEllipse($iconBrush, (-9 * $s), (-25 * $s), (18 * $s), (18 * $s))
    $g.FillPie($iconBrush, (-14 * $s), (-4 * $s), (28 * $s), (24 * $s), 180, 180)
    $g.FillRectangle($iconBrush, (-14 * $s), (7.9 * $s), (28 * $s), (6 * $s))
  }
  elseif ($kind -eq "process") {
    $g.DrawRectangle($iconPen, (-26 * $s), (-24 * $s), (22 * $s), (15 * $s))
    $g.DrawRectangle($iconPen, (6 * $s), (-10 * $s), (22 * $s), (15 * $s))
    $g.DrawRectangle($iconPen, (-26 * $s), (6 * $s), (22 * $s), (15 * $s))
    $g.DrawLines($iconPen, @([System.Drawing.PointF]::new((-4 * $s), (-16 * $s)), [System.Drawing.PointF]::new((2 * $s), (-16 * $s)), [System.Drawing.PointF]::new((2 * $s), (-3 * $s))))
    $g.DrawLines($iconPen, @([System.Drawing.PointF]::new((-4 * $s), (13 * $s)), [System.Drawing.PointF]::new((2 * $s), (13 * $s)), [System.Drawing.PointF]::new((2 * $s), (3 * $s))))
  }
  elseif ($kind -eq "tech") {
    $g.DrawRectangle($iconPen, (-14 * $s), (-22 * $s), (28 * $s), (28 * $s))
    foreach ($yy in @(-15, -8, -1)) {
      $g.DrawLine($iconPen, (-14 * $s), ($yy * $s), (-24 * $s), ($yy * $s))
      $g.DrawLine($iconPen, (14 * $s), ($yy * $s), (24 * $s), ($yy * $s))
    }
    foreach ($xx in @(-8, 0, 8)) {
      $g.DrawLine($iconPen, ($xx * $s), (-22 * $s), ($xx * $s), (-31 * $s))
      $g.DrawLine($iconPen, ($xx * $s), (6 * $s), ($xx * $s), (15 * $s))
    }
  }

  # label
  $lf = New-Object System.Drawing.Font("Segoe UI", (15.5 * $s), [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
  $sf = New-Object System.Drawing.StringFormat
  $sf.Alignment = [System.Drawing.StringAlignment]::Center
  $g.DrawString($label, $lf, $iconBrush, [System.Drawing.PointF]::new(0, (36 * $s)), $sf)

  $g.Restore($state)
  $brush.Dispose(); $hubFill.Dispose(); $pen.Dispose(); $iconBrush.Dispose(); $iconBrushDim.Dispose(); $iconPen.Dispose(); $lf.Dispose()
}

# faint orbit ring behind gears
$orbit = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(50, 201, 162, 63), 1)
$orbit.DashStyle = [System.Drawing.Drawing2D.DashStyle]::Dot
$g.DrawEllipse($orbit, 850, -10, 220, 220)

# trio: hub r=42, tooth tips ~54, centers ~96-100 apart for a tight interlock
Draw-GearLabeled $g 962 54 42 $gold  $goldLight "PEOPLE"     "people"  0
Draw-GearLabeled $g 912 136 42 $steel $steelIcon "PROCESS"    "process" 15
Draw-GearLabeled $g 1012 136 42 $blue  $blueIcon  "TECHNOLOGY" "tech"    0

# ---- headline (text zone x 330-820; bottom-left stays quiet for logo) ----
function Draw-Text($g, $text, $font, $brush, $x, $y) {
  $g.DrawString($text, $font, $brush, [System.Drawing.PointF]::new($x, $y))
}
$f1 = New-Object System.Drawing.Font($marcellus, 30.0, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$ivoryBrush = New-Object System.Drawing.SolidBrush($ivory)
$goldGradRect = New-Object System.Drawing.RectangleF(330, 84, 560, 40)
$goldGrad = New-Object System.Drawing.Drawing2D.LinearGradientBrush($goldGradRect, $goldLight, $goldDeep, [System.Drawing.Drawing2D.LinearGradientMode]::Vertical)

Draw-Text $g "DEVELOPMENT & ADVANCEMENT" $f1 $ivoryBrush 330 40
Draw-Text $g "OPERATIONS" $f1 $goldGrad 330 84

# ---- motto ----
$f2 = New-Object System.Drawing.Font("Segoe UI", 13.0, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$mistBrush = New-Object System.Drawing.SolidBrush($mist)
$goldBrush = New-Object System.Drawing.SolidBrush($gold)
$mx = 332.0; $my = 138.0
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
$g.DrawLine($rulePen, 332, 30, 392, 30)

$g.Dispose()
$bmp.Save($OutFile, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
Write-Output "wrote $OutFile"
