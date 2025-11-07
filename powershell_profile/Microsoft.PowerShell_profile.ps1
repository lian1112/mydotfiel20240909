# Oh My Posh 配置（使用正確的路徑）
# 動態取得當前使用者的路徑
$ohMyPoshPath = "$env:LOCALAPPDATA\Programs\oh-my-posh\bin\oh-my-posh.exe"

# 檢查 Oh My Posh 是否存在
if (Test-Path $ohMyPoshPath) {
    $ENV:POSH_THEMES_PATH = "$env:LOCALAPPDATA\Programs\oh-my-posh\themes"
    & $ohMyPoshPath init pwsh --config "$ENV:POSH_THEMES_PATH\half-life.omp.json" | Invoke-Expression
} else {
    # 如果找不到，嘗試使用 where 命令
    $ohMyPoshCmd = Get-Command oh-my-posh -ErrorAction SilentlyContinue
    if ($ohMyPoshCmd) {
        oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\half-life.omp.json" | Invoke-Expression
    } else {
        Write-Host "Oh My Posh 未找到，請確認安裝路徑" -ForegroundColor Yellow
    }
}

# 設置 PowerShell 的字符編碼
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8

# 檢查是否在 MobaXterm 中執行
if ($env:MOBATERM) {
    # MobaXterm 特定設定
    [Console]::InputEncoding = [System.Text.Encoding]::ASCII
    [Console]::OutputEncoding = [System.Text.Encoding]::ASCII
}

# 導入 PSReadLine
Import-Module PSReadLine

# 設置 PSReadLine 選項
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView

# 如果在 MobaXterm 中，可能需要調整編輯模式
if ($env:MOBATERM) {
    Set-PSReadLineOption -EditMode Windows
}

# 設置上下箭頭鍵搜索歷史命令
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

# 導入 Terminal-Icons (如果已安裝)
if (Get-Module -ListAvailable -Name Terminal-Icons) {
    Import-Module Terminal-Icons
} else {
    Write-Host "Terminal-Icons 模組未安裝，使用 'Install-Module -Name Terminal-Icons -Scope CurrentUser' 安裝" -ForegroundColor Yellow
}

# 導入 ZLocation (如果已安裝)
if (Get-Module -ListAvailable -Name ZLocation) {
    Import-Module ZLocation
} else {
    Write-Host "ZLocation 模組未安裝，使用 'Install-Module -Name ZLocation -Scope CurrentUser' 安裝" -ForegroundColor Yellow
}

# Import the Chocolatey Profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
    Import-Module "$ChocolateyProfile"
}

# 設定別名
Set-Alias vi vim

# 顯示啟動訊息（可選）
Write-Host "PowerShell $($PSVersionTable.PSVersion) 已載入" -ForegroundColor Green
if ($env:MOBATERM) {
    Write-Host "正在 MobaXterm 環境中執行" -ForegroundColor Cyan
}

# 如果是透過 SSH 連線
if ($env:SSH_TTY) {
    # 強制設定控制台模式
    $host.UI.RawUI.WindowTitle = "SSH Session"
    
    # 嘗試修復輸入
    if ($IsWindows) {
        Add-Type -TypeDefinition @"
            using System;
            using System.Runtime.InteropServices;
            public class ConsoleHelper {
                [DllImport("kernel32.dll", SetLastError = true)]
                public static extern bool SetConsoleMode(IntPtr hConsoleHandle, uint mode);
                
                [DllImport("kernel32.dll", SetLastError = true)]
                public static extern IntPtr GetStdHandle(int nStdHandle);
                
                [DllImport("kernel32.dll", SetLastError = true)]
                public static extern bool GetConsoleMode(IntPtr hConsoleHandle, out uint mode);
            }
"@
        $STD_INPUT_HANDLE = -10
        $handle = [ConsoleHelper]::GetStdHandle($STD_INPUT_HANDLE)
        $mode = 0
        [ConsoleHelper]::GetConsoleMode($handle, [ref]$mode)
        # 啟用 ENABLE_VIRTUAL_TERMINAL_INPUT
        [ConsoleHelper]::SetConsoleMode($handle, $mode -bor 0x0200)
    }
}

