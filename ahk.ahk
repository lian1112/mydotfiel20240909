; ============================================================================
; Section 1: 指令
; ============================================================================
#Requires AutoHotkey v2.0
#SingleInstance Force
#Warn
FileEncoding "UTF-8"
SetWorkingDir A_ScriptDir
CoordMode("Mouse", "Screen")


; ============================================================================
; Section 2: 全域變數
; ============================================================================

; 應用程式路徑
global LINE_PATH := "C:\Users\yulia\AppData\Local\LINE\bin\current\LINE.exe"  ; 未使用?
global LINE_PARAMS := "--multipleWindow --processStart LINE.exe"  ; 未使用?
global FIREFOX_PATH := "C:\Program Files\Mozilla Firefox\firefox.exe"
global vscode := "C:\Users\yulia\AppData\Local\Programs\Microsoft VS Code\Code.exe"
global tunnel := "allenl-2404"
global remote_ssh := "192.168.31.5"

; PotPlayer
global POTPLAYER_EXES := ["PotPlayer64.exe", "PotPlayer.exe", "PotPlayerMini64.exe", "PotPlayerMini.exe"]
global CURRENT_SCREEN := 2
global LAST_POSITION := ""

; Diablo 4
global autoClickActive := false
global currentMode := ""


; ============================================================================
; Section 3: 熱字串
; ============================================================================
::/ggg::yulian.lin2@gmail.com
::/reg::BlackDuck_AllenLin_Engineering_Test_hub_0013400001XYQeLAAX
::/tok::ZTQ3ODg1ZTgtYzg5OC00NDJlLThkZjktODk2YjgzMzRmZDM4OmE3MWJmMzhiLWMyMzAtNDg0NS05YTNhLTU3ODQ2MzEyYmUzZg==
::/lll::林口區麗園一街6巷5號10樓-2
::/eee::10F.-2, No. 5, Ln. 6, Liyuan 1st St., Linkou Dist., New Taipei City, Taiwan (R.O.C.)
::/jjj::用中文翻譯以上日文句子,並且用中文,說明日文日的文法,文法變化,詞性,連接詞變化,漢字標註假名
::/jjp::天天給我一篇日文長篇章,每段下方給我中文,並且用中文,說明日文日的文法,文法變化,詞性,連接詞變化,漢字標註假名
::/ccc::給我完整的function,記得不要影響現有功能
::/eng::對話是中文說明,code是英文
::/def::我的環境是linux(192.168.1.2)需要設定為defensics的SUT, windows11(defensics安裝在這台,191.168.31.1(小米路由器port轉發), 另外有192.168.1.1是有線網路)
::/ppp::查看project文檔並給我回答及提供出處(for 確保回答正確)
::/png1::/mnt/d/snipaste/recent/1.png
::/png2::/mnt/d/snipaste/recent/2.png
::/png3::/mnt/d/snipaste/recent/3.png
::/know::參考project的knowledgebase,查看以下的問題
::/know2::確定project的knowledgebase有提到這些?
::/snap::@/home/allenl/snipaste/recent/1.png
::/key::YWY2ODUzOTEtOGEyYy00YjQ1LWExOWItZTA1YWM2YTI4NWI4OjZjOTdlNmNhLTU5ODgtNGM4YS1hNzNhLWNiN2I4MGVjZjMzOA==


; ============================================================================
; Section 4: 啟動程式碼
; ============================================================================
ToolTip("整合腳本已啟動！")
SetTimer () => ToolTip(), -3000
LogMessage("整合腳本已啟動")

; Explorer 新視窗監控：自動合併到已有視窗的新 tab（使用系統級 WinEvent hook）
global explorerHook_pCallback := CallbackCreate(OnExplorerWindowShow, "F", 7)
global explorerHook_handle := DllCall("SetWinEventHook"
    , "UInt", 0x8002  ; EVENT_OBJECT_SHOW
    , "UInt", 0x8002
    , "Ptr", 0
    , "Ptr", explorerHook_pCallback
    , "UInt", 0  ; 所有 process
    , "UInt", 0  ; 所有 thread
    , "UInt", 0x0  ; WINEVENT_OUTOFCONTEXT
    , "Ptr")


; ============================================================================
; Section 5: 全域熱鍵 - 螢幕管理
; ============================================================================

; 4螢幕模式 - 全開（個人電腦）
!+5:: {
    ToolTip("正在啟用所有螢幕...")
    RunWait('D:\Tools\multimonitortool-x64\MultiMonitorTool.exe /enable "HNMR400156" "HNMR600125"')
    Sleep(1500)

    ToolTip("正在載入4螢幕配置...")
    RunWait('D:\Tools\multimonitortool-x64\MultiMonitorTool.exe /LoadConfig "D:\Tools\multimonitortool-x64\4monitors.cfg"')
    Sleep(1500)

    ToolTip("正在切換上方螢幕到個人電腦...")
    RunWait('D:\Tools\controlmymonitor\ControlMyMonitor.exe /SetValue "HNMR400156" 60 6')
    Sleep(500)

    ToolTip("正在切換下方螢幕到個人電腦...")
    RunWait('D:\Tools\controlmymonitor\ControlMyMonitor.exe /SetValue "HNMR600125" 60 15')

    ToolTip("切換完成! (4螢幕)")
    Sleep(1000)
    ToolTip()
}

; 2螢幕模式 - 切換到公司電腦
!+6:: {
    ToolTip("正在啟用所有螢幕...")
    RunWait('D:\Tools\multimonitortool-x64\MultiMonitorTool.exe /enable "HNMR400156" "HNMR600125"')
    Sleep(1500)

    ToolTip("正在切換上方螢幕到公司電腦...")
    RunWait('D:\Tools\controlmymonitor\ControlMyMonitor.exe /SetValue "HNMR400156" 60 15')
    Sleep(500)

    ToolTip("正在切換下方螢幕到公司電腦...")
    RunWait('D:\Tools\controlmymonitor\ControlMyMonitor.exe /SetValue "HNMR600125" 60 6')
    Sleep(1000)

    ToolTip("正在停用 Samsung 螢幕...")
    RunWait('D:\Tools\multimonitortool-x64\MultiMonitorTool.exe /disable "HNMR400156" "HNMR600125"')

    ToolTip("切換完成! (2螢幕)")
    Sleep(1000)
    ToolTip()
}

