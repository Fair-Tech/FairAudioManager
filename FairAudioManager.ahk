;{ ABOUT SECTION
;; Fair Audio Manager (by FairTech - Nicholas Fair)
;; https://github.com/Fair-Tech

;@Ahk2Exe-SetCompanyName FairTech US
;@Ahk2Exe-SetCopyright FairTech US 2022
;@Ahk2Exe-SetDescription Fair Audio Manager
;@Ahk2Exe-SetName FairAudioManager
;@Ahk2Exe-SetVersion 0.2

;@Ahk2Exe-AddResource FairAudioManager.ico, 160
;@Ahk2Exe-AddResource FairAudioManager.ico, 206
;@Ahk2Exe-AddResource FairAudioManager.ico, 207
;@Ahk2Exe-AddResource FairAudioManager.ico, 208
;@Ahk2Exe-SetMainIcon FairAudioManager.ico

; Websites used to generate the Icons in Base64
; Base64 to ICO https://base64.guru/converter/decode/image/ico
; ICO to Base64 https://base64.guru/converter/encode/image/ico


;;---------------TO-DO----------------
; NEW - Finish Replacing OLD About Gui with New Custom Settings Window
;3- Replace No Audio Icon with Default Windows Sound Icons after a few seconds of no audio (HOW?)
;6- MAYBE hide default windows sound tray while script is active, and show when exited
;7- ???
;8- Profit?!
;}

;{Libraries and Credits
#Include ..\Libs\Gdip.ahk                           ;https://www.autohotkey.com/boards/viewtopic.php?t=6517
#Include ..\Libs\VA.ahk                             ;https://www.tinyurl.com/VistaAudioAHK
#Include ..\Libs\TrayIconLite.ahk                   ;Modified TrayIcon Library Part (GetInfo and GetTrayBar)
#Include ..\Libs\TrayIconButton.ahk                 ;Modified TrayIcon Library Part (Button - Click Icon)
#Include ..\Libs\AudioOutputChanger.ahk             ;Flipeador on the AHK Forums!
#Include ..\Libs\TapHoldManager.ahk                 ;https://github.com/evilC/TapHoldManager
#Include ..\Libs\NotifyAnim.ahk


full_command_line := DllCall("GetCommandLine", "str")

if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)"))
{
    try
    {
        if A_IsCompiled
            Run *RunAs "%A_ScriptFullPath%" /restart
        else
            Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
    }
    ExitApp
}


;{ CREDITS
;; Base64PNG to HICON implementation by SKAN - tinyurl.com/PNGtoHICONAHK
;; Windows Color Picker Implementation by rbrtryn - tinyurl.com/ColorPickerAHK
;{ Websites used to generate the Icons in Base64
;   Base64 to ICO https://base64.guru/converter/decode/image/ico
;   ICO to Base64 https://base64.guru/converter/encode/image/ico
;}
;} END CREDITS
;} END LIBRARIES AND CREDITS

;;{Run Variables
#NoEnv                              ; Recommended for performance and compatibility with future AutoHotkey releases.
#InstallKeybdHook                   ; Keyboard Hook Requires by TapHoldManager Library
#SingleInstance, Force              ; Force Close Extra Instances
#MaxHotkeysPerInterval 200
#Persistent
SetBatchLines, -1
DetectHiddenWindows, On
SendMode Input
SetWorkingDir %A_ScriptDir%         ; Ensures a consistent starting directory.
;}

;GoSub NotifAreaInt

