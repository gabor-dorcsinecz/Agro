Add-Type -AssemblyName "System.Windows.Forms"

#[System.Windows.Forms.MessageBox]::Show("Hello, world!")

Add-Type @"
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Text;
using System.Windows.Forms;

class Program
{
    [DllImport("user32.dll", SetLastError = true)]
    private static extern IntPtr FindWindow(string lpClassName, string lpWindowName);

    [DllImport("user32.dll", SetLastError = true)]
    private static extern bool EnumChildWindows(IntPtr hWndParent, EnumWindowsProc lpEnumFunc, IntPtr lParam);

    [DllImport("user32.dll", SetLastError = true)]
    private static extern int GetWindowText(IntPtr hWnd, StringBuilder lpString, int nMaxCount);

    [DllImport("user32.dll", SetLastError = true)]
    private static extern int GetClassName(IntPtr hWnd, StringBuilder lpClassName, int nMaxCount);

    private delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);

    public static void doIt()
    {
		
		string processName = "ks"; 
		Process[] processes = Process.GetProcessesByName(processName);
		
		if (processes.Length == 0)
		{
			Console.WriteLine("No processes found with name: " + processName);
			return;
		}

		IntPtr mainWindowHandle = processes[0].MainWindowHandle;
		
		if (mainWindowHandle == IntPtr.Zero)
		{
			Console.WriteLine("Application " + processName + " has no main window.");
			return;
		}
		
		Console.WriteLine("Found application: " + processName);
		Console.WriteLine("Enumerating UI components...");

        List<string> childComponents = GetChildComponents(mainWindowHandle);

        foreach (var component in childComponents)
        {
            Console.WriteLine(component);
        }
    }

    private static List<string> GetChildComponents(IntPtr parentHandle)
    {
        List<string> components = new List<string>();

        EnumChildWindows(parentHandle, (hWnd, lParam) =>
        {
            StringBuilder windowText = new StringBuilder(256);
            StringBuilder className = new StringBuilder(256);

            GetWindowText(hWnd, windowText, windowText.Capacity);
            GetClassName(hWnd, className, className.Capacity);

            components.Add("ClassName: " + className + " , Text: " + windowText);

            return true; // Continue enumeration
        }, IntPtr.Zero);

        return components;
    }
}
"@

[Program]::DoIt()