; 3螢幕模式
!+7:: {
    ToolTip("正在啟用所有螢幕...")
    RunWait('D:\Tools\multimonitortool-x64\MultiMonitorTool.exe /enable "HNMR400156" "HNMR600125"')
    Sleep(3000)

    ToolTip("正在載入4螢幕配置...")
    RunWait('D:\Tools\multimonitortool-x64\MultiMonitorTool.exe /LoadConfig "D:\Tools\multimonitortool-x64\4monitors.cfg"')
    Sleep(7000)

    ToolTip("正在切換上方螢幕到公司電腦...")
    RunWait('D:\Tools\controlmymonitor\ControlMyMonitor.exe /SetValue "HNMR600156" 60 15')
    Sleep(1500)

    ToolTip("正在切換下方螢幕到個人電腦...")
    RunWait('D:\Tools\controlmymonitor\ControlMyMonitor.exe /SetValue "HNMR400125" 60 15')
    Sleep(1500)

    ToolTip("正在停用上方 Samsung...")
    RunWait('D:\Tools\multimonitortool-x64\MultiMonitorTool.exe /disable "HNMR400156"')
    Sleep(1000)

    ToolTip("正在載入3螢幕配置...")
    RunWait('D:\Tools\multimonitortool-x64\MultiMonitorTool.exe /LoadConfig "D:\Tools\multimonitortool-x64\3monitors.cfg"')

    ToolTip("切換完成! (3螢幕)")
    Sleep(1000)
    ToolTip()
}

; 切換上方螢幕到個人電腦
!+{:: {
    Run('D:\Tools\controlmymonitor\ControlMyMonitor.exe /SetValue "HNMR400156" 60 6')
}
; 切換下方螢幕到個人電腦
!+}:: {
    Run('D:\Tools\controlmymonitor\ControlMyMonitor.exe /SetValue "HNMR600125" 60 15')
}

; 切換上方螢幕到公司電腦
![:: {
    Run('D:\Tools\controlmymonitor\ControlMyMonitor.exe /SetValue "HNMR400156" 60 15')
}
; 切換下方螢幕到公司電腦
!]:: {
    Run('D:\Tools\controlmymonitor\ControlMyMonitor.exe /SetValue "HNMR600125" 60 6')
}

; 切換到只顯示 1,2 (停用 3,4)
!+2:: {
    Run('D:\Tools\multimonitortool-x64\MultiMonitorTool.exe /disable 3 4')
}

; 切換到 1,2,3 開啟(螢幕4關閉)
!+3:: {
    Run('D:\Tools\multimonitortool-x64\MultiMonitorTool.exe /LoadConfig "D:\Tools\multimonitortool-x64\monitors_123only.cfg"')
}

; 切換到 1,2,3,4 全開,恢復正確位置(4在上,3在下)
!+4:: {
    Run('D:\Tools\multimonitortool-x64\MultiMonitorTool.exe /enable 3 4')
    Sleep(1000)
    Run('D:\Tools\multimonitortool-x64\MultiMonitorTool.exe /SetMonitors "Name=\\.\DISPLAY4 BitsPerPixel=32 Width=3840 Height=2160 DisplayFlags=0 DisplayFrequency=60 DisplayOrientation=0 PositionX=-3840 PositionY=-1021" "Name=\\.\DISPLAY3 BitsPerPixel=32 Width=3840 Height=2160 DisplayFlags=0 DisplayFrequency=60 DisplayOrientation=0 PositionX=-3840 PositionY=1155" "Name=\\.\DISPLAY2 Primary=1 BitsPerPixel=32 Width=3840 Height=2160 DisplayFlags=0 DisplayFrequency=144 DisplayOrientation=0 PositionX=0 PositionY=0" "Name=\\.\DISPLAY1 BitsPerPixel=32 Width=3840 Height=2160 DisplayFlags=0 DisplayFrequency=60 DisplayOrientation=0 PositionX=3840 PositionY=-20"')
}


; ============================================================================
; Section 6: 全域熱鍵 - 應用程式啟動
; ============================================================================

; Alt+A: Microsoft Edge
!a:: {
    ActivateOrRun("msedge.exe", "c:\program files (x86)\microsoft\edge\application\msedge.exe")
}

; Alt+C: Claude
!c:: {
    ActivateOrRun("claude.exe", "C:\Users\yulia\AppData\Local\AnthropicClaude\claude.exe")
}

; Alt+D: VS Code
!d:: {
    ActivateOrRun("Code.exe", "C:\Users\yulia\AppData\Local\Programs\Microsoft VS Code\Code.exe")
}

; Alt+E: Yandex Browser
!e:: {
    ActivateOrRun("browser.exe", "C:\Users\yulia\AppData\Local\Yandex\YandexBrowser\Application\browser.exe")
}

; Alt+F: Total Commander
!f:: {
    ActivateOrRun("TOTALCMD64.EXE", "C:\Program Files\totalcmd\TOTALCMD64.EXE")
}

; Alt+I / Alt+Shift+E: Excel
!i::
!+e:: {
    ActivateOrRun("Excel.EXE", "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Excel.lnk")
}

