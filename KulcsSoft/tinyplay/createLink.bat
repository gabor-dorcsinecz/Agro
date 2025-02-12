@echo off
:: Set the path for the executable and the shortcut location
echo "HEEEEElll"
pause
echo "%USERPROFILE%"
pause
set "exePath=%~tinyplay.exe"  :: Path to prog.exe in the same directory as the .bat file
set "shortcutPath=%USERPROFILE%\Desktop\progShortcut.lnk"  :: Shortcut saved to the desktop
echo "%exePath%"
echo "%shortcutPath%"
pause

:: Create a VBScript file to create the shortcut
echo Set oWS = WScript.CreateObject("WScript.Shell") > create_shortcut.vbs

timeout /t 2 /nobreak
echo Set oLink = oWS.CreateShortcut("%shortcutPath%") >> create_shortcut.vbs
timeout /t 2 /nobreak
echo oLink.TargetPath = "%exePath%" >> create_shortcut.vbs
timeout /t 2 /nobreak
echo oLink.Save >> create_shortcut.vbs
timeout /t 2 /nobreak

:: Run the VBScript to create the shortcut
cscript //nologo create_shortcut.vbs

:: Clean up the temporary VBScript
del create_shortcut.vbs

echo Shortcut created successfully!
pause

