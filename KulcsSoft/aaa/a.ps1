Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Open the application
#Start-Process "C:\Path\To\Application.exe"
#Start-Sleep -Seconds 2

# Simulate a mouse click
[System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point(100, 200)
[System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
Start-Sleep -Seconds 20