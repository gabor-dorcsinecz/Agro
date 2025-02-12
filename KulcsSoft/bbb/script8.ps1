# Load required assemblies
Add-Type -AssemblyName System.Windows.Forms

# Import necessary DllImports
Add-Type @"
using System;
using System.Text;
using System.Diagnostics;
using System.Runtime.InteropServices;

public class WinAPI {
    [DllImport("user32.dll", SetLastError = true)]
    public static extern IntPtr FindWindow(string lpClassName, string lpWindowName);

    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool EnumChildWindows(IntPtr hWndParent, EnumWindowsProc lpEnumFunc, IntPtr lParam);

    [DllImport("user32.dll", SetLastError = true)]
    public static extern int GetWindowText(IntPtr hWnd, StringBuilder lpString, int nMaxCount);

    [DllImport("user32.dll", SetLastError = true)]
    public static extern int GetClassName(IntPtr hWnd, StringBuilder lpClassName, int nMaxCount);

    public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);
}
"@

# Define a function to list all components of a given process name
function Get-ComponentsFromProcess {
    param(
        [string]$processName
    )

    # Find the process by name
    $process = Get-Process -Name $processName -ErrorAction Stop

    if ($process) {
        Write-Host "Process found: $processName (ID: $($process.Id))"

        $mainWindowHandle = $process.MainWindowHandle
        if ($mainWindowHandle -eq [IntPtr]::Zero) {
            Write-Host "No main window handle found for process $processName."
            return
        }

        Write-Host "Enumerating child windows of the main window handle..."

        # Create a collection to hold component details
        $components = New-Object System.Collections.Generic.List[Object]

        # Enumerate child windows
        $callback = {
            param (
                [IntPtr]$hWnd,
                [IntPtr]$lParam
            )

            $windowText = New-Object Text.StringBuilder 256
            $className = New-Object Text.StringBuilder 256

            [WinAPI]::GetWindowText($hWnd, $windowText, $windowText.Capacity)
            [WinAPI]::GetClassName($hWnd, $className, $className.Capacity)

            $components.Add([PSCustomObject]@{
                ClassName = $className.ToString()
                Text      = $windowText.ToString()
            }) | Out-Null

            return $true # Continue enumeration
        }

        [WinAPI]::EnumChildWindows($mainWindowHandle, $callback, [IntPtr]::Zero)

        Write-Host "Components found:"
        $components | ForEach-Object {
            Write-Host "ClassName: $($_.ClassName), Text: $($_.Text)"
        }
    } else {
        Write-Host "Process '$processName' not found."
    }
}

# Call the function with the target process name
Get-ComponentsFromProcess -processName "ks"
