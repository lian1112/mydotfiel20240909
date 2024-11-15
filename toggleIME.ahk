#Requires AutoHotkey v2.0
#SingleInstance Force

; 使用者切換鍵
ToggleSogouIME() {
    Send "{Shift}"
    Sleep 100
}

; 監聽視窗啟動事件
OnWindowSwitch(wParam, lParam, msg, hwnd) {
    try {
        ; 獲取進程名稱
        processName := WinGetProcessName("A")
        
        ; 根據不同的應用程式設定輸入法
        switch processName {
            ; 設定為英文的應用程式
            case "chrome.exe", "Code.exe", "cmd.exe", "powershell.exe", "MobaXterm.exe", "msedge.exe":
                ToggleSogouIME()
            
            ; 設定為中文的應用程式    
            case "notepad.exe", "Line.exe":
                ToggleSogouIME()
        }
    } catch Error as e {
        ; 錯誤處理
        return
    }
}

; 監聽視窗切換 - 修正回調函數格式
OnMessage(0x0006, OnWindowSwitch)  ; WM_ACTIVATE message

; 快捷鍵手動切換
!8::ToggleSogouIME()    ; Alt + 1 切換輸入法