# Load the necessary .NET assemblies first
Add-Type -AssemblyName "System.Windows.Forms"
Add-Type -AssemblyName "System.Drawing"

# C# code with Add-Type block
Add-Type @"
using System;
using System.Windows.Forms;
using System.Drawing;

public class MyForm : Form
{
    public MyForm()
    {
        this.Text = "Hello, PowerShell!";
        this.Size = new Size(300, 200);
        Button button = new Button();
        button.Text = "Click Me";
        button.Size = new Size(100, 40);
        button.Location = new Point(100, 80);
        this.Controls.Add(button);
        button.Click += new EventHandler(Button_Click);
    }

    private void Button_Click(object sender, EventArgs e)
    {
        MessageBox.Show("Button was clicked!");
    }
}

public class Program
{
    public static void Main()
    {
        Application.EnableVisualStyles();
        Application.Run(new MyForm());
    }
}
"@

# Create and show the form
[MyForm]::new().ShowDialog()
