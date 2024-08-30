#Requires AutoHotkey v2.0
#SingleInstance

; Taken from here: https://www.autohotkey.com/boards/viewtopic.php?style=19&f=6&t=83241
; Maybe set Windows options for scrolling to "Multiple lines" but set the setting of how many lines to "1" or "2"

;#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
SetMouseDelay -1
SendMode "Input" ; Recommended for new scripts due to its superior speed and reliability.
;SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

Sensitivity := 20   ; how far it takes before the scroll happens
HideCursor := True  ; decides if the mouse cursor is hidden on scrolling

DidScroll := False 
IsLongMousePress := False

X1 := 0
Y1 := 0

$*MButton Up::{
	if (IsLongMousePress){
		MouseMove X1, Y1, 0    ;Set back the mouse possition
	}
    if (HideCursor) SystemCursor("Show")
    Send "{MButton up}"      ;Saves the Middel Click function
    if (!DidScroll && IsLongMousePress) {
        MiddelMoudeCopyPaste()
    }
    SetTimer MBScroll, 0 ;Ends the Scrolling (if started)
}

$*MButton::{
	global DidScroll, IsLongMousePress, X1, Y1
    DidScroll := False 
    IsLongMousePress := False
    MouseGetPos &X1, &Y1
    if (HideCursor) SystemCursor("Hide")
    waited := KeyWait("MButton", "U T0.250")
    If waited==0 {
        IsLongMousePress := True
		SetTimer MBScroll, 10
	}
    Else {
        state := GetKeyState("Mbutton")
        if (state)
            SendInput "{Mbutton down}"
        Else
            SendInput "{Mbutton}"
        }
}


MBScroll(){
	global DidScroll
    MouseGetPos &X2, &Y2
    MouseMove X1, Y1, 0    ;Sest back the mouse possition
    MouseDifferenceY := Abs(Y1 - Y2)
    MouseDifferenceX := Abs(X1 - X2)
    Difference := ""
    Direction := ""
    if (MouseDifferenceY >= MouseDifferenceX)
	{
        Direction := Y2 > Y1 ? "Down" : "Up"
        Difference := MouseDifferenceY
    } else {
        Direction := X2 > X1 ? "Right" : "Left"
        Difference := MouseDifferenceX
    }

    if (Difference >= 4 * Sensitivity)
    {
        state := GetKeyState("Mbutton")
        if (state)
            return
        Click "Wheel" . Direction ;SendInput "{Blind}{Wheel%Direction%}"
        DidScroll := True
        
    }  else if (Difference >= 3 * Sensitivity)
    {
        state := GetKeyState("Mbutton")
        if (state)
            return
        Click "Wheel" . Direction ;SendInput "{Blind}{Wheel%Direction%}"
        DidScroll := True
        Sleep 10
        
    }  else if (Difference >= 2 * Sensitivity)
    {
        state := GetKeyState("Mbutton")
        if (state)
            return
        Click "Wheel" . Direction ;SendInput "{Blind}{Wheel%Direction%}"
        DidScroll := True
        Sleep 30
        
    } else if (Difference >= Sensitivity)
    {
        state := GetKeyState("Mbutton")
        if (state)
            return
        Click "Wheel" . Direction ;SendInput "{Blind}{Wheel%Direction%}"
        DidScroll := True
        Sleep 50
        
    }
}

MiddelMoudeCopyPaste()
{
    ClipboardOld := ClipboardAll
    Clipboard := "" ; Must start off blank for detection to work.
    Send "^c"
    waited := ClipWait(1, 1)
    if waited==0  ; ClipWait timed out.
    {
        return
    }
    KeyWait "mbutton"
    Click
    Sleep 100
    Send "^v"
    Sleep 100
    Clipboard :=  ; Must start off blank for detection to work.
    
    Clipboard := ClipboardOld  ; Restore previous contents of clipboard.
    waited := ClipWait(1, 1)
    if waited==0  ; ClipWait timed out.
    {
        return
    }
return
}
		

; This is the section that handles the hiding of the cursor
; ===================================
SystemCursor(cmd)  ; cmd = "Show|Hide|Toggle|Reload"
{
    static visible := true, c := Map()
    static sys_cursors := [32512, 32513, 32514, 32515, 32516, 32642
                         , 32643, 32644, 32645, 32646, 32648, 32649, 32650]
    if (cmd = "Reload" or !c.Count)  ; Reload when requested or at first call.
    {
        for i, id in sys_cursors
        {
            h_cursor  := DllCall("LoadCursor", "Ptr", 0, "Ptr", id)
            h_default := DllCall("CopyImage", "Ptr", h_cursor, "UInt", 2
                , "Int", 0, "Int", 0, "UInt", 0)
            h_blank   := DllCall("CreateCursor", "Ptr", 0, "Int", 0, "Int", 0
                , "Int", 32, "Int", 32
                , "Ptr", Buffer(32*4, 0xFF)
                , "Ptr", Buffer(32*4, 0))
            c[id] := {default: h_default, blank: h_blank}
        }
    }
    switch cmd
    {
    case "Show": visible := true
    case "Hide": visible := false
    case "Toggle": visible := !visible
    default: return
    }
    for id, handles in c
    {
        h_cursor := DllCall("CopyImage"
            , "Ptr", visible ? handles.default : handles.blank
            , "UInt", 2, "Int", 0, "Int", 0, "UInt", 0)
        DllCall("SetSystemCursor", "Ptr", h_cursor, "UInt", id)
    }
}
