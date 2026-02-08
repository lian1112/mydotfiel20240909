@echo off
chcp 65001 >nul
set BACKUP_DIR=D:\mydotfile

echo [%date% %time%] Starting dotfile backup...

:: Total Commander
copy /Y "C:\Users\yulia\AppData\Roaming\GHISLER\wincmd.ini" "%BACKUP_DIR%\wincmd.ini"

:: Git config
copy /Y "C:\Users\yulia\.gitconfig" "%BACKUP_DIR%\.gitconfig"

:: SSH config
copy /Y "C:\Users\yulia\.ssh\config" "%BACKUP_DIR%\ssh_config"

:: Claude Code
copy /Y "C:\Users\yulia\.claude\CLAUDE.md" "%BACKUP_DIR%\claude\CLAUDE.md"
copy /Y "C:\Users\yulia\.claude\settings.json" "%BACKUP_DIR%\claude\settings.json"

:: VS Code
copy /Y "C:\Users\yulia\AppData\Roaming\Code\User\settings.json" "%BACKUP_DIR%\vscode\settings.json"
copy /Y "C:\Users\yulia\AppData\Roaming\Code\User\keybindings.json" "%BACKUP_DIR%\vscode\keybindings.json"

:: MobaXterm
copy /Y "C:\Users\yulia\AppData\Roaming\MobaXterm\MobaXterm.ini" "%BACKUP_DIR%\MobaXterm\MobaXterm.ini"

:: Notepad++
copy /Y "C:\Users\yulia\AppData\Roaming\Notepad++\config.xml" "%BACKUP_DIR%\notepadpp\config.xml"
copy /Y "C:\Users\yulia\AppData\Roaming\Notepad++\shortcuts.xml" "%BACKUP_DIR%\notepadpp\shortcuts.xml"

:: Snipaste
copy /Y "D:\snipaste\Snipaste.ini" "%BACKUP_DIR%\snipaste_ini\Snipaste.ini" 2>nul

:: PotPlayer
copy /Y "C:\Users\yulia\AppData\Roaming\PotPlayerMini64\PotPlayerMini64.ini" "%BACKUP_DIR%\PotPlayerMini64.ini" 2>nul

:: PowerShell profile
copy /Y "C:\Users\yulia\Documents\PowerShell\Microsoft.PowerShell_profile.ps1" "%BACKUP_DIR%\powershell_profile\Microsoft.PowerShell_profile.ps1" 2>nul

echo.
echo [%date% %time%] Backup complete. Pushing to git...

cd /d "%BACKUP_DIR%"
git add -A
git diff --cached --quiet
if %errorlevel% neq 0 (
    git commit -m "Auto backup dotfiles %date%"
    git push
    echo [%date% %time%] Pushed to remote.
) else (
    echo [%date% %time%] No changes to push.
)
