# Move the mouse to position (30,30) and simulate a double-click

# Add the necessary type to call user32.dll for mouse events
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class Mouse {
    [DllImport("user32.dll")]
    public static extern bool SetCursorPos(int X, int Y);
    [DllImport("user32.dll")]
    public static extern void mouse_event(int dwFlags, int dx, int dy, int dwData, int dwExtraInfo);
    public const int MOUSEEVENTF_LEFTDOWN = 0x02;
    public const int MOUSEEVENTF_LEFTUP = 0x04;
}
"@

# Move the mouse to coordinates (30,30)
[Mouse]::SetCursorPos(30, 30)

# Simulate a left button click (down + up)
[Mouse]::mouse_event(0x02, 0, 0, 0, 0) # Left button down
[Mouse]::mouse_event(0x04, 0, 0, 0, 0) # Left button up

# Pause briefly to simulate a natural double-click
Start-Sleep -Milliseconds 200

# Simulate the second click (down + up)
[Mouse]::mouse_event(0x02, 0, 0, 0, 0) # Left button down
[Mouse]::mouse_event(0x04, 0, 0, 0, 0) # Left button up