# 在 $PROFILE 中加入
function java17 {
    $env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-17.0.15.6-hotspot"
    $env:Path = "$env:JAVA_HOME\bin;" + ($env:Path -replace "[^;]*java[^;]*\\bin;?", "")
    java -version
}

function java21 {
    $env:JAVA_HOME = "C:\Users\yulia\scoop\apps\temurin21-jdk\current"
    $env:Path = "$env:JAVA_HOME\bin;" + ($env:Path -replace "[^;]*java[^;]*\\bin;?", "")
    java -version
}

# 使用：
java21  # 切換到 Java 21
Set-Alias notepad code

# ========== 歷史記錄自動保存系統 ==========

# 全域變數來存儲 timer
$global:HistoryTimer = $null
$global:HistoryTimerEvent = $null

# 保存歷史記錄的核心函數（優化版本）
function Save-SessionHistory {
    param([switch]$Silent = $false)
    
    try {
        $historyPath = "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt"
        
        # 確保目錄存在
        $historyDir = Split-Path -Path $historyPath -Parent
        if (-not (Test-Path $historyDir)) {
            New-Item -ItemType Directory -Path $historyDir -Force | Out-Null
        }
        
        # 方法1: 從 Get-History 取得當前 session 歷史
        $sessionHistory = @()
        $history = Get-History
        if ($history) {
            $sessionHistory = $history | ForEach-Object {
                # 將多行命令轉為單行
                $_.CommandLine -replace '`\r?\n\s*', ' ' -replace '\s+', ' '
            }
        }
        
        # 方法2: 從 PSReadLine 取得歷史
        $psReadLineHistory = @()
        try {
            # 使用臨時檔案取得 PSReadLine 歷史
            $tempFile = [System.IO.Path]::GetTempFileName()
            [Microsoft.PowerShell.PSConsoleReadLine]::SaveHistory($tempFile)
            
            if (Test-Path $tempFile) {
                $psReadLineHistory = Get-Content $tempFile -Encoding UTF8
                Remove-Item $tempFile -Force
            }
        } catch {
            # 忽略錯誤，繼續處理
        }
        
        # 讀取現有歷史檔案
        $existingHistory = @()
        if (Test-Path $historyPath) {
            $existingHistory = Get-Content $historyPath -Encoding UTF8 -ErrorAction SilentlyContinue
        }
        
        # 合併所有歷史（去重）
        $allHistory = @()
        $allHistory += $existingHistory
        $allHistory += $psReadLineHistory
        $allHistory += $sessionHistory
        
        # 去重並過濾空白
        $uniqueHistory = $allHistory | 
            Where-Object { $_ -and $_.Trim() -ne '' } |
            Select-Object -Unique
        
        # 寫入檔案
        if ($uniqueHistory.Count -gt 0) {
            $uniqueHistory | Set-Content -Path $historyPath -Encoding UTF8 -Force
            
            if (-not $Silent) {
                Write-Host "✓ 已保存 $($uniqueHistory.Count) 條歷史記錄到: " -NoNewline -ForegroundColor Green
                Write-Host $historyPath -ForegroundColor Cyan
            }
        }
        
    } catch {
        if (-not $Silent) {
            Write-Host "✗ 保存歷史時發生錯誤: $_" -ForegroundColor Red
        }
    }
}

