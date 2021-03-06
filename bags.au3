; Batch Add Game Steam (BAGS) is an automation script to activate multiple keys on Steam
;
; It is derivative work of Steam Bulk Key Activator (SBKA) by Shedo Surashu
; https://web.archive.org/web/20140214183818/http://coffeecone.com/sbka
; Steam altered their UI flow which invalidated SBKA's flow which spurred
; the creation of BAGS - which attempts to handle the new Add Game flow
; while introducing a new UI flow of its own.
; Therefore, the following in compliance with SBKA's GPLv3 license
; and in the spirit of free software is also released under GPLv3
; Enjoy!

#include <Constants.au3>
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>

; Set up simple event based GUI with 2 labels, 1 edit box and 1 button
Opt("GUIOnEventMode", 1)
Global $bags = GUICreate("BAGS", 260, 600)
GUISetOnEvent($GUI_EVENT_CLOSE, "OnClose")
GUICtrlCreateLabel("Add Keys (one per line)", 30, 10)
Global $editbox = GUICtrlCreateEdit("", 30, 30, 200, 400, $ES_WANTRETURN)
GUICtrlCreateLabel("Note: Steam won't let you redeem" & @CRLF & "more than 25 keys a day.", 30, 440)
; Create and hook up button
Local $buttonMsg = "Batch" & @CRLF & "Add" & @CRLF & "Game" & @CRLF & "Steam"
Local $button = GUICtrlCreateButton($buttonMsg, 80, 480, 100, 100, $BS_MULTILINE)
GUICtrlSetOnEvent($button, OnExecute)
GUISetState(@SW_SHOW)

; Keep it running
While True
   Sleep(100)
WEnd

; Attempts to redeem each line in the edit field as a key for a new game (or product)
Func OnExecute()
   Local $textBlock = GUICtrlRead($editbox)
   Local $keyArray = StringSplit($textBlock, @CRLF)
   Local $count = 0
   For $i = 1 to $keyArray[0]
	  If ($keyArray[$i] <> "") Then
		 Redeem($keyArray[$i])
		 $count = $count + 1
	  EndIf
   Next
   If ($count > 0) Then
	  GUICtrlSetData($editBox, "Completed (" & $count & ")")
   Else
	  GUICtrlSetData($editBox, "(Psst! Type your keys here)")
   EndIf
   WinActivate($bags);
EndFunc

; Exits the GUI
Func OnClose()
   Exit
EndFunc

; Meaty function that emulates user's action to redeem a steam key
Func Redeem($key)
   ; Check if the Steam window is available using the title and class name
   ; Class name is USurface_ followed by a number, so we wildcard it
   Local $steamwin = "[TITLE:Steam; REGEXPCLASS:USurface\_\d*]"
   Local $prodactwin = "[TITLE:Product Activation; REGEXPCLASS:USurface\_\d*]"
   Local $workingwin = "[TITLE:Steam - Working; REGEXPCLASS:USurface\_\d*]"
   Local $midX = @DesktopWidth / 2
   Local $midY = @DesktopHeight / 2
   If (WinExists($steamwin)) Then
	  WinActivate($steamwin)
	  If (WinActive($steamwin)) Then
		 ; Steam doesn't have traditional buttons so we can't access any controls directly
		 ; We will need to emulate mouse clicks on specific x,y positions
		 ; To facilitate this we will maximize the window to ensure our top-left is 0,0
		 ; and to ensure the top menu bar is completely exposed to click on
		 WinSetState($steamwin, "", @SW_MAXIMIZE)
		 ClickAndWait(150, 20)				; Click Games Menu and wait briefly for it
		 ClickAndWait(150, 64, 0)			; Click Activate Product, Skip waiting
		 WinWait($prodactwin, "", 5)		; Explicitly wait for Product Activation window
		 If WinExists($prodactwin) Then
			; Window appears in the center of the desktop, use this as point of reference
			; We will be clicking the second button at the bottom of the window, So
			; calculate its offset from the center for re-usage
			Local $buttonX = $midX + 100
			Local $buttonY = $midY + 150
			ClickAndWait($buttonX, $buttonY)	; Click the Next Button and wait for next page
			ClickAndWait($buttonX, $buttonY)	; Click on I Agree, wait for next page
			Send($key)							; Write the key in auto-focused field
			Sleep(200)							; Pause briefly for visual feedback
			ClickAndWait($buttonX, $buttonY)	; Click on Next to submit form
			; Wait for the Working Window to come and go
			WinWait($workingwin, "", 5)
			If WinExists($workingwin) Then
			   WinWaitClose($workingwin)
			EndIf
			; Whether the key succeeded or failed, we will click the 3rd button as a possible final Step
			; We will wait a little longer here as it is possible for Steam to stutter so we'll
			; give the system a second or two to catch up
			ClickAndWait($buttonX + 50, $buttonY)
			; So, this should close the window if the key was redeemed or the key was invalid.
			; However, if the key was already redeemed on the account, we enter a new flow
			; of trying to download the game. So check if the window still exists
			If WinExists($prodactwin) Then
			   ; We will not download the game. Unfortunately, it seems the window cannot be closed
			   ; Proceed thru the flow and cancel out
			   ClickAndWait($buttonX, $buttonY)			; Click The Next Button, wait for next page
			   ClickAndWait($buttonX + 50, $buttonY)	; Click the Cancel Button to bail out
			EndIf
			; Finished process
		 EndIf ; (end product win exist)
	  EndIf ; (end steam win active)
   EndIf
EndFunc

; Helper function to click a specific point and wait a specific delay
; Delay is 200 by default and is ignored when set to 0
Func ClickAndWait($x, $y, $wait=200)
   MouseClick("left", $x, $y)
   If ($wait > 0) Then
	  Sleep($wait)
   EndIf
EndFunc
