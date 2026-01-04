# ================================================================
# Total Commander Complete Setup (Including Folder class)
# ================================================================

$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host ""
    Write-Host "Restarting with Administrator rights..." -ForegroundColor Yellow
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`""
    exit
}

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Total Commander Complete Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Find Total Commander
Write-Host "[1/4] Finding Total Commander..." -ForegroundColor Yellow
$tcPath = ""
$possiblePaths = @(
    "C:\Program Files\totalcmd\TOTALCMD64.EXE",
    "C:\Program Files\totalcmd\TOTALCMD.EXE",
    "C:\Program Files (x86)\totalcmd\TOTALCMD64.EXE",
    "C:\Program Files (x86)\totalcmd\TOTALCMD.EXE",
    "C:\totalcmd\TOTALCMD64.EXE",
    "C:\totalcmd\TOTALCMD.EXE"
)

foreach ($path in $possiblePaths) {
    if (Test-Path $path) {
        $tcPath = $path
        Write-Host "        Found: $tcPath" -ForegroundColor Green
        break
    }
}

if (-not $tcPath) {
    Write-Host "        [ERROR] Not found!" -ForegroundColor Red
    $tcPath = Read-Host "Enter path"
    if (-not (Test-Path $tcPath)) {
        Read-Host "Press Enter to exit"
        exit 1
    }
}

Write-Host ""

# Backup
Write-Host "[2/4] Backing up..." -ForegroundColor Yellow
$backupDir = Join-Path $PSScriptRoot "Backups"
if (-not (Test-Path $backupDir)) {
    New-Item -Path $backupDir -ItemType Directory -Force | Out-Null
}

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
reg export "HKEY_CLASSES_ROOT\Directory\shell" (Join-Path $backupDir "Directory_$timestamp.reg") /y | Out-Null
reg export "HKEY_CLASSES_ROOT\Drive\shell" (Join-Path $backupDir "Drive_$timestamp.reg") /y | Out-Null
reg export "HKEY_CLASSES_ROOT\Folder\shell" (Join-Path $backupDir "Folder_$timestamp.reg") /y 2>$null | Out-Null
Write-Host "        [OK] Backup complete" -ForegroundColor Green
Write-Host ""

# Apply settings
Write-Host "[3/4] Applying settings..." -ForegroundColor Yellow
$tcPathReg = $tcPath -replace '\\', '\\'

# Remove DelegateExecute from Directory
try {
    Remove-ItemProperty -Path "Registry::HKEY_CLASSES_ROOT\Directory\shell\open\command" -Name "DelegateExecute" -ErrorAction SilentlyContinue
} catch {}

# Set Directory
Set-ItemProperty -Path "Registry::HKEY_CLASSES_ROOT\Directory\shell" -Name "(Default)" -Value "none"
if (-not (Test-Path "Registry::HKEY_CLASSES_ROOT\Directory\shell\open")) {
    New-Item -Path "Registry::HKEY_CLASSES_ROOT\Directory\shell\open" -Force | Out-Null
}
Set-ItemProperty -Path "Registry::HKEY_CLASSES_ROOT\Directory\shell\open" -Name "(Default)" -Value "Open with Total Commander"
Set-ItemProperty -Path "Registry::HKEY_CLASSES_ROOT\Directory\shell\open" -Name "Icon" -Value "$tcPath,0"

if (-not (Test-Path "Registry::HKEY_CLASSES_ROOT\Directory\shell\open\command")) {
    New-Item -Path "Registry::HKEY_CLASSES_ROOT\Directory\shell\open\command" -Force | Out-Null
}
Set-ItemProperty -Path "Registry::HKEY_CLASSES_ROOT\Directory\shell\open\command" -Name "(Default)" -Value "`"$tcPath`" /O /T /S `"%1`""

# Remove DelegateExecute from Drive
try {
    Remove-ItemProperty -Path "Registry::HKEY_CLASSES_ROOT\Drive\shell\open\command" -Name "DelegateExecute" -ErrorAction SilentlyContinue
} catch {}

