# Windows App Install Script (winget)
# Run: powershell -ExecutionPolicy Bypass -File install_apps.ps1

# --- 開發工具 ---
winget install -e --id Git.Git
winget install -e --id Microsoft.VisualStudioCode
winget install -e --id Microsoft.VisualStudio.2022.Community
winget install -e --id Microsoft.PowerShell
winget install -e --id AutoHotkey.AutoHotkey
winget install -e --id Neovim.Neovim
winget install -e --id Vim.Vim
winget install -e --id Python.Python.3.13
winget install -e --id OpenJS.NodeJS
winget install -e --id Docker.DockerDesktop
winget install -e --id Postman.Postman
winget install -e --id Google.AndroidStudio
winget install -e --id EclipseAdoptium.Temurin.17.JDK

# --- 瀏覽器 ---
winget install -e --id Google.Chrome
winget install -e --id Mozilla.Firefox
winget install -e --id Opera.Opera
winget install -e --id Yandex.Browser

# --- 終端/SSH ---
winget install -e --id Mobatek.MobaXterm
winget install -e --id WinSCP.WinSCP
winget install -e --id Warp.Warp

# --- 檔案管理 ---
winget install -e --id Ghisler.TotalCommander
winget install -e --id 7zip.7zip
winget install -e --id Tim.Kosse.FileZilla.Client
winget install -e --id Rclone.Rclone

# --- 通訊 ---
winget install -e --id Telegram.TelegramDesktop
winget install -e --id LINE.LINE
winget install -e --id Tencent.WeChat
winget install -e --id Microsoft.Teams
winget install -e --id Cisco.Webex
winget install -e --id Zoom.Zoom

# --- 媒體 ---
winget install -e --id Daum.PotPlayer
winget install -e --id XnSoft.XnViewMP
winget install -e --id Bandisoft.Bandicut
winget install -e --id PicView.PicView

# --- 工具 ---
winget install -e --id Notepad++.Notepad++
winget install -e --id Ditto.Ditto
winget install -e --id ShareX.ShareX
winget install -e --id Microsoft.PowerToys
winget install -e --id Listary.Listary
winget install -e --id OhMyPosh.OhMyPosh
winget install -e --id RustDesk.RustDesk
winget install -e --id Spotify.Spotify
winget install -e --id Notion.Notion
winget install -e --id Google.Drive
winget install -e --id Citrix.ShareFile

# --- VPN/遠端 ---
winget install -e --id NordSecurity.NordVPN
winget install -e --id Google.ChromeRemoteDesktop

# --- 遊戲 ---
winget install -e --id Valve.Steam
winget install -e --id EpicGames.EpicGamesLauncher
winget install -e --id Blizzard.BattleNet

# --- 虛擬化 ---
winget install -e --id Oracle.VirtualBox
winget install -e --id Microsoft.WSL

# --- 網路工具 ---
winget install -e --id WiresharkFoundation.Wireshark
winget install -e --id Npcap.Npcap

# --- 其他 ---
winget install -e --id Anthropic.Claude
winget install -e --id Syncthing.Syncthing
winget install -e --id CPUID.CPU-Z
winget install -e --id SharpKeys.SharpKeys

Write-Host "`nDone! Some apps may need manual install:" -ForegroundColor Green
Write-Host "  - 115 Browser (no winget package)"
Write-Host "  - Snipaste (https://www.snipaste.com)"
Write-Host "  - Black Duck Defensics/Detect/Coverity/Seeker (internal)"
Write-Host "  - Keil uVision (https://www.keil.com)"
Write-Host "  - Futubull (https://www.futunn.com)"
