Add-Type -AssemblyName "UIAutomationClient, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35"
Add-Type -AssemblyName "UIAutomationTypes, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35"


function Get-UIComponents {
    param (
        [Parameter(Mandatory=$true)]
        [string]$ProcessName
    )

    # Load the Windows UI Automation framework
    Add-Type -AssemblyName UIAutomation

    try {
        # Find the process by name
        $process = Get-Process -Name $ProcessName -ErrorAction Stop
        
        # Create a UI Automation element for the main window
        $mainWindow = [System.Windows.Automation.AutomationElement]::FromHandle($process.MainWindowHandle)
        
        if ($mainWindow -eq $null) {
            Write-Error "Could not find main window for process: $ProcessName"
            return
        }

        # Function to recursively traverse UI elements
        function Get-ChildUIElements {
            param (
                [System.Windows.Automation.AutomationElement]$element,
                [int]$depth = 0
            )

            if ($element -eq $null) { return }

            # Basic element information
            $elementInfo = [PSCustomObject]@{
                Name = $element.Current.Name
                ControlType = $element.Current.ControlType.ProgrammaticName
                AutomationId = $element.Current.AutomationId
                ClassName = $element.Current.ClassName
                Depth = $depth
            }

            # Output the current element
            $elementInfo

            # Recursively get child elements
            $children = $element.FindAll(
                [System.Windows.Automation.TreeScope]::Children, 
                [System.Windows.Automation.Condition]::TrueCondition
            )

            foreach ($child in $children) {
                Get-ChildUIElements -element $child -depth ($depth + 1)
            }
        }

        # Start retrieving UI components
        Get-ChildUIElements -element $mainWindow
    }
    catch {
        Write-Error "An error occurred: $_"
    }
}

# Usage example:
Get-UIComponents -ProcessName "ks"