# 啟動自動保存計時器
function Start-HistoryAutoSave {
    param(
        [int]$IntervalMinutes = 5
    )
    
    # 如果已有計時器在運行，先停止它
    Stop-HistoryAutoSave
    
    # 創建新的計時器
    $global:HistoryTimer = New-Object System.Timers.Timer
    $global:HistoryTimer.Interval = $IntervalMinutes * 60 * 1000  # 轉換為毫秒
    $global:HistoryTimer.AutoReset = $true
    
    # 註冊事件處理器
    $action = {
        Save-SessionHistory -Silent
    }
    
    $global:HistoryTimerEvent = Register-ObjectEvent -InputObject $global:HistoryTimer -EventName Elapsed -Action $action
    
    # 啟動計時器
    $global:HistoryTimer.Start()
    
    Write-Host "✓ 歷史記錄自動保存已啟動 (每 $IntervalMinutes 分鐘保存一次)" -ForegroundColor Green
}

# 停止自動保存計時器
function Stop-HistoryAutoSave {
    if ($global:HistoryTimer) {
        $global:HistoryTimer.Stop()
        $global:HistoryTimer.Dispose()
        $global:HistoryTimer = $null
    }
    
    if ($global:HistoryTimerEvent) {
        Unregister-Event -SourceIdentifier $global:HistoryTimerEvent.Name -ErrorAction SilentlyContinue
        $global:HistoryTimerEvent = $null
    }
    
    Write-Host "✓ 歷史記錄自動保存已停止" -ForegroundColor Yellow
}

# 查看自動保存狀態
function Get-HistoryAutoSaveStatus {
    if ($global:HistoryTimer -and $global:HistoryTimer.Enabled) {
        $interval = $global:HistoryTimer.Interval / 60000  # 轉換回分鐘
        Write-Host "✓ 自動保存：啟用 (每 $interval 分鐘)" -ForegroundColor Green
        Write-Host "  歷史檔案：$((Get-PSReadLineOption).HistorySavePath)" -ForegroundColor Cyan
        
        if (Test-Path (Get-PSReadLineOption).HistorySavePath) {
            $fileInfo = Get-Item (Get-PSReadLineOption).HistorySavePath
            Write-Host "  檔案大小：$([math]::Round($fileInfo.Length / 1KB, 2)) KB" -ForegroundColor Cyan
            Write-Host "  最後修改：$($fileInfo.LastWriteTime)" -ForegroundColor Cyan
        }
    } else {
        Write-Host "✗ 自動保存：停用" -ForegroundColor Red
    }
}

# 同步多個 Terminal 之間的歷史
function Sync-History {
    param(
        [switch]$Force
    )
    
    try {
        $historyPath = (Get-PSReadLineOption).HistorySavePath
        
        if (-not (Test-Path $historyPath)) {
            Write-Host "✗ 找不到歷史檔案: $historyPath" -ForegroundColor Red
            return
        }
        
        # 先保存當前的歷史
        Save-SessionHistory -Silent
        
        # 讀取完整的歷史檔案
        $allHistory = Get-Content $historyPath -Encoding UTF8
        
        # 取得唯一的命令（去重）
        $uniqueHistory = $allHistory | Select-Object -Unique
        
        if ($Force) {
            # 強制模式：清除當前歷史並重新載入
            Clear-History
            
            # 重新寫入歷史檔案（去重後）
            $uniqueHistory | Set-Content $historyPath -Encoding UTF8
        }
        
        # 將歷史加入到 PSReadLine
        $uniqueHistory | ForEach-Object {
            [Microsoft.PowerShell.PSConsoleReadLine]::AddToHistory($_)
        }
        
        Write-Host "✓ 已同步 $($uniqueHistory.Count) 條歷史記錄" -ForegroundColor Green
        
    } catch {
        Write-Host "✗ 同步歷史時發生錯誤: $_" -ForegroundColor Red
    }
}

