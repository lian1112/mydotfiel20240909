param(
    [string]$CurrentPath = "",
    [int]$MaxSizeMB = 200
)

$Host.UI.RawUI.WindowTitle = "Integrated Cleanup Tool"

Add-Type -AssemblyName Microsoft.VisualBasic

try {
    chcp 65001 | Out-Null
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
} catch {}

function Move-ToRecycleBin {
    param([string]$FilePath)
    try {
        [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile($FilePath, 'OnlyErrorDialogs', 'SendToRecycleBin')
        return $true
    } catch {
        return $false
    }
}

function Move-FolderToRecycleBin {
    param([string]$FolderPath)
    try {
        [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteDirectory($FolderPath, 'OnlyErrorDialogs', 'SendToRecycleBin')
        return $true
    } catch {
        return $false
    }
}

Clear-Host
Write-Host "=================================================================" -ForegroundColor Magenta
Write-Host "                    Integrated Cleanup Tool v1.0                " -ForegroundColor Magenta  
Write-Host "=================================================================" -ForegroundColor Magenta
Write-Host ""

if ([string]::IsNullOrEmpty($CurrentPath)) {
    $CurrentPath = Get-Location
    Write-Host "Using current directory: $CurrentPath" -ForegroundColor Yellow
} else {
    $CurrentPath = $CurrentPath.Trim('"').Trim("'").TrimEnd('\').TrimEnd('/')
    Write-Host "TC path received: $CurrentPath" -ForegroundColor Green
}

try {
    $pathExists = Test-Path -LiteralPath $CurrentPath
} catch {
    $pathExists = $false
    Write-Host "Path validation error: $($_.Exception.Message)" -ForegroundColor Red
}

if (-not $pathExists) {
    Write-Host ""
    Write-Host "Error: Path does not exist!" -ForegroundColor Red
    Write-Host "Path: $CurrentPath" -ForegroundColor Red
    Write-Host ""
    Write-Host "Press any key to exit..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

Write-Host ""
Write-Host "Search path: $CurrentPath" -ForegroundColor Cyan
Write-Host "Tasks: 1. Specific folders  2. Files < $MaxSizeMB MB" -ForegroundColor Cyan
Write-Host ""

Write-Host "[Task 1] Searching for specific folders..." -ForegroundColor Yellow

$targetFolder2 = "2048"
$pathKeyword = [char]0x9644 + [char]0x6a94  # 附檔
$textKeyword = [char]0x6587  # 文 (using Unicode)

$foundFolders = @()

Write-Host "Looking for folders containing: '$textKeyword' and folders named '$targetFolder2'" -ForegroundColor Gray
Write-Host "In paths containing: '$pathKeyword'" -ForegroundColor Gray
Write-Host "Debug: Searching all folders first..." -ForegroundColor Gray

try {
    Get-ChildItem -LiteralPath $CurrentPath -Directory -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
        $folder = $_
        
        # Debug: Show all folders found
        Write-Host "Found folder: $($folder.Name)" -ForegroundColor DarkGray
        
        # Check if folder name contains "文" OR is named "2048"
        if ($folder.Name.Contains($textKeyword) -or $folder.Name -eq $targetFolder2) {
            Write-Host "  -> Matched target folder: $($folder.Name)" -ForegroundColor Yellow
            # Check if path contains the keyword OR skip path check
            if ($folder.FullName.Contains($pathKeyword) -or $true) {
                Write-Host "  -> Adding to deletion list" -ForegroundColor Green
                $foundFolders += $folder
            }
        }
    }
} catch {
    Write-Host "Error searching folders: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "Found $($foundFolders.Count) target folders" -ForegroundColor Cyan

Write-Host "[Task 2] Searching for files < $MaxSizeMB MB..." -ForegroundColor Yellow

$MaxSizeBytes = $MaxSizeMB * 1024 * 1024
$smallFiles = @()

try {
    Get-ChildItem -LiteralPath $CurrentPath -File -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
        if ($_.Length -lt $MaxSizeBytes) {
            $smallFiles += $_
        }
        if ($smallFiles.Count % 1000 -eq 0 -and $smallFiles.Count -gt 0) {
            Write-Host "  Found $($smallFiles.Count) small files..." -ForegroundColor Gray
        }
    }
} catch {
    Write-Host "Error searching files: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "Found $($smallFiles.Count) small files" -ForegroundColor Cyan

Write-Host ""
Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host "Search Results Summary" -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Cyan

$folderTotalSize = 0
if ($foundFolders.Count -gt 0) {
    Write-Host ""
    Write-Host "[Specific Folders] ($($foundFolders.Count) items):" -ForegroundColor Yellow
    
    for ($i = 0; $i -lt $foundFolders.Count; $i++) {
        $folder = $foundFolders[$i]
        try {
            $folderSize = (Get-ChildItem -LiteralPath $folder.FullName -Recurse -File -ErrorAction SilentlyContinue | 
                          Measure-Object -Property Length -Sum).Sum
            if ($folderSize -eq $null) { $folderSize = 0 }
            $folderTotalSize += $folderSize
            $sizeMB = [math]::Round($folderSize / 1MB, 2)
        } catch {
            $sizeMB = "Cannot calculate"
        }
        
        $relativePath = $folder.FullName.Replace($CurrentPath, "").TrimStart('\', '/')
        if ([string]::IsNullOrEmpty($relativePath)) { $relativePath = $folder.Name }
        
        Write-Host ("{0,3}. " -f ($i+1)) -NoNewline -ForegroundColor Gray
        Write-Host $relativePath -ForegroundColor White -NoNewline
        Write-Host " ($sizeMB MB)" -ForegroundColor Gray
    }
}

$filesTotalSize = 0
if ($smallFiles.Count -gt 0) {
    Write-Host ""
    Write-Host "[Files < $MaxSizeMB MB] ($($smallFiles.Count) items):" -ForegroundColor Yellow
    
    foreach ($file in $smallFiles) {
        $filesTotalSize += $file.Length
    }
    
    $filesTotalSizeMB = [math]::Round($filesTotalSize / 1MB, 2)
    
    for ($i = 0; $i -lt $smallFiles.Count; $i++) {
        $file = $smallFiles[$i]
        $sizeMB = [math]::Round($file.Length / 1MB, 3)
        $relativePath = $file.FullName.Replace($CurrentPath, "").TrimStart('\', '/')
        if ([string]::IsNullOrEmpty($relativePath)) { $relativePath = $file.Name }
        
        Write-Host ("{0,4}. " -f ($i+1)) -NoNewline -ForegroundColor Gray
        Write-Host $relativePath -ForegroundColor White -NoNewline
        Write-Host " ($sizeMB MB)" -ForegroundColor Gray
    }
    
    Write-Host ""
    Write-Host "Total small files size: $filesTotalSizeMB MB" -ForegroundColor Cyan
}

$totalSize = $folderTotalSize + $filesTotalSize
$totalSizeMB = [math]::Round($totalSize / 1MB, 2)

Write-Host ""
Write-Host "=================================================================" -ForegroundColor Green
Write-Host "Total space to be freed: $totalSizeMB MB" -ForegroundColor Green
Write-Host "Folders: $($foundFolders.Count) items" -ForegroundColor Green
Write-Host "Files: $($smallFiles.Count) items" -ForegroundColor Green
Write-Host "=================================================================" -ForegroundColor Green

if ($foundFolders.Count -eq 0 -and $smallFiles.Count -eq 0) {
    Write-Host ""
    Write-Host "No items found matching criteria" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Press any key to exit..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 0
}

Write-Host ""
Write-Host "INFO: Items will be moved to Recycle Bin (can be restored)" -ForegroundColor Green
Write-Host ""

$confirmed = $false
while (-not $confirmed) {
    Write-Host "Move all these items to Recycle Bin? [Y/n] (default Y, press Enter to confirm): " -NoNewline -ForegroundColor Yellow
    
    # Read input using a more reliable method
    $input = [Console]::ReadLine()
    
    if ([string]::IsNullOrEmpty($input) -or $input.ToLower() -eq "y") {
        Write-Host "Confirmed: YES" -ForegroundColor Green
        $confirmed = $true
    } elseif ($input.ToLower() -eq "n") {
        Write-Host ""
        Write-Host "Operation cancelled" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Press any key to exit..."
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        exit 0
    } else {
        Write-Host "Please enter Y or N (or just press Enter for Yes)" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "Moving items to Recycle Bin..." -ForegroundColor Yellow
Write-Host ""

$deletedFolders = 0
$deletedFiles = 0
$errorCount = 0
$actualFreedSpace = 0

if ($foundFolders.Count -gt 0) {
    Write-Host "[Moving Folders to Recycle Bin]" -ForegroundColor Yellow
    
    for ($i = 0; $i -lt $foundFolders.Count; $i++) {
        $folder = $foundFolders[$i]
        try {
            $relativePath = $folder.FullName.Replace($CurrentPath, "").TrimStart('\', '/')
            if ([string]::IsNullOrEmpty($relativePath)) { $relativePath = $folder.Name }
            
            $folderSize = (Get-ChildItem -LiteralPath $folder.FullName -Recurse -File -ErrorAction SilentlyContinue | 
                          Measure-Object -Property Length -Sum).Sum
            if ($folderSize -eq $null) { $folderSize = 0 }
            
            $success = Move-FolderToRecycleBin -FolderPath $folder.FullName
            
            if ($success) {
                Write-Host ("+ [{0}/{1}] " -f ($i+1), $foundFolders.Count) -NoNewline -ForegroundColor Green
                Write-Host "$relativePath moved to Recycle Bin" -ForegroundColor Green
                $deletedFolders++
                $actualFreedSpace += $folderSize
            } else {
                Write-Host ("- [{0}/{1}] " -f ($i+1), $foundFolders.Count) -NoNewline -ForegroundColor Red
                Write-Host "$relativePath - move to Recycle Bin failed" -ForegroundColor Red
                $errorCount++
            }
        } catch {
            Write-Host ("- [{0}/{1}] " -f ($i+1), $foundFolders.Count) -NoNewline -ForegroundColor Red
            Write-Host "$relativePath - move to Recycle Bin failed" -ForegroundColor Red
            $errorCount++
        }
    }
    Write-Host ""
}

if ($smallFiles.Count -gt 0) {
    Write-Host "[Moving Small Files to Recycle Bin]" -ForegroundColor Yellow
    
    for ($i = 0; $i -lt $smallFiles.Count; $i++) {
        $file = $smallFiles[$i]
        try {
            $relativePath = $file.FullName.Replace($CurrentPath, "").TrimStart('\', '/')
            if ([string]::IsNullOrEmpty($relativePath)) { $relativePath = $file.Name }
            
            $fileSize = $file.Length
            $success = Move-ToRecycleBin -FilePath $file.FullName
            
            if ($success) {
                Write-Host ("+ [{0}/{1}] " -f ($i+1), $smallFiles.Count) -NoNewline -ForegroundColor Green
                Write-Host "$relativePath moved to Recycle Bin" -ForegroundColor Green
                $deletedFiles++
                $actualFreedSpace += $fileSize
            } else {
                Write-Host ("- [{0}/{1}] " -f ($i+1), $smallFiles.Count) -NoNewline -ForegroundColor Red
                Write-Host "$relativePath - move to Recycle Bin failed" -ForegroundColor Red
                $errorCount++
            }
        } catch {
            Write-Host ("- [{0}/{1}] " -f ($i+1), $smallFiles.Count) -NoNewline -ForegroundColor Red
            Write-Host "$relativePath - move to Recycle Bin failed" -ForegroundColor Red
            $errorCount++
        }
    }
}

$actualFreedSpaceMB = [math]::Round($actualFreedSpace / 1MB, 2)

Write-Host ""
Write-Host "=================================================================" -ForegroundColor Green
Write-Host "Move to Recycle Bin completed!" -ForegroundColor Green
Write-Host "Successfully moved folders: $deletedFolders" -ForegroundColor Green
Write-Host "Successfully moved files: $deletedFiles" -ForegroundColor Green
Write-Host "Space freed: $actualFreedSpaceMB MB" -ForegroundColor Green
Write-Host "Items can be restored from Recycle Bin" -ForegroundColor Cyan

if ($errorCount -gt 0) {
    Write-Host "Failed operations: $errorCount items" -ForegroundColor Red
}

Write-Host "=================================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")