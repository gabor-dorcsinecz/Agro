#Add-Type -Path "$PSScriptRoot\System.Windows.Forms.dll"
#Add-Type -Path "$PSScriptRoot\System.Drawing.dll"

Add-Type -AssemblyName "System.Windows.Forms"
Add-Type -AssemblyName "System.Drawing"
Add-Type -AssemblyName "UIAutomationClient"
Add-Type -AssemblyName "UIAutomationTypes"



$code = @"
using System;
using System.Text;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Collections.Generic;
using System.Reflection;
using System.Windows.Forms;
using System.Linq; 
using System.Windows.Automation;

public class Program
{
	
    // Import necessary Windows API functions
    [DllImport("user32.dll", SetLastError = true)]
    private static extern IntPtr FindWindow(string lpClassName, string lpWindowName);

    [DllImport("user32.dll", SetLastError = true)]
    private static extern IntPtr GetWindow(IntPtr hWnd, uint uCmd);

    [DllImport("user32.dll", SetLastError = true)]
    private static extern bool EnumChildWindows(IntPtr hWndParent, EnumWindowsProc lpEnumFunc, IntPtr lParam);

    [DllImport("user32.dll", SetLastError = true)]
    private static extern int GetWindowText(IntPtr hWnd, StringBuilder lpString, int nMaxCount);

    [DllImport("user32.dll", SetLastError = true)]
    private static extern int GetClassName(IntPtr hWnd, StringBuilder lpClassName, int nMaxCount);

	[DllImport("user32.dll")]
    private static extern bool EnumWindows(EnumWindowsProc lpEnumFunc, IntPtr lParam);

    [DllImport("user32.dll", SetLastError = true)]
    private static extern bool IsWindowVisible(IntPtr hWnd);

