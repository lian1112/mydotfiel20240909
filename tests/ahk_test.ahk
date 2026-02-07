#Requires AutoHotkey v2.0

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

; 全局热键用于测试
!/::
{
    if WinActive("ahk_class CabinetWClass") or WinActive("ahk_class ExploreWClass")
        MsgBox("Yes, 这是文件资源管理器。", "Explorer 检测", 64)
    else
        MsgBox("No, 这不是文件资源管理器。", "Explorer 检测", 48)
}