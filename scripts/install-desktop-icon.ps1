# Creates an "Angela's Projects" shortcut on your Desktop with a generated hub icon.
# Run once:  powershell -ExecutionPolicy Bypass -File scripts\install-desktop-icon.ps1
$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent $PSScriptRoot
$icoPath = Join-Path $PSScriptRoot "angela-projects.ico"

$size = 256
$bmp = New-Object System.Drawing.Bitmap $size, $size
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.Clear([System.Drawing.Color]::Transparent)

$radius = 52
$path = New-Object System.Drawing.Drawing2D.GraphicsPath
$path.AddArc(0, 0, $radius, $radius, 180, 90)
$path.AddArc($size - $radius, 0, $radius, $radius, 270, 90)
$path.AddArc($size - $radius, $size - $radius, $radius, $radius, 0, 90)
$path.AddArc(0, $size - $radius, $radius, $radius, 90, 90)
$path.CloseFigure()

$rect = New-Object System.Drawing.Rectangle 0, 0, $size, $size
$pink = [System.Drawing.Color]::FromArgb(255, 95, 162)
$purple = [System.Drawing.Color]::FromArgb(124, 92, 255)
$brush = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rect, $pink, $purple, 45)
$g.FillPath($brush, $path)

$ink = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(15, 16, 32))
$white = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::White)
$pen = New-Object System.Drawing.Pen $white, 10
$pen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$pen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round

$cx = $size / 2
$cy = 98
$g.DrawArc($pen, $cx - 34, $cy - 22, 68, 44, 200, 140)
$g.DrawArc($pen, $cx - 34, $cy + 2, 68, 44, -20, 140)

$font = New-Object System.Drawing.Font("Segoe UI", 34, [System.Drawing.FontStyle]::Bold)
$fmt = New-Object System.Drawing.StringFormat
$fmt.Alignment = [System.Drawing.StringAlignment]::Center
$fmt.LineAlignment = [System.Drawing.StringAlignment]::Center
$fmt.FormatFlags = [System.Drawing.StringFormatFlags]::NoWrap
$textRect = New-Object System.Drawing.RectangleF 0, 156, $size, 72
$g.DrawString("HUB", $font, $white, $textRect, $fmt)
$g.Dispose()

$dim = $size
$lockRect = New-Object System.Drawing.Rectangle 0, 0, $dim, $dim
$bd = $bmp.LockBits($lockRect, [System.Drawing.Imaging.ImageLockMode]::ReadOnly, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$stride = $bd.Stride
$px = New-Object byte[] ($stride * $dim)
[System.Runtime.InteropServices.Marshal]::Copy($bd.Scan0, $px, 0, $px.Length)
$bmp.UnlockBits($bd)

$xorSize = $dim * $dim * 4
$andSize = $dim * ($dim / 8)
$dibSize = 40 + $xorSize + $andSize

$ico = New-Object System.IO.MemoryStream
$bw = New-Object System.IO.BinaryWriter $ico
$bw.Write([UInt16]0); $bw.Write([UInt16]1); $bw.Write([UInt16]1)
$bw.Write([Byte]0); $bw.Write([Byte]0); $bw.Write([Byte]0); $bw.Write([Byte]0)
$bw.Write([UInt16]1); $bw.Write([UInt16]32)
$bw.Write([UInt32]$dibSize); $bw.Write([UInt32]22)
$bw.Write([UInt32]40); $bw.Write([Int32]$dim); $bw.Write([Int32]($dim * 2))
$bw.Write([UInt16]1); $bw.Write([UInt16]32); $bw.Write([UInt32]0)
$bw.Write([UInt32]0); $bw.Write([Int32]0); $bw.Write([Int32]0)
$bw.Write([UInt32]0); $bw.Write([UInt32]0)
for ($y = $dim - 1; $y -ge 0; $y--) { $bw.Write($px, $y * $stride, $stride) }
$bw.Write((New-Object byte[] $andSize))
$bw.Flush()
[System.IO.File]::WriteAllBytes($icoPath, $ico.ToArray())
Write-Host "Icon written to $icoPath" -ForegroundColor Green

$ws = New-Object -ComObject WScript.Shell
$desktop = [Environment]::GetFolderPath("Desktop")
$lnkPath = Join-Path $desktop "Angela's Projects.lnk"
$lnk = $ws.CreateShortcut($lnkPath)
$lnk.TargetPath = (Get-Command powershell).Source
$lnk.Arguments = "-ExecutionPolicy Bypass -NoProfile -File `"$($PSScriptRoot)\open-hub.ps1`""
$lnk.WorkingDirectory = $root
$lnk.IconLocation = "$icoPath,0"
$lnk.Description = "Open Angela's Projects hub — all public apps in one place"
$lnk.WindowStyle = 1
$lnk.Save()
Write-Host "Desktop shortcut created: $lnkPath" -ForegroundColor Green
Write-Host "Double-click 'Angela's Projects' on your desktop to open the live hub." -ForegroundColor Cyan