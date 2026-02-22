# Backup Total Commander wincmd.ini
$source = "C:\Users\yulia\AppData\Roaming\GHISLER\wincmd.ini"
$dest = "D:\mydotfile\wincmd.ini"

$destDir = Split-Path $dest -Parent
if (-not (Test-Path $destDir)) {
    New-Item -ItemType Directory -Path $destDir -Force | Out-Null
}

if (Test-Path $source) {
    Copy-Item -Path $source -Destination $dest -Force
    Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] Backup OK: $source -> $dest"
} else {
    Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] ERROR: Source not found: $source"
}