; Alt+J: Linux 路徑轉換 → 在 Total Commander 中開啟
!j:: {
    linuxPath := Trim(A_Clipboard)

    if (linuxPath = "") {
        ToolTip("剪貼簿是空的")
        SetTimer(() => ToolTip(), -2000)
        return
    }

    if !InStr(linuxPath, "/") {
        ToolTip("剪貼簿內容不是 Linux 路徑")
        SetTimer(() => ToolTip(), -2000)
        return
    }

    winPath := ""
    if (SubStr(linuxPath, 1, 13) = "/home/allenl/") {
        winPath := "Z:\" . StrReplace(SubStr(linuxPath, 14), "/", "\")
    } else if (linuxPath = "/home/allenl") {
        winPath := "Z:\"
    } else {
        ToolTip("無法對應的 Linux 路徑: " . linuxPath)
        SetTimer(() => ToolTip(), -2000)
        return
    }

    lastPart := ""
    lastSlashPos := InStr(winPath, "\",, -1)
    if (lastSlashPos > 0)
        lastPart := SubStr(winPath, lastSlashPos + 1)

    if (lastPart != "" && InStr(lastPart, ".")) {
        winPath := SubStr(winPath, 1, lastSlashPos - 1)
    }

    if (StrLen(winPath) > 3 && SubStr(winPath, -1) = "\")
        winPath := SubStr(winPath, 1, -1)

    if (winPath = "Z:")
        winPath := "Z:\"

    tcPath := "C:\Program Files\totalcmd\TOTALCMD64.EXE"

    try {
        Run(tcPath . ' /O /T /S "' . winPath . '"')
        ToolTip("已導航到: " . winPath)
    } catch as err {
        ToolTip("執行失敗: " . err.Message)
    }

    SetTimer(() => ToolTip(), -2000)
}

; Alt+K / Alt+Shift+G: Telegram
!+g::
!k:: {
    ActivateOrRun("Telegram.exe", "c:\Users\yulia\AppData\Roaming\Telegram Desktop\Telegram.exe")
}

; Alt+N: Notepad++
!n:: {
    ActivateOrRun("notepad++.exe", "C:\Program Files\Notepad++\notepad++.exe")
}

; Alt+P: PowerPoint
!p:: {
    ActivateOrRun("POWERPNT.EXE", "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\PowerPoint.lnk")
}

; Alt+Q: Google Chrome
!q:: {
    ActivateOrRun("chrome.exe", "C:\Program Files\Google\Chrome\Application\chrome.exe")
}

; Alt+S: Windows Terminal
!s:: {
    ActivateOrRun("WindowsTerminal.exe", "C:\Users\yulia\AppData\Local\Microsoft\WindowsApps\wt.exe")
}

; Alt+U: WinSCP
!u:: {
    ActivateOrRun("WinSCP.exe", "C:\Program Files (x86)\WinSCP\WinSCP.exe")
}

; Alt+X: Teams
!x:: {
    ActivateOrRun("ms-teams.exe", "C:\Users\yulia\AppData\Local\Microsoft\WindowsApps\ms-teams.exe")
}

; Alt+Y: Spotify
!y:: {
    ActivateOrRun("spotify.exe", "C:\Users\yulia\AppData\Roaming\Spotify\Spotify.exe")
}

; Alt+Z: Notion
!z:: {
    ActivateOrRun("Notion.exe", "C:\Users\yulia\AppData\Local\Programs\Notion\Notion.exe")
}

; Alt+;: FTNN (富途牛牛)
!;:: {
    ActivateOrRun("FTNN.exe", "C:\Users\yulia\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\富途牛牛.lnk")
}

; Alt+\: 115瀏覽器
!\:: {
    ActivateOrRun("115chrome.exe", "C:\Users\yulia\AppData\Local\115Chrome\Application\115chrome.exe")
}

; Alt+Shift+A: Opera
!+a:: {
    ActivateOrRun("opera.exe", "C:\Users\yulia\AppData\Local\Programs\Opera\opera.exe")
}

; Alt+Shift+F: FileZilla
!+f:: {
    ActivateOrRun("filezilla.exe", "C:\Program Files\FileZilla FTP Client\filezilla.exe")
}

; Alt+Shift+J: Linux 路徑轉換 → 用關聯程式開啟檔案
!+j:: {
    linuxPath := Trim(A_Clipboard)

    if (linuxPath = "") {
        ToolTip("剪貼簿是空的")
        SetTimer(() => ToolTip(), -2000)
        return
    }

    if !InStr(linuxPath, "/") {
        ToolTip("剪貼簿內容不是 Linux 路徑")
        SetTimer(() => ToolTip(), -2000)
        return
    }

    winPath := ""
    if (SubStr(linuxPath, 1, 13) = "/home/allenl/") {
        winPath := "Z:\" . StrReplace(SubStr(linuxPath, 14), "/", "\")
    } else if (linuxPath = "/home/allenl") {
        ToolTip("這是目錄，不是檔案")
        SetTimer(() => ToolTip(), -2000)
        return
    } else {
        ToolTip("無法對應的 Linux 路徑: " . linuxPath)
        SetTimer(() => ToolTip(), -2000)
        return
    }

    lastPart := ""
    lastSlashPos := InStr(winPath, "\",, -1)
    if (lastSlashPos > 0)
        lastPart := SubStr(winPath, lastSlashPos + 1)

    if (lastPart = "" || !InStr(lastPart, ".")) {
        ToolTip("這是目錄，不是檔案，請用 Alt+J")
        SetTimer(() => ToolTip(), -2000)
        return
    }

    try {
        Run('powershell -WindowStyle Hidden -Command "Invoke-Item \"' . winPath . '\""')
        ToolTip("已開啟: " . winPath)
    } catch as err {
        ToolTip("開啟失敗: " . err.Message)
    }

    SetTimer(() => ToolTip(), -2000)
}

; Alt+Shift+P: 小畫家
!+p:: ActivateOrRun("mspaint.exe", "C:\Windows\System32\mspaint.exe")

; Alt+Shift+R: Firefox
!+r:: {
    ActivateOrRun("firefox.exe", FIREFOX_PATH)
}

; Alt+Shift+S: Warp Terminal
!+s:: {
    ActivateOrRun("warp.exe", "C:\Users\yulia\AppData\Local\Programs\Warp\warp.exe")
}

; Alt+Shift+T: VS Code SSH 遠端連線
!+t:: {
    Run(vscode . " --remote ssh-remote+" . remote_ssh . " .")
}

; Alt+Shift+V: Beyond Compare
!+v:: {
    ActivateOrRun("BCompare.exe", "d:\Tools\buy\Beyond_Compare\Beyond_Compare_Pro_Win_v4.4.4\BCompare\BCompare.exe")
}

; Alt+Shift+X: Claude (同 Alt+C)
!+x:: {
    ActivateOrRun("claude.exe", "C:\Users\yulia\AppData\Local\AnthropicClaude\claude.exe")
}

; --- 已停用的應用程式快捷鍵 ---
; !.:: ActivateOrRun("WeChat.exe", ...)  ; WeChat 已停用
; !+j:: Run(vscode . " --remote tunnel+" . tunnel)  ; VS Code Tunnel 已改為 Linux 路徑轉換


; ============================================================================
; Section 7: 全域熱鍵 - 系統/工具
; ============================================================================

; Win+E: 切到已有的 Explorer 視窗，沒有才開新的
#e:: {
    if WinExist("ahk_class CabinetWClass") {
        WinActivate()
    } else {
        Run("explorer.exe")
    }
}

; Win+H: 開啟自動隱藏 taskbar
#h:: RunPowerShell(3)
; Win+Shift+H: 關閉自動隱藏 taskbar
#+h:: RunPowerShell(2)

; Win+L / Ctrl+L: 轉發 Ctrl+L
#l:: ^l
^l:: ^l

; Win+C: Send Ctrl+C
#c:: Send "^c"

; Win+Q: 關閉當前窗口 (Alt+F4)
#q:: {
    Send "!" "{F4}"
}

; Win+Shift+M: 最大化当前窗口
#+m:: {
    Send "#" "{Up}"
}

