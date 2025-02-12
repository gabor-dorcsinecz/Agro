@echo off
powershell -Command "Add-Type -AssemblyName System.Windows.Forms; Add-Type -AssemblyName System.Drawing; [System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point(30, 30); Add-Type @'
using System;
using System.Runtime.InteropServices;
public class MouseSimulator {
    [DllImport(\"user32.dll\")]
    public static extern void mouse_event(int dwFlags, int dx, int dy, int cButtons, int dwExtraInfo);
    public const int MOUSEEVENTF_LEFTDOWN = 0x02;
    public const int MOUSEEVENTF_LEFTUP = 0x04;
    public static void LeftClick() {
        mouse_event(MOUSEEVENTF_LEFTDOWN | MOUSEEVENTF_LEFTUP, 0, 0, 0, 0);
    }
}
'@; 

[MouseSimulator]::LeftClick(); Start-Sleep -Milliseconds 200; [MouseSimulator]::LeftClick();"

pause
