# Install-Module -Name UIAutomation -Scope CurrentUser

# Import the UIAutomation module
Import-Module UIAutomation

# Get the target window by its title
$window = Get-UIAWindow -n "ks" # Replace "Notepad" with the window title of your target application

if ($window -ne $null) {
    # Define a recursive function to traverse all child elements
    function Traverse-UIElements($element, $depth = 0) {
        # Print the current element with indentation based on depth
        $indent = " " * $depth
        Write-Output "$indent$($element.Current.Name) ($($element.Current.ControlType.ProgrammaticName))"

        # Traverse all child elements
        Get-UIAControl -InputObject $element | ForEach-Object {
            Traverse-UIElements $_ ($depth + 2)
        }
    }

    # Start traversal from the root element
    Traverse-UIElements $window
} else {
    Write-Output "Window not found."
}