; Ctrl+Shift+R: 重新載入腳本
$^+r:: {
    try {
        Reload
        SetTimer () => ToolTip("腳本已成功重新載入！"), -1000
        SetTimer () => ToolTip(), -3000
    } catch as err {
        LogMessage("錯誤: 無法重新載入腳本: " . err.Message)
        MsgBox("無法重新載入腳本: " . A_ScriptFullPath . "`n錯誤: " . err.Message)
    }
}

; Ctrl+Alt+T: 取得 Total Commander 文字
^!t:: {
    text := WinGetText("ahk_class TTOTAL_CMD")
    MsgBox(text)
}

; Ctrl+Alt+V: 剪貼板圖片存為 JPG
^!v:: {
    if !DllCall("IsClipboardFormatAvailable", "uint", 2)
        return

    hwnd := WinGetID("A")
    winClass := WinGetClass("A")

    if InStr(winClass, "TTOTAL_CMD")
        dir := GetTCPath(hwnd)
    else if winClass ~= "Progman|WorkerW"
        dir := A_Desktop
    else {
        for w in ComObject("Shell.Application").Windows
            if w.HWND = hwnd
                dir := w.Document.Folder.Self.Path
    }

    if !IsSet(dir) || !DirExist(dir)
        return

    ; GDI+ 存 JPG
    si := Buffer(24, 0), NumPut("uint", 1, si)
    DllCall("LoadLibrary", "str", "gdiplus")
    DllCall("gdiplus\GdiplusStartup", "ptr*", &pToken := 0, "ptr", si, "ptr", 0)
    DllCall("OpenClipboard", "ptr", 0)
    hBmp := DllCall("GetClipboardData", "uint", 2, "ptr")
    DllCall("gdiplus\GdipCreateBitmapFromHBITMAP", "ptr", hBmp, "ptr", 0, "ptr*", &pBitmap := 0)
    DllCall("CloseClipboard")

    ; JPEG CLSID
    clsid := Buffer(16)
    NumPut("int64", 0x11D31A04557CF401, "int64", 0x2EF31EF80000739A, clsid)

    filePath := dir "\" FormatTime(, "yyyyMMdd_HHmmss") ".jpg"
    DllCall("gdiplus\GdipSaveImageToFile", "ptr", pBitmap, "wstr", filePath, "ptr", clsid, "ptr", 0)
    DllCall("gdiplus\GdipDisposeImage", "ptr", pBitmap)
    DllCall("gdiplus\GdiplusShutdown", "ptr", pToken)

    TrayTip(filePath)
}

; Alt+M: 暫停/播放媒體
!m:: {
    Send "{Media_Play_Pause}"
}

; Alt+/: 顯示快捷鍵列表
!/:: {
    static hotkeyText := "
(
系統快捷鍵:
-------------------
Win+Shift+M: 最大化當前窗口
Win+Q: 關閉當前窗口 (Alt+F4)
Ctrl+Shift+R: 重新載入腳本
Win+C: Ctrl+C (複製)

應用程式快捷鍵:
-------------------
Alt+A: Microsoft Edge
Alt+C: Claude
Alt+D: VS Code
Alt+E: Yandex Browser
Alt+F: Total Commander
Alt+I: Excel
Alt+J: Linux路徑→TC開啟
Alt+K: Telegram
Alt+N: Notepad++
Alt+P: PowerPoint
Alt+Q: Chrome
Alt+S: Windows Terminal
Alt+U: WinSCP
Alt+X: Teams
Alt+Y: Spotify
Alt+Z: Notion
Alt+;: FTNN
Alt+\: 115瀏覽器
Alt+Shift+A: Opera
Alt+Shift+F: FileZilla
Alt+Shift+J: Linux路徑→開啟檔案
Alt+Shift+P: 小畫家
Alt+Shift+R: Firefox
Alt+Shift+S: Warp Terminal
Alt+Shift+T: VS Code SSH
Alt+Shift+V: Beyond Compare
Alt+Shift+X: Claude

螢幕管理:
-------------------
Alt+Shift+5: 4螢幕(個人電腦)
Alt+Shift+6: 2螢幕(公司電腦)
Alt+Shift+7: 3螢幕
Alt+Shift+{/}: 上/下螢幕→個人
Alt+[/]: 上/下螢幕→公司

115瀏覽器特殊功能:
-------------------
Q: 快速選擇並搜索
Ctrl+Q: 選擇並在新分頁搜索

文件管理器快捷鍵:
-------------------
/: 在Total Commander中打開
Ctrl+R: 重命名
Shift+Enter: 顯示右鍵菜單
)"

    MyGui := Gui()
    MyGui.SetFont("s10", "Consolas")
    MyGui.Add("Edit", "ReadOnly w800 h600", hotkeyText)
    MyGui.Title := "熱鍵列表"
    MyGui.Show()
}


; ============================================================================
; Section 8: #HotIf 區塊 - 應用程式專用熱鍵
; ============================================================================

; --- Chrome / Edge ---
#HotIf WinActive("ahk_exe chrome.exe") || WinActive("ahk_exe msedge.exe")
^r::{
    ToolTip("已轉換為 Ctrl+Shift+R")
    SetTimer () => ToolTip(), -1000
    Send "^+r"
}
#HotIf

