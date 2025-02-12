@echo off
echo Hello, World!

xcopy "%~dp0tinyplay" "C:\Program Files\tinyplay" /e /i /h /y

#start "" "%~dp0tinyplay.exe"

pause

