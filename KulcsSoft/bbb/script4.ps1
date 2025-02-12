Add-Type @"
    using System;
    using System.Runtime.InteropServices;
    using System.Text;

    public class WindowEnumerator {
        [DllImport("user32.dll")]
        public static extern bool EnumChildWindows(IntPtr hWndParent, EnumWindowsProc lpEnumFunc, IntPtr lParam);

        [DllImport("user32.dll", CharSet=CharSet.Auto)]
        public static extern int GetClassName(IntPtr hWnd, StringBuilder lpClassName, int nMaxCount);

        [DllImport("user32.dll", CharSet=CharSet.Auto)]
        public static extern int GetWindowText(IntPtr hWnd, StringBuilder lpString, int nMaxCount);

        public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);

        public static void ListChildWindows(IntPtr parentHandle) {
            EnumChildWindows(parentHandle, ChildWindowCallback, IntPtr.Zero);
        }

        private static bool ChildWindowCallback(IntPtr hWnd, IntPtr lParam) {
            StringBuilder className = new StringBuilder(256);
            StringBuilder windowText = new StringBuilder(256);

            GetClassName(hWnd, className, className.Capacity);
            GetWindowText(hWnd, windowText, windowText.Capacity);

            string classNameStr = className.ToString();
            string windowTextStr = windowText.ToString();

            if (!string.IsNullOrWhiteSpace(classNameStr) || 
                !string.IsNullOrWhiteSpace(windowTextStr)) {
                Console.WriteLine("Handle: " + hWnd);
                Console.WriteLine("Class Name: " + classNameStr);
                Console.WriteLine("Window Text: " + windowTextStr);
                Console.WriteLine("---");
            }

            return true;
        }
    }
"@

function Get-WindowControls {
    param (
        [Parameter(Mandatory=$true)]
        [string]$ProcessName
    )

    $process = Get-Process -Name $ProcessName -ErrorAction Stop
    
    # Explicitly convert MainWindowHandle to IntPtr
    $mainWindowHandle = [IntPtr]$process.MainWindowHandle

    [WindowEnumerator]::ListChildWindows($mainWindowHandle)
}

# Usage
Get-WindowControls -ProcessName "ks"