# Set Drive
Set-ItemProperty -Path "Registry::HKEY_CLASSES_ROOT\Drive\shell" -Name "(Default)" -Value "none"
if (-not (Test-Path "Registry::HKEY_CLASSES_ROOT\Drive\shell\open")) {
    New-Item -Path "Registry::HKEY_CLASSES_ROOT\Drive\shell\open" -Force | Out-Null
}
Set-ItemProperty -Path "Registry::HKEY_CLASSES_ROOT\Drive\shell\open" -Name "(Default)" -Value "Open with Total Commander"
Set-ItemProperty -Path "Registry::HKEY_CLASSES_ROOT\Drive\shell\open" -Name "Icon" -Value "$tcPath,0"

if (-not (Test-Path "Registry::HKEY_CLASSES_ROOT\Drive\shell\open\command")) {
    New-Item -Path "Registry::HKEY_CLASSES_ROOT\Drive\shell\open\command" -Force | Out-Null
}
Set-ItemProperty -Path "Registry::HKEY_CLASSES_ROOT\Drive\shell\open\command" -Name "(Default)" -Value "`"$tcPath`" /O /T /S `"%1`""

# Set Folder (This is the KEY!)
Write-Host "        Setting Folder class (Windows 10/11)..." -ForegroundColor Cyan
try {
    Remove-ItemProperty -Path "Registry::HKEY_CLASSES_ROOT\Folder\shell\open\command" -Name "DelegateExecute" -ErrorAction SilentlyContinue
} catch {}

Set-ItemProperty -Path "Registry::HKEY_CLASSES_ROOT\Folder\shell" -Name "(Default)" -Value "none" -ErrorAction SilentlyContinue
if (-not (Test-Path "Registry::HKEY_CLASSES_ROOT\Folder\shell\open")) {
    New-Item -Path "Registry::HKEY_CLASSES_ROOT\Folder\shell\open" -Force | Out-Null
}
Set-ItemProperty -Path "Registry::HKEY_CLASSES_ROOT\Folder\shell\open" -Name "(Default)" -Value "Open with Total Commander"
Set-ItemProperty -Path "Registry::HKEY_CLASSES_ROOT\Folder\shell\open" -Name "Icon" -Value "$tcPath,0" -ErrorAction SilentlyContinue

if (-not (Test-Path "Registry::HKEY_CLASSES_ROOT\Folder\shell\open\command")) {
    New-Item -Path "Registry::HKEY_CLASSES_ROOT\Folder\shell\open\command" -Force | Out-Null
}
Set-ItemProperty -Path "Registry::HKEY_CLASSES_ROOT\Folder\shell\open\command" -Name "(Default)" -Value "`"$tcPath`" /O /T /S `"%1`""

Write-Host "        [OK] All settings applied" -ForegroundColor Green
Write-Host ""

# Restart Explorer
Write-Host "[4/4] Restarting Windows Explorer..." -ForegroundColor Yellow
try {
    Stop-Process -Name explorer -Force
    Start-Sleep -Seconds 2
    Start-Process explorer
    Write-Host "        [OK] Explorer restarted" -ForegroundColor Green
} catch {
    Write-Host "        [WARNING] Please manually restart Explorer" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Setup Complete!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "OK Total Commander: $tcPath" -ForegroundColor Green
Write-Host "OK Backup: $backupDir" -ForegroundColor Green
Write-Host ""
Write-Host "IMPORTANT: Settings should work immediately!" -ForegroundColor Yellow
Write-Host "If not, try:" -ForegroundColor Yellow
Write-Host "1. Log out and log back in" -ForegroundColor Cyan
Write-Host "2. Restart computer" -ForegroundColor Cyan
Write-Host ""
Write-Host "Test now:" -ForegroundColor Green
Write-Host "- Double-click a folder" -ForegroundColor Cyan
Write-Host "- Double-click C: drive" -ForegroundColor Cyan
Write-Host ""
Read-Host "Press Enter to exit"