; --- PotPlayer --- (函式見 Section 12)
#HotIf WinActive("ahk_exe PotPlayer64.exe") or WinActive("ahk_exe PotPlayer.exe") or WinActive("ahk_exe PotPlayerMini64.exe") or WinActive("ahk_exe PotPlayerMini.exe")
w:: MovePotPlayerToPosition("topleft")
e:: MovePotPlayerToPosition("topright")
s:: MovePotPlayerToPosition("bottomleft")
d:: MovePotPlayerToPosition("bottomright")
r:: DistributePotPlayerWindows()
#HotIf

; --- 115 瀏覽器 --- (函式見 Section 11)
#HotIf is115Active()
q::
{
    Click 3
    Sleep 50
    Send "^c"
    Sleep 100

    processedText := ProcessClipboardText()
    A_Clipboard := processedText

    Send "{Ctrl}"
    Sleep 100
    Send "{Ctrl}"

    Sleep 200
    Send "^v"
    Sleep 100
}

^q::
{
    Click 3
    Sleep 50
    Send "^c"
    Sleep 100
    processedText := ProcessClipboardText(false)
    A_Clipboard := processedText

    Sleep 100
    Send "e"
    Sleep 100
    Send "gg"
    Sleep 300
    Send "gi"
    Sleep 100
    Send "^a"
    Sleep 100
    Send "^v"
    Sleep 100
    Send "{Enter}"
}
#HotIf

; --- Windows Explorer --- (函式見 Section 10)
#HotIf WinActive("ahk_class CabinetWClass") or WinActive("ahk_class ExploreWClass")
/::OpenInTotalCommander()
^r::Send "{F2}"
+Enter::Send "{AppsKey}"
; 方向鍵：→ 進入選中資料夾，← 上一層（只在檔案列表區，不影響地址列/搜尋列）
Right::ExplorerArrowRight()
Left::ExplorerArrowLeft()
; Ctrl+P：複製選中項目的完整路徑
^p::ExplorerCopyPath()
#HotIf

; --- Diablo 4 --- (函式見 Section 13)
#HotIf IsDiablo4Active()
s::HandleHotkey("s")
f::HandleHotkey("b")
v::HandleHotkey("b")
#HotIf


; ============================================================================
; Section 9: 函式 - 核心/共用工具
; ============================================================================

; Explorer 新視窗監控函式（系統級 WinEvent hook 回調）
OnExplorerWindowShow(hWinEventHook, event, hwnd, idObject, idChild, dwEventThread, dwmsEventTime) {
    ; 只處理視窗本體 (idObject=0, idChild=0)
    if (idObject != 0 || idChild != 0)
        return
    ; 檢查是否為 Explorer 視窗
    try {
        if (WinGetClass("ahk_id " . hwnd) != "CabinetWClass")
            return
    } catch {
        return
    }
    ; 延遲一下讓視窗完全初始化
    SetTimer(() => RedirectExplorerWindow(hwnd), -300)
}

RedirectExplorerWindow(newHwnd) {
    ; 確認視窗還存在
    if !WinExist("ahk_id " . newHwnd)
        return
    ; 取得新視窗的路徑和選中的項目
    newPath := ""
    selectedPath := ""
    newWindow := ""
    for window in ComObject("Shell.Application").Windows {
        try {
            if (window.HWND = newHwnd) {
                newWindow := window
                newPath := window.Document.Folder.Self.Path
                ; 檢查是否有選中的項目（115 用 /select 開的會選中子資料夾）
                if (window.Document.SelectedItems.Count > 0) {
                    item := window.Document.SelectedItems.Item(0)
                    if (item.IsFolder)
                        selectedPath := item.Path
                }
                break
            }
        }
    }
    if (newPath = "")
        return
    ; 如果有選中的子資料夾，目標路徑改為子資料夾
    targetPath := (selectedPath != "") ? selectedPath : newPath
    ; 找已有的 Explorer 視窗 HWND（非新視窗的）
    oldHwnd := 0
    for window in ComObject("Shell.Application").Windows {
        try {
            if (window.HWND != newHwnd) {
                oldHwnd := window.HWND
                break
            }
        }
    }
    if (oldHwnd = 0)
        return  ; 這是唯一的 Explorer 視窗，不處理
    ; 關掉新視窗
    WinClose("ahk_id " . newHwnd)
    Sleep(150)
    ; 在舊視窗用 WM_COMMAND 開新 tab，再用 COM Navigate2 導航
    WinActivate("ahk_id " . oldHwnd)
    WinWaitActive("ahk_id " . oldHwnd,, 2)
    ; 記錄開新 tab 前的 COM window 數量
    shellApp := ComObject("Shell.Application")
    oldCount := shellApp.Windows.Count
    ; 發送未公開的 WM_COMMAND 0xA21B 給 ShellTabWindowClass1 開新 tab
    try {
        SendMessage(0x0111, 0xA21B, 0, "ShellTabWindowClass1", "ahk_id " . oldHwnd)
    } catch {
        return
    }
    ; 等待新 tab 在 COM 中出現（最多 3 秒）
    timeout := A_TickCount + 3000
    while (shellApp.Windows.Count <= oldCount) {
        Sleep(50)
        if (A_TickCount > timeout)
            return
    }
    Sleep(100)
    ; 導航新 tab（COM 集合中最後一個就是新開的 tab）
    try {
        newTab := shellApp.Windows.Item(oldCount)
        newTab.Navigate2(targetPath)
    }
}

; 在所有視窗間循環切換
ActivateOrRun(processName, exePath, params := "") {
    try {
        idList := WinGetList("ahk_exe " . processName)
    } catch {
        Run(exePath . " " . params)
        return
    }

    realWindows := []
    for id in idList {
        if (WinGetTitle(id) != "") {
            realWindows.Push(id)
        }
    }

    if (realWindows.Length == 0) {
        Run(exePath . " " . params)
        return
    }

    activeWindow := 0
    try {
        activeWindow := WinGetID("A")
    }

    isTargetActive := false
    for id in realWindows {
        if (id == activeWindow) {
            isTargetActive := true
            break
        }
    }

    targetID := 0

    if (!isTargetActive) {
        targetID := realWindows[1]
    } else {
        sortedWindows := realWindows.Clone()

        Loop sortedWindows.Length - 1 {
            i := A_Index
            Loop sortedWindows.Length - i {
                j := A_Index
                if (sortedWindows[j] > sortedWindows[j + 1]) {
                    temp := sortedWindows[j]
                    sortedWindows[j] := sortedWindows[j + 1]
                    sortedWindows[j + 1] := temp
                }
            }
        }

        currentIndex := 0
        for i, id in sortedWindows {
            if (id == activeWindow) {
                currentIndex := i
                break
            }
        }

        nextIndex := currentIndex + 1
        if (nextIndex > sortedWindows.Length) {
            nextIndex := 1
        }
        targetID := sortedWindows[nextIndex]
    }

    if (targetID != 0) {
        WinActivate(targetID)
        try HandleMousePosition(targetID)
    }
}

