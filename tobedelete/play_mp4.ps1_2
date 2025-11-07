$player = "C:\Program Files\DAUM\PotPlayer\PotPlayerMini64.exe"
$paths = $args

Write-Host "腳本開始執行時間: $(Get-Date)"
Write-Host "正在嘗試播放視頻..."
Write-Host "參數: $paths"
Write-Host "PotPlayer 路徑: $player"

foreach ($path in $paths) {
    Write-Host "處理: $path"
    if (Test-Path -LiteralPath $path -PathType Container) {
        Write-Host "找到目錄: $path"
        Get-ChildItem -LiteralPath $path -File | Where-Object { $_.Extension -in '.mp4','.avi','.mkv' } | ForEach-Object {
            Write-Host "找到視頻文件: $($_.FullName)"
            Write-Host "正在執行: Start-Process `"$player`" -ArgumentList `"$($_.FullName)`""
            Start-Process $player -ArgumentList "`"$($_.FullName)`""
            Write-Host "PotPlayer 已啟動，播放 $($_.FullName)"
        }
    } elseif (Test-Path -LiteralPath $path -PathType Leaf) {
        Write-Host "找到文件: $path"
        Write-Host "正在執行: Start-Process `"$player`" -ArgumentList `"$path`""
        Start-Process $player -ArgumentList "`"$path`""
        Write-Host "PotPlayer 已啟動，播放 $path"
    } else {
        Write-Host "文件或目錄不存在: $path"
    }
}

Write-Host "腳本執行完畢"
Write-Host "腳本結束執行時間: $(Get-Date)"
Write-Host "處理結束。按任意鍵退出..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")