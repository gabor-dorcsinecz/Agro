@echo off
powershell -Command "Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point(30, 30); [System.Windows.Forms.SendKeys]::SendWait('{ENTER}')"

Install-Module -Name UIAutomation -Scope CurrentUser

pause


