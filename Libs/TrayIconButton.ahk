TrayIcon_Button(sExeName, sButton:="L", bDouble:=False, nIdx:=1)
{
    d := A_DetectHiddenWindows
    DetectHiddenWindows, On
    WM_MOUSEMOVE      = 0x0200
    WM_LBUTTONDOWN    = 0x0201
    WM_LBUTTONUP      = 0x0202
    WM_LBUTTONDBLCLK  = 0x0203
    WM_RBUTTONDOWN    = 0x0204
    WM_RBUTTONUP      = 0x0205
    WM_RBUTTONDBLCLK  = 0x0206
    WM_MBUTTONDOWN    = 0x0207
    WM_MBUTTONUP      = 0x0208
    WM_MBUTTONDBLCLK  = 0x0209
    sButton := "WM_" sButton "BUTTON"
    oIcons  := TrayIcon_GetInfo(sExeName)
    If ( bDouble )
        PostMessage, oIcons[nIdx].msgid, oIcons[nIdx].uid, %sButton%DBLCLK,, % "ahk_id " oIcons[nIdx].hwnd
    Else
    {
        PostMessage, oIcons[nIdx].msgid, oIcons[nIdx].uid, %sButton%DOWN,, % "ahk_id " oIcons[nIdx].hwnd
        PostMessage, oIcons[nIdx].msgid, oIcons[nIdx].uid, %sButton%UP,, % "ahk_id " oIcons[nIdx].hwnd
    }
    DetectHiddenWindows, %d%
    Return
}