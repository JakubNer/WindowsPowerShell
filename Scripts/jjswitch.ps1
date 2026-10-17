add-type -AssemblyName microsoft.VisualBasic
add-type -AssemblyName System.Windows.Forms

function hide {
    $sig = '[DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);'
    Add-Type -MemberDefinition $sig -name NativeMethods -namespace Win32
    $PSId = @(Get-Process "powershell" -ErrorAction SilentlyContinue)[0].MainWindowHandle
    If ($PSId -ne $NULL) { [Win32.NativeMethods]::ShowWindowAsync($PSId, 2)}
}

function switcher {
    [System.Windows.Forms.SendKeys]::SendWait("^+%{F12}")
}

function calc {
    Calc
    start-sleep -Milliseconds 500
    [Microsoft.VisualBasic.Interaction]::AppActivate("Calc")
}

function adam {
    hide;
    [System.Windows.Forms.SendKeys]::SendWait("adam{TAB}Let's talk Security!")
}

#adam;
switcher;