# 清理歷史記錄（移除重複和無效項目）
function Clean-History {
    param(
        [int]$KeepLast = 10000
    )
    
    $historyPath = (Get-PSReadLineOption).HistorySavePath
    
    if (Test-Path $historyPath) {
        # 備份原始檔案
        $backupPath = "$historyPath.backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        Copy-Item $historyPath $backupPath
        
        # 讀取並清理歷史
        $history = Get-Content $historyPath -Encoding UTF8
        $cleanedHistory = $history | 
            Where-Object { $_.Trim() -ne '' } |  # 移除空白行
            Select-Object -Unique |               # 移除重複
            Select-Object -Last $KeepLast       # 只保留最後 N 條
        
        # 寫回檔案
        $cleanedHistory | Set-Content $historyPath -Encoding UTF8
        
        Write-Host "✓ 歷史記錄已清理" -ForegroundColor Green
        Write-Host "  原始記錄數: $($history.Count)" -ForegroundColor Cyan
        Write-Host "  清理後記錄數: $($cleanedHistory.Count)" -ForegroundColor Cyan
        Write-Host "  備份檔案: $backupPath" -ForegroundColor Cyan
    }
}

# 註冊 PowerShell 退出事件
Register-EngineEvent PowerShell.Exiting -Action {
    Save-SessionHistory -Silent
    Stop-HistoryAutoSave
} | Out-Null

# 設定別名
Set-Alias -Name sah -Value Save-SessionHistory
Set-Alias -Name sync -Value Sync-History
Set-Alias -Name cleanh -Value Clean-History

# ========== 自動啟動 ==========
# 在 Profile 載入時自動啟動歷史記錄保存（每 5 分鐘）
Start-HistoryAutoSave -IntervalMinutes 5

# 顯示歡迎訊息
Write-Host "📝 歷史記錄自動保存系統已載入" -ForegroundColor Cyan
Write-Host "   • sah     - 手動保存歷史" -ForegroundColor Gray
Write-Host "   • sync    - 同步歷史記錄" -ForegroundColor Gray
Write-Host "   • cleanh  - 清理歷史記錄" -ForegroundColor Gray
Write-Host "   • Get-HistoryAutoSaveStatus - 查看狀態" -ForegroundColor Gray


# ========== 智能切換目錄函數 ==========

function cw {
    param(
        [Parameter(Position=0, ValueFromRemainingArguments=$true)]
        [string[]]$Path
    )
    
    # 如果沒有參數，顯示當前目錄
    if (-not $Path) {
        Write-Host "📁 當前目錄: " -NoNewline -ForegroundColor Cyan
        Write-Host $PWD.Path -ForegroundColor Yellow
        return
    }
    
    # 將所有參數組合成一個路徑（處理空格的情況）
    $FullPath = $Path -join ' '
    
    # 檢查路徑是否存在
    if (-not (Test-Path $FullPath)) {
        Write-Host "❌ 路徑不存在: $FullPath" -ForegroundColor Red
        
        # 嘗試模糊匹配
        $parentDir = Split-Path $FullPath -Parent
        $searchPattern = Split-Path $FullPath -Leaf
        
        if ($parentDir -and (Test-Path $parentDir)) {
            $matches = Get-ChildItem $parentDir -Filter "*$searchPattern*" -ErrorAction SilentlyContinue
            if ($matches) {
                Write-Host "`n可能的匹配項:" -ForegroundColor Yellow
                $matches | ForEach-Object {
                    Write-Host "  • $($_.FullName)" -ForegroundColor Gray
                }
            }
        }
        return
    }
    
    # 取得項目資訊
    $item = Get-Item $FullPath
    
    # 如果是檔案，切換到其所在目錄
    if ($item.PSIsContainer -eq $false) {
        $targetDir = $item.DirectoryName
        Write-Host "📄 檢測到檔案: " -NoNewline -ForegroundColor Yellow
        Write-Host $item.Name
        Write-Host "📁 切換到目錄: " -NoNewline -ForegroundColor Cyan
        Write-Host $targetDir -ForegroundColor Green
        
        Set-Location $targetDir
        
        # 顯示該目錄下的內容
        Write-Host "`n目錄內容:" -ForegroundColor Cyan
        Get-ChildItem | Format-Wide -AutoSize
        
        # 如果是 HTML 檔案，詢問是否要開啟
        if ($item.Extension -eq '.html' -or $item.Extension -eq '.htm') {
            Write-Host "`n是否要開啟此 HTML 檔案? (Y/N) " -NoNewline -ForegroundColor Yellow
            $response = Read-Host
            if ($response -eq 'Y' -or $response -eq 'y') {
                Start-Process $item.FullName
            }
        }
    }
    # 如果是目錄，直接切換
    else {
        Write-Host "📁 切換到目錄: " -NoNewline -ForegroundColor Cyan
        Write-Host $FullPath -ForegroundColor Green
        Set-Location $FullPath
        
        # 顯示新目錄的內容
        Write-Host "`n目錄內容:" -ForegroundColor Cyan
        Get-ChildItem | Format-Wide -AutoSize
    }
}