; --- 備用版本 (未使用) ---
; ActivateOrRun(processName, exePath, params := "") {
;     LogMessage("嘗試啟動或切換到: " . processName)
;     ...
; }

; --- 備用版本2: 追蹤最近使用的視窗 (未使用) ---
; global recentWindows := Map()
; ActivateOrRun(processName, exePath, params := "") {
;     ...
; }

; 共用的滑鼠處理邏輯
HandleMousePosition(windowID) {
    WinGetPos(&winX, &winY, &winWidth, &winHeight, windowID)
    centerX := winX + winWidth / 2
    centerY := winY + winHeight / 2

    MouseGetPos(&mouseX, &mouseY)

    windowMonitor := GetMonitorFromPoint(centerX, centerY)
    mouseMonitor := GetMonitorFromPoint(mouseX, mouseY)

    if (windowMonitor != mouseMonitor) {
        MoveToCenterOfMonitor(windowMonitor)
    }
}

; 嘗試運行程序並處理錯誤
RunProgram(exePath, params := "") {
    try {
        if (FileExist(exePath)) {
            Run exePath . " " . params
            LogMessage("成功啟動程序: " . exePath . " 參數: " . params)
        } else {
            throw Error("文件不存在")
        }
    } catch as err {
        errorMessage := "無法啟動程序: " . exePath . "`n參數: " . params . "`n錯誤: " . err.Message . "`n`n請檢查路徑是否正確，並確保您有權限運行該程序。"
        LogMessage("錯誤: " . errorMessage)
        MsgBox(errorMessage)
    }
}

; 記錄消息到文件
LogMessage(message) {
    ; FileAppend FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss") . " - " . message . "`n", "ahk_log.txt"
}

; 取得螢幕邊界
GetMonitorBounds() {
    monitorCount := MonitorGetCount()
    bounds := []

    loop monitorCount {
        MonitorGet(A_Index, &left, &top, &right, &bottom)
        bounds.Push({
            number: A_Index,
            left: left,
            top: top,
            right: right,
            bottom: bottom
        })
    }
    return bounds
}

; 從座標取得所在螢幕編號
GetMonitorFromPoint(x, y) {
    bounds := GetMonitorBounds()

    for bound in bounds {
        if (x >= bound.left && x <= bound.right && y >= bound.top && y <= bound.bottom) {
            return bound.number
        }
    }

    minDist := -1
    closestMonitor := 1

    for bound in bounds {
        monitorCenterX := bound.left + (bound.right - bound.left) / 2
        monitorCenterY := bound.top + (bound.bottom - bound.top) / 2

        dist := Sqrt((x - monitorCenterX) ** 2 + (y - monitorCenterY) ** 2)

        if (minDist = -1 || dist < minDist) {
            minDist := dist
            closestMonitor := bound.number
        }
    }

    return closestMonitor
}

; 移動滑鼠到指定螢幕中央
MoveToCenterOfMonitor(monitorNumber) {
    MonitorGetWorkArea(monitorNumber, &left, &top, &right, &bottom)
    centerX := left + (right - left) / 2
    centerY := top + (bottom - top) / 2
    MouseMove(centerX, centerY, 2)
}

; 透過 PowerShell 設定 taskbar 自動隱藏
RunPowerShell(value) {
    cmd := Format('PowerShell.exe -Command "$path = `'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3`'; $v = (Get-ItemProperty -Path $path).Settings; $v[8] = {}; Set-ItemProperty -Path $path -Name Settings -Value $v; Stop-Process -Name explorer -Force"', value)
    Run(cmd,, "Hide")
}


; ============================================================================
; Section 10: 函式 - 檔案總管整合
; ============================================================================

; 取得 Total Commander 當前路徑
GetTCPath(hwnd) {
    text := WinGetText("ahk_id " hwnd)
    if RegExMatch(text, "m)^([a-zA-Z]:\\.+)>", &m)
        return m[1]
    return ""
}

; 取得 Explorer 當前路徑
GetExplorerPath() {
    for window in ComObject("Shell.Application").Windows {
        if (window.HWND == WinGetID("A")) {
            return window.Document.Folder.Self.Path
        }
    }
    return ""
}

; 在 Total Commander 中打開當前 Explorer 路徑
OpenInTotalCommander() {
    explorerHwnd := WinExist("A")
    currentPath := GetExplorerPath()
    selectedItem := GetSelectedItem()
    isFolder := IsSelectedItemFolder()

    if (currentPath != "") {
        try {
            tcPath := 'C:\Program Files\totalcmd\TOTALCMD64.EXE'

            if (selectedItem != "" && isFolder) {
                params := '/O /T "' . currentPath . "\" . selectedItem . '"'
            } else {
                params := '/O /T "' . currentPath . '"'
            }

            if (WinExist("ahk_class TTOTAL_CMD")) {
                Run tcPath . " " . params
            } else {
                Run tcPath . " " . params
            }

            WinWait "ahk_class TTOTAL_CMD"
            WinActivate "ahk_class TTOTAL_CMD"
            Sleep 500

            if (explorerHwnd) {
                WinClose("ahk_id " . explorerHwnd)
            }
        } catch as e {
            MsgBox("Error running Total Commander: " . e.Message)
        }
    } else {
        MsgBox("Failed to get current path")
    }
}

; 取得當前選中的檔案或資料夾名稱
GetSelectedItem() {
    try {
        for window in ComObject("Shell.Application").Windows {
            if (window.Document.Folder.Self.Path == GetExplorerPath()) {
                for item in window.Document.SelectedItems {
                    return item.Name
                }
            }
        }
    }
    return ""
}

