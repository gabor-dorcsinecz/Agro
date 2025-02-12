function Get-WindowControls {
    param (
        [Parameter(Mandatory=$true)]
        [string]$ProcessName
    )

    $signature = @'
[DllImport("user32.dll")]
public static extern bool EnumChildWindows(IntPtr hWndParent, EnumWindowProc lpEnumFunc, IntPtr lParam);

[DllImport("user32.dll", CharSet=CharSet.Auto)]
public static extern int GetClassName(IntPtr hWnd, System.Text.StringBuilder lpClassName, int nMaxCount);

[DllImport("user32.dll", CharSet=CharSet.Auto)]
public static extern int GetWindowText(IntPtr hWnd, System.Text.StringBuilder lpString, int nMaxCount);

public delegate bool EnumWindowProc(IntPtr hWnd, IntPtr lParam);
'@

    echo "STARTING"

    $user32 = Add-Type -MemberDefinition $signature -Name "User32" -Namespace "Win32" -PassThru

    $results = @()

    $enumFunc = {
        param($hWnd, $lParam)
        
        $className = New-Object System.Text.StringBuilder(256)
        $windowText = New-Object System.Text.StringBuilder(256)
        
        $user32::GetClassName($hWnd, $className, $className.Capacity) | Out-Null
        $user32::GetWindowText($hWnd, $windowText, $windowText.Capacity) | Out-Null
        
        $componentInfo = [PSCustomObject]@{
            Handle = $hWnd
            ClassName = $className.ToString()
            WindowText = $windowText.ToString()
        }
        
        $results.Add($componentInfo) | Out-Null
        
        # Print component names to console
        if (-not [string]::IsNullOrWhiteSpace($componentInfo.WindowText)) {
            Write-Host "Component Name: $($componentInfo.WindowText)"
        }
        if (-not [string]::IsNullOrWhiteSpace($componentInfo.ClassName)) {
            Write-Host "Component Class: $($componentInfo.ClassName)"
        }
        
        return $true
    }

    $process = Get-Process -Name $ProcessName -ErrorAction Stop
	Write-Output "Process: $process"
    $mainWindowHandle = $process.MainWindowHandle

    $user32::EnumChildWindows($mainWindowHandle, $enumFunc, [IntPtr]::Zero) | Out-Null

    return $results
}

# Usage example:
Get-WindowControls -ProcessName "ks"