# 增強版 cw - 支援歷史記錄和快速跳轉
function cw2 {
    param(
        [Parameter(Position=0, ValueFromRemainingArguments=$true)]
        [string[]]$Path,
        [switch]$List,
        [switch]$Back,
        [switch]$Save,
        [string]$Alias
    )
    
    # 初始化歷史記錄
    if (-not $global:CwHistory) {
        $global:CwHistory = New-Object System.Collections.ArrayList
    }
    
    # 初始化書籤
    if (-not $global:CwBookmarks) {
        $global:CwBookmarks = @{}
    }
    
    # 顯示歷史記錄
    if ($List) {
        Write-Host "`n📜 目錄歷史:" -ForegroundColor Cyan
        for ($i = 0; $i -lt $global:CwHistory.Count; $i++) {
            Write-Host "  $i : $($global:CwHistory[$i])" -ForegroundColor Gray
        }
        Write-Host "`n🔖 書籤:" -ForegroundColor Cyan
        $global:CwBookmarks.GetEnumerator() | ForEach-Object {
            Write-Host "  $($_.Key) : $($_.Value)" -ForegroundColor Gray
        }
        return
    }
    
    # 返回上一個目錄
    if ($Back) {
        if ($global:CwHistory.Count -gt 1) {
            $prevDir = $global:CwHistory[-2]
            Set-Location $prevDir
            Write-Host "↩️  返回到: $prevDir" -ForegroundColor Green
        } else {
            Write-Host "❌ 沒有歷史記錄" -ForegroundColor Red
        }
        return
    }
    
    # 保存當前目錄為書籤
    if ($Save) {
        if ($Alias) {
            $global:CwBookmarks[$Alias] = $PWD.Path
            Write-Host "✅ 已保存書籤 '$Alias' -> $($PWD.Path)" -ForegroundColor Green
        } else {
            Write-Host "❌ 請提供書籤名稱: cw -Save -Alias <name>" -ForegroundColor Red
        }
        return
    }
    
    # 檢查是否為書籤
    if ($Path.Count -eq 1 -and $global:CwBookmarks.ContainsKey($Path[0])) {
        $bookmarkPath = $global:CwBookmarks[$Path[0]]
        Write-Host "🔖 使用書籤 '$($Path[0])'" -ForegroundColor Yellow
        Set-Location $bookmarkPath
        $global:CwHistory.Add($PWD.Path) | Out-Null
        return
    }
    
    # 如果沒有參數，顯示當前目錄
    if (-not $Path) {
        Write-Host "📁 當前目錄: " -NoNewline -ForegroundColor Cyan
        Write-Host $PWD.Path -ForegroundColor Yellow
        return
    }
    
    # 將所有參數組合成一個路徑
    $FullPath = $Path -join ' '
    
    # 檢查路徑是否存在
    if (-not (Test-Path $FullPath)) {
        # 嘗試在常用目錄中搜尋
        $searchDirs = @(
            "D:\",
            "C:\",
            $env:USERPROFILE,
            "$env:USERPROFILE\Documents",
            "$env:USERPROFILE\Desktop",
            "$env:USERPROFILE\Downloads"
        )
        
        Write-Host "🔍 搜尋 '$FullPath'..." -ForegroundColor Yellow
        
        foreach ($dir in $searchDirs) {
            $results = Get-ChildItem -Path $dir -Filter "*$FullPath*" -Directory -ErrorAction SilentlyContinue | Select-Object -First 5
            if ($results) {
                Write-Host "`n在 $dir 找到:" -ForegroundColor Cyan
                $results | ForEach-Object {
                    Write-Host "  • $($_.FullName)" -ForegroundColor Gray
                }
            }
        }
        return
    }
    
    # 取得項目資訊
    $item = Get-Item $FullPath
    
    # 記錄當前目錄到歷史
    $global:CwHistory.Add($PWD.Path) | Out-Null
    
    # 如果是檔案，切換到其所在目錄
    if ($item.PSIsContainer -eq $false) {
        $targetDir = $item.DirectoryName
        Write-Host "📄 檢測到檔案: " -NoNewline -ForegroundColor Yellow
        Write-Host $item.Name
        Write-Host "📁 切換到目錄: " -NoNewline -ForegroundColor Cyan
        Write-Host $targetDir -ForegroundColor Green
        
        Set-Location $targetDir
        
        # 根據檔案類型執行不同操作
        switch ($item.Extension.ToLower()) {
            {$_ -in '.html', '.htm'} {
                Write-Host "🌐 開啟 HTML 檔案..." -ForegroundColor Yellow
                Start-Process $item.FullName
            }
            {$_ -in '.txt', '.log', '.md'} {
                Write-Host "📝 使用 VS Code 開啟..." -ForegroundColor Yellow
                code $item.FullName
            }
            {$_ -in '.pdf'} {
                Write-Host "📑 開啟 PDF 檔案..." -ForegroundColor Yellow
                Start-Process $item.FullName
            }
        }
    }
    # 如果是目錄，直接切換
    else {
        Write-Host "📁 切換到目錄: " -NoNewline -ForegroundColor Cyan
        Write-Host $FullPath -ForegroundColor Green
        Set-Location $FullPath
    }
    
    # 顯示目錄內容摘要
    $items = Get-ChildItem
    $dirs = $items | Where-Object { $_.PSIsContainer }
    $files = $items | Where-Object { -not $_.PSIsContainer }
    
    Write-Host "`n📊 內容摘要: " -NoNewline -ForegroundColor Cyan
    Write-Host "$($dirs.Count) 個目錄, $($files.Count) 個檔案" -ForegroundColor Gray
    
    # 顯示前幾個項目
    if ($items.Count -gt 0) {
        Write-Host "📋 項目預覽:" -ForegroundColor Cyan
        $items | Select-Object -First 10 | ForEach-Object {
            if ($_.PSIsContainer) {
                Write-Host "  📁 $($_.Name)" -ForegroundColor Blue
            } else {
                Write-Host "  📄 $($_.Name)" -ForegroundColor Gray
            }
        }
        if ($items.Count -gt 10) {
            Write-Host "  ... 還有 $($items.Count - 10) 個項目" -ForegroundColor DarkGray
        }
    }
}

