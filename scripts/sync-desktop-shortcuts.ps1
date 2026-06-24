# Align desktop shortcuts with the same live URLs as the projects hub (index.html).
# Run: powershell -ExecutionPolicy Bypass -File scripts\sync-desktop-shortcuts.ps1
$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$manifestPath = Join-Path $PSScriptRoot "projects-manifest.json"
$openLive = Join-Path $PSScriptRoot "open-live.ps1"
$manifest = Get-Content $manifestPath -Raw | ConvertFrom-Json
$desktop = [Environment]::GetFolderPath("Desktop")
$ws = New-Object -ComObject WScript.Shell

$created = 0
$updated = 0
$skipped = 0

foreach ($project in $manifest.projects) {
  if (-not $project.liveUrl) { $skipped++; continue }

  $lnkPath = Join-Path $desktop "$($project.shortcut).lnk"
  $iconPath = $project.icon
  if ($iconPath -and -not [System.IO.Path]::IsPathRooted($iconPath)) {
    $iconPath = Join-Path $root $iconPath
  }

  $exists = Test-Path $lnkPath
  $lnk = $ws.CreateShortcut($lnkPath)
  $lnk.TargetPath = (Get-Command powershell).Source
  $lnk.Arguments = "-ExecutionPolicy Bypass -NoProfile -File `"$openLive`" -Url `"$($project.liveUrl)`""
  $lnk.WorkingDirectory = $root
  $lnk.Description = "Open $($project.shortcut) - same link as Angela's Projects hub"
  $lnk.WindowStyle = 1
  if ($iconPath -and (Test-Path $iconPath)) {
    $lnk.IconLocation = "$iconPath,0"
  }
  $lnk.Save()

  if ($exists) { $updated++ } else { $created++ }
  Write-Host ("  {0} -> {1}" -f $project.shortcut, $project.liveUrl) -ForegroundColor Green
}

Write-Host ""
Write-Host "Hub: $($manifest.hubUrl)" -ForegroundColor Cyan
Write-Host "Shortcuts created: $created, updated: $updated, skipped: $skipped" -ForegroundColor Cyan
Write-Host "Desktop icons now open the same live URLs as the hub Open buttons." -ForegroundColor Cyan