; Explorer 方向鍵 → ：選中資料夾時進入，否則原始行為
ExplorerArrowRight() {
    ; 只在檔案列表區攔截，其他地方（地址列/搜尋列/重命名）放行原始行為
    if (!ExplorerFocusInFileList())
        return Send("{Right}")
    ; 如果選中的是資料夾，進入
    if (IsSelectedItemFolder())
        return Send("{Enter}")
    ; 否則原始行為
    Send("{Right}")
}

; Explorer 方向鍵 ← ：上一層資料夾，否則原始行為
ExplorerArrowLeft() {
    ; 只在檔案列表區攔截，其他地方放行原始行為
    if (!ExplorerFocusInFileList())
        return Send("{Left}")
    ; 上一層（Alt+Up）
    Send("!{Up}")
}

; Ctrl+P：複製選中項目的完整路徑，沒有選中則複製當前資料夾路徑
ExplorerCopyPath() {
    try {
        for window in ComObject("Shell.Application").Windows {
            if (window.HWND = WinGetID("A")) {
                ; 有選中項目 → 複製選中項目路徑
                if (window.Document.SelectedItems.Count > 0) {
                    A_Clipboard := window.Document.SelectedItems.Item(0).Path
                } else {
                    ; 沒有選中 → 複製當前資料夾路徑
                    A_Clipboard := window.Document.Folder.Self.Path
                }
                ToolTip("已複製: " . A_Clipboard)
                SetTimer(() => ToolTip(), -1500)
                return
            }
        }
    }
}

; 判斷 Explorer 焦點是否在檔案列表區（反向邏輯：只有在列表區才攔截）
ExplorerFocusInFileList() {
    try {
        focused := ControlGetFocus("A")
        focusedClass := ControlGetClassNN(focused)
        ; 檔案列表的控件 class 包含這些
        if (InStr(focusedClass, "DirectUIHWND")
            || InStr(focusedClass, "SysListView32")
            || InStr(focusedClass, "SysTreeView32")
            || InStr(focusedClass, "ShellTabWindowClass"))
            return true
    }
    return false
}

; 判斷選中的項目是否為資料夾
IsSelectedItemFolder() {
    try {
        for window in ComObject("Shell.Application").Windows {
            if (window.Document.Folder.Self.Path == GetExplorerPath()) {
                for item in window.Document.SelectedItems {
                    return item.IsFolder
                }
            }
        }
    }
    return false
}


; ============================================================================
; Section 11: 函式 - 剪貼板/文字處理
; ============================================================================

; 檢查 115 app 是否為活動窗口
is115Active() {
    return WinActive("ahk_exe 115chrome.exe")
}

; 處理剪貼板文本 (replaceDash=true 時將 "-" 替換為空格)
ProcessClipboardText(replaceDash := true) {
    text := A_Clipboard
    processedText := ""
    startFound := false
    lastNumIndex := 0

    Loop Parse, text
    {
        if (!startFound && RegExMatch(A_LoopField, "[A-Za-z]"))
            startFound := true

        if (startFound)
        {
            if (replaceDash && A_LoopField == "-")
                processedText .= " "
            else
                processedText .= A_LoopField

            if (RegExMatch(A_LoopField, "\d"))
                lastNumIndex := A_Index
        }
    }

    return Trim(SubStr(processedText, 1, lastNumIndex))
}


; ============================================================================
; Section 12: 函式 - PotPlayer
; ============================================================================

GetNextScreen() {
    global CURRENT_SCREEN
    screens := MonitorGetCount()
    CURRENT_SCREEN := Mod(CURRENT_SCREEN, screens) + 1
    return CURRENT_SCREEN
}

GetCurrentScreenAndPosition(&currentScreen, &currentPosition) {
    potplayerExe := ""
    for exe in POTPLAYER_EXES {
        if WinExist("ahk_exe " . exe) {
            potplayerExe := exe
            break
        }
    }

    if (potplayerExe != "") {
        WinGetPos(&x, &y, &width, &height, "ahk_exe " . potplayerExe)
        centerX := x + width / 2
        centerY := y + height / 2

        screens := MonitorGetCount()
        Loop screens {
            MonitorGet(A_Index, &left, &top, &right, &bottom)
            if (centerX >= left && centerX < right && centerY >= top && centerY < bottom) {
                currentScreen := A_Index
                break
            }
        }

        screenWidth := right - left
        screenHeight := bottom - top
        halfWidth := screenWidth / 2
        halfHeight := screenHeight / 2

        relativeX := centerX - left
        relativeY := centerY - top

        if (relativeX < halfWidth) {
            if (relativeY < halfHeight)
                currentPosition := "topleft"
            else
                currentPosition := "bottomleft"
        } else {
            if (relativeY < halfHeight)
                currentPosition := "topright"
            else
                currentPosition := "bottomright"
        }
    }
}

MovePotPlayerToPosition(position) {
    global LAST_POSITION, CURRENT_SCREEN
    potplayerExe := ""
    for exe in POTPLAYER_EXES {
        if WinExist("ahk_exe " . exe) {
            potplayerExe := exe
            break
        }
    }

    if (potplayerExe != "") {
        try {
            currentScreen := 0
            currentPosition := ""
            GetCurrentScreenAndPosition(&currentScreen, &currentPosition)

            left := 0
            top := 0
            right := 0
            bottom := 0
            MonitorGet(currentScreen, &left, &top, &right, &bottom)

            width := right - left
            height := bottom - top

            quarterWidth := Floor(width / 2)
            quarterHeight := Floor(height / 2)

            x := left
            y := top
            switch position {
                case "topleft":
                    ; x 和 y 已经设置为左上角
                case "topright":
                    x := left + width - quarterWidth
                case "bottomleft":
                    y := top + height - quarterHeight
                case "bottomright":
                    x := left + width - quarterWidth
                    y := top + height - quarterHeight
            }

            WinGetPos(&currentX, &currentY, &currentWidth, &currentHeight, "ahk_exe " . potplayerExe)

            isInPlannedPosition := (currentX = x) and (currentY = y) and
                                   (currentWidth = quarterWidth) and (currentHeight = quarterHeight)

            if (isInPlannedPosition) {
                CURRENT_SCREEN := GetNextScreen()
                MonitorGet(CURRENT_SCREEN, &left, &top, &right, &bottom)
                width := right - left
                height := bottom - top
                quarterWidth := Floor(width / 2)
                quarterHeight := Floor(height / 2)

                switch position {
                    case "topleft":
                        x := left
                        y := top
                    case "topright":
                        x := left + width - quarterWidth
                        y := top
                    case "bottomleft":
                        x := left
                        y := top + height - quarterHeight
                    case "bottomright":
                        x := left + width - quarterWidth
                        y := top + height - quarterHeight
                }
            } else {
                CURRENT_SCREEN := currentScreen
            }

            WinMove(x, y, quarterWidth, quarterHeight, "ahk_exe " . potplayerExe)
            WinActivate("ahk_exe " . potplayerExe)

            LAST_POSITION := position
        } catch as err {
            MsgBox("移动 PotPlayer 窗口时发生错误: " . err.Message)
        }
    } else {
        MsgBox("未找到 PotPlayer 窗口。请确保 PotPlayer 正在运行。")
    }
}