# 快速跳轉到專案目錄
function cwp {
    param(
        [string]$ProjectName
    )
    
    # 定義專案目錄
    $projectDirs = @{
        "cov" = "D:\coverity"
        "docs" = "$env:USERPROFILE\Documents"
        "downloads" = "$env:USERPROFILE\Downloads"
        # 在這裡添加更多專案目錄
        "def" = "c:\Program Files\Black Duck\Defensics Monitor\"
    }
    
    if (-not $ProjectName) {
        Write-Host "`n📁 可用的專案目錄:" -ForegroundColor Cyan
        $projectDirs.GetEnumerator() | ForEach-Object {
            Write-Host "  $($_.Key) : $($_.Value)" -ForegroundColor Gray
        }
        return
    }
    
    if ($projectDirs.ContainsKey($ProjectName)) {
        cw $projectDirs[$ProjectName]
    } else {
        Write-Host "❌ 未知的專案: $ProjectName" -ForegroundColor Red
        Write-Host "使用 'cwp' 查看可用專案" -ForegroundColor Yellow
    }
}

# 設定別名
Set-Alias -Name cd -Value cw -Option AllScope
Set-Alias -Name cwd -Value cw2

# 快捷鍵綁定（可選）
Set-PSReadLineKeyHandler -Key Alt+LeftArrow -ScriptBlock {
    cw2 -Back
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}


