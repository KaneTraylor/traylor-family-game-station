# Renders the Traylor wordmark into the skin's 900x235 splash logo slot.
# Run from the repo root with Windows PowerShell:
#   powershell.exe -ExecutionPolicy Bypass -File tools\render-wordmark.ps1
Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$fontDir = Join-Path $root 'src\skin\Fonts'
$out = Join-Path $root 'src\skin\Images\Aurora.Skin.Scenes.Splash.Logo.Alternate.png'

$fonts = New-Object System.Drawing.Text.PrivateFontCollection
$fonts.AddFontFile((Join-Path $fontDir 'Inter-SemiBold.ttf'))
$fonts.AddFontFile((Join-Path $fontDir 'Inter-Light.ttf'))
$semi = $fonts.Families | Where-Object { $_.Name -eq 'Inter SemiBold' } | Select-Object -First 1
$light = $fonts.Families | Where-Object { $_.Name -eq 'Inter Light' } | Select-Object -First 1
if (-not $semi -or -not $light) { throw "Inter families not found: $($fonts.Families.Name -join ', ')" }

$w = 900; $h = 235
$bmp = New-Object System.Drawing.Bitmap $w, $h, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.Clear([System.Drawing.Color]::Transparent)
$g.SmoothingMode = 'AntiAlias'
$g.TextRenderingHint = 'AntiAliasGridFit'
$g.InterpolationMode = 'HighQualityBicubic'
$white = [System.Drawing.Brushes]::White
$fmt = [System.Drawing.StringFormat]::GenericTypographic

# Draws text one glyph at a time so we can letter-space it, centred on $cx.
function Draw-Spaced($text, $font, $tracking, $cx, $y) {
    $widths = @()
    foreach ($ch in $text.ToCharArray()) {
        # Typographic measurement collapses a lone space; give it a third of an em.
        if ($ch -eq ' ') { $widths += $font.Size * 0.33 }
        else { $widths += $g.MeasureString([string]$ch, $font, 10000, $fmt).Width }
    }
    $total = ($widths | Measure-Object -Sum).Sum + $tracking * ($text.Length - 1)
    $x = $cx - $total / 2
    for ($i = 0; $i -lt $text.Length; $i++) {
        $g.DrawString([string]$text[$i], $font, $white, $x, $y, $fmt)
        $x += $widths[$i] + $tracking
    }
}

$big = New-Object System.Drawing.Font $semi, 118, ([System.Drawing.FontStyle]::Regular), ([System.Drawing.GraphicsUnit]::Pixel)
$small = New-Object System.Drawing.Font $light, 40, ([System.Drawing.FontStyle]::Regular), ([System.Drawing.GraphicsUnit]::Pixel)
Draw-Spaced 'TRAYLOR' $big 26 ($w / 2) 34
Draw-Spaced 'Family Game Station' $small 6 ($w / 2) 162

$g.Dispose()
$bmp.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
Write-Output "wrote $out"

# Dark-backed copy for checking the result; build/ is ignored by git.
$previewDir = Join-Path $root 'build'
New-Item -ItemType Directory -Force $previewDir | Out-Null
$preview = New-Object System.Drawing.Bitmap $w, $h
$pg = [System.Drawing.Graphics]::FromImage($preview)
$pg.Clear([System.Drawing.Color]::FromArgb(255, 5, 7, 11))
$pg.DrawImage($bmp, 0, 0)
$pg.Dispose()
$preview.Save((Join-Path $previewDir 'wordmark-preview.png'), [System.Drawing.Imaging.ImageFormat]::Png)
$preview.Dispose()
$bmp.Dispose()
