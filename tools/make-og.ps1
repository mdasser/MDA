# Renders the Open Graph share image (1200x630) used in link previews (LinkedIn, etc.)
param(
  [string]$OutFile = "C:\Users\mdass\Claude\Code\MDA\assets\mda-og-image.png"
)

Add-Type -AssemblyName System.Drawing

$W = 1200; $H = 630
$fontPath = "C:\Users\mdass\Claude\Code\MDA\assets\Marcellus-Regular.ttf"
$pfc = New-Object System.Drawing.Text.PrivateFontCollection
$pfc.AddFontFile($fontPath)
$marcellus = $pfc.Families[0]

$bmp = New-Object System.Drawing.Bitmap($W, $H)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAlias

$navy      = [System.Drawing.Color]::FromArgb(255, 8, 17, 32)
$navyMid   = [System.Drawing.Color]::FromArgb(255, 16, 32, 58)
$gold      = [System.Drawing.Color]::FromArgb(255, 201, 162, 63)
$goldLight = [System.Drawing.Color]::FromArgb(255, 227, 200, 120)
$goldDeep  = [System.Drawing.Color]::FromArgb(255, 176, 140, 46)
$ivory     = [System.Drawing.Color]::FromArgb(255, 242, 240, 234)
$mist      = [System.Drawing.Color]::FromArgb(255, 207, 216, 230)

# background gradient + soft glow upper-right
$bgRect = New-Object System.Drawing.Rectangle(0, 0, $W, $H)
$bg = New-Object System.Drawing.Drawing2D.LinearGradientBrush($bgRect, $navy, $navyMid, 20.0)
$g.FillRectangle($bg, 0, 0, $W, $H)
$glowPath = New-Object System.Drawing.Drawing2D.GraphicsPath
$glowPath.AddEllipse(700, -250, 800, 800)
$glow = New-Object System.Drawing.Drawing2D.PathGradientBrush($glowPath)
$glow.CenterColor = [System.Drawing.Color]::FromArgb(55, 62, 142, 221)
$glow.SurroundColors = @([System.Drawing.Color]::FromArgb(0, 8, 17, 32))
$g.FillRectangle($glow, 0, 0, $W, $H)

# monogram ring, left side
$cx = 280.0; $cy = 315.0; $r = 150.0
$pen = New-Object System.Drawing.Pen($gold, 9)
$g.DrawEllipse($pen, ($cx - $r), ($cy - $r), (2 * $r), (2 * $r))
$pen2 = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(140, 201, 162, 63), 2)
$r2 = $r - 14
$g.DrawEllipse($pen2, ($cx - $r2), ($cy - $r2), (2 * $r2), (2 * $r2))

$fMono = New-Object System.Drawing.Font($marcellus, 120.0, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$sf = New-Object System.Drawing.StringFormat
$sf.Alignment = [System.Drawing.StringAlignment]::Center
$sf.LineAlignment = [System.Drawing.StringAlignment]::Center
$gradRect = New-Object System.Drawing.RectangleF(($cx - $r), ($cy - 60), (2 * $r), 120)
$monoBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush($gradRect, $goldLight, $goldDeep, [System.Drawing.Drawing2D.LinearGradientMode]::Vertical)
$monoRect = New-Object System.Drawing.RectangleF(($cx - $r), ($cy - $r - 5), (2 * $r), (2 * $r))
$g.DrawString("MD", $fMono, $monoBrush, $monoRect, $sf)

# text block, right side
$tx = 510.0
$fName = New-Object System.Drawing.Font($marcellus, 64.0, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$ivoryBrush = New-Object System.Drawing.SolidBrush($ivory)
$g.DrawString("MD Advisory, LLC", $fName, $ivoryBrush, [System.Drawing.PointF]::new($tx, 175))

$rulePen = New-Object System.Drawing.Pen($gold, 3)
$g.DrawLine($rulePen, $tx + 6, 270, $tx + 126, 270)

$fSub = New-Object System.Drawing.Font($marcellus, 34.0, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$subGradRect = New-Object System.Drawing.RectangleF($tx, 300, 620, 100)
$subBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush($subGradRect, $goldLight, $goldDeep, [System.Drawing.Drawing2D.LinearGradientMode]::Vertical)
$g.DrawString("DEVELOPMENT & ADVANCEMENT", $fSub, $subBrush, [System.Drawing.PointF]::new($tx + 6, 300))
$g.DrawString("OPERATIONS", $fSub, $subBrush, [System.Drawing.PointF]::new($tx + 6, 348))

$fMotto = New-Object System.Drawing.Font("Segoe UI", 24.0, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$mistBrush = New-Object System.Drawing.SolidBrush($mist)
$goldBrush = New-Object System.Drawing.SolidBrush($gold)
$mx = $tx + 6; $my = 432.0
foreach ($part in @("A L I G N", "*", "O P T I M I Z E", "*", "A C C E L E R A T E")) {
  if ($part -eq "*") {
    $g.FillEllipse($goldBrush, ($mx + 12), ($my + 11.0), 8, 8)
    $mx += 44
  } else {
    $g.DrawString($part, $fMotto, $mistBrush, [System.Drawing.PointF]::new($mx, $my))
    $mx += $g.MeasureString($part, $fMotto).Width - 6
  }
}

$g.Dispose()
$bmp.Save($OutFile, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
Write-Output "wrote $OutFile"
