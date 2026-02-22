$taskName = "Backup-WincmdIni"
$scriptPath = "D:\mydotfile\backup-wincmd.ps1"
$trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Monday -At "22:00"
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`""
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
Register-ScheduledTask -TaskName $taskName -Trigger $trigger -Action $action -Settings $settings -Description "每週一 22:00 備份 Total Commander wincmd.ini" -Force
