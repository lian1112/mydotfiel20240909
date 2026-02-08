#Requires AutoHotkey v2.0
#SingleInstance Force

; 測試 !+5 螢幕切換的每一步，顯示結果
MsgBox("即將測試 MultiMonitorTool 和 ControlMyMonitor`n按 OK 開始`n`n測試步驟:`n1. /enable (啟用螢幕)`n2. /LoadConfig (載入配置)`n3. /SetValue (切換輸入源)", "螢幕切換測試")

; 測試 1: MultiMonitorTool /enable
ToolTip("測試 1/3: RunWait MultiMonitorTool /enable ...")
startTime := A_TickCount
try {
    RunWait('D:\Tools\multimonitortool-x64\MultiMonitorTool.exe /enable "HNMR400156" "HNMR600125"')
    elapsed := A_TickCount - startTime
    result1 := "✓ /enable 完成 (" . elapsed . "ms)"
} catch as e {
    result1 := "✗ /enable 失敗: " . e.Message
}
ToolTip(result1)
Sleep(2000)

; 測試 2: MultiMonitorTool /LoadConfig
ToolTip("測試 2/3: RunWait MultiMonitorTool /LoadConfig ...")
startTime := A_TickCount
try {
    RunWait('D:\Tools\multimonitortool-x64\MultiMonitorTool.exe /LoadConfig "D:\Tools\multimonitortool-x64\4monitors.cfg"')
    elapsed := A_TickCount - startTime
    result2 := "✓ /LoadConfig 完成 (" . elapsed . "ms)"
} catch as e {
    result2 := "✗ /LoadConfig 失敗: " . e.Message
}
ToolTip(result2)
Sleep(2000)

; 測試 3: ControlMyMonitor /SetValue (只讀取不切換 - 用 /GetValue)
ToolTip("測試 3/3: RunWait ControlMyMonitor /SetValue ...")
startTime := A_TickCount
try {
    ; 這會切換上方螢幕到個人電腦（VCP 60 = Input Source, 6 = HDMI1）
    RunWait('D:\Tools\controlmymonitor\ControlMyMonitor.exe /SetValue "HNMR400156" 60 6')
    elapsed := A_TickCount - startTime
    result3 := "✓ /SetValue HNMR400156 完成 (" . elapsed . "ms)"
} catch as e {
    result3 := "✗ /SetValue 失敗: " . e.Message
}
ToolTip(result3)
Sleep(2000)

; 顯示結果
ToolTip()
MsgBox("測試結果:`n`n" . result1 . "`n" . result2 . "`n" . result3 . "`n`n如果時間都是 0-50ms 且螢幕沒切換,`n代表命令沒有真正執行。`n`n如果時間超過 100ms 且螢幕有反應,`n代表正常。", "測試結果")
ExitApp()
