Add-Type @"
using System;
using System.Windows.Automation;

class Program
{
    public static void Doit()
    {
        string targetAppName = "ks"; // Name of the application window
        AutomationElement appElement = FindApplicationWindow(targetAppName);

        if (appElement != null)
        {
            Console.WriteLine("Found application: " + targetAppName);
            Console.WriteLine("UI Components:");
            TraverseUIComponents(appElement, 0);
        }
        else
        {
            Console.WriteLine("Application " + targetAppName + " not found.");
        }
    }

    static AutomationElement FindApplicationWindow(string appName)
    {
        return AutomationElement.RootElement.FindFirst(
            TreeScope.Children,
            new PropertyCondition(AutomationElement.NameProperty, appName));
    }

    static void TraverseUIComponents(AutomationElement element, int depth)
    {
        if (element == null) return;

        // Indentation for better readability
        string indent = new string(' ', depth * 2);

        // Display the name and control type of the UI component
        Console.WriteLine(indent + " " + element.Current.Name + element.Current.ControlType.ProgrammaticName);

        // Traverse all children of the current element
        var children = element.FindAll(TreeScope.Children, Condition.TrueCondition);
        foreach (AutomationElement child in children)
        {
            TraverseUIComponents(child, depth + 1);
        }
    }
}

"@

[Program]::Doit()