#Requires AutoHotkey v2.0
FileEncoding "UTF-8"
SetWorkingDir A_ScriptDir


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


; 全局變量
global LINE_PATH := "C:\Users\yulia\AppData\Local\LINE\bin\current\LINE.exe"
global LINE_PARAMS := "--multipleWindow --processStart LINE.exe"
global FIREFOX_PATH := "C:\Program Files\Mozilla Firefox\firefox.exe"
global POTPLAYER_EXES := ["PotPlayer64.exe", "PotPlayer.exe", "PotPlayerMini64.exe", "PotPlayerMini.exe"]
global CURRENT_SCREEN := 2
global LAST_POSITION := ""


; sleep-stable.ahk - AutoHotkey v2
; Alt+Shift+S 進入睡眠模式


#HotIf WinActive("ahk_exe chrome.exe") || WinActive("ahk_exe msedge.exe")
^r::{
    ToolTip("已轉換為 Ctrl+Shift+R")
    SetTimer () => ToolTip(), -1000
    Send "^+r"
}
#HotIf

#Requires AutoHotkey v2.0
#SingleInstance Force

; Alt + J: 將 clipboard 中的 Linux 路徑轉換為 Windows 路徑，並在 Total Commander 中 cd 到該路徑
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
    
    ; 路徑對應: /home/allenl → Z:
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
    
    ; 判斷最後是否為檔案（包含副檔名）
    lastPart := ""
    lastSlashPos := InStr(winPath, "\",, -1)
    if (lastSlashPos > 0)
        lastPart := SubStr(winPath, lastSlashPos + 1)
    
    if (lastPart != "" && InStr(lastPart, ".")) {
        winPath := SubStr(winPath, 1, lastSlashPos - 1)
    }
    
    ; 移除尾端反斜線（但保留 Z:\）
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

; Alt + Shift + J: 將 clipboard 中的 Linux 路徑轉換為 Windows 路徑，用關聯程式開啟檔案
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
    
    ; 檢查是否為檔案（包含副檔名）
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
; !+s::  ; Alt+Shift+S
; {
;     Sleep(500)

;     ; 等待按鍵釋放*

;     SendMessage(0x112, 0xF170, 2,, "Program Manager")

; }
; ============================================================
; 4螢幕模式 - 全開（個人電腦）
; ============================================================
!+5:: {
    mmt := 'D:\Tools\multimonitortool-x64\MultiMonitorTool.exe'
    cmm := 'D:\Tools\controlmymonitor\ControlMyMonitor.exe'
    
    ; 步驟1: 啟用所有螢幕
    ToolTip("正在啟用所有螢幕...")
    RunWait(mmt ' /enable "HNMR400156" "HNMR600125"')
    Sleep(1500)
    
    ; 步驟2: 載入4螢幕配置
    ToolTip("正在載入4螢幕配置...")
    RunWait(mmt ' /LoadConfig "D:\Tools\multimonitortool-x64\4monitors.cfg"')
    Sleep(1500)
    
    ; 步驟3: 切換輸入源
    ToolTip("正在切換上方螢幕到個人電腦...")
    RunWait(cmm ' /SetValue "HNMR400156" 60 6')
    Sleep(500)
    
    ToolTip("正在切換下方螢幕到個人電腦...")
    RunWait(cmm ' /SetValue "HNMR600125" 60 15')
    
    ToolTip("切換完成! (4螢幕)")
    Sleep(1000)
    ToolTip()
}

!+7:: {
    mmt := 'D:\Tools\multimonitortool-x64\MultiMonitorTool.exe'
    cmm := 'D:\Tools\controlmymonitor\ControlMyMonitor.exe'
    
    ; 步驟1: 啟用所有螢幕
    ToolTip("正在啟用所有螢幕...")
    RunWait(mmt ' /enable "HNMR400156" "HNMR600125"')
    Sleep(3000)  ; 3秒
    
    ; 步驟2: 載入4螢幕配置
    ToolTip("正在載入4螢幕配置...")
    RunWait(mmt ' /LoadConfig "D:\Tools\multimonitortool-x64\4monitors.cfg"')
    Sleep(7000)  ; 3秒
    
    ; 步驟3: 切換上方螢幕到公司電腦
    ToolTip("正在切換上方螢幕到公司電腦...")
    RunWait(cmm ' /SetValue "HNMR600156" 60 15')
    Sleep(1500)
    
    ; 步驟4: 切換下方螢幕到個人電腦
    ToolTip("正在切換下方螢幕到個人電腦...")
    RunWait(cmm ' /SetValue "HNMR400125" 60 15')
    Sleep(1500)
    
    ; 步驟5: 停用上方螢幕
    ToolTip("正在停用上方 Samsung...")
    RunWait(mmt ' /disable "HNMR400156"')
    Sleep(1000)
    
    ; 步驟6: 載入3螢幕配置
    ToolTip("正在載入3螢幕配置...")
    RunWait(mmt ' /LoadConfig "D:\Tools\multimonitortool-x64\3monitors.cfg"')
    
    ToolTip("切換完成! (3螢幕)")
    Sleep(1000)
    ToolTip()
}
!+6:: {
    mmt := 'D:\Tools\multimonitortool-x64\MultiMonitorTool.exe'
    cmm := 'D:\Tools\controlmymonitor\ControlMyMonitor.exe'
    
    ; 步驟1: 啟用所有螢幕
    ToolTip("正在啟用所有螢幕...")
    RunWait(mmt ' /enable "HNMR400156" "HNMR600125"')
    Sleep(1500)
    
    ; 步驟2: 切換輸入源
    ToolTip("正在切換上方螢幕到公司電腦...")
    RunWait(cmm ' /SetValue "HNMR400156" 60 15')
    Sleep(500)
    
    ToolTip("正在切換下方螢幕到公司電腦...")
    RunWait(cmm ' /SetValue "HNMR600125" 60 6')
    Sleep(1000)
    
    ; 步驟3: 停用兩個 Samsung
    ToolTip("正在停用 Samsung 螢幕...")
    RunWait(mmt ' /disable "HNMR400156" "HNMR600125"')
    
    ToolTip("切換完成! (2螢幕)")
    Sleep(1000)
    ToolTip()
}
; !+5:: {
;     ; 步驟1: 先啟用所有螢幕
;     ToolTip("正在啟用所有螢幕...")
;     Run('D:\Tools\multimonitortool-x64\MultiMonitorTool.exe /enable 3 4')
;     Sleep(1000)

;     ; 步驟2: 載入正確的螢幕配置
;     ToolTip("正在設定螢幕位置...")
;     Run('D:\Tools\multimonitortool-x64\MultiMonitorTool.exe /LoadConfig "D:\Tools\multimonitortool-x64\4monitors.cfg"')
;     Sleep(3000)

;     ; 步驟3: 切換輸入源
;     ToolTip("正在切換螢幕4(上方)輸入源到個人電腦...")
;     RunWait('D:\Tools\controlmymonitor\ControlMyMonitor.exe /SetValue "HNMR600125" 60 15')
;     Sleep(2000)

;     ToolTip("正在切換螢幕1(下方)輸入源到個人電腦...")
;     RunWait('D:\Tools\controlmymonitor\ControlMyMonitor.exe /SetValue "HNMR400156" 60 6')
;     Sleep(2000)

;     ; 完成
;     ToolTip("切換完成! (4個螢幕模式)")
;     Sleep(2000)
;     ToolTip()
; }

; !+6:: {
;     ; 步驟1: 先啟用所有螢幕
;     ToolTip("正在啟用所有螢幕...")
;     Run('D:\Tools\multimonitortool-x64\MultiMonitorTool.exe /enable 3 4')
;     Sleep(1000)
    
;     ; 步驟2: 載入3螢幕配置（作為中間狀態）
;     ToolTip("正在設定螢幕位置...")
;     RunWait('D:\Tools\multimonitortool-x64\MultiMonitorTool.exe /LoadConfig "D:\Tools\multimonitortool-x64\3monitors.cfg"')
;     Sleep(2000)
    
;     ; 步驟3: 切換輸入源到公司電腦
;     ToolTip("正在切換螢幕4(上方)輸入源到公司電腦...")
;     RunWait('D:\Tools\controlmymonitor\ControlMyMonitor.exe /SetValue "HNMR600125" 60 6')
;     Sleep(2000)
    
;     ToolTip("正在切換螢幕1(下方)輸入源到公司電腦...")
;     RunWait('D:\Tools\controlmymonitor\ControlMyMonitor.exe /SetValue "HNMR400156" 60 15')
;     Sleep(2000)
    
;     ; 步驟4: 停用 Samsung 螢幕
;     ; 注意：在2螢幕模式下，Windows會重新分配DISPLAY編號
;     ; 原本的 DISPLAY1(Samsung下) 和 DISPLAY4(Samsung上) 會變成 DISPLAY3 和 DISPLAY4
;     ; 所以這裡要用 DISPLAY3 和 DISPLAY4 而不是 1 和 4
;     ; 可以查看 D:\Tools\multimonitortool-x64\MultiMonitorTool.exe /SaveConfig "D:\Tools\multimonitortool-x64\2monitors.cfg"產生的2monitors.cfg來確認是哪個DISPLAY編號是存在的
;     ToolTip("正在停用 Samsung 螢幕...")
;     RunWait('D:\Tools\multimonitortool-x64\MultiMonitorTool.exe /disable \\.\DISPLAY3')
;     Sleep(2000)
;     RunWait('D:\Tools\multimonitortool-x64\MultiMonitorTool.exe /disable \\.\DISPLAY4')
;     Sleep(2000)
    
;     ; 完成
;     ToolTip("切換完成! (2螢幕模式 - 公司電腦)")
;     Sleep(1000)
;     ToolTip()
; }
; ; 切換螢幕3到個人電腦,保留3個螢幕
; !+7:: {
;         ; 步驟1: 先啟用所有螢幕
;     ToolTip("正在啟用所有螢幕...")
;     Run('D:\Tools\multimonitortool-x64\MultiMonitorTool.exe /enable 3 4')
;     Sleep(1000)

;     ; 步驟2: 載入正確的螢幕配置
;     ToolTip("正在設定螢幕位置...")
;     Run('D:\Tools\multimonitortool-x64\MultiMonitorTool.exe /LoadConfig "D:\Tools\multimonitortool-x64\4monitors.cfg"')
;     Sleep(3000)

;     ; 步驟3: 切換輸入源
;     ToolTip("正在切換螢幕4(上方)輸入源到個人電腦...")
;     RunWait('D:\Tools\controlmymonitor\ControlMyMonitor.exe /SetValue "HNMR600125" 60 15')
;     Sleep(2000)

;     ToolTip("正在切換螢幕1(下方)輸入源到個人電腦...")
;     RunWait('D:\Tools\controlmymonitor\ControlMyMonitor.exe /SetValue "HNMR400156" 60 6')
;     Sleep(2000)

;     ; 完成
;     ToolTip("切換完成! (4個螢幕模式)")
;     Sleep(2000)
;     ToolTip()
;     ToolTip("正在啟用螢幕...")
;     RunWait('D:\Tools\multimonitortool-x64\MultiMonitorTool.exe /enable \\.\DISPLAY1')
;     Sleep(2000)
    
;     ToolTip("正在設定螢幕位置...")
;     RunWait('D:\Tools\multimonitortool-x64\MultiMonitorTool.exe /LoadConfig "D:\Tools\multimonitortool-x64\3monitors.cfg"')
;     Sleep(2000)
    
;     ToolTip("正在切換螢幕到個人電腦...")
;     RunWait('D:\Tools\controlmymonitor\ControlMyMonitor.exe /SetValue "HNMR600125" 60 15')
;     Sleep(1000)
    
;     ToolTip("切換完成! (3螢幕模式)")
;     Sleep(1000)
;     ToolTip()
; }
^!t:: {
    text := WinGetText("ahk_class TTOTAL_CMD")
    MsgBox(text)
}


^!v:: {
    if !DllCall("IsClipboardFormatAvailable", "uint", 2)
        return
    
    hwnd := WinGetID("A")
    winClass := WinGetClass("A")
    
    ; 取得當前目錄
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

GetTCPath(hwnd) {
    text := WinGetText("ahk_id " hwnd)
    if RegExMatch(text, "m)^([a-zA-Z]:\\.+)>", &m)
        return m[1]
    return ""
}

;切換上方螢幕到個人電腦
!+{:: {
    Run('D:\Tools\controlmymonitor\ControlMyMonitor.exe /SetValue "HNMR400156" 60 6')
}
;切換下方螢幕到個人電腦
!+}:: {
    Run('D:\Tools\controlmymonitor\ControlMyMonitor.exe /SetValue "HNMR600125" 60 15')
}

;切換上方螢幕到公司電腦
![:: {
    Run('D:\Tools\controlmymonitor\ControlMyMonitor.exe /SetValue "HNMR400156" 60 15')
}
;切換下方螢幕到公司電腦
!]:: {
    Run('D:\Tools\controlmymonitor\ControlMyMonitor.exe /SetValue "HNMR600125" 60 6')
}

; 在檔案開頭定義
vscode := "C:\Users\yulia\AppData\Local\Programs\Microsoft VS Code\Code.exe"
tunnel := "allenl-2404"

; !+j:: {  ; Ctrl+Alt+T
;     Run(vscode . " --remote tunnel+" . tunnel)
; }

; 在檔案開頭定義
vscode := "C:\Users\yulia\AppData\Local\Programs\Microsoft VS Code\Code.exe"
remote_ssh := "192.168.31.5"  ; 這是你在 ~/.ssh/config 設定的 Host 名稱

; SSH 遠端連線快捷鍵
!+t:: {  ; Ctrl+Alt+J
    Run(vscode . " --remote ssh-remote+" . remote_ssh . " .")
}

; 切換到只顯示 1,2 (停用 3,4)
!+2:: {
    Run('D:\Tools\multimonitortool-x64\MultiMonitorTool.exe /disable 3 4')
}

; 切換到 1,2,3,4 全開,恢復正確位置(4在上,3在下)
!+4:: {
    ; 先啟用所有螢幕
    Run('D:\Tools\multimonitortool-x64\MultiMonitorTool.exe /enable 3 4')
    Sleep(1000)
    
    ; 設定正確位置 - 螢幕4在上(-1021),螢幕3在下(1155)
    Run('D:\Tools\multimonitortool-x64\MultiMonitorTool.exe /SetMonitors "Name=\\.\DISPLAY4 BitsPerPixel=32 Width=3840 Height=2160 DisplayFlags=0 DisplayFrequency=60 DisplayOrientation=0 PositionX=-3840 PositionY=-1021" "Name=\\.\DISPLAY3 BitsPerPixel=32 Width=3840 Height=2160 DisplayFlags=0 DisplayFrequency=60 DisplayOrientation=0 PositionX=-3840 PositionY=1155" "Name=\\.\DISPLAY2 Primary=1 BitsPerPixel=32 Width=3840 Height=2160 DisplayFlags=0 DisplayFrequency=144 DisplayOrientation=0 PositionX=0 PositionY=0" "Name=\\.\DISPLAY1 BitsPerPixel=32 Width=3840 Height=2160 DisplayFlags=0 DisplayFrequency=60 DisplayOrientation=0 PositionX=3840 PositionY=-20"')
}

; 切換到 1,2,3 開啟(螢幕4關閉)
!+3:: {
    Run('D:\Tools\multimonitortool-x64\MultiMonitorTool.exe /LoadConfig "D:\Tools\multimonitortool-x64\monitors_123only.cfg"')
}

; PotPlayer 特定熱鍵
#HotIf WinActive("ahk_exe PotPlayer64.exe") or WinActive("ahk_exe PotPlayer.exe") or WinActive("ahk_exe PotPlayerMini64.exe") or WinActive("ahk_exe PotPlayerMini.exe")
w:: MovePotPlayerToPosition("topleft")
e:: MovePotPlayerToPosition("topright")
s:: MovePotPlayerToPosition("bottomleft")
d:: MovePotPlayerToPosition("bottomright")
r:: DistributePotPlayerWindows()
#HotIf

;系統熱鍵,先透過powertoy remap alt+shit+ 在用akh 模擬alt+shift+
; !+t:: {
;     ActivateOrRun("Todo.exe", "C:\Program Files\WindowsApps\Microsoft.Todos_2.114.7122.0_x64__8wekyb3d8bbwe\Todo.exe")
; }


RunPowerShell(value) {
    cmd := Format('PowerShell.exe -Command "$path = `'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3`'; $v = (Get-ItemProperty -Path $path).Settings; $v[8] = {}; Set-ItemProperty -Path $path -Name Settings -Value $v; Stop-Process -Name explorer -Force"', value)
    Run(cmd,, "Hide")
}


; !o:: {
;     SetWorkingDir "D:\Tools\controlmymonitor"
;     Run('pwsh -File "switch.ps1" -M 3 -V 17')
; }


#h:: RunPowerShell(3)  ; 開啟自動隱藏taksbar
; #l:: ^l
#l:: ^l
^l:: ^l
#+h:: RunPowerShell(2)  ; 關閉自動隱藏tarskbar

!u:: {
    ActivateOrRun("WinSCP.exe", "C:\Program Files (x86)\WinSCP\WinSCP.exe")
 }


!+r:: {
    ActivateOrRun("firefox.exe", FIREFOX_PATH)
}


; !+g:: {
;     ActivateOrRun("onenote.exe", "C:\Users\yulia\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Chrome Apps\Chrome 遠端桌面.lnk")
;     ; ActivateOrRun("onenote.exe", "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\OneNote.lnk")
; }

; !+t:: {
;     ActivateOrRun("ms-teams.exe", "C:\Users\yulia\AppData\Local\Microsoft\WindowsApps\ms-teams.exe")
; }
!x:: {
    ActivateOrRun("ms-teams.exe", "C:\Users\yulia\AppData\Local\Microsoft\WindowsApps\ms-teams.exe")
}

; !+g:: {
;     ; ActivateOrRun("Arc.exe", "C:\Users\yulia\AppData\Local\Microsoft\WindowsApps\Arc.exe")
;     ActivateOrRun("onenote.exe", "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\OneNote.lnk")
; }

; !+d::{
;     ; ActivateOrRun("cursor.exe", "C:\Users\yulia\AppData\Local\Programs\cursor\Cursor.exe")
;     ActivateOrRun("Wireshark.exe", "C:\Program Files\Wireshark\Wireshark.exe")
; }

; ; Alt+t: 啟動/切換 VS Code
; !+T:: {
;     ActivateOrRun("Code.exe", "C:\Users\yulia\AppData\Local\Programs\Microsoft VS Code\Code.exe")
; }
; 熱鍵設置
; Alt+A: 啟動/切換 Microsoft Edge
; !e::
!a:: {
    ActivateOrRun("msedge.exe", "c:\program files (x86)\microsoft\edge\application\msedge.exe")
}

; Alt+z: 啟動/切換 Onenote
!z:: {
    ActivateOrRun("Notion.exe", "C:\Users\yulia\AppData\Local\Programs\Notion\Notion.exe")
}


; Alt+Q: 啟動/切換 Google Chrome
!q:: {
    ActivateOrRun("chrome.exe", "C:\Program Files\Google\Chrome\Application\chrome.exe")
}

; !.:: {
;     ActivateOrRun("WeChat.exe", "C:\Program Files\Tencent\WeChat\WeChat.exe")
; }


; Alt+S: 啟動/切換 Windows Terminal
!s:: {
    ; ActivateOrRun("MobaXterm.exe", "C:\Program Files (x86)\Mobatek\MobaXterm\MobaXterm.exe")
    ActivateOrRun("WindowsTerminal.exe", "C:\Users\yulia\AppData\Local\Microsoft\WindowsApps\wt.exe")
}

!+s:: {
    ; ActivateOrRun("MobaXterm.exe", "C:\Program Files (x86)\Mobatek\MobaXterm\MobaXterm.exe")
    ActivateOrRun("warp.exe", "C:\Users\yulia\AppData\Local\Programs\Warp\warp.exe")
}

; #Requires AutoHotkey v2.0
; ^+1:: {
;     if WinActive("ahk_exe Warp.exe") {
;         SendInput "ssh allenl@192.168.31.5{Enter}"
;     }
; }

!c:: {
    ActivateOrRun("claude.exe", "C:\Users\yulia\AppData\Local\AnthropicClaude\claude.exe")
}

!n:: {
    ActivateOrRun("notepad++.exe", "C:\Program Files\Notepad++\notepad++.exe")
}

; Alt+f: 啟動/切換 Total Commander
!f:: {
    ActivateOrRun("TOTALCMD64.EXE", "C:\Program Files\totalcmd\TOTALCMD64.EXE")
}

; !x:: {
;     ActivateOrRun("slack.exe", "C:\Users\yulia\AppData\Local\slack\slack.exe")
; }

!y:: {
    ActivateOrRun("spotify.exe", "C:\Users\yulia\AppData\Roaming\Spotify\Spotify.exe")
}


!+x:: {
    ActivateOrRun("claude.exe", "C:\Users\yulia\AppData\Local\AnthropicClaude\claude.exe")
}

; !5::
!p:: {
    ActivateOrRun("POWERPNT.EXE", "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\PowerPoint.lnk")
}

!+p:: ActivateOrRun("mspaint.exe", "C:\Windows\System32\mspaint.exe")


!i::
!+e:: {
    ActivateOrRun("Excel.EXE", "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Excel.lnk")
}

; !k:: {
;     ActivateOrRun("daqxqlite.exe", "C:\SysJust\XQLite\daqxqlite.exe")
; }

!+g::
!k:: {
    ; ActivateOrRun("WindowsTerminal.exe", "C:\Users\yulia\AppData\Local\Microsoft\WindowsApps\wt.exe")
    ; ActivateOrRun("MobaXterm.exe", "C:\Program Files (x86)\Mobatek\MobaXterm\MobaXterm.exe")
    ActivateOrRun("Telegram.exe", "c:\Users\yulia\AppData\Roaming\Telegram Desktop\Telegram.exe")
}
!\:: {
    ActivateOrRun("115chrome.exe", "C:\Users\yulia\AppData\Local\115Chrome\Application\115chrome.exe")
}

!;:: {
    ActivateOrRun("FTNN.exe", "C:\Users\yulia\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\富途牛牛.lnk")
}

; !+t:: {
;     ; ActivateOrRun("pycharm64.exe", "C:\Users\yulia\AppData\Local\Programs\PyCharm Community\bin\pycharm64.exe")
;     ActivateOrRun("Code.exe", "C:\Users\yulia\AppData\Local\Programs\Microsoft VS Code\Code.exe")
; }


;  !`::#5 
; !`:: {
;     ; ActivateOrRun("pycharm64.exe", "C:\Users\yulia\AppData\Local\Programs\PyCharm Community\bin\pycharm64.exe")
;     ActivateOrRun("claude.exe", "C:\Users\yulia\AppData\Local\AnthropicClaude\claude.exe")
; }



!+v:: {
    ActivateOrRun("BCompare.exe", "d:\Tools\buy\Beyond_Compare\Beyond_Compare_Pro_Win_v4.4.4\BCompare\BCompare.exe")
}



; !+w::
; !o:: {
;     ActivateOrRun("Wireshark.exe", "C:\Program Files\Wireshark\Wireshark.exe")
; }

!e:: {
    ActivateOrRun("browser.exe", "C:\Users\yulia\AppData\Local\Yandex\YandexBrowser\Application\browser.exe")
}


!+a:: {
    ActivateOrRun("opera.exe", "C:\Users\yulia\AppData\Local\Programs\Opera\opera.exe")
}

!+f:: {
    ActivateOrRun("filezilla.exe", "C:\Program Files\FileZilla FTP Client\filezilla.exe")
}



; Show hotkey list when Ctrl+/ is pressed
!/:: {
    static hotkeyText := "
(
系統快捷鍵:
-------------------
Win+Shift+M: 最大化當前窗口
Win+Q: 關閉當前窗口 (Alt+F4)
Ctrl+Shift+R: 重新載入腳本
Alt+V: Win+V (顯示剪貼板)
Win+C: Ctrl+C (複製)

應用程式快捷鍵:
-------------------
Alt+A: Microsoft Edge
Alt+cAlt+Shift+D: Cursor
Alt+D: VS Code
Alt+r: Firefox
Alt+F: Total Commander
Alt+H/Alt+\: 115瀏覽器
Alt+K: XQLite
Alt+N: Notepad++
Alt+O/Alt+Shift+W: WhatsApp
Alt+P: PowerPoint
Alt+Q: Chrome
Alt+S: MobaXterm
Alt+Shift+S: Windows Terminal
Alt+T: Todo
Alt+U: WinSCP
Alt+X: Teams
Alt+Y: Spotify
Alt+z: Notion
Alt+.: WeChat
Alt+;: FTNN
Alt+Shift+C: Beyond Compare
Alt+Shift+E: Excel
Alt+Shift+G: OneNote
Alt+Shift+R: Opera

115瀏覽器特殊功能:
-------------------
Q: 快速選擇並搜索
Ctrl+Q: 選擇並在新分頁搜索

文件管理器快捷鍵:
-------------------
/: 在Total Commander中打開
左箭頭: 返回上一級目錄
右箭頭: 進入所選目錄
Ctrl+R: 重命名
Shift+Enter: 顯示右鍵菜單
)"

    ; Create GUI
    MyGui := Gui()
    MyGui.SetFont("s10", "Consolas")
    MyGui.Add("Edit", "ReadOnly w800 h600", hotkeyText)
    MyGui.Title := "熱鍵列表"
    
    ; Show GUI
    MyGui.Show()
}


; Alt+4: 執行 Win+2
; !4:: Send "#2"

; Alt+1: 執行 Win+1
; !1:: Send "#1"
; !3:: Send "#3"

; ; Alt+V: 執行 Win+V
; !v:: Send "#v"

#c:: Send "^c"

; ctl+Shift+R: 重新載入腳本
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

                

; Win+Shift+M 最大化当前窗口
#+m:: {
    Send "#" "{Up}"
}


#q:: {
    Send "!" "{F4}"
}

; Alt+M: 暫停/播放 YouTube (或其他媒體)
!m:: {
    Send "{Media_Play_Pause}"
}



; 檢查 115 app 是否為活動窗口
is115Active() {
    return WinActive("ahk_exe 115chrome.exe")
}

; 處理剪貼板文本
ProcessClipboardText() {
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
            if (A_LoopField == "-")
                processedText .= " "
            else
                processedText .= A_LoopField
            
            if (RegExMatch(A_LoopField, "\d"))
                lastNumIndex := A_Index
        }
    }
    
    return Trim(SubStr(processedText, 1, lastNumIndex))
}

; 處理剪貼板文本
ProcessClipboardText2() {
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
            ; if (A_LoopField == "-")
            ;     processedText .= " "
            ; else
            processedText .= A_LoopField
            
            if (RegExMatch(A_LoopField, "\d"))
                lastNumIndex := A_Index
        }
    }
    
    return Trim(SubStr(processedText, 1, lastNumIndex))
}

; 當 115 app 處於活動狀態時的熱鍵
#HotIf is115Active()
q::
{
    ; 三擊選擇當前文字
    Click 3
    Sleep 50  ; 短暫等待以確保選擇完成

    ; 複製選中的文字
    Send "^c"
    Sleep 100  ; 等待以確保複製完成

    ; 處理剪貼板文本
    processedText := ProcessClipboardText()
    A_Clipboard := processedText  ; 將處理後的文本放回剪貼板

    ; 啟動 Listary
    Send "{Ctrl}"
    Sleep 100  ; 等待 Listary 打開
    Send "{Ctrl}"

    ; 貼上處理後的文字
    Sleep 200  ; 給 Listary 更多時間來完全打開
    Send "^v"
    Sleep 100
    ; Send "{Enter}"  ; 注釋掉自動回車，按照您的要求
}
#HotIf  ; 結束條件熱鍵

; 當 115 app 處於活動狀態時的熱鍵
#HotIf is115Active()
^q::
{
    ; 三擊選擇當前文字
    Click 3
    Sleep 50  ; 短暫等待以確保選擇完成
    ; 複製選中的文字
    Send "^c"
    Sleep 100  ; 等待以確保複製完成
    ; 處理剪貼板文本
    processedText := ProcessClipboardText2()
    A_Clipboard := processedText  ; 將處理後的文本放回剪貼板
    
    ; 瀏覽器操作序列
    Sleep 100
    Send "e"  ; 瀏覽器前一個分頁
    Sleep 100
    Send "gg"  ; 瀏覽器滾動到頂部
    Sleep 300
    Send "gi"  ; 瀏覽器跳到輸入框
    Sleep 100
    Send "^a"  ; 選擇all文字
    Sleep 100
    Send "^v"  ; 貼上文字
    Sleep 100
    Send "{Enter}"  ; 執行搜尋
}
#HotIf  ; 結束條件熱鍵

; 函数：获取当前资源管理器路径
GetExplorerPath() {
    for window in ComObject("Shell.Application").Windows {
        if (window.HWND == WinGetID("A")) {
            return window.Document.Folder.Self.Path
        }
    }
    return ""
}

; 使用优化的 #HotIf 表达式
#HotIf WinActive("ahk_class CabinetWClass") or WinActive("ahk_class ExploreWClass")
/::OpenInTotalCommander()
; Left::Send "!{Up}"  ; Left 键映射到 Alt+Up(向上一级目录)
; Right::Send "{Enter}"
^r::Send "{F2}"  ; Ctrl+R 映射到 F2(重命名)
+Enter::Send "{AppsKey}"  ; Shift+Enter 映射到显示上下文菜单
#HotIf

OpenInTotalCommander() {
    explorerHwnd := WinExist("A")  ; 記住當前 Explorer 視窗 ID
    currentPath := GetExplorerPath()
    selectedItem := GetSelectedItem()
    isFolder := IsSelectedItemFolder()
    
    if (currentPath != "") {
        try {
            tcPath := 'C:\Program Files\totalcmd\TOTALCMD64.EXE'
            
            ; 构建命令行参数
            if (selectedItem != "" && isFolder) {
                ; 如果选中的是文件夹,打开该文件夹
                params := '/O /T "' . currentPath . "\" . selectedItem . '"'
            } else {
                ; 否则,打开当前路径
                params := '/O /T "' . currentPath . '"'
            }
            
            ; 检查 Total Commander 是否已经运行
            if (WinExist("ahk_class TTOTAL_CMD")) {
                ; 如果已运行,使用 /O /T 参数来激活现有窗口并应用新的路径
                Run tcPath . " " . params
            } else {
                ; 如果未运行,正常启动 Total Commander
                Run tcPath . " " . params
            }
            
            ; 等待 Total Commander 窗口出现或激活
            WinWait "ahk_class TTOTAL_CMD"
            
            ; 激活 Total Commander 窗口
            WinActivate "ahk_class TTOTAL_CMD"
            
            ; 給 Total Commander 一些時間來加載
            Sleep 500
            
            ; 關閉原本的 Explorer 視窗
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

; 函数:获取当前选中的文件或文件夹名称
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

; 函数:判断选中的项目是否为文件夹
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

; 确保 GetExplorerPath 函数在此处定义
; 如果它在其他地方定义，可以删除这个注释

; 确保 GetExplorerPath 函数在此处定义
; 如果它在其他地方定义，可以删除这个注释

; 函數：啟動或在多個實例間切換應用程序
; ActivateOrRun(processName, exePath, params := "") {
;     LogMessage("嘗試啟動或切換到: " . processName)
;     if (windowSet := WinGetList("ahk_exe " . processName)) {
;         LogMessage("找到 " . windowSet.Length . " 個窗口")
;         try {
;             activeWindow := WinGetID("A")
;         } catch as err {
;             LogMessage("獲取活動窗口時出錯: " . err.Message)
;             activeWindow := 0  
;         }

;         nextWindow := 0
;         found := false  ; 初始化 found 變量

;         if (activeWindow != 0) {
;             for window in windowSet {
;                 if (found) {
;                     nextWindow := window
;                     break
;                 }
;                 if (window == activeWindow) {
;                     found := true
;                 }
;             }
;         } else {
;             if (windowSet.Length > 0) {
;                 nextWindow := windowSet[1]
;             }
;         }

;         ; 如果沒有找到下一個窗口，選擇第一個窗口
;         if (nextWindow == 0 && windowSet.Length > 0) {
;             nextWindow := windowSet[1]
;         }

;         ; 激活下一個窗口
;         if (nextWindow != 0) {
;             WinActivate(nextWindow)
;             LogMessage("激活窗口: " . nextWindow)
;         } else {
;             ; 如果沒有找到窗口，啟動新實例
;             RunProgram(exePath, params)
;         }
;     } else {
;         LogMessage("沒有找到窗口，嘗試啟動新實例")
;         ; 如果沒有找到任何窗口，啟動新實例
;         RunProgram(exePath, params)
;     }
; }

#SingleInstance Force
#Warn
; Ensure coordinate mode is screen
CoordMode("Mouse", "Screen")

; Function to get monitor bounds
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

GetMonitorFromPoint(x, y) {
    bounds := GetMonitorBounds()
    
    ; Check if point is within monitor bounds
    for bound in bounds {
        if (x >= bound.left && x <= bound.right && y >= bound.top && y <= bound.bottom) {
            return bound.number
        }
    }
    
    ; If not found, find closest monitor by comparing distances to center
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

; Function to move mouse to center of specific monitor
MoveToCenterOfMonitor(monitorNumber) {
    MonitorGetWorkArea(monitorNumber, &left, &top, &right, &bottom)
    centerX := left + (right - left) / 2
    centerY := top + (bottom - top) / 2
    MouseMove(centerX, centerY, 2)
}

; ; 追蹤最近使用的視窗
; global recentWindows := Map()

; ; 在兩個最近使用的視窗間切換
; ActivateOrRun(processName, exePath, params := "") {
;     windowSet := WinGetList("ahk_exe " . processName)
    
;     if (windowSet.Length == 0) {
;         Run(exePath . " " . params)
;         return
;     }
    
;     try {
;         activeWindow := WinGetID("A")
;         activeProcessName := WinGetProcessName("A")
;     } catch {
;         activeWindow := 0
;         activeProcessName := ""
;     }
    
;     ; 如果當前已經是目標程式的視窗
;     if (activeProcessName == processName) {
;         ; 只有當有多個視窗時才切換
;         if (windowSet.Length > 1) {
;             if (!recentWindows.Has(processName)) {
;                 recentWindows[processName] := []
;             }
            
;             recent := recentWindows[processName]
            
;             ; 更新最近視窗列表
;             for i, win in recent {
;                 if (win == activeWindow) {
;                     recent.RemoveAt(i)
;                     break
;                 }
;             }
;             recent.InsertAt(1, activeWindow)
;             while (recent.Length > 2) {
;                 recent.Pop()
;             }
            
;             ; 決定下一個視窗
;             nextWindow := 0
;             if (recent.Length >= 2) {
;                 nextWindow := recent[2]
;             } else {
;                 ; 找第一個不同的視窗
;                 for window in windowSet {
;                     if (window != activeWindow) {
;                         nextWindow := window
;                         break
;                     }
;                 }
;             }
            
;             if (nextWindow != 0) {
;                 WinActivate(nextWindow)
;                 HandleMousePosition(nextWindow)
;             }
;         }
;         ; 如果只有1個視窗，不做任何事（已經在該視窗了）
;     } else {
;         ; 當前不是目標程式，激活第一個視窗
;         WinActivate(windowSet[1])
;         HandleMousePosition(windowSet[1])
;     }
; }

; 在所有視窗間循環切換
ActivateOrRun(processName, exePath, params := "") {
    ; 1. 獲取視窗列表 (預設為 Z-Order: 最近使用的在前)
    try {
        idList := WinGetList("ahk_exe " . processName)
    } catch {
        Run(exePath . " " . params)
        return
    }

    ; 2. 過濾掉沒有標題的視窗
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

    ; 3. 判斷當前視窗狀態
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
        ; ============================================================
        ; 情境 A: 從外部 (Edge) 切換進來
        ; ============================================================
        ; 使用 WinGetList 的原始順序 (Z-Order)，第一個就是「最近使用」的視窗
        targetID := realWindows[1]
    } else {
        ; ============================================================
        ; 情境 B: 已經在 VSCode 裡，要輪流切換 (Cycle)
        ; ============================================================
        ; 這裡我們必須「強制排序」，建立一個固定的順序 (例如按 ID 大小)
        ; 這樣才不會受 Z-Order 變動影響，導致永遠只在兩個視窗間跳動
        
        sortedWindows := realWindows.Clone()
        
        ; 簡單的氣泡排序 (Bubble Sort)，按 ID 從小到大排
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

        ; 在「排序後」的列表中找到當前視窗的位置
        currentIndex := 0
        for i, id in sortedWindows {
            if (id == activeWindow) {
                currentIndex := i
                break
            }
        }

        ; 抓下一個 (輪替)
        nextIndex := currentIndex + 1
        if (nextIndex > sortedWindows.Length) {
            nextIndex := 1 ; 到底了，回到第一個
        }
        targetID := sortedWindows[nextIndex]
    }

    ; 4. 執行切換
    if (targetID != 0) {
        WinActivate(targetID)
        try HandleMousePosition(targetID)
    }
}



; 為了避免報錯，如果你沒有把 HandleMousePosition 放在這段代碼裡，
; 記得要確保你的腳本其他地方有定義它。

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

; !+d:: {
;     ActivateOrRun("Code.exe", "C:\Users\yulia\AppData\Local\Programs\Microsoft VS Code\Code.exe")
; }

!d:: {
    ActivateOrRun("Code.exe", "C:\Users\yulia\AppData\Local\Programs\Microsoft VS Code\Code.exe")
}

; 函數：嘗試運行程序並處理錯誤
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

; 函數：記錄消息到文件
LogMessage(message) {
    ; FileAppend FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss") . " - " . message . "`n", "ahk_log.txt"
}

; PotPlayer 相關函數
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
            
            ; 获取当前窗口位置和大小
            WinGetPos(&currentX, &currentY, &currentWidth, &currentHeight, "ahk_exe " . potplayerExe)
            
            ; 检查窗口是否已经在计划位置（完全匹配）
            isInPlannedPosition := (currentX = x) and (currentY = y) and 
                                   (currentWidth = quarterWidth) and (currentHeight = quarterHeight)
            
            if (isInPlannedPosition) {
                ; 如果已经在计划位置，移动到下一个屏幕
                CURRENT_SCREEN := GetNextScreen()
                ; 获取新屏幕的尺寸
                MonitorGet(CURRENT_SCREEN, &left, &top, &right, &bottom)
                width := right - left
                height := bottom - top
                quarterWidth := Floor(width / 2)
                quarterHeight := Floor(height / 2)
                
                ; 计算新屏幕上的位置
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
                ; 如果不在计划位置，移动到当前屏幕的计划位置
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
    
    ; 获取所有打开的 PotPlayer 窗口
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
    
    ; 获取可用屏幕数量
    screenCount := MonitorGetCount()
    
    ; 分配窗口到屏幕
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
        
        ; 计算每个屏幕可以容纳的窗口数量
        windowsPerScreen := Min(4, windows.Length - windowIndex + 1)
        
        if (windowsPerScreen == 1) {
            ; 如果只有一个窗口，将其最大化
            WinMove(left, top, width, height, "ahk_id " . windows[windowIndex])
            windowIndex++
        } else {
            ; 否则，将窗口分配到屏幕的四个角落
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
; 啟動提示
ToolTip("整合腳本已啟動！")
SetTimer () => ToolTip(), -3000
LogMessage("整合腳本已啟動")


; Diablo 4 自動連按功能
; 檢查是否為 Diablo 4 遊戲視窗 (確認執行檔名稱為 Diablo IV.exe)
IsDiablo4Active() {
    return WinActive("ahk_exe Diablo IV.exe") || WinActive("ahk_class Diablo IV Main Window Class")
}

; 全局變量來追蹤自動連按狀態
global autoClickActive := false
global currentMode := ""

; 當 Diablo 4 處於活動狀態時的熱鍵
#HotIf IsDiablo4Active()
s::HandleHotkey("s")
f::HandleHotkey("b")
v::HandleHotkey("b")
#HotIf

; 處理熱鍵的函數
HandleHotkey(key) {
    global autoClickActive, currentMode
    
    ; 如果按下的按鍵與當前模式相同,則取消自動連按
    if (key = "s" && currentMode = "full" || key = "b" && currentMode = "mouse") {
        autoClickActive := false
        SetTimer AutoClickLoop, 0
        
        ; 取得螢幕尺寸
        screenWidth := A_ScreenWidth
        screenHeight := A_ScreenHeight
        
        ; 計算中間位置
        tooltipX := screenWidth // 2 - 100
        tooltipY := screenHeight // 2 + 1500
        
        ToolTip("0000000000000000", tooltipX, tooltipY)
        SetTimer () => ToolTip(), -2000
        currentMode := ""
        return
    }
    
    ; 設定新模式
    if (key = "s") {
        currentMode := "full"
    } else if (key = "b") {
        currentMode := "mouse"
    }
    
    ; 啟動或維持啟動狀態
    if (!autoClickActive) {
        autoClickActive := true
        SetTimer AutoClickLoop, 25  ; 每25ms檢查一次,確保精確度
    }
    
    ; 顯示模式提示
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
    
    ; 檢查是否仍然在 Diablo 4 中
    if (!IsDiablo4Active()) {
        global autoClickActive := false
        SetTimer AutoClickLoop, 0
        ToolTip("自動連按已停止 - Diablo 4 不再是活動視窗", 100, 100)
        SetTimer () => ToolTip(), -2000
        initialized := false
        return
    }
    
    ; 初始化時設定錯開的起始時間,每個間隔 50ms
    if (!initialized) {
        nextKTime := currentTime + 0          ; 0ms - K鍵
        nextJTime := currentTime + 50         ; 50ms - J鍵
        nextQTime := currentTime + 100        ; 100ms - Q
        nextWTime := currentTime + 150        ; 150ms - W
        nextETime := currentTime + 200        ; 200ms - E
        nextRTime := currentTime + 250        ; 250ms - R
        nextYTime := currentTime + 300        ; 300ms - Y
        nextClickTime := currentTime + 350    ; 350ms - 滑鼠左鍵
        nextATime := currentTime + 400        ; 400ms - A
        initialized := true
    }
    
    global currentMode
    
    ; K鍵每150毫秒按一次 (不論何種模式)
    if (currentTime >= nextKTime) {
        Send "k"
        nextKTime := currentTime + 150
    }
    
    ; J鍵每150毫秒按一次 (不論何種模式)
    if (currentTime >= nextJTime) {
        Send "j"
        nextJTime := currentTime + 150
    }
    
    ; 只有在全鍵模式時才按鍵盤按鍵
    if (currentMode = "full") {
        ; Q 鍵每150毫秒按一次
        if (currentTime >= nextQTime) {
            Send "q"
            nextQTime := currentTime + 400
        }
        
        ; W 鍵每100毫秒按一次
        if (currentTime >= nextWTime) {
            Send "w"
            nextWTime := currentTime + 50
        }
        
        ; E 鍵每100毫秒按一次
        if (currentTime >= nextETime) {
            Send "e"
            nextETime := currentTime + 100
        }
        
        ; R 鍵每100毫秒按一次
        if (currentTime >= nextRTime) {
            Send "r"
            nextRTime := currentTime + 100
        }
        
        ; Y 鍵每100毫秒按一次
        if (currentTime >= nextYTime) {
            Send "y"
            nextYTime := currentTime + 100
        }
        
        ; 滑鼠左鍵每100毫秒按一次
        if (currentTime >= nextClickTime) {
            Click
            nextClickTime := currentTime + 100
        }
        
        ; A 鍵每1500毫秒按一次
        if (currentTime >= nextATime) {
            Send "a"
            nextATime := currentTime + 1500
        }
    }
}