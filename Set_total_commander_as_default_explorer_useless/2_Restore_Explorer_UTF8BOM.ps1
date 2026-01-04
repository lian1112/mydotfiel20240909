#Requires -RunAsAdministrator
# ================================================================
# Restore Windows Explorer Default Settings
# ================================================================

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Restore Windows Explorer" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if backup files exist
$backupDir = Join-Path $PSScriptRoot "Backups"
$hasBackup = $false
$latestDirBackup = ""
$latestDrvBackup = ""

if (Test-Path $backupDir) {
    $dirBackups = Get-ChildItem -Path $backupDir -Filter "Directory_Shell_Backup_*.reg" -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending
    $drvBackups = Get-ChildItem -Path $backupDir -Filter "Drive_Shell_Backup_*.reg" -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending
    
    if ($dirBackups -and $drvBackups) {
        $latestDirBackup = $dirBackups[0].FullName
        $latestDrvBackup = $drvBackups[0].FullName
        $hasBackup = $true
        $backupTime = $dirBackups[0].LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss")
    }
}

Write-Host "Please select restore method:" -ForegroundColor Yellow
Write-Host ""

if ($hasBackup) {
    Write-Host "[1] Restore from backup (Recommended)" -ForegroundColor Green
    Write-Host "    Backup time: $backupTime"
    Write-Host ""
    Write-Host "[2] Restore to Windows default settings" -ForegroundColor Cyan
    Write-Host ""
    $choice = Read-Host "Choose (1/2)"
} else {
    Write-Host "[Note] Backup files not found" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "[1] Restore to Windows default settings" -ForegroundColor Cyan
    Write-Host ""
    $choice = Read-Host "Press 1 to continue, or any other key to cancel"
}