DistributePotPlayerWindows() {
    potplayerWindows := []

    for exe in POTPLAYER_EXES {
        winIds := WinGetList("ahk_exe " . exe)
        for winId in winIds {
            potplayerWindows.Push(winId)
        }
    }

    windowCount := potplayerWindows.Length
    if (windowCount == 0) {
        MsgBox("没有找到打开的 PotPlayer 窗口。")
        return
    }

    screenCount := MonitorGetCount()
    DistributeWindowsToScreens(potplayerWindows, screenCount)
}

DistributeWindowsToScreens(windows, screenCount) {
    windowIndex := 1
    Loop screenCount {
        screenIndex := A_Index
        if (windowIndex > windows.Length) {
            break
        }

        MonitorGet(screenIndex, &left, &top, &right, &bottom)
        width := right - left
        height := bottom - top

        windowsPerScreen := Min(4, windows.Length - windowIndex + 1)

        if (windowsPerScreen == 1) {
            WinMove(left, top, width, height, "ahk_id " . windows[windowIndex])
            windowIndex++
        } else {
            positions := ["topleft", "topright", "bottomleft", "bottomright"]
            Loop windowsPerScreen {
                if (windowIndex > windows.Length) {
                    break
                }

                x := left
                y := top
                quarterWidth := Floor(width / 2)
                quarterHeight := Floor(height / 2)

                switch positions[A_Index] {
                    case "topleft":
                        ; x 和 y 已经设置为左上角
                    case "topright":
                        x := left + width - quarterWidth
                    case "bottomleft":
                        y := top + height - quarterHeight
                    case "bottomright":
                        x := left + width - quarterWidth
                        y := top + height - quarterHeight
                }

                WinMove(x, y, quarterWidth, quarterHeight, "ahk_id " . windows[windowIndex])
                windowIndex++
            }
        }
    }
}


; ============================================================================
; Section 13: 函式 - Diablo 4
; ============================================================================

; 檢查是否為 Diablo 4 遊戲視窗
IsDiablo4Active() {
    return WinActive("ahk_exe Diablo IV.exe") || WinActive("ahk_class Diablo IV Main Window Class")
}

; 處理熱鍵的函數
HandleHotkey(key) {
    global autoClickActive, currentMode

    if (key = "s" && currentMode = "full" || key = "b" && currentMode = "mouse") {
        autoClickActive := false
        SetTimer AutoClickLoop, 0

        screenWidth := A_ScreenWidth
        screenHeight := A_ScreenHeight

        tooltipX := screenWidth // 2 - 100
        tooltipY := screenHeight // 2 + 1500

        ToolTip("0000000000000000", tooltipX, tooltipY)
        SetTimer () => ToolTip(), -2000
        currentMode := ""
        return
    }

    if (key = "s") {
        currentMode := "full"
    } else if (key = "b") {
        currentMode := "mouse"
    }

    if (!autoClickActive) {
        autoClickActive := true
        SetTimer AutoClickLoop, 25
    }

    if (currentMode = "full") {
        ToolTip("1111111111111111", A_ScreenWidth // 2 - 100, A_ScreenHeight // 2 + 1500)
    } else if (currentMode = "mouse") {
        ToolTip("K + J 連按", A_ScreenWidth // 2 - 100, A_ScreenHeight // 2 + 1500)
    }
    SetTimer () => ToolTip(), -2000
}

; 自動連按循環函數
AutoClickLoop() {
    static nextKTime := 0
    static nextJTime := 0
    static nextQTime := 0
    static nextWTime := 0
    static nextETime := 0
    static nextRTime := 0
    static nextYTime := 0
    static nextClickTime := 0
    static nextATime := 0
    static initialized := false

    currentTime := A_TickCount

    if (!IsDiablo4Active()) {
        global autoClickActive := false
        SetTimer AutoClickLoop, 0
        ToolTip("自動連按已停止 - Diablo 4 不再是活動視窗", 100, 100)
        SetTimer () => ToolTip(), -2000
        initialized := false
        return
    }

    if (!initialized) {
        nextKTime := currentTime + 0
        nextJTime := currentTime + 50
        nextQTime := currentTime + 100
        nextWTime := currentTime + 150
        nextETime := currentTime + 200
        nextRTime := currentTime + 250
        nextYTime := currentTime + 300
        nextClickTime := currentTime + 350
        nextATime := currentTime + 400
        initialized := true
    }

    global currentMode

    if (currentTime >= nextKTime) {
        Send "k"
        nextKTime := currentTime + 150
    }

    if (currentTime >= nextJTime) {
        Send "j"
        nextJTime := currentTime + 150
    }

    if (currentMode = "full") {
        if (currentTime >= nextQTime) {
            Send "q"
            nextQTime := currentTime + 400
        }

        if (currentTime >= nextWTime) {
            Send "w"
            nextWTime := currentTime + 50
        }

        if (currentTime >= nextETime) {
            Send "e"
            nextETime := currentTime + 100
        }

        if (currentTime >= nextRTime) {
            Send "r"
            nextRTime := currentTime + 100
        }

        if (currentTime >= nextYTime) {
            Send "y"
            nextYTime := currentTime + 100
        }

        if (currentTime >= nextClickTime) {
            Click
            nextClickTime := currentTime + 100
        }

        if (currentTime >= nextATime) {
            Send "a"
            nextATime := currentTime + 1500
        }
    }
}