# ========== 完整的歷史記錄解決方案 ==========

# 1. 統一歷史路徑
$global:UnifiedHistoryPath = "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt"

# 2. 確保 PSReadLine 設定正確
Set-PSReadLineOption -HistorySavePath $global:UnifiedHistoryPath
Set-PSReadLineOption -HistorySaveStyle SaveIncrementally
Set-PSReadLineOption -MaximumHistoryCount 10000

# 3. 啟動時強制載入歷史（優化：只載入最後 1000 條）
if (Test-Path $global:UnifiedHistoryPath) {
    $historyContent = Get-Content $global:UnifiedHistoryPath -Encoding UTF8 -ErrorAction SilentlyContinue
    if ($historyContent) {
        $loadedCount = 0
        # 只載入最後 10000 條以加快啟動速度
        $historyContent | Select-Object -Last 10000 | Where-Object { $_.Trim() -ne '' } | ForEach-Object {
            try {
                [Microsoft.PowerShell.PSConsoleReadLine]::AddToHistory($_)
                $loadedCount++
            } catch {}
        }
        Write-Host "📚 已載入 $loadedCount 條歷史記錄" -ForegroundColor Green
    }
}

# ========== 記錄所有命令到歷史 ==========

# 1. 設定 AddToHistoryHandler 記錄所有內容
Set-PSReadLineOption -AddToHistoryHandler {
    param($line)
    # 只要不是空白就記錄（包括變數賦值）
    return -not [string]::IsNullOrWhiteSpace($line)
}

# 2. 確保歷史設定正確
Set-PSReadLineOption -HistorySaveStyle SaveIncrementally
Set-PSReadLineOption -MaximumHistoryCount 10000
Set-PSReadLineOption -HistorySavePath "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt"

# 3. 額外：確保特殊命令也被記錄
Set-PSReadLineOption -HistoryNoDuplicates:$false  # 允許重複命令也記錄

# 4. 測試函數
function Test-AllHistory {
    Write-Host "`n測試歷史記錄功能..." -ForegroundColor Cyan
    
    # 測試各種命令
    $testCommands = @(
        '$TestVar = "123"',
        'echo "test"',
        'cd C:\',
        '$ApiToken = "test-token"',
        '123'  # 短命令
    )
    
    foreach ($cmd in $testCommands) {
        $handler = (Get-PSReadLineOption).AddToHistoryHandler
        $result = & $handler $cmd
        
        $status = if ($result) { "✓" } else { "✗" }
        $color = if ($result) { "Green" } else { "Red" }
        
        Write-Host "$status $cmd" -ForegroundColor $color
    }
}

# 5. 顯示當前設定
Write-Host "`n📝 歷史記錄設定已更新：" -ForegroundColor Green
Write-Host "   • 記錄所有命令（包括變數賦值）" -ForegroundColor Gray
Write-Host "   • 允許重複命令" -ForegroundColor Gray
Write-Host "   • 最大歷史數量: 10000" -ForegroundColor Gray
Write-Host "   • 歷史檔案: $((Get-PSReadLineOption).HistorySavePath)" -ForegroundColor Gray