if ($hasBackup) {
    if ($choice -eq "1") {
        # Restore from backup
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host " Restoring from backup" -ForegroundColor Cyan
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host ""
        
        Write-Host "[1/2] Restoring folder open settings..." -ForegroundColor Yellow
        try {
            $result = Start-Process "reg" -ArgumentList "import `"$latestDirBackup`"" -Wait -PassThru -NoNewWindow
            if ($result.ExitCode -eq 0) {
                Write-Host "        [SUCCESS] Folder settings restored" -ForegroundColor Green
            } else {
                Write-Host "        [FAILED] Restore failed" -ForegroundColor Red
            }
        } catch {
            Write-Host "        [FAILED] Restore failed: $_" -ForegroundColor Red
        }
        
        Write-Host ""
        Write-Host "[2/2] Restoring drive open settings..." -ForegroundColor Yellow
        try {
            $result = Start-Process "reg" -ArgumentList "import `"$latestDrvBackup`"" -Wait -PassThru -NoNewWindow
            if ($result.ExitCode -eq 0) {
                Write-Host "        [SUCCESS] Drive settings restored" -ForegroundColor Green
            } else {
                Write-Host "        [FAILED] Restore failed" -ForegroundColor Red
            }
        } catch {
            Write-Host "        [FAILED] Restore failed: $_" -ForegroundColor Red
        }
        
    } elseif ($choice -eq "2") {
        # Restore to default - call internal function
        Restore-DefaultExplorer
    } else {
        Write-Host ""
        Write-Host "Restore operation cancelled" -ForegroundColor Yellow
        Write-Host ""
        Read-Host "Press Enter to exit"
        exit 0
    }
} else {
    if ($choice -eq "1") {
        # Restore to default
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host " Restoring to Windows default settings" -ForegroundColor Cyan
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host ""
        
        # Create temporary Registry file - Directory
        $tempRegDir = Join-Path $env:TEMP "Restore_Explorer_Dir.reg"
        
        $regContentDir = @"
Windows Registry Editor Version 5.00

; ================================================================
; Restore default folder open with Windows Explorer
; ================================================================

[HKEY_CLASSES_ROOT\Directory\shell]
@=""

[HKEY_CLASSES_ROOT\Directory\shell\open]

[HKEY_CLASSES_ROOT\Directory\shell\open\command]
@=hex(2):25,00,53,00,79,00,73,00,74,00,65,00,6d,00,52,00,6f,00,6f,00,74,00,25,\
  00,5c,00,45,00,78,00,70,00,6c,00,6f,00,72,00,65,00,72,00,2e,00,65,00,78,00,\
  65,00,00,00
"DelegateExecute"="{11dbb47c-a525-400b-9e80-a54615a090c0}"
"@
        
        # Create temporary Registry file - Drive
        $tempRegDrv = Join-Path $env:TEMP "Restore_Explorer_Drv.reg"
        
        $regContentDrv = @"
Windows Registry Editor Version 5.00

; ================================================================
; Restore default drive open with Windows Explorer
; ================================================================

[HKEY_CLASSES_ROOT\Drive\shell]
@=""

[HKEY_CLASSES_ROOT\Drive\shell\open]

[HKEY_CLASSES_ROOT\Drive\shell\open\command]
@=hex(2):25,00,53,00,79,00,73,00,74,00,65,00,6d,00,52,00,6f,00,6f,00,74,00,25,\
  00,5c,00,45,00,78,00,70,00,6c,00,6f,00,72,00,65,00,72,00,2e,00,65,00,78,00,\
  65,00,00,00
"DelegateExecute"="{11dbb47c-a525-400b-9e80-a54615a090c0}"
"@
        
        # Write files (using Unicode encoding)
        [System.IO.File]::WriteAllText($tempRegDir, $regContentDir, [System.Text.Encoding]::Unicode)
        [System.IO.File]::WriteAllText($tempRegDrv, $regContentDrv, [System.Text.Encoding]::Unicode)
        
        Write-Host "[1/2] Restoring folder open settings..." -ForegroundColor Yellow
        try {
            $result = Start-Process "reg" -ArgumentList "import `"$tempRegDir`"" -Wait -PassThru -NoNewWindow
            if ($result.ExitCode -eq 0) {
                Write-Host "        [SUCCESS] Folder settings restored" -ForegroundColor Green
            } else {
                Write-Host "        [FAILED] Restore failed" -ForegroundColor Red
            }
        } catch {
            Write-Host "        [FAILED] Restore failed: $_" -ForegroundColor Red
        }
        
        Write-Host ""
        Write-Host "[2/2] Restoring drive open settings..." -ForegroundColor Yellow
        try {
            $result = Start-Process "reg" -ArgumentList "import `"$tempRegDrv`"" -Wait -PassThru -NoNewWindow
            if ($result.ExitCode -eq 0) {
                Write-Host "        [SUCCESS] Drive settings restored" -ForegroundColor Green
            } else {
                Write-Host "        [FAILED] Restore failed" -ForegroundColor Red
            }
        } catch {
            Write-Host "        [FAILED] Restore failed: $_" -ForegroundColor Red
        }
        
        # Cleanup temporary files
        Remove-Item $tempRegDir -Force -ErrorAction SilentlyContinue
        Remove-Item $tempRegDrv -Force -ErrorAction SilentlyContinue
        
    } else {
        Write-Host ""
        Write-Host "Restore operation cancelled" -ForegroundColor Yellow
        Write-Host ""
        Read-Host "Press Enter to exit"
        exit 0
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Restore Complete!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "IMPORTANT:" -ForegroundColor Yellow
Write-Host "1. Please log out and log back in, or restart"
Write-Host "2. Settings will take effect after re-login"
Write-Host ""
Write-Host "Test items:" -ForegroundColor Cyan
Write-Host "- Double-click a folder on desktop -> Should open with Windows Explorer"
Write-Host "- Double-click C: drive in This PC -> Should open with Windows Explorer"
Write-Host ""
Read-Host "Press Enter to exit"
