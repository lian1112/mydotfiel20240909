# Define PotPlayer path
$player = "C:\Program Files\DAUM\PotPlayer\PotPlayerMini64.exe"

# Log start time
$startTime = Get-Date
Write-Host "Script start time: $startTime" -ForegroundColor Cyan
Write-Host "Received parameters: $args" -ForegroundColor Yellow

# Ensure we have at least one parameter
if ($args.Count -eq 0) {
    Write-Host "ERROR: No parameters provided!" -ForegroundColor Red
    Write-Host "Press Enter to exit..."
    Read-Host
    exit
}

# Process each folder
foreach ($folder in $args) {
    Write-Host "`nProcessing path: $folder" -ForegroundColor Yellow
    
    # Check if it's a folder
    if (Test-Path -LiteralPath $folder -PathType Container) {
        Write-Host "This is a valid folder" -ForegroundColor Green
        
        # Find all MP4 files
        $mp4Files = Get-ChildItem -LiteralPath $folder -Filter "*.mp4" -File -ErrorAction SilentlyContinue
        
        # Display the number of files found
        if ($null -eq $mp4Files -or $mp4Files.Count -eq 0) {
            Write-Host "No MP4 files found in the folder!" -ForegroundColor Red
        } else {
            Write-Host "Found $($mp4Files.Count) MP4 files" -ForegroundColor Green
            
            # Process each MP4 file
            foreach ($file in $mp4Files) {
                $fullPath = $file.FullName
                Write-Host "`nProcessing file: $fullPath" -ForegroundColor Cyan
                
                # Start PotPlayer
                try {
                    # Build command line
                    $playerArgs = "`"$fullPath`""
                    Write-Host "About to execute: $player $playerArgs" -ForegroundColor Yellow
                    
                    # Start process
                    $process = Start-Process -FilePath $player -ArgumentList $playerArgs -PassThru
                    Write-Host "PotPlayer started, Process ID: $($process.Id)" -ForegroundColor Green
                    
                    # Wait a moment to make sure process starts
                    Start-Sleep -Seconds 1
                    
                    # Check if process is still running
                    if (-not (Get-Process -Id $process.Id -ErrorAction SilentlyContinue)) {
                        Write-Host "WARNING: PotPlayer process seems to have ended" -ForegroundColor Red
                    }
                } catch {
                    Write-Host "Error starting PotPlayer: $($_.Exception.Message)" -ForegroundColor Red
                }
            }
        }
    } else {
        Write-Host "This path is not a valid folder!" -ForegroundColor Red
    }
}

# Log end time
$endTime = Get-Date
$duration = $endTime - $startTime
Write-Host "`nScript execution complete" -ForegroundColor Green
Write-Host "Execution time: $($duration.TotalSeconds) seconds" -ForegroundColor Cyan
Write-Host "Script end time: $endTime" -ForegroundColor Cyan
Write-Host "`nPress Enter to exit..." -NoNewline
Read-Host