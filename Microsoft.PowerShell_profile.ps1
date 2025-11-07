# Oh My Posh 配置（使用絕對路徑）
$ENV:POSH_THEMES_PATH = "C:\Users\yulia\AppData\Local\Programs\oh-my-posh\themes\"
& "C:\Users\yulia\AppData\Local\Programs\oh-my-posh\bin\oh-my-posh.exe" init pwsh --config "$ENV:POSH_THEMES_PATH\half-life.omp.json" | Invoke-Expression

# 設置 PowerShell 的字符編碼
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8


# 導入 PSReadLine
Import-Module PSReadLine
# 設置 PSReadLine 選項
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
# 設置上下箭頭鍵搜索歷史命令
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

# 導入 Terminal-Icons (如果已安裝)
if (Get-Module -ListAvailable -Name Terminal-Icons) {
    Import-Module Terminal-Icons
} else {
    Write-Host "Terminal-Icons 模組未安裝，使用 'Install-Module -Name Terminal-Icons -Scope CurrentUser' 安裝"
}

# 導入 ZLocation (如果已安裝)
if (Get-Module -ListAvailable -Name ZLocation) {
    Import-Module ZLocation
} else {
    Write-Host "ZLocation 模組未安裝，使用 'Install-Module -Name ZLocation -Scope CurrentUser' 安裝"
}