#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.2
 Author:         Chris Mosher

 Script Function:
	In a running FTM, export the current tree as GEDCOM.

#ce ----------------------------------------------------------------------------

#include <MsgBoxConstants.au3>
#include <Date.au3>
#include <IE.au3>



Func Now()
	Local $t = _Date_Time_SystemTimeToDateTimeStr(_Date_Time_GetSystemTime(), 1)
	$t = StringReplace($t, "/", "-")
	$t = StringReplace($t, " ", "-")
	$t = StringReplace($t, ":", "-")
	Return $t
EndFunc




; case insensitive match on substring of window title
Opt("WinTitleMatchMode", -2) ;1=start, 2=subStr, 3=exact, 4=advanced, -1 to -4=Nocase
Opt("SendKeyDelay", 31)

Local $winFtm = WinWait("Family Tree Maker", "", 17)
If $winFtm = 0 Then
	MsgBox($MB_ICONWARNING, "AutoIT", "Cannot find FTM running.")
	Exit
EndIf

Local $nameTree = WinGetTitle($winFtm)
If Not @error = 0 Then
	MsgBox($MB_ICONWARNING, "AutoIT", "Cannot get name of current tree.")
	Exit
EndIf

$nameTree = StringRegExpReplace($nameTree, "(.*) - Family Tree .*", "$1")



If WinActivate($winFtm) = 0 Then
	MsgBox($MB_ICONWARNING, "AutoIT", "Cannot activate FTM window.")
	Exit
EndIf
WinWaitActive($winFtm)

Sleep(83)
Send("!f") ; menu: File
Send("e") ; Export



Local $winExport = WinWaitActive("Export", "Media", 17)
If $winExport = 0 Then
	MsgBox($MB_ICONWARNING, "AutoIT", "Cannot open Export window.")
	Exit
EndIf

Sleep(83)
Send("!o") ; Output format
Send("g") ; GEDCOM
Send("{ENTER}")



Local $winGedcom = WinWaitActive("Export to GEDCOM", "Destination", 17)
If $winGedcom = 0 Then
	MsgBox($MB_ICONWARNING, "AutoIT", "Cannot open Export GEDCOM window.")
	Exit
EndIf

Sleep(83)
Send("{ENTER}")



Local $winSave = WinWaitActive("Export to", "Save", 17)
If $winSave = 0 Then
	MsgBox($MB_ICONWARNING, "AutoIT", "Cannot open Export-to window.")
	Exit
EndIf

Local $now = Now()
Local $filenameBase = $nameTree & "_" & $now
Local $filenameFtm = $filenameBase & ".ftm.ged"
;~ Local $filenameAnc = $filenameBase & ".anc.ged"

; Use this (i.e., paste from the clipboard) as the argument to update_from_anc_ftm.sh
If ClipPut($filenameBase) = 0 Then
    MsgBox($MB_ICONWARNING, "AutoIT", "Could not copy filename to clipboard: " & $filenameBase)
EndIf

Sleep(83)
; in the filename text box, delete the current name
Send("{BACKSPACE}")
; and then type in the new name (and directory)
; Example: "\\VBOXSVR\shared\Mosher_2018-01-18-18-27-23.ftm.ged"
Send("\\VBOXSVR\shared\" & $filenameFtm)
Send("{ENTER}")



Local $winStatus = WinWaitActive("Export Status", "OK", 17)
If $winStatus = 0 Then
	MsgBox($MB_ICONWARNING, "AutoIT", "Cannot find Export-Status window.")
	Exit
EndIf
Local $status = WinGetText($winStatus)
Sleep(83)
Send("{ENTER}")

If Not StringRegExp(StringLower($status), ".*success.*") Then
	MsgBox($MB_ICONWARNING, "AutoIT", "Export was not successful.")
	Exit
EndIf



;~ $ie = _IECreate()
;~ _IENavigate($ie, "https://www.ancestry.com/")
;~ Sleep(2345)

;~ _IELoadWait($ie)
;~ _IELinkClickByText($ie, "Trees")
;~ Sleep(2345)
;~ _IELinkClickByText($ie, $nameTree)
;~ Sleep(3456)
;~ _IELoadWait($ie)
;~ _IELinkClickByText($ie, "Tree Settings")
;~ Sleep(3456)

;~ _IELoadWait($ie)
;~ Local $buttonExport = _IEGetObjById($ie, "exportTreeLink")
;~ Local $i = 0
;~ While Not @error = 0
;~ 	Sleep(1234)
;~ 	$buttonExport = _IEGetObjById($ie, "exportTreeLink")
;~ 	$i = $i+1
;~ 	If $i > 43 Then
;~ 		MsgBox($MB_ICONWARNING, "AutoIT", "Cannot find Export button.")
;~ 		Exit
;~ 	EndIf
;~ WEnd

;~ _IEAction($buttonExport, "scrollintoview")
;~ _IEAction($buttonExport, "click")

;~ _IELoadWait($ie)



;~ MsgBox($MB_ICONINFORMATION, "AutoIT", "Wait for it, then click DOWNLOAD GEDCOM and choose Save As...")



;~ Local $winSaveAs = WinWaitActive("Save As", "", 127)
;~ If $winSaveAs = 0 Then
;~ 	MsgBox($MB_ICONWARNING, "AutoIT", "Cannot find Save-As dialog box.")
;~ 	Exit
;~ EndIf
;~ Sleep(83)
;~ Send("{BACKSPACE}")
;~ Send("\\VBOXSVR\shared\" & $filenameAnc)
;~ Send("{ENTER}")