    [DllImport("user32.dll", SetLastError = true)]
    private static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint lpdwProcessId);

	[DllImport("user32.dll", SetLastError = true)]
    private static extern int GetWindowTextLength(IntPtr hWnd);

	[DllImport("user32.dll")]
    static extern IntPtr GetParent(IntPtr hWnd);
	
    private delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);

	public static void ListWindows() {
		 List<WindowInfo> windows = GetOpenWindows();
        foreach (var window in windows)
        {
            Console.WriteLine("Title:" + window.Title + " Process: " + window.ProcessName + ", PID: " + window.ProcessId);
        }
	}
	
	public static void Doit()
	{
		string processName = "ks"; 
		Process[] processes = Process.GetProcessesByName(processName);
		
		if (processes.Length == 0)
		{
			Console.WriteLine("No processes found with name: " + processName);
			return;
		}
		Console.WriteLine("Found: " + processes.Length + " Processes named: " + processName );

		Process[] mainWindowProcess = processes.Where(p => p.MainWindowHandle != IntPtr.Zero).ToArray();
		IntPtr mainWindowHandle = mainWindowProcess[0].MainWindowHandle;
		
		if (mainWindowHandle == IntPtr.Zero)
		{
			Console.WriteLine("Application " + processName + " has no main window.");
			return;
		}
		
		Console.WriteLine("Found application: " + processName);
		
		PrintGridData(mainWindowHandle);

		/*
		Console.WriteLine("Enumerating UI components...");

		// Dictionary to track parent-child relationships
		Dictionary<IntPtr, List<IntPtr>> childWindows = new Dictionary<IntPtr, List<IntPtr>>();

		EnumChildWindows(mainWindowHandle, (hWnd, lParam) =>
		{
			// Get parent handle
			IntPtr parentHandle = GetParent(hWnd);
			
			// If parent is not tracked, add it
			if (!childWindows.ContainsKey(parentHandle))
			{
				childWindows[parentHandle] = new List<IntPtr>();
			}
		
			// Add this window to its parent's children list
			childWindows[parentHandle].Add(hWnd);
			
			return true;
		}, IntPtr.Zero);

		// Start printing from the main window
		PrintWindowHierarchy(mainWindowHandle, 0, childWindows);
		*/
	}

	private static void PrintWindowHierarchy(IntPtr parentHandle, int depth, Dictionary<IntPtr, List<IntPtr>> childWindows)
	{
			if (!childWindows.ContainsKey(parentHandle))
				return;
			
			foreach (IntPtr hWnd in childWindows[parentHandle])
			{
				string indent = new string(' ', depth * 2);
				
				string windowText = GetWindowTitle(hWnd);
				string className = GetWindowClassName(hWnd);
				
				Console.WriteLine(indent + "Handle: " + hWnd + " Title: " + windowText +" , Class: " + className);
				//GetParentClassnames(hWnd);
				
				// Recursively print children
				PrintWindowHierarchy(hWnd, depth + 1, childWindows);
			}
	}

    private static string GetWindowTitle(IntPtr hWnd)
    {
        const int maxCount = 256;
        StringBuilder sb = new StringBuilder(maxCount);
        GetWindowText(hWnd, sb, maxCount);
        return sb.ToString();
    }

    private static string GetWindowClassName(IntPtr hWnd)
    {
        const int maxCount = 256;
        StringBuilder sb = new StringBuilder(maxCount);
        
		GetClassName(hWnd, sb, maxCount);
        string text = sb.ToString();
		//if (text == "WindowsForms10.Window.8.app.0.3a48e15_r9_ad1") 
		//	text = "KulcsComponent";
		
		return text;
    }
	
	
	static void PrintControlProperties(IntPtr hWnd, string className)
    {
        // Get the control from the handle
        Control control = Control.FromHandle(hWnd);

        if (control == null || control.GetType().Name != className)
        {
            Console.WriteLine("No control of class '{className}' found for the given handle.");
            return;
        }

        Console.WriteLine("Properties of " + className + " Control:");
        Type controlType = control.GetType();
        PropertyInfo[] properties = controlType.GetProperties();

        foreach (PropertyInfo property in properties)
        {
            try
            {
                var value = property.GetValue(control, null); // Get property value
                Console.WriteLine(property.Name + ":" + value);
            }
            catch (Exception ex)
            {
                Console.WriteLine(property.Name + ": Unable to retrieve value : " + ex.Message);
            }
        }
    }
	
	static void PrintGridData (IntPtr mainWindowHandle) {
		/*
		AutomationElement rootElement = AutomationElement.FromHandle(mainWindowHandle);
		String[] labels = FindAllButtons(rootElement);
		foreach(var label in labels) 
		{
			Console.WriteLine(label);
		}			
		*/
		
		/*
		var dataGrid = FindDataGrid(mainWindowHandle);
        if (dataGrid != null)
        {
            Console.WriteLine("DataGrid found!");
            var data = ExtractTableData(dataGrid);
            foreach (var row in data)
            {
               Console.WriteLine(string.Join(", ", row));
            }
        }
        else
        {
            Console.WriteLine("DataGrid not found.");
        }
		*/
		
		
		AutomationElement rootElement = AutomationElement.FromHandle(mainWindowHandle);
		ExtractTableData(rootElement);

/*		
		AutomationElementCollection tables = rootElement.FindAll(TreeScope.Descendants, new PropertyCondition(AutomationElement.ControlTypeProperty, ControlType.Table));
		foreach(AutomationElement table in tables) {
			Console.WriteLine("Table found. Name: " + table.Current.Name);
			 //PrintChildrenRecursively(rootElement, 0);
		}
	*/	
		
	}
	
	
	
	
	static void ExtractTableData(AutomationElement rootElement)
	{
		/*
		AutomationElementCollection windows = rootElement.FindAll(TreeScope.Descendants, new PropertyCondition(AutomationElement.ControlTypeProperty, ControlType.Window));
		foreach(AutomationElement ae in windows) 
		{
			Console.WriteLine("Window: " + ae.Current.Name);
		}
		
		AutomationElement bejovoSzamlakWindow = windows
            .Cast<AutomationElement>()
            .FirstOrDefault(e => e.Current.Name == "Bejövő számlák listája (309)");

		
        //AutomationElement bejovoSzamlakWindow = FindFirstElementWithProperty(windows, AutomationElement.NameProperty, "Bejövő számlák listája (309)");
		Console.WriteLine("Found window: " + bejovoSzamlakWindow.Current.Name);
		*/
		
		try 
		{
		
		AutomationElementCollection tables = rootElement.FindAll(TreeScope.Descendants, new PropertyCondition(AutomationElement.ControlTypeProperty, ControlType.Table));
		
		foreach (AutomationElement table in tables) 
		{
			Console.WriteLine("Found Table: " + table.Current.Name);
			// Search for the element with the specified name
			AutomationElement adatPanel = table.FindFirst(TreeScope.Children, new PropertyCondition(AutomationElement.NameProperty, "Adat panel"));
			Console.WriteLine("Found Adat Panel: " + adatPanel.Current.Name);

			AutomationElementCollection rows = adatPanel.FindAll(TreeScope.Children, new PropertyCondition(AutomationElement.ControlTypeProperty, ControlType.ListItem));
			
			foreach(AutomationElement row in rows) 
			{
				Console.WriteLine("Found Row: " + row.Current.Name);
				AutomationElementCollection cells = row.FindAll(TreeScope.Children, new PropertyCondition(AutomationElement.ControlTypeProperty, ControlType.Custom));

				foreach (AutomationElement cell in cells)
				{
					// Get the Name property, which usually contains the text
					string text = cell.Current.Name;
					Console.WriteLine("Text 1 : " + text);
					
				   object patternObj;
				   if (cell.TryGetCurrentPattern(ValuePattern.Pattern, out patternObj))
					{
						var valuePattern = (ValuePattern)patternObj;
						Console.WriteLine("Text 2: " + valuePattern.Current.Value);
					}

					// Try TextPattern
					if (cell.TryGetCurrentPattern(TextPattern.Pattern, out patternObj))
					{
						var textPattern = (TextPattern)patternObj;
						Console.WriteLine("Text 2: " + textPattern.DocumentRange.GetText(-1)); // Text from TextPattern
					}
				}
			}
		}
		} catch (Exception ex)
            {
				Console.WriteLine("+++++++++++++++++++++");
				Console.WriteLine(ex.ToString());
            }


		/*
		AutomationElementCollection rows = table.FindAll(TreeScope.Children, new PropertyCondition(AutomationElement.ControlTypeProperty, ControlType.Custom)); // or Row
		foreach (AutomationElement row in rows)
		{
			Console.WriteLine("Row: " + row.Current.Name);
			AutomationElementCollection cells = row.FindAll(TreeScope.Children, new PropertyCondition(AutomationElement.ControlTypeProperty, ControlType.Text)); // or DataItem
			foreach (AutomationElement cell in cells)
			{
				Console.WriteLine(cell.Current.Name); // Print cell data
			}
		}
		*/

	}
	
	
	static AutomationElement FindFirstElementWithProperty(AutomationElementCollection elements, AutomationProperty property, object value)
    {
        foreach (AutomationElement element in elements)
        {
            object currentValue = element.GetCurrentPropertyValue(property);

            if (currentValue != null && currentValue.Equals(value))
            {
                return element; // Return the first matching element
            }
        }

        return null; // No match found
    }
	
	 static void PrintChildrenRecursively(AutomationElement parentElement, int level)
    {
        // Find all children of the current element
        AutomationElementCollection children = parentElement.FindAll(TreeScope.Children, Condition.TrueCondition);

        foreach (AutomationElement child in children)
        {
            // Get the control type and name
            string controlType = child.Current.ControlType.ProgrammaticName;
            string name = child.Current.Name;

            // Indent output based on recursion level
            string indent = new string(' ', level * 2);

            Console.WriteLine(indent + " - ControlType: " + controlType + " , Name: " + name);

            // Recurse into the child element
            PrintChildrenRecursively(child, level + 1);
        }
    }
	
