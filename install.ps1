<#
  Bootstrap installer for Windows Sleep-Mode Wake & Display.

  One-line install (run in the classic blue Windows PowerShell):

      irm https://raw.githubusercontent.com/badrAlzahrani/windows-sleep-wake-display/main/install.ps1 | iex

  It downloads the main tool and launches its interactive menu.
#>

$ErrorActionPreference = "Stop"

$repoRaw = "https://raw.githubusercontent.com/badrAlzahrani/windows-sleep-wake-display/main"
$toolUrl = "$repoRaw/wake-display.ps1"
$dest    = Join-Path $env:TEMP "wake-display.ps1"

Write-Host "Fetching Windows Sleep-Mode Wake & Display ..." -ForegroundColor Cyan
Write-Host "جاري جلب اداة ايقاظ ويندوز من النوم ..." -ForegroundColor Cyan

try {
    Invoke-WebRequest -Uri $toolUrl -OutFile $dest -UseBasicParsing
} catch {
    Write-Host "Download failed. Check your connection and the repo URL." -ForegroundColor Red
    Write-Host "فشل التنزيل. تحقق من الاتصال ومن رابط المستودع." -ForegroundColor Red
    exit 1
}

# Launch the tool (it self-elevates via UAC on its own).
Start-Process -FilePath "powershell.exe" `
    -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$dest`""
