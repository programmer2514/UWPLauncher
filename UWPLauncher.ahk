#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

; Purge old app lists
DeleteOlderThan("%A_WorkingDir%\config\*", 7, 1)

; If there are command line arguments, parse them, otherwise, run GUI
If (A_Args[1])
{
    ; Set AppListResult
    AppListResult := A_Args[1]

    ; See whether to make app fullscreen
    If ((A_Args[1] = "-f") || (A_Args[1] = "--fullscreen") || (A_Args[1] = "/F"))
    {
        IsFullscreen := 1
        AppListResult := A_Args[2]
        
    } Else If ((A_Args[1] = "-n") || (A_Args[1] = "--name") || (A_Args[1] = "/N")) {
    
        ; Load whole app list file into AppsList
        FileRead, AppsList, config\apps-list.txt
        
        ; Make sure files exist
        If (ErrorLevel = 1) {
            Stdout(" ", false)
            Stdout(" ", false)
            Stdout(" ", false)
            Stdout("Error: App lists are missing or outdated.`nPlease run ""UWPLauncher --update-lists"" to update them.", false)
            Send, {Control Down}C{Control Up}
            Goto, MainGuiClose
            Return
        }
        
        ; Read AppsList line by line
        Loop, Parse, AppsList, `n`r
        {
            If (InStr(A_LoopField, "!") && !InStr(A_LoopField, "\") && InStr(SubStr(A_LoopField, 1, 62), A_Args[2]))
                AppListResult := SubStr(A_LoopField, 63)
        }
        
    } Else If ((A_Args[1] = "-l") || (A_Args[1] = "--link") || (A_Args[1] = "/L")) {
        
        IsLink := 1
        AppListResult := A_Args[2]
        
    } Else If ((A_Args[1] = "-u") || (A_Args[1] = "--update-lists") || (A_Args[1] = "/U")) {
        
        Stdout(" ", false)
        Stdout(" ", false)
        Stdout(" ", false)
        Stdout("Updating app lists...", false)
        
        ; Create a new list of installed applications
        RunWait, powershell "get-StartApps | Ft -autosize | out-string -width 4096" > %A_WorkingDir%\config\apps-list.txt,, Hide
        RunWait, powershell "Get-AppxPackage" > %A_WorkingDir%\config\apps-data.txt,, Hide
        
        Stdout("App lists updated successfully.", false)
        Send, {Control Down}C{Control Up}
        Goto, MainGuiClose
        Return
        
    } Else If ((A_Args[1] = "-d") || (A_Args[1] = "--download-psexec") || (A_Args[1] = "/D")) {
        
        Stdout(" ", false)
        Stdout(" ", false)
        Stdout(" ", false)
        Stdout("Downloading PSExec from https://live.sysinternals.com/...", false)
        
        ; Download PSExec
        UrlDownloadToFile, https://live.sysinternals.com/PSExec.exe, %A_WorkingDir%\bin\psexec.exe
        
        If (ErrorLevel)
            Stdout("PSExec download failed.", false)
        Else
            Stdout("PSExec downloaded successfully.", false)
        
        Send, {Control Down}C{Control Up}
        Goto, MainGuiClose
        Return
    } Else If ((A_Args[1] = "-c") || (A_Args[1] = "--clean-data") || (A_Args[1] = "/C")) {
        
        Stdout(" ", false)
        Stdout(" ", false)
        Stdout(" ", false)
        Stdout("Cleaning app data...", false)
    
        ; Clean up files
        FileRemoveDir, %A_WorkingDir%\ico, 1
        FileCreateDir, %A_WorkingDir%\ico
        FileRemoveDir, %A_WorkingDir%\config, 1
        FileCreateDir, %A_WorkingDir%\config
        FileDelete, %A_WorkingDir%\bin\psexec.exe
        
        Stdout("App data removed successfully.", false)
        Send, {Control Down}C{Control Up}
        Goto, MainGuiClose
        Return
        
    } Else If ((A_Args[1] = "-h") || (A_Args[1] = "--help") || (A_Args[1] = "/?")) {
    
        Stdout(" ", false)
        Stdout(" ", false)
        Stdout(" ", false)
        Stdout("Executes or creates a link to any Universal Windows Program.`n`nuwplauncher [option] [-n] [appid]`nUWPLAUNCHER [OPTION] [/N] [APPID]`n`nOptions:`n  /C, -c, --clean-data         Remove psexec.exe, app lists, and converted .ico files, standalone`n  /D, -d, --download-psexec    Download psexec.exe, overwrites current copy, standalone`n  /F, -f, --fullscreen         Launch the specified application in fullscreen mode`n  /G, -g, --gui                Start the application in GUI mode, standalone`n  /?, -h, --help               Shows this help text, standalone`n  /L, -l, --link               Create a link to the specified application instead of launching it`n  /N, -n, --name               Specifies that AppID should be a name, if omitted, uses unique ID`n  /U, -u, --update-lists       Updates the lists necessary to perform operations, standalone`n`nIf the name switch is omitted, AppID should be the unique identifier of the app to launch`n  Ex:  uwplauncher Microsoft.WindowsCalculator_8wekyb3d8bbwe!App`n`nIf the name switch is specified, AppID should be the literal name of the app to launch`n  Ex:  uwplauncher --name Calculator`n`nMore examples:`n  Launch Bing Weather fullscreen using the name switch:`n    uwplauncher -f -n Weather`n`n  Add 3D Viewer to the current user's desktop omitting the name switch:`n    uwplauncher -l Microsoft.Microsoft3DViewer_8wekyb3d8bbwe!Microsoft.Microsoft3DViewer", false)
        Send, {Control Down}C{Control Up}
        Goto, MainGuiClose
        Return
    } Else If ((A_Args[1] = "-g") || (A_Args[1] = "--gui") || (A_Args[1] = "/G")) {
    
        Goto BeginUI
        
    }
    
    If ((A_Args[2] = "-n") || (A_Args[2] = "--name") || (A_Args[1] = "/N"))
    {
        ; Load whole app list file into AppsList
        FileRead, AppsList, config\apps-list.txt
        
        ; Make sure files exist
        If (ErrorLevel = 1) {
            Stdout(" ", false)
            Stdout(" ", false)
            Stdout(" ", false)
            Stdout("Error: App lists are missing or outdated.`nPlease run ""UWPLauncher --update-lists"" to update them.", false)
            Send, {Control Down}C{Control Up}
            Goto, MainGuiClose
            Return
        }
        
        ; Read AppsList line by line
        Loop, Parse, AppsList, `n`r
        {
            If (InStr(A_LoopField, "!") && !InStr(A_LoopField, "\") && InStr(SubStr(A_LoopField, 1, 62), A_Args[3]))
                AppListResult := SubStr(A_LoopField, 63)
        }
        IsName := 1
    }
    
    ; Start application
    If (IsFullscreen)
    {
        GoSub, StartAppFullscreen
    } Else If (IsLink) {
        
        ; Check if running as admin
        if (!A_IsAdmin)
        {
            Stdout(" ", false)
            Stdout(" ", false)
            Stdout(" ", false)
            Stdout("Error: The program must be run as Administrator to execute this command", false)
            Send, {Control Down}C{Control Up}
            Goto, MainGuiClose
            Return
        }
    
        ; Load whole app data file into AppsData
        FileRead, AppsData, config\apps-data.txt
    
        ; Load whole app list file into AppsList
        FileRead, AppsList, config\apps-list.txt
        
        ; Make sure files exist
        If (ErrorLevel = 1) {
            Stdout(" ", false)
            Stdout(" ", false)
            Stdout(" ", false)
            Stdout("Error: App lists are missing or outdated.`nPlease run ""UWPLauncher --update-lists"" to update them.", false)
            Send, {Control Down}C{Control Up}
            Goto, MainGuiClose
            Return
        }
    
        ; Define ListOfAppIDs
        ListOfAppIDs =
        
        ; Read AppsData line by line
        Loop, Parse, AppsData, `n`r
        {
            If (InStr(A_LoopField, "PackageFullName   : "))
                ListOfAppIDs .= SubStr(A_LoopField, 21) "|"
        }
        
        ; Set AppListResult to "Name        AppID"
        Loop, Parse, AppsList, `n`r
        {
            If (InStr(A_LoopField, "!") && !InStr(A_LoopField, "\") && InStr(A_LoopField, AppListResult))
                AppListResult := A_LoopField
        }
        
        Stdout(" ", false)
        Stdout(" ", false)
        Stdout(" ", false)
        Stdout("Creating app shortcut...", false)
        Stdout(" ", false)
        
        ; Create shortcut
        GoSub, CreateAppShortcut
        
        Stdout(" ", false)
        Stdout(" ", false)
        Stdout("Shortcut created successfully.", false)
        
        Sleep, 100
        
        Send, {Control Down}C{Control Up}
        
    } Else {
        GoSub, StartApp
    }
    
} else {

    ; Start GUI
    Goto, BeginUI
}

; Finish program
Goto, MainGuiClose
Return

BeginUI:

    ; Elevate script
    GoSub, ElevateScript

    ; Download PSExec
    If (!FileExist("bin\psexec.exe"))
    {
        ; Ask user
        MsgBox, 0x24, File missing, This program requires PSExec.exe by SysInternals`nto retrieve windows app icons.`n`nThe license terms for this application can be viewed at https://docs.microsoft.com/en-us/sysinternals/license-terms.`n`nWould you like to download this file now?
        IfMsgBox Yes
        {
            ; Notify user
            MsgBox, 0x34, Warning, This file may be flagged as unsafe by certain antiviruses.`n`nThis is because it runs with the priveleges required to read and modify the source code of Windows applications.`n`nContinue download?
            IfMsgBox Yes
            {
                UrlDownloadToFile, https://live.sysinternals.com/PSExec.exe, %A_WorkingDir%\bin\psexec.exe
                If (ErrorLevel)
                    MsgBox, 0x10, Download failed, Error!`nDownload failed, skipping..., 3
                Else
                    MsgBox, 0x40, Success, File downloaded successfully.
            }
        }
    }

    ; Display splash screen using a ActiveX GUI
    var = %A_WorkingDir%\img\splash-screen.gif
    Gui, Splash: +ToolWindow +border -Caption 
    Gui, Splash: Margin, 1,1
    Gui, Splash: Color, c00b0f0
    Gui, Splash: Add, ActiveX, w607 h455 vWB, shell explorer
    wb.Navigate("about:blank")
    html := "<html><body style='background-color: transparent' style='overflow:hidden' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'><img src='" var "' border=0 padding=0></body></html>"
    wb.document.write(html)
    wb.refresh()
    Gui, Splash: show, AutoSize Center
    
    ; Create a new list of installed applications
    RunWait, powershell "get-StartApps | Ft -autosize | out-string -width 4096" > %A_WorkingDir%\config\apps-list.txt,, Hide
    RunWait, powershell "Get-AppxPackage" > %A_WorkingDir%\config\apps-data.txt,, Hide
    
    ; Update splash screen
    var = %A_WorkingDir%\img\splash-screen-2.gif
    html := "<html><body style='background-color: transparent' style='overflow:hidden' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'><img src='" var "' border=0 padding=0></body></html>"
    wb.document.write(html)
    wb.refresh()
    Sleep, 100
    
    ; Load whole app list file into AppsList
    FileRead, AppsList, config\apps-list.txt
    
    ; Load whole app data file into AppsData
    FileRead, AppsData, config\apps-data.txt
    
    ; Define ListOfWords
    ListOfWords =
    
    ; Read AppsList line by line
    Loop, Parse, AppsList, `n`r
    {
        ; Add app info to ListOfWords variable
        If (InStr(A_LoopField, "!") && !InStr(A_LoopField, "\"))
        {
            var := "!"
            string := A_LoopField
            StringReplace, string, string, %var%, %var%, UseErrorLevel
            If (ErrorLevel = 1)
                ListOfWords .= A_LoopField "|"
        }
    }
    
    ; Define ListOfAppIDs
    ListOfAppIDs =
    
    ; Read AppsData line by line
    Loop, Parse, AppsData, `n`r
    {
        If (InStr(A_LoopField, "PackageFullName   : "))
            ListOfAppIDs .= SubStr(A_LoopField, 21) "|"
    }
    
    ; Define listbox variable to be filtered
    ListOfFilteredWords := ListOfWords
    
    ; Update splash screen
    var = %A_WorkingDir%\img\splash-screen-3.gif
    html := "<html><body style='background-color: transparent' style='overflow:hidden' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'><img src='" var "' border=0 padding=0></body></html>"
    wb.document.write(html)
    wb.refresh()
    Sleep, 100
    
    ; Initialize GUI
    Gui, Main: New,, UWPLauncher
    Gui, Main: -AlwaysOnTop
    
    ; Add menu bar
    Menu, FileMenu, Add, &Start App`tEnter, StartApp
    Menu, FileMenu, Add, &Start App (Fullscreen)`tShift+Enter, StartAppFullscreen
    Menu, FileMenu, Add
    Menu, FileMenu, Add, &Add to Desktop`tCtrl+=, CreateAppShortcut
    Menu, FileMenu, Add
    Menu, FileMenu, Add, E&xit`tCtrl+Q, MainGuiClose
    Menu, EditMenu, Add, &Copy to Clipboard`tCtrl+C, CopyAppToClipboard
    Menu, EditMenu, Add, &Clean up app data`tCtrl+D, CleanUpData
    Menu, EditMenu, Add, &Reload`tCtrl+R, BeginUI
    Menu, HelpMenu, Add, &Bug Report/Feature Request..., SubmitBugReport
    Menu, HelpMenu, Add, Project &Wiki..., GotoWiki
    Menu, HelpMenu, Add
    Menu, HelpMenu, Add, &About, AboutMenu
    Menu, ParentMenu, Add, &File, :FileMenu
    Menu, ParentMenu, Add, &Edit, :EditMenu
    Menu, ParentMenu, Add, &Help, :HelpMenu
    Gui, Main: Menu, ParentMenu
    
    ; Display logo
    Gui, Main: Margin, 10, 5
    Gui, Main: Font, s18 italic c00b0f0
    Gui, Main: Add, Text, x28 y28, Launcher
    Gui, Main: Font, s25 norm bold
    Gui, Main: Add, Text, x10 y2 BackGroundTrans, UWP
    
    ; Display By...
    Gui, Main: Font, s14 norm
    Gui, Main: Add, Text, x554 y16, By Benjamin Pryor
    
    ; Reset font attributes
    Gui, Main: Font
    
    ; Create search bar
    Gui, Main: Add, Text, x10, Search Apps:
    Gui, Main: Add, Edit, w632 x78 y59 hwndAppSearch vSearchTerm gSearch
    
    ; Switch to monospace font
    Gui, Main: Font, s10, Lucida Console
    
    ; Create listbox
    Gui, Main: Add, ListBox, w700 r30 x10 hwndAppChoice vAppListResult Sort +HScroll, %ListOfFilteredWords%
    
    ; Add action buttons
    Gui, Main: Font
    Gui, Main: Add, Button, x9 y498 gStartApp, Start App
    Gui, Main: Add, Button, x71 y498 gStartAppFullscreen, Start App (Fullscreen)
    Gui, Main: Add, Button, x190 y498 gButtonCopyApp, Copy Launch Command to Clipboard
    Gui, Main: Add, Button, x380 y498 gCreateAppShortcut, Add to Desktop
    Gui, Main: Add, Button, x472 y498 gCleanUpData, Clean up app data
    Gui, Main: Add, Button, x631 y498 w80 gMainGuiClose, Exit
    
    ; Update splash screen
    var = %A_WorkingDir%\img\splash-screen-4.gif
    html := "<html><body style='background-color: transparent' style='overflow:hidden' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'><img src='" var "' border=0 padding=0></body></html>"
    wb.document.write(html)
    wb.refresh()
    Sleep, 1000
    
    ; Close splash screen
    Gui, Splash: Destroy
    
    ; Create main GUI
    Gui, Main: Show
    
Return

StartApp:
    
    ; Update GUI variables
    Gui, Submit, NoHide
    
    ; Trim whitespace off end of string
    AppListResult := RTrim(AppListResult, " ")
    
    ; Get family name of selected app
    Loop, Parse, AppListResult, %A_Space%
    {
        AppID := A_LoopField
    }
    
    ; Execute app
    Run, "C:\Windows\explorer.exe" shell:AppsFolder\%AppID%
    
Return

StartAppFullscreen:
    
    ; Call StartApp
    Gosub, StartApp

    ;Make sure app is running
    WinWait, %AppName%,, 1
    
    ; Make app fullscreen
    Send {LWin down}{Shift down}{Enter}{Shift up}{LWin up}
    
Return

CopyAppToClipboard:
    
    ; Update GUI variables
    Gui, Submit, NoHide
    
    ; Trim whitespace off end of string
    AppListResult := RTrim(AppListResult, " ")
    
    ; Get family name of selected app
    Loop, Parse, AppListResult, %A_Space%
    {
        AppID := A_LoopField
    }
    
    ; Copy launch command to clipboard
    Temp = "C:\Windows\explorer.exe" shell:AppsFolder\%AppID%
    Clipboard := Temp
    
Return

ButtonCopyApp:
    
    ; Call actual routine
    GoSub, CopyAppToClipboard
    
    ; Notify user
    MsgBox, 0x40, Success!, Command copied to clipboard
    
Return

CreateAppShortcut:

    ; Get the app icon (png)
    GoSub, GetAppIcon
    
    ; Update GUI variables
    Gui, Submit, NoHide
    
    ; Trim whitespace off end of string
    AppListResult := RTrim(AppListResult, " ")
    
    ; Get family name of selected app
    Loop, Parse, AppListResult, %A_Space%
    {
        AppID := A_LoopField
    }
    
    ; Get name of selected app
    AppName := RTrim(AppListResult, AppID)
    AppName := RTrim(AppName, " ")

    ; Check for necessary files
    If (!FileExist("bin\psexec.exe"))
    {
        MsgBox, 0x30, Missing Binaries, PSExec could not be found!`n`nApp shortcut will be created without an icon.`nPlease restart the application to download necessary binaries.`nYou can also run "UWPLauncher --get-psexec" to download it.
    } else {
        ; Generate .ico file for app shortcut
        RunWait, "%A_WorkingDir%\bin\psexec.exe" /accepteula -sid "%A_WorkingDir%\bin\convert.exe" "%FullIconPath%" "%A_WorkingDir%\ico\%AppName%.ico",, Hide
    }
    
    ; Check for actual icon
    If (FullIconPath = DefaultIconPath)
        MsgBox, 0x30, No Icon Found, No icon found!`nPlaceholder icon will be generated.
    
    FileCreateShortcut, explorer.exe, %A_Desktop%\%AppName%.lnk,, shell:AppsFolder\%AppID%,, %A_WorkingDir%\ico\%AppName%.ico
    
Return

GetAppIcon:
    
    ; Update GUI variables
    Gui, Submit, NoHide
    
    ; Reset FullIconPath
    FullIconPath = %A_WorkingDir%\img\no-icon.ico
    DefaultIconPath = %A_WorkingDir%\img\no-icon.ico
    
    ; Trim whitespace off end of string
    AppListResult := RTrim(AppListResult, " ")
    
    ; Get family name of selected app
    Loop, Parse, AppListResult, %A_Space%
    {
        AppID := A_LoopField
    }
    
    ; Get name of selected app
    Loop, Parse, AppID, _
    {
        If (A_Index = 1)
            AppName := A_LoopField
    }
    
    ; Get specific ID of selected app
    Loop, Parse, ListOfAppIDs, |
    {
        If (InStr(A_LoopField, AppName))
            SpecificAppID := A_LoopField
    }
    
    ; Read root path of app from registry
    RegRead, RootPath, HKEY_CLASSES_ROOT\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\Repository\Packages\%SpecificAppID%, PackageRootFolder
    
    ; Only run if root directory exists
    If (RootPath && !ErrorLevel)
    {
        ; Set the working directory
        SetWorkingDir %RootPath%\Assets
        
        ; Search for logo
        Loop, Files, *Logo.scale-???.png, R
        {
            If (!InStr(A_LoopFileFullPath, "Wide"))
                IconPath := A_LoopFileFullPath
        }
        
        ; Search for AppList
        Loop, Files, *AppList.scale-???.png, R
        {
            If ((!InStr(A_LoopFileFullPath, "Wide")) && (!InStr(A_LoopFileFullPath, "contrast")))
                IconPath := A_LoopFileFullPath
        }
        
        ; Search for Icon
        Loop, Files, *Icon.scale-???.png, R
        {
            If (!InStr(A_LoopFileFullPath, "Wide"))
                IconPath := A_LoopFileFullPath
        }
        
        ; Only run if Icon exists
        If (IconPath && !ErrorLevel)
            FullIconPath = %RootPath%\Assets\%IconPath%
    }
    
    ; Reset working directory
    SetWorkingDir %A_ScriptDir%
    
Return

CleanUpData:

    ; Make sure
    MsgBox, 0x21, Clean up app data, Are you sure?`n`nThis will remove all icons for`ndesktop shortcuts created by this app
    
    IfMsgBox OK
    {
        ; Clean up files
        FileRemoveDir, %A_WorkingDir%\ico, 1
        FileCreateDir, %A_WorkingDir%\ico
        FileRemoveDir, %A_WorkingDir%\config, 1
        FileCreateDir, %A_WorkingDir%\config
        FileDelete, %A_WorkingDir%\bin\psexec.exe
        
        MsgBox, 0x24, Exit App?, Files cleaned up successfully.`nExit app?
        
        ; Exit app
        IfMsgBox Yes
            Goto, MainGuiClose

        ; Reload UI
        IfMsgBox No
            Goto, BeginUI
    }
    
Return

ElevateScript:

    ; If the script is not elevated, relaunch as administrator and kill current instance:
    full_command_line := DllCall("GetCommandLine", "str")
    
    if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)"))
    {
        try ; leads to having the script re-launching itself as administrator
        {
            if A_IsCompiled
                Run *RunAs "%A_ScriptFullPath%" /restart
            else
                Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
        }
        ExitApp
    }

Return

Search:

    ; Update GUI variables
    Gui, Submit, NoHide
    
    ; Prevent listbox redraw during search operation
    GuiControl, -Redraw, MyListBox
    
    ; Empty listbox
    ListOfFilteredWords = 
    
    ; Parse list of all apps
    Loop, Parse, ListOfWords, |
    {
    
        ; If it matches the search term, add it back to the listbox
        If (InStr(SubStr(A_LoopField, 1, 62), SearchTerm))
        {
            ListOfFilteredWords .= A_LoopField
            ListOfFilteredWords .= "|"
        }
    }
    
    ; Update the listbox
    GuiControl,, AppListResult, |%ListOfFilteredWords%
    
    ; Enable listbox redraw
    GuiControl, +Redraw, MyListBox
    
    ; Scroll to top of listbox
    ControlSend,, {Home}, ahk_id %AppChoice%
    
Return

AboutMenu:
    
    ; Disable the main window
    Gui, Main: +Disabled
    
    ; Creat about window and set attributes
    Gui, About: New,, About
    Gui, About: -MaximizeBox -MinimizeBox
    Gui, About: Margin, 20, 20
    Gui, About: Color, ffffff
    
    ; Add about text
    Gui, About: Add, Link, 0x6, UWPLauncher v1.0`n    - By Benjamin Pryor`n`nWritten in <a href="https://www.autohotkey.com">AutoHotKey</a>.`nSource code can be found on <a href="https://github.com/calclover2514/UWPLauncher">Github</a>.`n`nUses ImageMagick v7.0.10-29 for icon conversion.`nThe ImageMagick Development Team, 2020. ImageMagick, Available at: <a href="https://imagemagick.org/">https://imagemagick.org</a>.`n`nUses PSExec by Sysinternals for icon retreival.`nLicensing information for this tool can be viewed at <a href="https://docs.microsoft.com/en-us/sysinternals/license-terms/">https://docs.microsoft.com/en-us/sysinternals/license-terms</a>.`n`nPublished under the <a href="https://www.autohotkey.com/docs/license.htm">GNU General Public License</a> Version 2.
    
    ; Remove GUI margin
    Gui, About: Margin, 0, 0
    
    ; Draw OK button
    Gui, About: Add, Button, x470 y210 w80 h22 gAboutGuiClose, OK
    
    ; Draw 4 progress bars around button b/c AHK can't draw rectangles and progress bars block button execution
    Gui, About: Add, Progress, x0 y200 w566 h10 Backgroundf0f0f0
    Gui, About: Add, Progress, x0 y210 w470 h22 Backgroundf0f0f0
    Gui, About: Add, Progress, x550 y210 w16 h22 Backgroundf0f0f0
    Gui, About: Add, Progress, x0 y232 w566 h10 Backgroundf0f0f0
    
    ; Show about window
    Gui, About: Show
    
Return

SubmitBugReport:
    Run, https://github.com/calclover2514/UWPLauncher/issues/new
Return

GotoWiki:
    Run, https://github.com/calclover2514/UWPLauncher/wiki
Return

AboutGuiClose:
    
    ; Enable main window
    Gui, Main: -Disabled
    
    ; Destroy about window
    Gui, About: Destroy
    
Return

MainGuiClose:

    ; Make sure the script exits when the GUI closes
    ExitApp
    
Return


;   /¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
;__/   Taken from https://forum.cockos.com/showthread.php?t=180661   \____________________________________________________________________________________________________

DeleteOlderThan(path, olderThan, recursive := 0)
{
    loop, % path, 0, % recursive
    {
        today := A_Now
        EnvSub, today, % A_LoopFileTimeModified, days
        if (today > olderThan)
        {
            FileRecycle, % A_LoopFileLongPath
        }
    }
}

;   /¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
;__/   Taken from https://www.autohotkey.com/boards/viewtopic.php?t=56877   \______________________________________________________________________________________________

Stdout(output:="", sciteCheck := true){	;output to console	-	sciteCheck reduces Stdout/Stdin performance,so where performance is necessary disable it accordingly
	Global ___console___
	If (sciteCheck && ProcessExist("SciTE.exe") && GetScriptParentProcess() = "SciTE.exe"){	;if script parent is scite,output to scite console & return
		FileAppend, %output%`n, *
		Return
	}																												;CONOUT$ is a special file windows uses to expose attached console output
	( output ? ( !___console___? (DllCall("AttachConsole", "int", -1) || DllCall("AllocConsole")) & (___console___:= true) : "" ) & FileAppend(output . "`n","CONOUT$") : DllCall("FreeConsole") & (___console___:= false) & StdExit() )
}

Stdin(output:="", sciteCheck := true){	;output to console & wait for input & return input
	Global ___console___
	If (sciteCheck && ProcessExist("SciTE.exe") && GetScriptParentProcess() = "SciTE.exe"){	;if script parent is scite,output to scite console & return
		FileAppend, %output%`n, *
		Return
	}
	( output ? ( !___console___? (DllCall("AttachConsole", "int", -1) || DllCall("AllocConsole")) & (___console___:= true) : "" ) & FileAppend(output . "`n","CONOUT$") & (Stdin := FileReadLine("CONIN$",1)) : DllCall("FreeConsole") & (___console___:= false) & StdExit() )
	Return Stdin
}

StdExit(){
	If GetScriptParentProcess() = "cmd.exe"		;couldn't get this: 'DllCall("GenerateConsoleCtrlEvent", CTRL_C_EVENT, 0)' to work so...
		ControlSend, , {Enter}, % "ahk_pid " . GetParentProcess(GetCurrentProcess())
}

FileAppend(str, file){
	FileAppend, %str%, %file%
}

FileReadLine(file,lineNum){
	FileReadLine, retVal, %file%, %lineNum%
	return retVal
}

ProcessExist(procName){
	Process, Exist, % procName
	Return ErrorLevel
}

GetScriptParentProcess(){
	return GetProcessName(GetParentProcess(GetCurrentProcess()))
}

GetParentProcess(PID)
{
	static function := DllCall("GetProcAddress", "ptr", DllCall("GetModuleHandle", "str", "kernel32.dll", "ptr"), "astr", "Process32Next" (A_IsUnicode ? "W" : ""), "ptr")
	if !(h := DllCall("CreateToolhelp32Snapshot", "uint", 2, "uint", 0))
		return
	VarSetCapacity(pEntry, sz := (A_PtrSize = 8 ? 48 : 36)+(A_IsUnicode ? 520 : 260))
	Numput(sz, pEntry, 0, "uint")
	DllCall("Process32First" (A_IsUnicode ? "W" : ""), "ptr", h, "ptr", &pEntry)
	loop
	{
		if (pid = NumGet(pEntry, 8, "uint") || !DllCall(function, "ptr", h, "ptr", &pEntry))
			break
	}
	DllCall("CloseHandle", "ptr", h)
	return Numget(pEntry, 16+2*A_PtrSize, "uint")
}

GetProcessName(PID)
{
	static function := DllCall("GetProcAddress", "ptr", DllCall("GetModuleHandle", "str", "kernel32.dll", "ptr"), "astr", "Process32Next" (A_IsUnicode ? "W" : ""), "ptr")
	if !(h := DllCall("CreateToolhelp32Snapshot", "uint", 2, "uint", 0))
		return
	VarSetCapacity(pEntry, sz := (A_PtrSize = 8 ? 48 : 36)+260*(A_IsUnicode ? 2 : 1))
	Numput(sz, pEntry, 0, "uint")
	DllCall("Process32First" (A_IsUnicode ? "W" : ""), "ptr", h, "ptr", &pEntry)
	loop
	{
		if (pid = NumGet(pEntry, 8, "uint") || !DllCall(function, "ptr", h, "ptr", &pEntry))
			break
	}
	DllCall("CloseHandle", "ptr", h)
	return StrGet(&pEntry+28+2*A_PtrSize, A_IsUnicode ? "utf-16" : "utf-8")
}

GetCurrentProcess()
{
	return DllCall("GetCurrentProcessId")
}