/*	
		static AutomationElement FindDataGrid(IntPtr mainWindowHandle)
    {
		Console.WriteLine("FindDataGrid");
		AutomationElement rootElement = AutomationElement.FromHandle(mainWindowHandle);

        // Search for a DataGrid control in the subtree
        //return rootElement.FindFirst(TreeScope.Descendants, new PropertyCondition(AutomationElement.ControlTypeProperty, ControlType.DataGrid));
		
		return rootElement.FindFirst(TreeScope.Descendants, new PropertyCondition(AutomationElement.ControlTypeProperty, ControlType.Table));
    }

	
	 static string[][] ExtractDataFromDataGrid(AutomationElement dataGrid)
    {
        var rows = dataGrid.FindAll(TreeScope.Children, new PropertyCondition(AutomationElement.ControlTypeProperty, ControlType.DataItem));
        string[][] data = new string[rows.Count][];

        for (int i = 0; i < rows.Count; i++)
        {
            var row = rows[i];
            var cells = row.FindAll(TreeScope.Children, new PropertyCondition(AutomationElement.ControlTypeProperty, ControlType.Text));
            data[i] = new string[cells.Count];

            for (int j = 0; j < cells.Count; j++)
            {
                data[i][j] = cells[j].Current.Name; // Get the text content of the cell
            }
        }

        return data;
    }

 static string[][] ExtractDataFromTable(AutomationElement table)
    {
        var rows = table.FindAll(TreeScope.Children, new PropertyCondition(AutomationElement.ControlTypeProperty, ControlType.DataItem));
        string[][] data = new string[rows.Count][];

        for (int i = 0; i < rows.Count; i++)
        {
            var row = rows[i];
            var cells = row.FindAll(TreeScope.Children, new PropertyCondition(AutomationElement.ControlTypeProperty, ControlType.Text));
            data[i] = new string[cells.Count];

            for (int j = 0; j < cells.Count; j++)
            {
                data[i][j] = cells[j].Current.Name; // Get the text content of the cell
            }
        }

        return data;
    }
*/

 static string[] FindAllButtons(AutomationElement rootElement)
    {
        if (rootElement == null)
            return new string[0];

        // Find all buttons in the UI tree (descendants of the root element)
        var buttonElements = rootElement.FindAll(TreeScope.Descendants, new PropertyCondition(AutomationElement.ControlTypeProperty, ControlType.Button));

        string[] buttonLabels = new string[buttonElements.Count];

        // Extract the Name property (label) of each button
        for (int i = 0; i < buttonElements.Count; i++)
        {
            buttonLabels[i] = buttonElements[i].Current.Name;
        }

        return buttonLabels;
    }
	

	/*
	static void GetParentClassnames(IntPtr hwnd) 
	{
		 List<IntPtr> parentHandles = GetParentHierarchy(hwnd);
        foreach (var handle in parentHandles)
        {
            string parentClassName = GetClassNameX(handle);
            Console.WriteLine("Handle: " + handle + ", parentClass: " + parentClassName);
        }
    }
	
	static string GetClassNameX(IntPtr hwnd)
    {
        StringBuilder className = new StringBuilder(256); // Class name buffer
        int length = GetClassName(hwnd, className, className.Capacity);
        return length > 0 ? className.ToString() : "Unknown";
    }

	static List<IntPtr> GetParentHierarchy(IntPtr hwnd)
    {
        List<IntPtr> parentHandles = new List<IntPtr>();
        IntPtr currentHandle = hwnd;

        while (true)
        {
            IntPtr parentHandle = GetParent(currentHandle);
            if (parentHandle == IntPtr.Zero) break; // No more parents
            parentHandles.Add(parentHandle);
            currentHandle = parentHandle;
        }

        return parentHandles;
    }
	*/
	
	//============ For listing running apps ========
	
	 private static List<WindowInfo> GetOpenWindows()
    {
        List<WindowInfo> windows = new List<WindowInfo>();

        // Callback for each window
        EnumWindows((hWnd, lParam) =>
        {
            if (IsWindowVisible(hWnd))
            {
                int length = GetWindowTextLength(hWnd);
                if (length > 0)
                {
                    StringBuilder builder = new StringBuilder(length + 1);
                    GetWindowText(hWnd, builder, builder.Capacity);

                    uint processId;
                    GetWindowThreadProcessId(hWnd, out processId);

                    string processName = GetProcessName((int)processId);

                    windows.Add(new WindowInfo
                    {
                        Title = builder.ToString(),
                        ProcessId = (int)processId,
                        ProcessName = processName
                    });
                }
            }
            return true; // Continue enumeration
        }, IntPtr.Zero);

        return windows;
    }

    private static string GetProcessName(int processId)
    {
        try
        {
            Process process = Process.GetProcessById(processId);
            return process.ProcessName;
        }
        catch
        {
            return "Unknown";
        }
    }
	
	private class WindowInfo
    {
        public string Title { get; set; }
        public int ProcessId { get; set; }
        public string ProcessName { get; set; }
    }

}

"@

Add-Type -TypeDefinition $code -ReferencedAssemblies @(
    "System.Windows.Forms",
    "System.Drawing",
	"UIAutomationClient",
	"UIAutomationTypes"
)

#Call the main function here
[Program]::DoIt()
#[Program]::ListWindows()
