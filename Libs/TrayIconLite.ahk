TrayIcon_GetInfo(sExeName := "explorer.exe") {
  DetectHiddenWindows, % (Setting_A_DetectHiddenWindows := A_DetectHiddenWindows) ? "On" :
  oTrayIcon_GetInfo := {}
  For key, sTray in ["Shell_TrayWnd", "NotifyIconOverflowWindow"] {
    idxTB := TrayIcon_GetTrayBar(sTray)
    WinGet, pidTaskbar, PID, ahk_class %sTray%
    hProc := DllCall("OpenProcess", UInt, 0x38, Int, 0, UInt, pidTaskbar)
    pRB   := DllCall("VirtualAllocEx", Ptr, hProc, Ptr, 0, UPtr, 20, UInt, 0x1000, UInt, 0x4)
    SendMessage, 0x418, 0, 0, ToolbarWindow32%idxTB%, ahk_class %sTray%   ; TB_BUTTONCOUNT
    szBtn := VarSetCapacity(btn, (A_Is64bitOS ? 32 : 20), 0)
    szNfo := VarSetCapacity(nfo, (A_Is64bitOS ? 32 : 24), 0)
    szTip := VarSetCapacity(tip, 128 * 2, 0)
    Loop, %ErrorLevel% {
      SendMessage, 0x417, A_Index - 1, pRB, ToolbarWindow32%idxTB%, ahk_class %sTray%   ; TB_GETBUTTON
      DllCall("ReadProcessMemory", Ptr, hProc, Ptr, pRB, Ptr, &btn, UPtr, szBtn, UPtr, 0)
      iBitmap := NumGet(btn, 0, "Int")
      IDcmd   := NumGet(btn, 4, "Int")
      statyle := NumGet(btn, 8)
      dwData  := NumGet(btn, (A_Is64bitOS ? 16 : 12))
      iString := NumGet(btn, (A_Is64bitOS ? 24 : 16), "Ptr")
      DllCall("ReadProcessMemory", Ptr, hProc, Ptr, dwData, Ptr, &nfo, UPtr, szNfo, UPtr, 0)
      hWnd  := NumGet(nfo, 0, "Ptr")
      uID   := NumGet(nfo, (A_Is64bitOS ? 8 : 4), "UInt")
      msgID := NumGet(nfo, (A_Is64bitOS ? 12 : 8))
      hIcon := NumGet(nfo, (A_Is64bitOS ? 24 : 20), "Ptr")
      WinGet, pID, PID, ahk_id %hWnd%
      WinGet, sProcess, ProcessName, ahk_id %hWnd%
      WinGetClass, sClass, ahk_id %hWnd%
      If !sExeName || (sExeName = sProcess) || (sExeName = pID) {
        DllCall("ReadProcessMemory", Ptr, hProc, Ptr, iString, Ptr, &tip, UPtr, szTip, UPtr, 0)
        Index := (oTrayIcon_GetInfo.MaxIndex()>0 ? oTrayIcon_GetInfo.MaxIndex()+1 : 1)
        oTrayIcon_GetInfo[Index,"idx"] := A_Index - 1, oTrayIcon_GetInfo[Index,"IDcmd"]   := IDcmd
        oTrayIcon_GetInfo[Index,"pID"] := pID, oTrayIcon_GetInfo[Index,"uID"] := uID
        oTrayIcon_GetInfo[Index,"msgID"] := msgID, oTrayIcon_GetInfo[Index,"hIcon"] := hIcon
        oTrayIcon_GetInfo[Index,"hWnd"] := hWnd, oTrayIcon_GetInfo[Index,"Class"] := sClass
        oTrayIcon_GetInfo[Index,"Process"] := sProcess, oTrayIcon_GetInfo[Index,"Tray"] := sTray
        oTrayIcon_GetInfo[Index,"Tooltip"] := StrGet(&tip, "UTF-16")
      }
    }
    DllCall("VirtualFreeEx", Ptr, hProc, Ptr, pRB, UPtr, 0, Uint, 0x8000)
    DllCall("CloseHandle", Ptr, hProc)
  }
  DetectHiddenWindows, %Setting_A_DetectHiddenWindows%
  Return oTrayIcon_GetInfo
}

TrayIcon_GetTrayBar(Tray:="Shell_TrayWnd") {
  DetectHiddenWindows, % (Setting_A_DetectHiddenWindows := A_DetectHiddenWindows) ? "On" :
  WinGet, ControlList, ControlList, ahk_class %Tray%
  RegExMatch(ControlList, "(?<=ToolbarWindow32)\d+(?!.*ToolbarWindow32)", nTB)
  Loop, %nTB% {
    ControlGet, hWnd, hWnd,, ToolbarWindow32%A_Index%, ahk_class %Tray%
    hParent := DllCall( "GetParent", Ptr, hWnd )
    WinGetClass, sClass, ahk_id %hParent%
    If !(sClass = "SysPager" or sClass = "NotifyIconOverflowWindow" )
      Continue
    idxTB := A_Index
    Break
  }
  DetectHiddenWindows, %Setting_A_DetectHiddenWindows%
  Return  idxTB
}