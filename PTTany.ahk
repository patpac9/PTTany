Menu, Tray, NoStandard ; remove standard Menu items
Menu, Tray, Add , &Change, Change ;add a item named Change that goes to the Change label
Menu, Tray, Add , E&xit, ExitSub ;add a item named Exit that goes to the ButtonExit label
goto, Control
Return

Control:

SetBatchLines -1
SplashTextOn,,, Suche Audio Quellen...

ControlTypes = VOLUME

ComponentTypes = MASTER,MICROPHONE

Gui, Add, Listview, w400 h400 gMyListView, Mixer|Component Type|Control Type|Setting
LV_ModifyCol(4, "Integer")
SetFormat, Float, 0.2 

Loop
{
    CurrMixer := A_Index
    SoundGet, Setting,,, %CurrMixer%
    if ErrorLevel = Can't Open Specified Mixer
        break


    Loop, parse, ComponentTypes, `,
    {
        CurrComponent := A_LoopField
        SoundGet, Setting, %CurrComponent%,, %CurrMixer%
        if ErrorLevel = Mixer Doesn't Support This Component Type
            continue  ; Start a new iteration to move on to the next component type.
        Loop  ; For each instance of this component type, query its control types.
        {
            CurrInstance := A_Index
            SoundGet, Setting, %CurrComponent%:%CurrInstance%,, %CurrMixer%
            if ErrorLevel in Mixer Doesn't Have That Many of That Component Type,Invalid Control Type or Component Type
                break  ; No more instances of this component type.
            Loop, parse, ControlTypes, `,
            {
                CurrControl := A_LoopField
                SoundGet, Setting, %CurrComponent%:%CurrInstance%, %CurrControl%,%CurrMixer%
                if ErrorLevel in Component Doesn't Support This Control Type,Invalid Control Type or Component Type
                    continue
                if ErrorLevel
                    Setting := ErrorLevel
                ComponentString := CurrComponent
                if CurrInstance > 1
                    ComponentString = %ComponentString%:%CurrInstance%
                LV_Add("", CurrMixer, ComponentString, CurrControl, Setting)
            }
        }
    }
}

Loop % LV_GetCount("Col")  ; Auto-size each column to fit its contents.
    LV_ModifyCol(A_Index, "AutoHdr")

SplashTextOff
Gui, Add, Button, Default, Okay
Gui, Add, Text, vtext12, PPT Key
Gui, Add, Hotkey, vMainbutton, NumpadSub
Gui, Show
return

MyListView:
if ("ListView_ItemFocus(gMyListView, Item, Selected)")
{
    LV_GetText(RowText, A_EventInfo)  ; Get the text from the row's first field.
    LV_GetText(RowText1, A_EventInfo, 2)
    LV_GetText(RowText2, A_EventInfo, 4)
    ToolTip Sie verwenden nun "%RowText1%" von Mixer "%RowText%"
    SetTimer, RemoveToolTip, -3000
}
return

RemoveToolTip:
ToolTip
return

GuiClose:
ExitApp

ButtonOkay:
if (RowText2 < 20){
Vollaut := 100
} else {
Vollaut := RowText2
}
If (!RowText){
MsgBox, Mixer muss mit Doppelclick ausgewaelt werden.
} else {
Gui, Submit
Gui, Destroy
OnExit, ExitSub
If (!Mainbutton){
MsgBox, Es wurde kein Hotkey ausgewaelt.
goto, Control
} else {
SoundSet, -100, %RowText1%, VOLUME,%RowText%
TrayTip, PTTany, Mixer mit ID "%RowText%" ist nun Stummgeschalten!`nPush to Talk ist aktiv!`nPush "%Mainbutton%" to Talk, 2
goto, hotk
}
}
return

hotk:
Hotkey, %Mainbutton%, speak
return

speak:

SoundSet, +%Vollaut%, %RowText1%, VOLUME,%RowText%
KeyWait, %Mainbutton%
SoundSet, -100, %RowText1%, VOLUME,%RowText%

return

Change:
SoundSet, +%Vollaut%, %RowText1%, VOLUME,%RowText%
TrayTip, PTTany, Mixer ist wieder auf %Vollaut% Volume, 2
Mainbutton = "nope"
goto, Control
return

ExitSub:
SoundSet, +%Vollaut%, %RowText1%, VOLUME,%RowText%
TrayTip, PTTany, Mixer ist wieder auf %Vollaut% Volume, 2
ExitApp 