;{Initialization


;; Initialize TapHoldManager
thm := new TapHoldManager()

;; Create VolMuteFunc and set hotkey to Volume_Mute
thm.Add("Volume_Mute", Func("VolMuteFunc"))

;; Initialize Tray Listening
last_valid = []
OnMessage(0x404, "AHK_NOTIFYICON")
OnMessage(0x200, "WM_MOUSEMOVE")  ; Int Left Click Drag Menu

;; Clean Exit
OnExit("ExitApplication")


;{ Base 64 Icons
IconColorPallete := "iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAA0klEQVRYhdXWLQ7CQBiE4Sk/jntwCrAoNFgOgEFxBC5CQq9BuAAGzSGwBEQz5ks23b/uTl+1ZtPOk4o2LZ4/JLRZH1OuY5J0O0Oz3b47tLeyD54f7gAUBHgoJcHlTEeADSVhlzM9AZZLwrWc6QqwWIm+5UxfgPlK+C5n4xFgLonQ5ay6QIPrI+p/YPk6AQC2qzcA4LKYRr1AdYHgb4DLbefPF0C4xHgEXMttoRL6Ar7Lbb4SugKxy219EnoCuZbbXBI6AkMtt1mJ+gKlltsoUV3gDx6yPiizmZYIAAAAAElFTkSuQmCC"
IconLogo := "iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAACXBIWXMAAA7EAAAOxAGVKw4bAAALAGlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iQWRvYmUgWE1QIENvcmUgNi4wLWMwMDIgNzkuMTY0NDg4LCAyMDIwLzA3LzEwLTIyOjA2OjUzICAgICAgICAiPiA8cmRmOlJERiB4bWxuczpyZGY9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkvMDIvMjItcmRmLXN5bnRheC1ucyMiPiA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0iIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtbG5zOmRjPSJodHRwOi8vcHVybC5vcmcvZGMvZWxlbWVudHMvMS4xLyIgeG1sbnM6cGhvdG9zaG9wPSJodHRwOi8vbnMuYWRvYmUuY29tL3Bob3Rvc2hvcC8xLjAvIiB4bWxuczp4bXBNTT0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL21tLyIgeG1sbnM6c3RFdnQ9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9zVHlwZS9SZXNvdXJjZUV2ZW50IyIgeG1sbnM6c3RSZWY9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9zVHlwZS9SZXNvdXJjZVJlZiMiIHhtbG5zOnRpZmY9Imh0dHA6Ly9ucy5hZG9iZS5jb20vdGlmZi8xLjAvIiB4bWxuczpleGlmPSJodHRwOi8vbnMuYWRvYmUuY29tL2V4aWYvMS4wLyIgeG1wOkNyZWF0b3JUb29sPSJBZG9iZSBQaG90b3Nob3AgMjIuMCAoV2luZG93cykiIHhtcDpDcmVhdGVEYXRlPSIyMDIyLTA4LTEwVDE2OjAxOjIwLTA0OjAwIiB4bXA6TW9kaWZ5RGF0ZT0iMjAyMi0wOC0xOVQyMTozMzowMy0wNDowMCIgeG1wOk1ldGFkYXRhRGF0ZT0iMjAyMi0wOC0xOVQyMTozMzowMy0wNDowMCIgZGM6Zm9ybWF0PSJpbWFnZS9wbmciIHBob3Rvc2hvcDpDb2xvck1vZGU9IjMiIHBob3Rvc2hvcDpJQ0NQcm9maWxlPSJzUkdCIElFQzYxOTY2LTIuMSIgeG1wTU06SW5zdGFuY2VJRD0ieG1wLmlpZDplY2JhMThlNS1jOGI1LWIyNGMtYjhiMy04YmZhMDFjZDY2NzEiIHhtcE1NOkRvY3VtZW50SUQ9ImFkb2JlOmRvY2lkOnBob3Rvc2hvcDpiODE2MzZmOS0wNWI5LWYxNDUtYmU4OS0zNGRhM2EyMmNlY2MiIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0ieG1wLmRpZDo4N2I5MmU2Ny1lNmU5LWNhNGUtOTgwNy04NTc3MTVkYWQ1MDkiIHRpZmY6T3JpZW50YXRpb249IjEiIHRpZmY6WFJlc29sdXRpb249Ijk2MDAwMC8xMDAwMCIgdGlmZjpZUmVzb2x1dGlvbj0iOTYwMDAwLzEwMDAwIiB0aWZmOlJlc29sdXRpb25Vbml0PSIyIiBleGlmOkNvbG9yU3BhY2U9IjEiIGV4aWY6UGl4ZWxYRGltZW5zaW9uPSI1MTIiIGV4aWY6UGl4ZWxZRGltZW5zaW9uPSI1MTIiPiA8eG1wTU06SGlzdG9yeT4gPHJkZjpTZXE+IDxyZGY6bGkgc3RFdnQ6YWN0aW9uPSJjcmVhdGVkIiBzdEV2dDppbnN0YW5jZUlEPSJ4bXAuaWlkOjg3YjkyZTY3LWU2ZTktY2E0ZS05ODA3LTg1NzcxNWRhZDUwOSIgc3RFdnQ6d2hlbj0iMjAyMi0wOC0xMFQxNjowMToyMC0wNDowMCIgc3RFdnQ6c29mdHdhcmVBZ2VudD0iQWRvYmUgUGhvdG9zaG9wIDIyLjAgKFdpbmRvd3MpIi8+IDxyZGY6bGkgc3RFdnQ6YWN0aW9uPSJjb252ZXJ0ZWQiIHN0RXZ0OnBhcmFtZXRlcnM9ImZyb20gaW1hZ2UvcG5nIHRvIGFwcGxpY2F0aW9uL3ZuZC5hZG9iZS5waG90b3Nob3AiLz4gPHJkZjpsaSBzdEV2dDphY3Rpb249InNhdmVkIiBzdEV2dDppbnN0YW5jZUlEPSJ4bXAuaWlkOjhhNjQ1MzJlLTQ0ZDgtZjM0Ni1iOTY3LWI2ZDIyNDRlN2M0MyIgc3RFdnQ6d2hlbj0iMjAyMi0wOC0xMFQxNzozMDoxMS0wNDowMCIgc3RFdnQ6c29mdHdhcmVBZ2VudD0iQWRvYmUgUGhvdG9zaG9wIDIyLjAgKFdpbmRvd3MpIiBzdEV2dDpjaGFuZ2VkPSIvIi8+IDxyZGY6bGkgc3RFdnQ6YWN0aW9uPSJzYXZlZCIgc3RFdnQ6aW5zdGFuY2VJRD0ieG1wLmlpZDpjZmVkZDRhNy0yMmY5LTk0NGYtODAxYy05OWNlMWI0YzAzZmYiIHN0RXZ0OndoZW49IjIwMjItMDgtMTlUMjE6MzM6MDMtMDQ6MDAiIHN0RXZ0OnNvZnR3YXJlQWdlbnQ9IkFkb2JlIFBob3Rvc2hvcCAyMi4wIChXaW5kb3dzKSIgc3RFdnQ6Y2hhbmdlZD0iLyIvPiA8cmRmOmxpIHN0RXZ0OmFjdGlvbj0iY29udmVydGVkIiBzdEV2dDpwYXJhbWV0ZXJzPSJmcm9tIGFwcGxpY2F0aW9uL3ZuZC5hZG9iZS5waG90b3Nob3AgdG8gaW1hZ2UvcG5nIi8+IDxyZGY6bGkgc3RFdnQ6YWN0aW9uPSJkZXJpdmVkIiBzdEV2dDpwYXJhbWV0ZXJzPSJjb252ZXJ0ZWQgZnJvbSBhcHBsaWNhdGlvbi92bmQuYWRvYmUucGhvdG9zaG9wIHRvIGltYWdlL3BuZyIvPiA8cmRmOmxpIHN0RXZ0OmFjdGlvbj0ic2F2ZWQiIHN0RXZ0Omluc3RhbmNlSUQ9InhtcC5paWQ6ZWNiYTE4ZTUtYzhiNS1iMjRjLWI4YjMtOGJmYTAxY2Q2NjcxIiBzdEV2dDp3aGVuPSIyMDIyLTA4LTE5VDIxOjMzOjAzLTA0OjAwIiBzdEV2dDpzb2Z0d2FyZUFnZW50PSJBZG9iZSBQaG90b3Nob3AgMjIuMCAoV2luZG93cykiIHN0RXZ0OmNoYW5nZWQ9Ii8iLz4gPC9yZGY6U2VxPiA8L3htcE1NOkhpc3Rvcnk+IDx4bXBNTTpEZXJpdmVkRnJvbSBzdFJlZjppbnN0YW5jZUlEPSJ4bXAuaWlkOmNmZWRkNGE3LTIyZjktOTQ0Zi04MDFjLTk5Y2UxYjRjMDNmZiIgc3RSZWY6ZG9jdW1lbnRJRD0iYWRvYmU6ZG9jaWQ6cGhvdG9z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"
IconSettings := "iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAI2SURBVFhHvddLiM1RAMfxvySPjGJjY8pCZhALC7LAVkjKzEKTlLIkSZLEghULKRsjK2RDeZWFzUxNWMyGhDRjIYoojyJvvr9//zude/3O/56bjl99unU6j//9n9e9RYeZg9f4HXEFWbMWbuCGMWTNTriBG35gKrLlONzAoSX4p0yrPl2uwg0a2oJYplef0ZzEV1zCahVUmQ8tML1iN2hIi3QPpkDRlGzFEH5iM2yW4jvCzu5Dr/1jUJbqAfSF3gRlooVq18lthBVz2o+mbIKrmMsHzEUZzdVTuIo5nUWZvXAV6mhNXMRBHMFNfIOrG6MFvQzFYFWQ6gJ0JLdmAe7AtXH0AOtQTsEp/IKrGJp4bZFon6c8xDusR1P6oMXhGsgLzEC7LETrdg49Rg9seuEayTGk5hZcH68wC9HMg2so0RPM5ChcH+9RG70+11A2IjXaGa6Pt6hNN1xDOYDUXIbrYxyNO+KvaGE8gWsojzAZ7aIT7hNcHzKKRWjKBmh+XIOQDp66TELs24c+YxdUv9iOlGtWdJ0egnsTXdAh5drFnEGxLyhIpanSg2hn9OMEtMVc3TqHUd7Nz6qC/+k5Jg42nYKuUk4DaMowXMUc7qJcgGGWo3UxarVew5egLJUW7A207i6Vr4TNOajSQ+zGbCiLoTs/5caUEayConnegXtQ+/OIRpX14zSW03ADhq4jFh31bX+a16XdPyPp5NbsOGvgBg1tQ7bonHeDhlYga+ourJeYicQUxR/rkDieiCGTKQAAAABJRU5ErkJggg=="
IconMixer := "iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAACXBIWXMAAA7EAAAOxAGVKw4bAAAF8WlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iQWRvYmUgWE1QIENvcmUgNi4wLWMwMDIgNzkuMTY0NDg4LCAyMDIwLzA3LzEwLTIyOjA2OjUzICAgICAgICAiPiA8cmRmOlJERiB4bWxuczpyZGY9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkvMDIvMjItcmRmLXN5bnRheC1ucyMiPiA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0iIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtbG5zOmRjPSJodHRwOi8vcHVybC5vcmcvZGMvZWxlbWVudHMvMS4xLyIgeG1sbnM6cGhvdG9zaG9wPSJodHRwOi8vbnMuYWRvYmUuY29tL3Bob3Rvc2hvcC8xLjAvIiB4bWxuczp4bXBNTT0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL21tLyIgeG1sbnM6c3RFdnQ9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9zVHlwZS9SZXNvdXJjZUV2ZW50IyIgeG1wOkNyZWF0b3JUb29sPSJBZG9iZSBQaG90b3Nob3AgMjIuMCAoV2luZG93cykiIHhtcDpDcmVhdGVEYXRlPSIyMDIyLTA4LTIxVDEzOjUxOjM0LTA0OjAwIiB4bXA6TW9kaWZ5RGF0ZT0iMjAyMi0wOC0yMVQxNDo1ODoyMS0wNDowMCIgeG1wOk1ldGFkYXRhRGF0ZT0iMjAyMi0wOC0yMVQxNDo1ODoyMS0wNDowMCIgZGM6Zm9ybWF0PSJpbWFnZS9wbmciIHBob3Rvc2hvcDpDb2xvck1vZGU9IjMiIHBob3Rvc2hvcDpJQ0NQcm9maWxlPSJzUkdCIElFQzYxOTY2LTIuMSIgeG1wTU06SW5zdGFuY2VJRD0ieG1wLmlpZDoxNTMzNmIyMC1mMzBmLTNjNDctODFjOS01YzZjNjE3ODdkNTQiIHhtcE1NOkRvY3VtZW50SUQ9ImFkb2JlOmRvY2lkOnBob3Rvc2hvcDpmNzdjYmU0ZC0yNmRhLTAxNGEtYmZmMi1kZjUxM2QzZWExZTciIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0ieG1wLmRpZDoxNWM1MzBjNC1mNDIwLTIwNDAtOWZlMy0yMDFmYTVlMjk4ZmQiPiA8eG1wTU06SGlzdG9yeT4gPHJkZjpTZXE+IDxyZGY6bGkgc3RFdnQ6YWN0aW9uPSJjcmVhdGVkIiBzdEV2dDppbnN0YW5jZUlEPSJ4bXAuaWlkOjE1YzUzMGM0LWY0MjAtMjA0MC05ZmUzLTIwMWZhNWUyOThmZCIgc3RFdnQ6d2hlbj0iMjAyMi0wOC0yMVQxMzo1MTozNC0wNDowMCIgc3RFdnQ6c29mdHdhcmVBZ2VudD0iQWRvYmUgUGhvdG9zaG9wIDIyLjAgKFdpbmRvd3MpIi8+IDxyZGY6bGkgc3RFdnQ6YWN0aW9uPSJzYXZlZCIgc3RFdnQ6aW5zdGFuY2VJRD0ieG1wLmlpZDoxNTMzNmIyMC1mMzBmLTNjNDctODFjOS01YzZjNjE3ODdkNTQiIHN0RXZ0OndoZW49IjIwMjItMDgtMjFUMTQ6NTg6MjEtMDQ6MDAiIHN0RXZ0OnNvZnR3YXJlQWdlbnQ9IkFkb2JlIFBob3Rvc2hvcCAyMi4wIChXaW5kb3dzKSIgc3RFdnQ6Y2hhbmdlZD0iLyIvPiA8L3JkZjpTZXE+IDwveG1wTU06SGlzdG9yeT4gPC9yZGY6RGVzY3JpcHRpb24+IDwvcmRmOlJERj4gPC94OnhtcG1ldGE+IDw/eHBhY2tldCBlbmQ9InIiPz6vqoLiAAABj0lEQVRYw82X3VXDMAyFr5mm5wAj8NBlaJKBkpQBmIOHsgGnbBPxYhWhWP6LA/gpba7lz7J17Tgiwl82R0RwzvHvZwBn/3wC8MIvJKjXr7R6MjlxNYBOxyOADwNAa++J6GoArLQArjkAPYA5E2AgokkBpNbXNQUAMLFODD4IjewzNc9ABGDUM+f+vwUw+VjcjzhuCoA7F+8BQ6NblwLouHwqATiLY2BilLMJgxkwdnhPRHMAIBq3KgMGQCfMRrdqgJIM3LSsz5lYywyEjGgzwKoMc9xttyVQtU2BwUYDYhcA091k5ppWQcDdTgDu/H+LGFRXRLMM5LjbIA+b1N6qAeBLxWy5mxp8E4BegljQ/Y3o3wCoDXkDIKJzayMqsuICJ9x2FhTcCbMBkvbaGOC7CsRLfXl0lr0a0HWHkQKI2atly9uWQLxkql5lYcwEKKmCHwBZl0fv+dMeSxCzVx54CZhMsyWQTX5EvgK4BHzd1EYAzLih28sDgCdPfeGPU6OxdgHwntAeABz98xuATwD4AjvQr/p85ddkAAAAAElFTkSuQmCC"
IconDevMix := ""
IconSlider := ""
IconControl := "iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAACXBIWXMAAA7EAAAOxAGVKw4bAAAF8WlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iQWRvYmUgWE1QIENvcmUgNi4wLWMwMDIgNzkuMTY0NDg4LCAyMDIwLzA3LzEwLTIyOjA2OjUzICAgICAgICAiPiA8cmRmOlJERiB4bWxuczpyZGY9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkvMDIvMjItcmRmLXN5bnRheC1ucyMiPiA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0iIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtbG5zOmRjPSJodHRwOi8vcHVybC5vcmcvZGMvZWxlbWVudHMvMS4xLyIgeG1sbnM6cGhvdG9zaG9wPSJodHRwOi8vbnMuYWRvYmUuY29tL3Bob3Rvc2hvcC8xLjAvIiB4bWxuczp4bXBNTT0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL21tLyIgeG1sbnM6c3RFdnQ9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9zVHlwZS9SZXNvdXJjZUV2ZW50IyIgeG1wOkNyZWF0b3JUb29sPSJBZG9iZSBQaG90b3Nob3AgMjIuMCAoV2luZG93cykiIHhtcDpDcmVhdGVEYXRlPSIyMDIyLTA4LTIxVDEzOjUxOjM0LTA0OjAwIiB4bXA6TW9kaWZ5RGF0ZT0iMjAyMi0wOC0yMVQxNToxODo0MS0wNDowMCIgeG1wOk1ldGFkYXRhRGF0ZT0iMjAyMi0wOC0yMVQxNToxODo0MS0wNDowMCIgZGM6Zm9ybWF0PSJpbWFnZS9wbmciIHBob3Rvc2hvcDpDb2xvck1vZGU9IjMiIHBob3Rvc2hvcDpJQ0NQcm9maWxlPSJzUkdCIElFQzYxOTY2LTIuMSIgeG1wTU06SW5zdGFuY2VJRD0ieG1wLmlpZDoyZjk1MDg4Yy1mOTFmLTUyNDAtOWFkYi1iOTVmYTJkZmNlNGIiIHhtcE1NOkRvY3VtZW50SUQ9ImFkb2JlOmRvY2lkOnBob3Rvc2hvcDoxMThiNmIxYi0zMWU4LWQzNGEtYjRkZi1kYTY1ZjQ4MmVhOWMiIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0ieG1wLmRpZDo3NTc4NDJjMy1iMzY3LTc1NDMtOTlkYS1mYzNlYzY1OWZjMjEiPiA8eG1wTU06SGlzdG9yeT4gPHJkZjpTZXE+IDxyZGY6bGkgc3RFdnQ6YWN0aW9uPSJjcmVhdGVkIiBzdEV2dDppbnN0YW5jZUlEPSJ4bXAuaWlkOjc1Nzg0MmMzLWIzNjctNzU0My05OWRhLWZjM2VjNjU5ZmMyMSIgc3RFdnQ6d2hlbj0iMjAyMi0wOC0yMVQxMzo1MTozNC0wNDowMCIgc3RFdnQ6c29mdHdhcmVBZ2VudD0iQWRvYmUgUGhvdG9zaG9wIDIyLjAgKFdpbmRvd3MpIi8+IDxyZGY6bGkgc3RFdnQ6YWN0aW9uPSJzYXZlZCIgc3RFdnQ6aW5zdGFuY2VJRD0ieG1wLmlpZDoyZjk1MDg4Yy1mOTFmLTUyNDAtOWFkYi1iOTVmYTJkZmNlNGIiIHN0RXZ0OndoZW49IjIwMjItMDgtMjFUMTU6MTg6NDEtMDQ6MDAiIHN0RXZ0OnNvZnR3YXJlQWdlbnQ9IkFkb2JlIFBob3Rvc2hvcCAyMi4wIChXaW5kb3dzKSIgc3RFdnQ6Y2hhbmdlZD0iLyIvPiA8L3JkZjpTZXE+IDwveG1wTU06SGlzdG9yeT4gPC9yZGY6RGVzY3JpcHRpb24+IDwvcmRmOlJERj4gPC94OnhtcG1ldGE+IDw/eHBhY2tldCBlbmQ9InIiPz4AC4d5AAADmklEQVRYw52XS2xNURSGv6L1ptQr1XpLvSoiiHgFkYikpIMONCI6x0jMOjMxqQkaEilhwICIBCFeMaGtV4SKNKXaW6lqtSjlqvYY+HesnJxz7jlWsnPP3nuttdfz3/sOJZomAhuATUAe0An8IjNVAseANcBboCOMcViEkqHADKAEWAA0AO+B18BgBgPWAsUaBXIgIw0HlgLzzVo58A7w5EmZ2Zsn/uEBup5Kxo2xUV4CjJSVB4FlCvVoYBuwGhgFDAAfgJQO3wdsB7oVmd9G5yHJOOoA6jKF7BqQBr4C9cBdKe6XF/1AG3AHqBVfGriqXDsq9HnvAW8y1UC/8pqjsTKEd7qGpUHjvTPAT3OUvotR+S8z+Y47miVn62B3CO8PYLb/4CH69XT4Z7Pnaf5E6XiiuWd4emTEIJCltfkhTo4AHgH5/rAuBuaq2Gx4u4DTCtsnYJK8rQAmi6cAKJXSZjkxI6LW8oCHwCzryHEVXUqeuJDdk3GWlmjd8QwCrarwamCzouUBj+VxUDrOWKWtIUxnTZvalJ0N4W9Va7Zoflgyr0L4lzuFL9T3fb7DJgBTfWvTtG6pT/IvVGiFvvpaBbQHpOOkq4EjCu1qwe4YMSwGdqgGenRwqS8t34ArSmGD9LlifGN41gNNPgNWOF3ZUr7FF65+zU8DVcrbKwNMnrzeJPlsGej2SnwHVgSkocrmdrMumqB8pUPWG4CNxuv9Zq84IOzPffK1bmMRUKOrNgkQpYFTkkfp9BT2UQEG7PDJf3CFki8l2droEu6nfQrSatdO8eWofhy4FOk3FVDUADeA72Y+1t0FDcB5KewALgC9Ap5tQK4K8TpwCRgH7FSXnJc8BoTaQoDol7Bho7uDnAHtwDkJ9hiwyVNtAPwEbgOXlfOUiu+eruQc04KpCDTsMt/t9kXULe8sTDcJ0RYCL4FGgdOAEM9SATDegFsYjTbf9VFPst+q2qPyrEVtNxDCP9N8N0botd1RPczzvKiHSndWVtZNc5HsEbKN0MVTD9wCvugB6+htiL4iRQrgPlCH53mRQ7RVtRHUit3AAeCEWSsMMWCvad+8v5d+ZgMKE2JDZ8Rru1c8/55wMQyoSWjA85DDt8i4dXH/F9jwJ6G2iPUCP7jFMWBKQgOaQtZfBy0OiaGwN6EBH5MwxzHgWUIDHiXijlGEKxMUYCVJKSYOlAsZww7uAnbxPxTTAPfv5rjuhB611AN5nct/0h/C+vTZgmrwrwAAAABJRU5ErkJggg=="
IconExit := "iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAACXBIWXMAAA7EAAAOxAGVKw4bAAAJ5WlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iQWRvYmUgWE1QIENvcmUgNi4wLWMwMDIgNzkuMTY0NDg4LCAyMDIwLzA3LzEwLTIyOjA2OjUzICAgICAgICAiPiA8cmRmOlJERiB4bWxuczpyZGY9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkvMDIvMjItcmRmLXN5bnRheC1ucyMiPiA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0iIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtbG5zOmRjPSJodHRwOi8vcHVybC5vcmcvZGMvZWxlbWVudHMvMS4xLyIgeG1sbnM6cGhvdG9zaG9wPSJodHRwOi8vbnMuYWRvYmUuY29tL3Bob3Rvc2hvcC8xLjAvIiB4bWxuczp4bXBNTT0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL21tLyIgeG1sbnM6c3RFdnQ9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9zVHlwZS9SZXNvdXJjZUV2ZW50IyIgeG1sbnM6c3RSZWY9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9zVHlwZS9SZXNvdXJjZVJlZiMiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIDIyLjAgKFdpbmRvd3MpIiB4bXA6Q3JlYXRlRGF0ZT0iMjAyMi0wOC0yMVQxMzo1MTozNC0wNDowMCIgeG1wOk1vZGlmeURhdGU9IjIwMjItMDgtMjFUMTQ6NDE6MzEtMDQ6MDAiIHhtcDpNZXRhZGF0YURhdGU9IjIwMjItMDgtMjFUMTQ6NDE6MzEtMDQ6MDAiIGRjOmZvcm1hdD0iaW1hZ2UvcG5nIiBwaG90b3Nob3A6Q29sb3JNb2RlPSIzIiBwaG90b3Nob3A6SUNDUHJvZmlsZT0ic1JHQiBJRUM2MTk2Ni0yLjEiIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6MTdkYzRhZDktMGVlNS1lZTQ4LTlhZjgtNTdlYWIwODgzMWM0IiB4bXBNTTpEb2N1bWVudElEPSJhZG9iZTpkb2NpZDpwaG90b3Nob3A6NGZhNGNlYWItOGM1Ni1jODQ4LThmYTgtNDVmYmQwMDI3YWY1IiB4bXBNTTpPcmlnaW5hbERvY3VtZW50SUQ9InhtcC5kaWQ6NzgxMTg3NzctYWE3MS1kYTQ1LTk3NmMtOTQxZGYwYmZhZDRjIj4gPHhtcE1NOkhpc3Rvcnk+IDxyZGY6U2VxPiA8cmRmOmxpIHN0RXZ0OmFjdGlvbj0iY3JlYXRlZCIgc3RFdnQ6aW5zdGFuY2VJRD0ieG1wLmlpZDo3ODExODc3Ny1hYTcxLWRhNDUtOTc2Yy05NDFkZjBiZmFkNGMiIHN0RXZ0OndoZW49IjIwMjItMDgtMjFUMTM6NTE6MzQtMDQ6MDAiIHN0RXZ0OnNvZnR3YXJlQWdlbnQ9IkFkb2JlIFBob3Rvc2hvcCAyMi4wIChXaW5kb3dzKSIvPiA8cmRmOmxpIHN0RXZ0OmFjdGlvbj0iY29udmVydGVkIiBzdEV2dDpwYXJhbWV0ZXJzPSJmcm9tIGltYWdlL3BuZyB0byBhcHBsaWNhdGlvbi92bmQuYWRvYmUucGhvdG9zaG9wIi8+IDxyZGY6bGkgc3RFdnQ6YWN0aW9uPSJzYXZlZCIgc3RFdnQ6aW5zdGFuY2VJRD0ieG1wLmlpZDphMjgwNjRlZS05OGQ4LTAzNDYtYjU3Ny04NmEyOGQwZDJhNjMiIHN0RXZ0OndoZW49IjIwMjItMDgtMjFUMTM6NTg6MjEtMDQ6MDAiIHN0RXZ0OnNvZnR3YXJlQWdlbnQ9IkFkb2JlIFBob3Rvc2hvcCAyMi4wIChXaW5kb3dzKSIgc3RFdnQ6Y2hhbmdlZD0iLyIvPiA8cmRmOmxpIHN0RXZ0OmFjdGlvbj0ic2F2ZWQiIHN0RXZ0Omluc3RhbmNlSUQ9InhtcC5paWQ6YjUyNWY2N2EtMWYxMi1lNzRlLTk0ZDgtODdiODhkZjA2Y2VlIiBzdEV2dDp3aGVuPSIyMDIyLTA4LTIxVDE0OjQxOjMxLTA0OjAwIiBzdEV2dDpzb2Z0d2FyZUFnZW50PSJBZG9iZSBQaG90b3Nob3AgMjIuMCAoV2luZG93cykiIHN0RXZ0OmNoYW5nZWQ9Ii8iLz4gPHJkZjpsaSBzdEV2dDphY3Rpb249ImNvbnZlcnRlZCIgc3RFdnQ6cGFyYW1ldGVycz0iZnJvbSBhcHBsaWNhdGlvbi92bmQuYWRvYmUucGhvdG9zaG9wIHRvIGltYWdlL3BuZyIvPiA8cmRmOmxpIHN0RXZ0OmFjdGlvbj0iZGVyaXZlZCIgc3RFdnQ6cGFyYW1ldGVycz0iY29udmVydGVkIGZyb20gYXBwbGljYXRpb24vdm5kLmFkb2JlLnBob3Rvc2hvcCB0byBpbWFnZS9wbmciLz4gPHJkZjpsaSBzdEV2dDphY3Rpb249InNhdmVkIiBzdEV2dDppbnN0YW5jZUlEPSJ4bXAuaWlkOjE3ZGM0YWQ5LTBlZTUtZWU0OC05YWY4LTU3ZWFiMDg4MzFjNCIgc3RFdnQ6d2hlbj0iMjAyMi0wOC0yMVQxNDo0MTozMS0wNDowMCIgc3RFdnQ6c29mdHdhcmVBZ2VudD0iQWRvYmUgUGhvdG9zaG9wIDIyLjAgKFdpbmRvd3MpIiBzdEV2dDpjaGFuZ2VkPSIvIi8+IDwvcmRmOlNlcT4gPC94bXBNTTpIaXN0b3J5PiA8eG1wTU06RGVyaXZlZEZyb20gc3RSZWY6aW5zdGFuY2VJRD0ieG1wLmlpZDpiNTI1ZjY3YS0xZjEyLWU3NGUtOTRkOC04N2I4OGRmMDZjZWUiIHN0UmVmOmRvY3VtZW50SUQ9InhtcC5kaWQ6NzgxMTg3NzctYWE3MS1kYTQ1LTk3NmMtOTQxZGYwYmZhZDRjIiBzdFJlZjpvcmlnaW5hbERvY3VtZW50SUQ9InhtcC5kaWQ6NzgxMTg3NzctYWE3MS1kYTQ1LTk3NmMtOTQxZGYwYmZhZDRjIi8+IDwvcmRmOkRlc2NyaXB0aW9uPiA8L3JkZjpSREY+IDwveDp4bXBtZXRhPiA8P3hwYWNrZXQgZW5kPSJyIj8+meDtSgAAAZxJREFUWMPFl81NAzEQhb9FtMAxfyWA6IHDFhFnk5BsP0kkTnQRDpRBAwiOVIBIZC52WFmxPY69YiRfvKt5b2bsN2O01tgF3AFDZy/Lur46PgfArdYau6E76xuoKW+18X3C8hHQwA/Q9AluVgtwf+aDJaF6BD8RGAZ+yM1EHfHd2hLUZqMkiRj4Dlh2T/osQkIVBN8AS2DoXjVVgIQk8tZe93N3fZpRjhj4FlgDE6sRPrFpIiSmF0a+MoeeGAEJiSb5wHXAJQQkJFRC5INzMi2x0Jk4RgjugAUw9vUJqYVIJKU9x5SQRDft49IdTZm060BJtsAjMJI4vE4k8GWAgiMA8AJ89t7PAyWY/xd4L/NECPwYOBNFSEi0fRPRgllf4LaljhJlu1jka0dei5GQgPsULnuokYCvIiKjLs2EpOYrocI1qZmQRN5K5VU4Wc2780CpyFMzMfG9jFzwQYaWhDKxtA9FH/iiUEv13Y71FXDj/HwAnoA34BV4L0Dg2WTy4OxXlR2LqqpqnZa611p//P1ZZT3RjY8J8GBdAvwC1qoEow3xF48AAAAASUVORK5CYII="
IconTest := "iVBORw0KGgoAAAANSUhEUgAAACoAAAAgCAIAAADrOn1qAAAACXBIWXMAAAsTAAALEwEAmpwYAAAFyGlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iQWRvYmUgWE1QIENvcmUgNi4wLWMwMDIgNzkuMTY0NDg4LCAyMDIwLzA3LzEwLTIyOjA2OjUzICAgICAgICAiPiA8cmRmOlJERiB4bWxuczpyZGY9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkvMDIvMjItcmRmLXN5bnRheC1ucyMiPiA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0iIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtbG5zOnhtcE1NPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvbW0vIiB4bWxuczpzdEV2dD0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL3NUeXBlL1Jlc291cmNlRXZlbnQjIiB4bWxuczpkYz0iaHR0cDovL3B1cmwub3JnL2RjL2VsZW1lbnRzLzEuMS8iIHhtbG5zOnBob3Rvc2hvcD0iaHR0cDovL25zLmFkb2JlLmNvbS9waG90b3Nob3AvMS4wLyIgeG1wOkNyZWF0b3JUb29sPSJBZG9iZSBQaG90b3Nob3AgMjIuMCAoV2luZG93cykiIHhtcDpDcmVhdGVEYXRlPSIyMDIyLTA4LTIxVDE1OjIwOjM2LTA0OjAwIiB4bXA6TWV0YWRhdGFEYXRlPSIyMDIyLTA4LTIxVDE1OjIwOjM2LTA0OjAwIiB4bXA6TW9kaWZ5RGF0ZT0iMjAyMi0wOC0yMVQxNToyMDozNi0wNDowMCIgeG1wTU06SW5zdGFuY2VJRD0ieG1wLmlpZDpiNWNmMWJkYi0xYTU3LTcwNDktOWViYy1jMzNlNWZmZWE4MzIiIHhtcE1NOkRvY3VtZW50SUQ9ImFkb2JlOmRvY2lkOnBob3Rvc2hvcDpiMzY5OGFmZi05M2VhLWU1NDAtOTA4Ni0wODY2NjNjNjA1NDciIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0ieG1wLmRpZDpiNTE3OWEwMS1mZGIyLWU3NDAtYjUzZi0yYWM1YzhhMDQ0MTEiIGRjOmZvcm1hdD0iaW1hZ2UvcG5nIiBwaG90b3Nob3A6Q29sb3JNb2RlPSIzIj4gPHhtcE1NOkhpc3Rvcnk+IDxyZGY6U2VxPiA8cmRmOmxpIHN0RXZ0OmFjdGlvbj0iY3JlYXRlZCIgc3RFdnQ6aW5zdGFuY2VJRD0ieG1wLmlpZDpiNTE3OWEwMS1mZGIyLWU3NDAtYjUzZi0yYWM1YzhhMDQ0MTEiIHN0RXZ0OndoZW49IjIwMjItMDgtMjFUMTU6MjA6MzYtMDQ6MDAiIHN0RXZ0OnNvZnR3YXJlQWdlbnQ9IkFkb2JlIFBob3Rvc2hvcCAyMi4wIChXaW5kb3dzKSIvPiA8cmRmOmxpIHN0RXZ0OmFjdGlvbj0ic2F2ZWQiIHN0RXZ0Omluc3RhbmNlSUQ9InhtcC5paWQ6YjVjZjFiZGItMWE1Ny03MDQ5LTllYmMtYzMzZTVmZmVhODMyIiBzdEV2dDp3aGVuPSIyMDIyLTA4LTIxVDE1OjIwOjM2LTA0OjAwIiBzdEV2dDpzb2Z0d2FyZUFnZW50PSJBZG9iZSBQaG90b3Nob3AgMjIuMCAoV2luZG93cykiIHN0RXZ0OmNoYW5nZWQ9Ii8iLz4gPC9yZGY6U2VxPiA8L3htcE1NOkhpc3Rvcnk+IDwvcmRmOkRlc2NyaXB0aW9uPiA8L3JkZjpSREY+IDwveDp4bXBtZXRhPiA8P3hwYWNrZXQgZW5kPSJyIj8+dYak8AAAAC9JREFUSMftzUENADAQA6DWv+jOxJL7gAGaU02y7eZu9Xq9Xq/X6/V6vV6v/9gfegfAWiG+xsCCAAAAAElFTkSuQmCC"
IconFairTech := "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"
;} END Base64 Icons

;{ New Function for Showing Tray Volume Popup
ShowTrayVolume(x = 0, y = 0) {
  Static VolumeTrayIcon, TI := {}, OSCheck := A_OSVersion >= "10." && A_OSVersion < "W"
  DetectHiddenWindows, % (Setting_A_DetectHiddenWindows:=A_DetectHiddenWindows)?"On":
  if !VolumeTrayIcon && OSCheck {
    For key, sTray in ["Shell_TrayWnd", "NotifyIconOverflowWindow"] {
      WinGet,ControlList,ControlList,ahk_class %sTray%
      RegExMatch(ControlList,"(?<=ToolbarWindow32)\d+(?!.*ToolbarWindow32)",nTB)
      Loop, %nTB% {
        ControlGet,hWnd,hWnd,,ToolbarWindow32%A_Index%,ahk_class %sTray%
        WinGetClass,sClass,% "ahk_id " DllCall("GetParent",Ptr,hWnd)
        if !(sClass = "SysPager" or sClass = "NotifyIconOverflowWindow")
          Continue
        idxTB:=A_Index
        Break
      }
      WinGet,pidTaskbar,PID,ahk_class %sTray%
      hProc:=DllCall("OpenProcess",UInt,0x38,Int,0,UInt,pidTaskbar)
      pRB:=DllCall("VirtualAllocEx",Ptr,hProc,Ptr,0,UPtr,20,UInt,0x1000,UInt,0x4)
      SendMessage,0x418,0,0,ToolbarWindow32%idxTB%,ahk_class %sTray%
      szBtn:=VarSetCapacity(btn,(A_Is64bitOS?32:20),0)
      szNfo:=VarSetCapacity(nfo,(A_Is64bitOS?32:24),0)
      szTip:=VarSetCapacity(tip,128*2,0)
      Loop, %ErrorLevel% {
        SendMessage,0x417,A_Index-1,pRB,ToolbarWindow32%idxTB%,ahk_class %sTray%
        DllCall("ReadProcessMemory",Ptr,hProc,Ptr,pRB,Ptr,&btn,UPtr,szBtn,UPtr,0)
        dwData:=NumGet(btn,(A_Is64bitOS?16:12))
        iString:=NumGet(btn,(A_Is64bitOS?24:16),"Ptr")
        DllCall("ReadProcessMemory",Ptr,hProc,Ptr,dwData,Ptr,&nfo, UPtr,szNfo,UPtr,0)
        hWnd:=NumGet(nfo,0,"Ptr"),msgID:=NumGet(nfo,(A_Is64bitOS?12:8))
        WinGet,pID,PID,ahk_id %hWnd%
        WinGet,sProcess,ProcessName,ahk_id %hWnd%
        WinGet,sStyle,Style,ahk_id %hWnd%
        Index:=(TI.MaxIndex()>0?TI.MaxIndex()+1:1)
        DllCall("ReadProcessMemory",Ptr,hProc,Ptr,iString,Ptr,&tip,UPtr,szTip,UPtr, 0)
        TI[Index,"msgID"]:=msgID,TI[Index,"hWnd"]:=hWnd,TI[Index,"Process"]:=sProcess
        TI[Index,"Style"]:=sStyle,TI[Index,"Tooltip"]:=StrGet(&tip, "UTF-16")
      }
      DllCall("VirtualFreeEx",Ptr,hProc,Ptr,pRB,UPtr,0,Uint,0x8000)
      DllCall("CloseHandle",Ptr,hProc)
    }
    Loop, % TI.MaxIndex()
      if (TI[A_Index].Style = "0x84000000") && (TI[A_Index].Process = "explorer.exe")
      && ((SubStr(TI[A_Index].tooltip, 0) = "%") || (SubStr(TI[A_Index].tooltip, -4) = "muted")) {
        VolumeTrayIcon:={"msgID":TI[A_Index].msgID,"Hwnd":"ahk_id " TI[A_Index].hWnd}
        Break
      }
  }
  if (OSCheck)
    PostMessage, VolumeTrayIcon.msgID,, 1024,, % VolumeTrayIcon.Hwnd
  else
    Run, % A_WinDir "\System32\SndVol.exe -f " (x&0xFFFF)|((y&0xFFFF)<<16)
  DetectHiddenWindows, %Setting_A_DetectHiddenWindows%
}
;}

;{ Start gdi+
global pToken := Gdip_Startup()
If !pToken
{
	MsgBox, 48, gdiplus error!, Gdiplus failed to start. Please ensure you have gdiplus on your system
	ExitApp
}
;}

;; Prepare GUI
;InitializeSettingsGui()

;{ Stored variables
global isRanAtStartup := 1
global mainColor := 4294967295
global DEV1 :=
global DEV2 :=
global INDEV1 :=
global INDEV2 :=
global POPS := 1
global EarTrumpet := 0


IniRead, isRanAtStartup, %A_ScriptFullPath%:Stream:$DATA, Settings, Startup, error
IniRead, mainColor, %A_ScriptFullPath%:Stream:$DATA, Settings, MainColor, error
IniRead, DEV1, %A_ScriptFullPath%:Stream:$DATA, Settings, DEV1, error
IniRead, DEV2, %A_ScriptFullPath%:Stream:$DATA, Settings, DEV2, error
IniRead, INDEV1, %A_ScriptFullPath%:Stream:$DATA, Settings, INDEV1, error
IniRead, INDEV2, %A_ScriptFullPath%:Stream:$DATA, Settings, INDEV2, error
IniRead, POPS, %A_ScriptFullPath%:Stream:$DATA, Settings, POPS, error
IniRead, EarTrumpet, %A_ScriptFullPath%:Stream:$DATA, Settings, EarTrumpet, error
;IniRead, FirstRun, %A_ScriptFullPath%:Stream:$DATA, Settings, FirstRun, 1



;{ Audio Device Initialization

;{Create lists of devices
devicesOutEnum := ComObjCreate("{BCDE0395-E52F-467C-8E3D-C4579291692E}", "{A95664D2-9614-4F35-A746-DE8DB63617E6}")
VA_IMMDeviceEnumerator_EnumAudioEndpoints(devicesOutEnum, 0, 1, devicesOut)	;Gets all output devices that are active
VA_IMMDeviceCollection_GetCount(devicesOut, countOut)

devicesInEnum := ComObjCreate("{BCDE0395-E52F-467C-8E3D-C4579291692E}", "{A95664D2-9614-4F35-A746-DE8DB63617E6}")
VA_IMMDeviceEnumerator_EnumAudioEndpoints(devicesInEnum, 1, 1, devicesIn)	;Gets all input devices that are active
VA_IMMDeviceCollection_GetCount(devicesIn, countIn)
;}

;{ Get default devices
VA_IMMDeviceEnumerator_GetDefaultAudioEndpoint(devicesInEnum, 0, 0, defaultDevice)
global defaultOut = new Endpoint(defaultDevice)

VA_IMMDeviceEnumerator_GetDefaultAudioEndpoint(devicesInEnum, 0, 2, defaultDevice)
global defaultComOut = new Endpoint(defaultDevice)

VA_IMMDeviceEnumerator_GetDefaultAudioEndpoint(devicesInEnum, 1, 0, defaultDevice)
global defaultIn = new Endpoint(defaultDevice)

VA_IMMDeviceEnumerator_GetDefaultAudioEndpoint(devicesInEnum, 1, 2, defaultDevice)
global defaultComIn = new Endpoint(defaultDevice)

ObjRelease(defaultDevice)
;}


;{ Create and populate arrays with active devices
global Outputs := Array()
Loop %countOut%
{
	VA_IMMDeviceCollection_Item(devicesOut, A_Index-1, device)
	thisOut := new Endpoint(device)
	Outputs.push(thisOut)
}
global Inputs := Array()
Loop %countIn%
{
	VA_IMMDeviceCollection_Item(devicesIn, A_Index-1, device)
	thisIn := new Endpoint(device)
	Inputs.push(thisIn)
}

ObjRelease(devicesInEnum)
ObjRelease(devicesOutEnum)
ObjRelease(devicesIn)
ObjRelease(devicesOut)
ObjRelease(device)
;}


;Create and populate the menus and arrays of devices

global VisDev := Array()
Loop, % countOut
	{
		dev := Outputs[A_INDEX]
		nam := dev.GetName()
        VisDev.Push(nam)
        OutputDDL .= nam "|"
	}


	Loop, % countIn
	{
		dev := Inputs[A_INDEX]
		nam := dev.GetName()
        VisDev.Push(nam)
        InputDDL .= nam "|"
	}

;}


;{ Tray Icon Initialization
RefreshTrayTip()

Menu, Tray, NoStandard

;{ Fair Multi-Tool Integrations (Add Shortcuts)
if FileExist("FairDisplayManager.exe")
{
    Menu, Tray, Add, Display Manager, DisplayManagerRun
    Menu, Tray, Icon, Display Manager, %A_ScriptDir%/FairDisplayManager.exe
    Menu, Tray, Add
}
;} END Fair Multi-Tool Integrations

Menu, Tray, Add, Volume Mixer, Mixer
Menu, Tray, Icon, Volume Mixer, % "HICON:" . Base64PNG_to_HICON(IconMixer)
Menu, Tray, Add, Sound Settings, SoundCtrl
Menu, Tray, Icon, Sound Settings, % "HICON:" . Base64PNG_to_HICON(IconControl)
Menu, Tray, Add
Menu, Tray, Add, App Settings, Settings
Menu, Tray, Icon, App Settings, % "HICON:" . Base64PNG_to_HICON(IconSettings)
Menu, Tray, Add, Exit, ExitApplication
Menu, Tray, Icon, Exit, % "HICON:" . Base64PNG_to_HICON(IconExit)

;} END Tray Icon Initialization


;{NEW GUI
;InitializeSettingsGui()
;{
Gui, Tab ; Do not include in tabs
Gui, Color, 1b1b1b, 1b1b1b
Gui, Font, cWhite Bold s10, Tahoma
Gui, +ToolWindow
Gui, +LastFound
WinSet, Transparent, 220
Winset, AlwaysOnTop
Gui, -Caption
Gui, Add, Picture, x+60 y+15 Icon1 w50 h50, %A_ScriptFullPath%
Gui, Add, Text, xp-40 y+5 w180 h20, Fair Audio Manager

;{ Audio Device Tabs
Gui, Add, Tab3,x9 y100 w175 h150, Playback | Recording

;{ Tab 1
Gui, Tab, 1
Gui, Add, Text, +Center, Output Device 1:
Gui, Add, DDL, vDEV1, % OutputDDL ; Use List of Playback Devices
IniRead, DEV1, %A_ScriptFullPath%:Stream:$DATA, Settings, DEV1, ERROR
GuiControl, Choose, DEV1, %DEV1%

Gui, Add, Text, +Center, Output Device 2:
Gui, Add, DDL, vDEV2, % OutputDDL ; Use List of Playback Devices
IniRead, DEV2, %A_ScriptFullPath%:Stream:$DATA, Settings, DEV2, ERROR
GuiControl, Choose, DEV2, %DEV2%
;}

;{ Tab 2
Gui, Tab, 2

Gui, Add, Text, +Center, Input Device 1:
Gui, Add, DDL, vINDEV1, % InputDDL ; Use List of Input Devices
IniRead, INDEV1, %A_ScriptFullPath%:Stream:$DATA, Settings, INDEV1, ERROR
GuiControl, Choose, INDEV1, %INDEV1%

Gui, Add, Text, +Center, Input Device 2:
Gui, Add, DDL, vINDEV2, % InputDDL ; Use List of Input Devices
IniRead, INDEV2, %A_ScriptFullPath%:Stream:$DATA, Settings, INDEV2, ERROR
GuiControl, Choose, INDEV2, %INDEV2%
;}

;} END AUDIO DEVICE TABS

Gui, Tab ; Do not include in tabs
Gui, Font, cWhite s10, Tahoma
Gui, Add, CheckBox, gEarToggle vEarTrumpet x30 y270, EarTrumpet Mode
Gui, Add, CheckBox, gPopupToggle vPOPS xp yp+20, Notifications
Gui, Add, CheckBox, gStartupToggle visRanAtStartup xp yp+20, Run on Startup
Gui, Add, Button, xp+15 y+10 w100 h30 gChangeColor, Change Color
;Gui, Add, Button, xp yp+40 w100 h30, Save     ; Old Save Button, No Longer Needed
Gui, Add, Button, x165 y9 w20 h20 , X
Gui, Add, Button, x5 y9 w20 h20 , ?

;{ Gui Controls Settings
if (EarTrumpet=1)
    GuiControl,,EarTrumpet,1
else if (EarTrumpet=0)
    GuiControl,,EarTrumpet,0
if (isRanAtStartup)
    GuiControl,,isRanAtStartup,1
if (POPS=1)
    GuiControl,,POPS,1
else if (POPS = "0" or POPS = "error")
    GuiControl,,POPS,0
;}
;}

;}

;{~~~~~~~~~~ First Run Routine ~~~~~~~~~~
IniRead, FirstRun, %A_ScriptFullPath%:Stream:$DATA, Settings, FirstRun, 1
if (FirstRun=1) {
    Settings()
    InitializeAboutGUI()
    FirstRun:=0
    IniWrite, 0, %A_ScriptFullPath%:Stream:$DATA, Settings, FirstRun
}
;}~~~~~~~~ END First Run Routine ~~~~~~~~


;{ Initialize Audio Visualizer Icon
spectrum := []
While 1
{
    VA_IAudioMeterInformation_GetPeakValue(VA_GetAudioMeter(), vPeakValue)
    Loop 5
        spectrum[A_Index] := Clamp(vPeakValue * 32 + ((vPeakValue <  0.001) ? 0 : Random(-8,8)), 2, 32)
    CreateTrayIcon(spectrum)
    Sleep, 70
}

Random(min := 0, max := 1.0)
{
	Random, rand, min, max
	return rand
}
;} END Initialize Audio Visualizer Icon

;{ Exit Application Gracefully
ExitApplication()
{
    Gdip_Shutdown(pToken)
    ExitApp
    Exit
}
;} END Exit Application Gracefully

;{ Settings Window Open
Settings()
{
    ;Gui, Show, NoActivate, Settings
    ; Get Monitor Size, Set GUI Size and Position Bottom Right, and Show GUI
SysGet, marea, Monitor
wfactor= 0 ;Customize to adjust the horizontal position based on OS edition and style
hfactor= 40 ;Customize to adjust the vertical position based on OS edition and style
width= 190
height= 380
xaxis := (marearight-width-wfactor)
yaxis := (mareabottom-height-hfactor)
Gui, Show, w%width% h%height% x%xaxis% y%yaxis%, FairAudioManager
    if (isRanAtStartup)
        GuiControl,,isRanAtStartup,1
    if (POPS=1)
    GuiControl,,POPS,1
else if (POPS = "0" or POPS = "error")
    GuiControl,,POPS,0
if (EarTrumpet=1)
    GuiControl,,EarTrumpet,1
else if (EarTrumpet=0)
    GuiControl,,EarTrumpet,0
;OnMessage( 0x200, "WM_MOUSEMOVE" )  ; Int Left Click Drag Menu
}
;} END Settings Window Open

;----------------------------- Left Click anywhere on UI to Drag Window
WM_MOUSEMOVE( wparam, lparam, msg, hwnd )
{
	if wparam = 1 ; LButton
		PostMessage, 0xA1, 2,,, A ; WM_NCLBUTTONDOWN
}
;----------------------------- END Left Click Drag

ChangeColor()
{
    MyColor := ChooseColor(0x80FF, GuiHwnd, , , Colors*)
    if (MyColor != "cancel")
        mainColor := 0xFF000000 | MyColor
    IniWrite, %mainColor%, %A_ScriptFullPath%:Stream:$DATA, Settings, MainColor
}

StartupToggle()
{
    isRanAtStartup := !isRanAtStartup
    ;Menu, Tray, ToggleCheck, Run at Startup
    GuiControlGet, visRanAtStartup,, checkbox
    if(isRanAtStartup)
    {
		FileCreateShortcut,%A_ScriptFullPath%,%A_AppData%\Microsoft\Windows\Start Menu\Programs\Startup\FairAudioManager.lnk,%A_ScriptDir%
        ;MsgBox, Startup Shortcut Created!
    }
	else
    {
		FileDelete, %A_AppData%\Microsoft\Windows\Start Menu\Programs\Startup\FairAudioManager.lnk
        ;MsgBox, No Longer Starting with Windows
    }

    IniWrite, %isRanAtStartup%, %A_ScriptFullPath%:Stream:$DATA, Settings, Startup
}

PopupToggle()
{
    return
}

EarToggle()
{
    ;IniRead, EarTrumpet, %A_ScriptFullPath%:Stream:$DATA, Settings, EarTrumpet, error
    return
}

Clamp(n, min, max)
{
    return Max(Min(max, n), min)
}

CreateTrayIcon(spectrum)
{
    pBrushBack := Gdip_BrushCreateSolid(mainColor)
    pBitmap := Gdip_CreateBitmap(32, 32)
    G := Gdip_GraphicsFromImage(pBitmap)
    Gdip_SetSmoothingMode(G, 1)
    X := [2,8,14,20,26]
    Loop 5
        Gdip_FillRectangle(G, pBrushBack, X[A_Index], 32-spectrum[A_Index], 4, 32)
	hIcon := Gdip_CreateHICONFromBitmap(pBitmap)
	Gdip_DeleteBrush(pBrushBack)
    Gdip_DeleteGraphics(G)
    Gdip_DisposeImage(pBitmap)
	Menu, Tray, Icon, HICON:%hIcon%
	DestroyIcon(hIcon)
}

ChooseColor(pRGB := 0, hOwner := 0, DlgX := 0, DlgY := 0 , Palette*)
{
    static CustColors    ; Custom colors are remembered between calls
    static SizeOfCustColors := VarSetCapacity(CustColors, 64, 0)
    static StructSize := VarSetCapacity(ChooseColor, 9 * A_PtrSize, 0)

    CustData := (DlgX << 16) | DlgY    ; Store X in high word, Y in the low word

;___Load user's custom colors
    for Index, Value in Palette
        NumPut(BGR2RGB(Value), CustColors, (Index - 1) * 4, "UInt")

;___Set up a ChooseColor structure as described in the MSDN
    NumPut(StructSize, ChooseColor, 0, "UInt")
    NumPut(hOwner, ChooseColor, A_PtrSize, "UPtr")
    NumPut(BGR2RGB(pRGB), ChooseColor, 3 * A_PtrSize, "UInt")
    NumPut(&CustColors, ChooseColor, 4 * A_PtrSize, "UPtr")
    NumPut(0x113, ChooseColor, 5 * A_PtrSize, "UInt")
    NumPut(CustData, ChooseColor, 6 * A_PtrSize, "UInt")
    NumPut(RegisterCallback("ColorWindowProc"), ChooseColor, 7 * A_PtrSize, "UPtr")

;___Call the function
    if(! DllCall("comdlg32\ChooseColor", "UPtr", &ChooseColor, "UInt"))
        Return "cancel"

;___Save the changes made to the custom colors
    Loop 16
        Palette[A_Index] := BGR2RGB(NumGet(CustColors, (A_Index - 1) * 4, "UInt"))

    return BGR2RGB(NumGet(ChooseColor, 3 * A_PtrSize, "UINT"))
}

; { Quick Memory Clear Task
DllCall("SetProcessWorkingSetSize", "Ptr",-1, "Ptr",-1, "Ptr",-1)
;}


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~TESTING
ColorWindowProc(hwnd, msg, wParam, lParam)
{
    static WM_INITDIALOG := 0x0110
    if (msg <> WM_INITDIALOG)
        return 0

    hOwner := NumGet(lParam+0, A_PtrSize, "UPtr")
    if (hOwner)
        return 0

    DetectSetting := A_DetectHiddenWindows
    DetectHiddenWindows On
    CustData := NumGet(lParam+0, 6 * A_PtrSize, "UInt")
    ;DlgX := CustData >> 16, DlgY := CustData & 0xFFFF
    DlgX := A_ScreenWidth - 640
    DlgY := A_ScreenHeight - 365
    WinMove ahk_id %hwnd%, , %DlgX%, %DlgY%
    ;WinSet ahk_id %hwnd%, ,

    DetectHiddenWindows %DetectSetting%
    return 0
}

BGR2RGB(Color)
{
    return  (Color & 0xFF000000) | ((Color & 0xFF0000) >> 16) |  (Color & 0x00FF00) | ((Color & 0x0000FF) << 16)
}

Base64PNG_to_HICON(Base64PNG, W:=0, H:=0)
{
   BLen:=StrLen(Base64PNG), Bin:=0,     nBytes:=Floor(StrLen(RTrim(Base64PNG,"="))*3/4)
   Return DllCall("Crypt32.dll\CryptStringToBinary", "Str",Base64PNG, "UInt",BLen, "UInt",1
               ,"Ptr",&(Bin:=VarSetCapacity(Bin,nBytes)), "UIntP",nBytes, "UInt",0, "UInt",0)
         ? DllCall("CreateIconFromResourceEx", "Ptr",&Bin, "UInt",nBytes, "Int",True, "UInt"
                  ,0x30000, "Int",W, "Int",H, "UInt",0, "UPtr") : 0
}



LogoPng(NewHandle := False)
{
    Static hBitmap := 0
    If (NewHandle)
        hBitmap := 0
    If (hBitmap)
        Return hBitmap
    VarSetCapacity(B64, 252 << !!A_IsUnicode)
    B64 := "iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAQAAADZc7J/AAAABGdBTUEAALGPC/xhBQAAACBjSFJNAAB6JgAAgIQAAPoAAACA6AAAdTAAAOpgAAA6mAAAF3CculE8AAAAAmJLR0QA/4ePzL8AAAAHdElNRQfmBx8WKhTbiQ5xAAACtElEQVRIx5WVP0wTcRTHP3ctimjS2qIDaGWqihqqJFg1jZGFQRGJIUSDddPoQnTQxYTJFTZdz8WEzT+44kCsRhlguGiURKLxX9IoGJViQ78OPevd9fD03fL73Xvvc+/3e/feMwgQxSvHprpnM8W2UgwaF5vnO2Zyk+aEsUC4aHvBGl5KCaFxUXtSGl4qWNr+d+cme/RmOa29OiuE2lwAhCLKl+1RNa3mnrbshGJap6TSQj1Cljb5IAlZttJB7p0jRUMI9ahPCLULXVHcB0CGRorqrPv6SPG3wXENCq3VYWffqjV1kJGiJwo1WbbhqPapTzl1aUgPFVOv+jSmXQFRWLbrLuzRRE11S9JrvZD0WTf0U5J0ug6AErJHa4nLl/EA/sh7FfRNJ2ratDbU1vmyk9SCFVEwoKKKpvVQd5zD+ZNasADFh5fwAJ7rue6rQQ06pwsyVMVfFrrpgwwvKc7KUEpewIK+6K5zVYaOOuvq3htDSitD5lT3G19KY8Sd1R4yPOEaZwC4ToI0G1yWb5jqjs5mvO6P2M0+OrkNlNjMHN/J0gvs4R2bmOaBy3o2Ey22eQHraQJaOQU8pYEs39jIO3YCQ7Sw6LEutkVLMS8gww73L0aSJF8RAAfqCqAUiwYX1gceA59IMkeSg3yknQl+AC99ltHGRTbWA55xsrbOco9XHOEib+vsGhfN5nlC5CcrnMcI1DXPmx0zYYAPvAcqgbqOGTM3mQoBbGMvcDXgAClyk6Y50V8Ki8EALtFS976/ZE6YxsLgeCSMALTgt4owOG4s4C/nLg1oQIdcf3zWqc2tvkqolTPYYwmfklCAq6F4W9q/AXwtzdtU/wXga6rgbuthgMC2Xo3CshOhgFUHS/Uu7LF8OeID7NeylrWsLdXRNrbqaHMgruHqbV/BwzWwRv5nvP8CUT+YHp3X/0cAAAAldEVYdGRhdGU6Y3JlYXRlADIwMjItMDctMzFUMjI6NDI6MjArMDA6MDDiOzsIAAAAJXRFWHRkYXRlOm1vZGlmeQAyMDIyLTA3LTMxVDIyOjQyOjIwKzAwOjAwk2aDtAAAAABJRU5ErkJggg=="
    If !DllCall("Crypt32.dll\CryptStringToBinary", "Ptr", &B64, "UInt", 0, "UInt", 0x01, "Ptr", 0, "UIntP", DecLen, "Ptr", 0, "Ptr", 0)
        Return False
    VarSetCapacity(Dec, DecLen, 0)
    If !DllCall("Crypt32.dll\CryptStringToBinary", "Ptr", &B64, "UInt", 0, "UInt", 0x01, "Ptr", &Dec, "UIntP", DecLen, "Ptr", 0, "Ptr", 0)
        Return False
    ; Bitmap creation adopted from "How to convert Image data (JPEG/PNG/GIF) to hBITMAP?" by SKAN
    ; -> http://www.autohotkey.com/board/topic/21213-how-to-convert-image-data-jpegpnggif-to-hbitmap/?p=139257
    hData := DllCall("Kernel32.dll\GlobalAlloc", "UInt", 2, "UPtr", DecLen, "UPtr")
    pData := DllCall("Kernel32.dll\GlobalLock", "Ptr", hData, "UPtr")
    DllCall("Kernel32.dll\RtlMoveMemory", "Ptr", pData, "Ptr", &Dec, "UPtr", DecLen)
    DllCall("Kernel32.dll\GlobalUnlock", "Ptr", hData)
    DllCall("Ole32.dll\CreateStreamOnHGlobal", "Ptr", hData, "Int", True, "PtrP", pStream)
    hGdip := DllCall("Kernel32.dll\LoadLibrary", "Str", "Gdiplus.dll", "UPtr")
    VarSetCapacity(SI, 16, 0), NumPut(1, SI, 0, "UChar")
    DllCall("Gdiplus.dll\GdiplusStartup", "PtrP", pToken, "Ptr", &SI, "Ptr", 0)
    DllCall("Gdiplus.dll\GdipCreateBitmapFromStream",  "Ptr", pStream, "PtrP", pBitmap)
    DllCall("Gdiplus.dll\GdipCreateHBITMAPFromBitmap", "Ptr", pBitmap, "PtrP", hBitmap, "UInt", 0)
    DllCall("Gdiplus.dll\GdipDisposeImage", "Ptr", pBitmap)
    DllCall("Gdiplus.dll\GdiplusShutdown", "Ptr", pToken)
    DllCall("Kernel32.dll\FreeLibrary", "Ptr", hGdip)
    DllCall(NumGet(NumGet(pStream + 0, 0, "UPtr") + (A_PtrSize * 2), 0, "UPtr"), "Ptr", pStream)
    Return hBitmap
}
;}

;{ Setup VolMute HotKey Functions
VolMuteFunc(isHold, taps, state){
    ;IF Button is Held
if (isHold=1) & (taps=1) & (state=1){    ;  state=1 means it activates when key is down. 0 means when key is up.
Gosub ToggleDevice()
    RefreshTrayTip()
return
}
    ;IF Button is Tapped
if (isHold=0) & (taps=1) & (state){
	;SoundSet, +1, , mute  ;Toggles Mute on Current Audio Device (Retaining Original Functionality)
    GoSub ToggleMute
    RefreshTrayTip()
    return
}
    ;IF Button is Tapped and Held
if (isHold=1) & (taps=2) & (state=1){
    Gosub ToggleInDevice()
    RefreshTrayTip()
    return
}
}
;}




;{ Toggle Audio Device Function
ToggleDevice():
{
GoSub RefreshDefaultOutput
defOutTog := defaultOut.GetName()
    if (DEV1 = "ERROR" or DEV2 = "ERROR" or DEV1 = "" or DEV2 = "")
    {
    MsgBox, Audio Devices not set. Please Select your Devices in the Settings Menu.
    Settings()
    defOutTog :=
    return
    }
    else
    {
        if (defOutTog = DEV1)
        {
            SetDefaultEndpoint( GetDeviceID(Devices, DEV2) )
            if (POPS=1){
                NotifyText := "🔊: " DEV2
                GoSub NotifySend
                NotifyText :=
            }
            defOutTog :=
            return
        }
        else if (defOutTog = DEV2)
        {
            SetDefaultEndpoint( GetDeviceID(Devices, DEV1) )
            if (POPS=1){
                NotifyText := "🔊: " DEV1
                GoSub NotifySend
                NotifyText :=
            }
            defOutTog :=
            return
        }
        else
        {
        ;MsgBox, Audio Devices not set. Please Select your Devices in the Settings Menu.
        SetDefaultEndpoint( GetDeviceID(Devices, DEV1) )
        if (POPS=1){
            NotifyText := "🔊: " DEV1
            GoSub NotifySend
            NotifyText :=
        }
        ;RefreshTrayTip()
        defOutTog :=
        return
    }
    return
}
}
;} End Function for Toggle Audio Device

;{ Toggle Recording Device Function - TESTING
ToggleInDevice():
{
GoSub RefreshDefaultInput
defInTog := defaultIn.GetName()
    if (INDEV1 = "ERROR" or INDEV2 = "ERROR" or INDEV1 = "" or INDEV2 = "")
    {
    MsgBox, Audio Devices not set. Please Select your Devices in the Settings Menu.
    Settings()
    defInTog :=
    return
    }
    else
    {
        if (defInTog = INDEV1)
        {
            VA_SetDefaultEndpoint(INDEV2,1)
            ;RefreshTrayTip()
            if (POPS=1){
                NotifyText := "🎤: " INDEV2
                GoSub NotifySend
                NotifyText :=
            }
            defInTog :=
            return
        }
        else if (defInTog = INDEV2)
        {
            VA_SetDefaultEndpoint(INDEV1,1)
            ;RefreshTrayTip()
            if (POPS=1){
                NotifyText := "🎤: " INDEV1
                GoSub NotifySend
                NotifyText :=
            }
            defInTog :=
            return
        }
        else
        {
        ;MsgBox, Audio Devices not set. Please Select your Devices in the Settings Menu.
        SetDefaultEndpoint( GetDeviceID(Devices, INDEV1) )
        RefreshTrayTip()
        if (POPS=1){
            NotifyText := "🎤: " INDEV1
            GoSub NotifySend
            NotifyText :=
        }
        defInTog :=
        return
    }
    return
}
}

ToggleMute:
{
    SoundSet, +1, , mute
    RefreshTrayTip()
    ;SoundGet, master_mute,, Mute   ;On=Muted Off=Not Muted
    if (POPS = "1" AND master_mute = "Off") {
        NotifyText := TRAYTIPTEXT
        GoSub NotifySend
        NotifyText :=
    }
    if (POPS = "1" AND master_mute = "On") {
        NotifyText := TIPDEV "`: " "Muted"
        GoSub NotifySend
        NotifyText :=
    }
    return
}

    TRAYTIPTEXT := TIPDEV "`: " "Muted"
;} End Function for Toggle Audio Device


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;{~~~~~~~~~~~~~~~SUBROUTINES AND HOTKEYS~~~~~~~~~~~~~~~
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

;{ Setup Bottom Right Function
NotifAreaInt()
{
    global
    SysGet, WorkArea, MonitorWorkArea
    MonX := WorkAreaRight
    MonY := WorkAreaBottom
}

;{ Setup Bottom Right Hotspot Subroutine?
NotifAreaInt:
{
global SysGet, WorkArea, MonitorWorkArea
global MonX := WorkAreaRight
global MonY := WorkAreaBottom
MsgBox, MonX: %MonX% -- MonY: %MonY%
return
}
;}

;{ Function to Open Windows Sound Mixer
Mixer: ; Show the app/volume mixer
{
SetWinDelay, -1
Run "sndvol" -t
WinWaitActive, ahk_class #32770
WinMove, % A_ScreenWidth - 480, % A_ScreenHeight - 340 - 43
return
}
;}

;{ Function to Open Sliders
DevMixer: ; Show the master device mixer
{
Run, "sndvol" -f
WinWaitActive, ahk_class #32770
WinMove, % A_ScreenWidth - 350, % A_ScreenHeight - 290 - 48
Return
}
;}

;{Function to Open Sound Control Panel
SoundCtrl:
{
SetWinDelay -1
if (POPS=1){
NotifyText = Opening Sound Control Panel...
GoSub NotifySend
NotifyText :=
}
Run, mmsys.cpl    ; Open Sound Control Panel
WinWaitActive, ahk_class #32770
WinMove, % A_ScreenWidth - 412, % A_ScreenHeight - 450 - 48
return
}

;{ NEW Function to Open Windows Volume Slider
Slider:
{
SetWinDelay, -1
IniRead, EarTrumpet, %A_ScriptFullPath%:Stream:$DATA, Settings, EarTrumpet, error
if (EarTrumpet=1){
    GoSub EarMenu
    return
}
else {
    ShowTrayVolume(A_ScreenWidth, A_ScreenHeight)    ; New Call for Showing Tray Volume Popup! - Thanks MiM#9148
    return
}
Return
}
;}

;{ Function for Settings Close
ButtonX:
{
    Gui About:Cancel
    Gui About:Destroy
    Gui, Submit
    GoSub SettingsSave
    return
}
;}

;{ Function for Settings Close
Button?:
{
    InitializeAboutGUI()
    return
}
;}

;{ Function for Save Button (same as Close, without closing Gui)
ButtonSave:
{
    Gui, Submit, NoHide
    GoSub SettingsSave
    return
}
;} END Save Button Function

;{ Settings Save Function, Saves all data to Alternative Data Stream of Script/Compiled EXE
SettingsSave:
{
    IniWrite, %DEV1%, %A_ScriptFullPath%:Stream:$DATA, Settings, DEV1
    IniWrite, %DEV2%, %A_ScriptFullPath%:Stream:$DATA, Settings, DEV2
    IniWrite, %INDEV1%, %A_ScriptFullPath%:Stream:$DATA, Settings, INDEV1
    IniWrite, %INDEV2%, %A_ScriptFullPath%:Stream:$DATA, Settings, INDEV2
    IniWrite, %isRanAtStartup%, %A_ScriptFullPath%:Stream:$DATA, Settings, Startup
    IniWrite, %POPS%, %A_ScriptFullPath%:Stream:$DATA, Settings, POPS
    IniWrite, %mainColor%, %A_ScriptFullPath%:Stream:$DATA, Settings, MainColor
    IniWrite, %EarTrumpet%, %A_ScriptFullPath%:Stream:$DATA, Settings, EarTrumpet
    if (POPS=1){
        NotifyText = ⚙ Settings Saved!
        GoSub NotifySend
        NotifyText :=
    }
    return
}
;} END Settings Save Function

;{ Listening Function for Tray Icon - Left Click, Double Click, Middle Click, and Hovered?
AHK_NOTIFYICON(wParam, lParam)
{
    if (lParam = 0x202) { ; LEFT CLICK tray icon
;        Settimer, Tray_SingleClick, -400
        Settimer, Tray_SingleClick, -200
        return 1
    }
	else if (lParam = 0x203) { ; Double Left Click tray icon
;        Settimer, Tray_DoubleClick, -150
        Settimer, Tray_DoubleClick, -75
    return 1

    }
   if (lParam = 0x204) { ; Right Click tray icon
			;Leave Empty for Context (Tray) Menu
        return
    }
    if (lParam = 0x208) { ; Middle Click Tray Icon

        ;GoSub SoundCtrl
        ;SoundSet, +1, , mute  ;Toggles Mute on Current Audio Device
        GoSub ToggleMute
        RefreshTrayTip()
        return
    }
    if (lParam = 0x200) { ; Is Hovered? Enable Mouse Wheel Functions
        MouseGetPos, x, y
        global last_valid := [x, y]
        ;RefreshTrayTip()
    }
}
;}

;{ Mouse Wheel Hotkey Functions
~WheelUp::
    MouseGetPos, x, y
    if (last_valid[1] == x && last_valid[2] == y) {  ;If Hovered
        ;msgbox You used wheel up while hovering the icon  ;Function
        SoundSet +5
        RefreshTrayTip()
        return
    }
return

~WheelDown::
    MouseGetPos, x, y
    if (last_valid[1] == x && last_valid[2] == y) {
        ;msgbox You used wheel down while hovering the icon ;Function
        SoundSet -5
        RefreshTrayTip()
        return
    }
return

;{ Tray Timers for Tray Icon Functions
Tray_DoubleClick:
loop 2
Settimer, Tray_SingleClick, Off
;msgbox You Double left-clicked tray icon ;Double Click Function
GoSub Mixer
RefreshTrayTip()
return

Tray_SingleClick:
;msgbox You left-clicked tray icon ;Left Click Function
GoSub Slider
RefreshTrayTip()
return
;}

;{ Nothing...
Nothing:
return
;}

;{ Refresh the Default Output Variable - Use when Toggling Devices
RefreshDefaultOutput:
{
VA_IMMDeviceEnumerator_GetDefaultAudioEndpoint(devicesOutEnum, 0, 0, defaultDevice)
global defaultOut = new Endpoint(defaultDevice)
return
}
;}

RefreshDefaultInput:
{
VA_IMMDeviceEnumerator_GetDefaultAudioEndpoint(devicesInEnum, 1, 0, defaultDevice)
global defaultIn = new Endpoint(defaultDevice)
return
}


;;{ Populate Tray Tip Function
RefreshTrayTip()
{
Global
GoSub RefreshDefaultOutput
TIPDEV := defaultOut.GetName()
SoundGet, master_volume
TIPVOL := Round(master_volume)
SoundGet, master_mute,, Mute   ;On=Muted Off=Not Muted
if (master_mute = "On") {
    TRAYTIPTEXT := TIPDEV "`: " "Muted"
    Menu, Tray, Tip, %TRAYTIPTEXT%
}
if (master_mute = "Off") {
    TRAYTIPTEXT := TIPDEV "`: " TIPVOL "`%"
    Menu, Tray, Tip, %TRAYTIPTEXT%
}
;Menu, Tray, Tip, %TRAYTIPTEXT%
EmptyMem()
return
}
;}

;;{ Open Ear Trumpet Menu Instead of Default Windows Menu
EarMenu:
{
Send, ^{NumpadDiv}
return
}
;}

;{ Send Notification Function
NotifySend:
{
Notify:=Notify(1)
;NotifyText=🎤🔊
Notif:=Notify.AddWindow(A_space NotifyText A_space,{Animate:"Blend",Hide:"Blend",Time:"3000",Background:"0x1B1B1B",Color:"0xFFFFFF",ShowDelay:100,Radius:10,Size:11,Font:"Tahoma"})
return
}

/*
;{ DEBUG Hotkeys
F1::
GoSub RefreshDefaultOutput
devicetest := VA_GetDevice("playback")
devicenametest := VA_GetDeviceName(devicetest)
defOuttest := defaultOut.GetName()
GoSub RefreshDefaultInput
deviceintest := VA_GetDevice("capture")
deviceinnametest := VA_GetDeviceName(deviceintest)
defIntest := defaultIn.GetName()
SoundGet, master_volume
MsgBox, FairAudioManager DEBUG Menu!`n`nOutput Device 1: %DEV1%`n`nOutput Device 2: %DEV2%`n`nCurrent Output Device Cleaned: %defOuttest%`n`nCurrent Output Device (raw): %devicenametest%`n`nCurrent Tray Tip Text: %A_IconTip%`n`nCurrent Volume: %master_volume%`n`n`n`nInput Device 1: %INDEV1%`n`nInput Device 2: %INDEV2%`n`nCurrent Input Device Cleaned: %defIntest%`n`nCurrent Input Device (raw): %deviceinnametest%`n`n`n`nCurrent Variables:`n`nisRanAtStartup?: %isRanAtStartup%`nFull Path of Script: %A_ScriptFullPath%`nMain Color: %MainColor%`n
return

F5::
SetDefaultEndpoint( GetDeviceID(Devices, DEV1) )
return

F6::
SetDefaultEndpoint( GetDeviceID(Devices, DEV2) )
return

F7::
GoSub RefreshDefaultInput
VA_SetDefaultEndpoint(INDEV1,1)
return

F8::
GoSub RefreshDefaultInput
VA_SetDefaultEndpoint(INDEV2,1)
return

F9::
NotifAreaInt()
MsgBox, %MonX%`n%MonY%
return
;}

F10::
MsgBox, POPS?: %POPS%

F11::
TrayIcon_Button("EarTrumpet.exe", "L")
return

F12::
GoSub EarMenu
return
*/


;}~~~~~~~~~~~~~~~SUBROUTINES AND HOTKEYS~~~~~~~~~~~~~~~

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

;More functions to get information about devices, adapted from Vista Audio

GetDeviceDesc(device)
{
	static PKEY_Device_DeviceDesc
	if !VarSetCapacity(PKEY_Device_DeviceDesc)
		VarSetCapacity(PKEY_Device_DeviceDesc, 20)
		,VA_GUID(PKEY_Device_DeviceDesc :="{A45C254E-DF1C-4EFD-8020-67D146A850E0}")
		,NumPut(2, PKEY_Device_DeviceDesc, 16)
	VarSetCapacity(prop, 16)
	VA_IMMDevice_OpenPropertyStore(device, 0, store)
	; store->GetValue(.., [out] prop)
	DllCall(NumGet(NumGet(store+0)+5*A_PtrSize), "ptr", store, "ptr", &PKEY_Device_DeviceDesc, "ptr", &prop)
	ObjRelease(store)
	VA_WStrOut(deviceDesc := NumGet(prop,8))
	return deviceDesc
}

;Broken
GetDeviceIcon(device)
{
	static PKEY_DrvPkg_Icon
	if !VarSetCapacity(PKEY_DrvPkg_Icon)
		VarSetCapacity(PKEY_DrvPkg_Icon, 20)
		,VA_GUID(PKEY_DrvPkg_Icon :="{CF73BB51-3ABF-44A2-85E0-9A3DC7A12132}")
		,NumPut(4, PKEY_DrvPkg_Icon, 16)
	VarSetCapacity(prop, 16)
	VA_IMMDevice_OpenPropertyStore(device, 0, store)
	; store->GetValue(.., [out] prop)
	DllCall(NumGet(NumGet(store+0)+5*A_PtrSize), "ptr", store, "ptr", &PKEY_DrvPkg_Icon, "ptr", &prop)
	ObjRelease(store)
	VA_WStrOut(deviceIcon := NumGet(prop,8))
	return deviceIcon
}

;PKEY_DrvPkg_Icon: {CF73BB51-3ABF-44A2-85E0-9A3DC7A12132} 4
;PKEY_DeviceClass_Icon: {259ABFFC-50A7-47CE-AF8-68C9A7D73366} 4


;{~~~~~~~~~~~ABOUT GUI~~~~~~~~~~~~
InitializeAboutGui()
{
Global
Gui About: New, +LabelAboutInfo +hWndhAbtWnd -MinimizeBox -MaximizeBox -SysMenu +ToolWindow -Caption +Owner
Gui About: +LastFound
WinSet, Transparent, 220
Gui About: Add, Button, gAbtX x278 y6 w21 h21, &X          ; CLOSE Button

;{ About Section
Gui About: Font, cWhite, Tahoma
Gui About: Color, 1b1b1b, 1b1b1b
Gui About: Font
Gui About: Font, s13 Bold Underline cAqua, Tahoma
Gui About: Add, Picture, x123 y7 w60 h60, % "HICON:" . Base64PNG_to_HICON(IconFairTech)
Gui About: Add, Text, x33 yp+62 w239 h30 +0x200 +Center, About Fair Audio Manager
Gui About: Font
Gui About: Font, cWhite, Tahoma
Gui About:Add, Text, x6 yp+32 w293 h95 +Center, Fair Audio Manager is exactly what it sounds like!`n`nUse it to Toggle Playback and Recording Devices,`nAdjust your Volume by scrolling over the Tray Icon,`nOpen Windows Volume Popup, Mixer, or Sound Settings`nwith different gestures on the Tray Icon,`nand more!`n
;} END About Section


;{ Credits Section
Gui About:Font, s11 Bold Underline q0 cAqua, Tahoma
Gui About:Add, Text, x116 y520 w72 h16 +0x200 +Center, Credits
Gui About:Font
Gui About:Font, cWhite, Tahoma
Gui About:Add, Button, +Center gDonateAbt x53 yp+25 w60 h18, &Donate
Gui About:Add, Button, +Center gGithubAbt xp+70 yp w60 h18, &GitHub
Gui About:Add, Button, +Center gKudosAbt xp+70 yp w60 h18, &Kudos
Gui About:Add, Text, x10 yp+25 w293 h90 +Center, Created By: FairTech.us - Nicholas Fair
;} END Credits Section


;{ Instructions Section
;Gui About:Font
Gui About:Font, s11 Bold Underline cAqua, Tahoma
Gui About:Add, Text, x105 y199 w95 h16 +0x200 +Center, Instructions
Gui About:Font
Gui About:Font, cWhite, Tahoma
Gui About:Add, Text, x8 yp+19 w290 h110 +Center, Right-Click the Tray Icon and select 'App Settings'`nHere you can Configure your Input/Output Device Pairs,`nPopup Notifications, Startup Behavior, and *EarTrumpet Compatibility.`n`n *EarTrumpet must be Installed and Running.`nIn EarTrumpet Settings, set the Flyout Hotkey to`nCtrl + Numpad Divide.
;} END Instructions Section


;{ Hotkeys Section
Gui About:Font
Gui About:Font, s11 Bold Underline q0 cAqua, Tahoma
Gui About:Add, Text, x116 y340 w72 h16 +0x200 +Center, Hotkeys
Gui About:Font
Gui About:Font, s8 Bold Underline q0 cAqua, Tahoma
Gui About:Add, Text, x100 yp+22 w104 h16 +0x200 +Center, Mute Media Key
Gui About:Font
Gui About:Font, cWhite, Tahoma
Gui About:Add, Text, x44 yp+18 w217 h45 +Center, Tap - Mute`nHold - Toggle Output Device`nDouble Tap and Hold - Toggle Input Device
Gui About:Font
Gui About:Font, cWhite, Tahoma
;Gui About:Font
Gui About:Font, s8 Bold Underline q0 cAqua, Tahoma
Gui About:Add, Text, x119 yp+45 w66 h16 +0x200 +Center, Tray Icon
Gui About:Font
Gui About:Font, cWhite, Tahoma
Gui About:Add, Text, x44 yp+19 w217 h72 +Center, Right Click - Context Menu/Settings`nLeft Click - Open Volume Popup/EarTrumpet`nDouble Click - Open Mixer`nMiddle Click - Toggle Speaker Mute`nScroll Up/Down - Adjust Volume Up/Down
;} END Hotkeys Section


Gui About:Show, x851 y223 w305 h594, About Fair Audio Manager
EmptyMem()
Return

DonateAbt:
{
    Run, https://www.FairTech.us/donate
    Return
}
GithubAbt:
{
    Run, https://www.github.com/Fair-Tech
    Return
}
KudosAbt:
{
    Run, https://www.github.com/Fair-Tech
    Return
}


VistaAudioAbt:
{
    Run, https://www.autohotkey.com/board/topic/21984-vista-audio-control-functions/
    Return
}
TrayIconAbt:
{
    Run, https://gist.github.com/tmplinshi/83c52a9dffe65c105803d026ca1a07da
    Return
}
VisualizerAbt:
{
    Run, https://github.com/balawi28/TrayAudioVisualizer
    Return
}
GDIPAbt:
{
    Run, https://www.autohotkey.com/boards/viewtopic.php?t=6517
    Return
}


AboutInfoEscape:
AboutInfoClose:
AbtX:
    Gui About:Cancel
    Gui About:Destroy
    EmptyMem()
    return

return
}

;}~~~~~~~~~~~END ABOUT GUI~~~~~~~~~~~~


;{~~~~~~~~~~~~~~~~~~~~~~Functions for Fair Multi-Tool Integrations~~~~~~~~~~~~~~~~~~~~~~

;{ Monitor Switcher
DisplayManagerInt:
Menu, Tray, Add, DisplayManager, DisplayManagerRun
return
DisplayManagerRun:
Run, FairDisplayManager.exe
return
;} END Monitor Switcher

;{ Hotkey Manager
HotkeyManagerInt:
Menu, Tray, Add, Hotkey Manager, HotkeyManagerRun
return
HotkeyManagerRun:
Run, FairHotkeyManager.exe
return
;} END Hotkey Manager

;}~~~~~~~~~~~~~~~~~~~~~~~~~~END Fair Multi-Tool Integrations~~~~~~~~~~~~~~~~~~~~~~~~~~



;{ Empty Memory Function  ; CALL FUNCTION: EmptyMem()
EmptyMem(PID="Fair Audio Manager"){
	;pid:=(pid="Fair Audio Manager") ? DllCall("GetCurrentProcessId") : pid
    pid := DllCall("GetCurrentProcessId")
	h:=DllCall("OpenProcess", "UInt", 0x001F0FFF, "Int", 0, "Int", pid)
	DllCall("SetProcessWorkingSetSize", "UInt", h, "Int", -1, "Int", -1)
	DllCall("CloseHandle", "Int", h)
}
;}

;All audio devices will be stored as an Endpoint object
class Endpoint {

	__New(_device) {
		this.device := _device

		this.name := GetDeviceDesc(this.device)

		VA_IMMDevice_GetId(this.device, _id)  ;id will be used as the UID for each object
		this.id := _id

		;this.iconpath := GetDeviceIcon(this.device)
		;MsgBox, % this.iconpath
	}
	IsSame(ByRef _device) {
		return this.id == _device.GetId()
	}
	GetName() {
		return this.name
	}
	GetId() {
		return this.id
	}
}

/*~~~~~~~~~~~~~NOTES~~~~~~~~~~~~~~~

