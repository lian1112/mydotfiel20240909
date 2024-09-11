#Requires AutoHotkey v2.0
FileEncoding "UTF-8"
SetWorkingDir A_ScriptDir


::/ggg::yulian.lin2@gmail.com
::/key::Synopsys_AllenLin_Engineering_Test_hub_00130000005No8C
::/tok::ZTQ3ODg1ZTgtYzg5OC00NDJlLThkZjktODk2YjgzMzRmZDM4OmE3MWJmMzhiLWMyMzAtNDg0NS05YTNhLTU3ODQ2MzEyYmUzZg==

; 全局變量
global LINE_PATH := "C:\Users\yulia\AppData\Local\LINE\bin\current\LINE.exe"
global LINE_PARAMS := "--multipleWindow --processStart LINE.exe"
global FIREFOX_PATH := "C:\Program Files\Mozilla Firefox\firefox.exe"
global POTPLAYER_EXES := ["PotPlayer64.exe", "PotPlayer.exe", "PotPlayerMini64.exe", "PotPlayerMini.exe"]
global CURRENT_SCREEN := 2
global LAST_POSITION := ""

; 函數：啟動或在多個實例間切換應用程序
ActivateOrRun(processName, exePath, params := "") {
    LogMessage("嘗試啟動或切換到: " . processName)
    if (windowSet := WinGetList("ahk_exe " . processName)) {
        LogMessage("找到 " . windowSet.Length . " 個窗口")
        try {
            activeWindow := WinGetID("A")
        } catch as err {
            LogMessage("獲取活動窗口時出錯: " . err.Message)
            activeWindow := 0  
        }

        nextWindow := 0
        found := false  ; 初始化 found 變量

        if (activeWindow != 0) {
            for window in windowSet {
                if (found) {
                    nextWindow := window
                    break
                }
                if (window == activeWindow) {
                    found := true
                }
            }
        } else {
            if (windowSet.Length > 0) {
                nextWindow := windowSet[1]
            }
        }

        ; 如果沒有找到下一個窗口，選擇第一個窗口
        if (nextWindow == 0 && windowSet.Length > 0) {
            nextWindow := windowSet[1]
        }

        ; 激活下一個窗口
        if (nextWindow != 0) {
            WinActivate(nextWindow)
            LogMessage("激活窗口: " . nextWindow)
        } else {
            ; 如果沒有找到窗口，啟動新實例
            RunProgram(exePath, params)
        }
    } else {
        LogMessage("沒有找到窗口，嘗試啟動新實例")
        ; 如果沒有找到任何窗口，啟動新實例
        RunProgram(exePath, params)
    }
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
;     ActivateOrRun("ms-teams.exe", "C:\Users\yulia\AppData\Local\Microsoft\WindowsApps\ms-teams.exe")
; }

; !+g:: {
;     ActivateOrRun("ms-teams.exe", "C:\Users\yulia\AppData\Local\Microsoft\WindowsApps\ms-teams.exe")
; }

; !+r:: {
;     ActivateOrRun("ms-teams.exe", "C:\Users\yulia\AppData\Local\Microsoft\WindowsApps\ms-teams.exe")
; }

; !+l:: {
;     ActivateOrRun("ms-teams.exe", "C:\Users\yulia\AppData\Local\Microsoft\WindowsApps\ms-teams.exe")
; }

!2:: {
    ActivateOrRun("cursor.exe", "C:\Users\yulia\AppData\Local\Programs\cursor\Cursor.exe")
}

; Alt+2: 啟動/切換 VS Code
!+T:: {
    ActivateOrRun("Code.exe", "C:\Users\yulia\AppData\Local\Programs\Microsoft VS Code\Code.exe")
}
; 熱鍵設置
; Alt+A: 啟動/切換 Microsoft Edge
!a:: {
    ActivateOrRun("msedge.exe", "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe")
}

; Alt+z: 啟動/切換 Onenote
!z:: {
    ActivateOrRun("onenote.exe", "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\OneNote.lnk")
}

; Alt+Q: 啟動/切換 Google Chrome
!q:: {
    ActivateOrRun("chrome.exe", "C:\Program Files\Google\Chrome\Application\chrome.exe")
}

; Alt+S: 啟動/切換 Windows Terminal
; !s:: {
;     ActivateOrRun("WindowsTerminal.exe", "C:\Program Files\WindowsApps\Microsoft.WindowsTerminal_1.20.11781.0_x64__8wekyb3d8bbwe\wt.exe")
; }
!s:: {
    ActivateOrRun("MobaXterm.exe", "C:\Program Files (x86)\Mobatek\MobaXterm\MobaXterm.exe")
}


; Alt+f: 啟動/切換 Total Commander
!f:: {
    ActivateOrRun("TOTALCMD64.EXE", "C:\Program Files\totalcmd\TOTALCMD64.EXE")
}

!x:: {
    ActivateOrRun("slack.exe", "C:\Users\yulia\AppData\Local\slack\slack.exe")
}

!k:: {
    ActivateOrRun("spotify.exe", "C:\Users\yulia\AppData\Roaming\Spotify\Spotify.exe")
}




!p:: {
    ActivateOrRun("POWERPNT.EXE", "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\PowerPoint.lnk")
}

; Alt+3: 啟動/切換 xq
!3:: {
    ActivateOrRun("daqxqlite.exe", "C:\Users\yulia\OneDrive\Desktop\XQ全球贏家(個人版).lnk")
}



!\:: {
    ActivateOrRun("115chrome.exe", "C:\Users\yulia\AppData\Local\115Chrome\Application\115chrome.exe")
}

!;:: {
    ActivateOrRun("FTNN.exe", "C:\Program Files (x86)\FTNN\FTNN.exe")
}

!d:: {
    ActivateOrRun("pycharm64.exe", "C:\Users\yulia\AppData\Local\Programs\PyCharm Community\bin\pycharm64.exe")
}

; !c:: {
;     ; ActivateOrRun("YoudaoDict.exe", "C:\Users\yulia\AppData\Local\youdao\dict\Application\YoudaoDict.exe")
; }



; Alt+W: 啟動/切換 Firefox
!+w:: {
    ActivateOrRun("firefox.exe", FIREFOX_PATH)
}

; Alt+4: 執行 Win+2
!4:: Send "#2"

; Alt+1: 執行 Win+1
!1:: Send "#1"

; Alt+V: 執行 Win+V
!v:: Send "#v"

#c:: Send "^c"

; ctl+Shift+R: 重新載入腳本
^+r:: {
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

; 函数：获取当前资源管理器路径
GetExplorerPath() {
    for window in ComObject("Shell.Application").Windows {
        if (window.HWND == WinGetID("A")) {
            return window.Document.Folder.Self.Path
        }
    }
    return ""
}

; 函数：在Total Commander中打开当前路径
OpenInTotalCommander() {
    currentPath := GetExplorerPath()
    if (currentPath != "") {
        try {
            Run 'C:\Program Files\totalcmd\TOTALCMD64.EXE /O /T "' . currentPath . '"'
            ; MsgBox("Attempting to open Total Commander with path: " . currentPath)
        } catch as e {
            MsgBox("Error running Total Commander: " . e.Message)
        }
    } else {
        MsgBox("Failed to get current path")
    }
}

; 使用优化的 #HotIf 表达式
#HotIf WinActive("ahk_class CabinetWClass") or WinActive("ahk_class ExploreWClass")
^/::OpenInTotalCommander()
#HotIf


; 啟動提示
ToolTip("整合腳本已啟動！")
SetTimer () => ToolTip(), -3000
LogMessage("整合腳本已啟動")