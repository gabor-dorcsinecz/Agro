# Get all running processes
$processes = Get-Process

# Filter processes that have a main window title (GUI applications)
$guiProcesses = $processes | Where-Object { $_.MainWindowHandle -ne 0 }

# List the names of GUI applications
$guiProcesses | Select-Object -Property Name | Sort-Object Name | Format-Table -AutoSize


