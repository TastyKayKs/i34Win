Add-Type -MemberDefinition '
        [StructLayout(LayoutKind.Sequential)]
        public struct RECT
        {
             public int Left;        // x position of upper-left corner
             public int Top;         // y position of upper-left corner
             public int Right;       // x position of lower-right corner
             public int Bottom;      // y position of lower-right corner
        }

        [DllImport("user32.dll", SetLastError = true)]
        public static extern IntPtr SetParent(IntPtr hWndChild, IntPtr hWndNewParent);

        [DllImport("user32.dll", SetLastError = true)]
        public static extern IntPtr SetWindowLongPtrW(IntPtr hWnd, int nIndex, IntPtr dwNewLong);

        [DllImport("user32.dll", SetLastError = true)]
        public static extern IntPtr GetWindowLongPtrW(IntPtr hWnd, int nIndex);

        [DllImport("user32.dll", SetLastError = true)]
        public static extern bool SetWindowPos(IntPtr hWnd, IntPtr hWndInsertAfter, int X, int Y, int cx, int cy, uint uFlags);

        [DllImport("user32.dll", SetLastError = true)]
        public static extern bool SetForegroundWindow(IntPtr hWnd);

        [DllImport("user32.dll", SetLastError = true)]
        public static extern IntPtr GetForegroundWindow();

        [DllImport("user32.dll", SetLastError = true)]
        public static extern short GetAsyncKeyState(int vKey);

        [DllImport("user32.dll", SetLastError = true)]
        public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);

        [DllImport("user32.dll", SetLastError = true)]
        public static extern bool GetWindowRect(IntPtr hWnd, out RECT LPRECT);

        [DllImport("user32.dll")]
        public static extern void mouse_event(int dwFlags, int dx, int dy, int dwData, int dwExtraInfo);

        [DllImport("kernel32.dll", SetLastError = true)]
        public static extern bool TerminateProcess(IntPtr hProcess, uint uExitCode);
    ' -Namespace Window -Name Utils

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$tabber = [hashtable]::Synchronized(@{})
$tabber.next = $false
$tabber.prev = $false
$tabber.running = $false

$f = [System.Windows.Forms.Form]::new()
$f.Height = 800
$f.Width = 1200
$f.Menu = [System.Windows.Forms.MainMenu]::new()
$f.Menu.MenuItems.Add('Test1')
$f.Menu.MenuItems.Add('Test2')
$f.Menu.MenuItems.Add('Test3').MenuItems.Add('Test4')

$procs = @()
$procs+=(ps notepad)
$procs+=(ps wordpad)

$procs | %{$_.MainWindowHandle}

$f.show()

[Window.Utils]::SetParent($procs[0].MainWindowHandle, $f.Handle)
#[Window.Utils]::SetWindowLongPtrW($procs[0].MainWindowHandle, -16, 0x10000000)
[Window.Utils]::SetWindowPos($procs[0].MainWindowHandle, 0, 0, 0, $f.width/2, $f.height, 0x4260)

[Window.Utils]::SetParent($procs[1].MainWindowHandle, $f.Handle)
#[Window.Utils]::SetWindowLongPtrW($procs[1].MainWindowHandle, -16, 0x10000000)
[Window.Utils]::SetWindowPos($procs[1].MainWindowHandle, 0, $f.width/2, 0, $f.width/2, $f.height, 0x4260)

$f.hide()
$f.add_keyUp({
    #Write-Host ($_.KeyCode.ToString().GetType() | Out-String)
    $_.SuppressKeyPress
    if($_.KeyCode.ToString() -notmatch 'Tab' -and !$_.Control){
        [Window.Utils]::SetForegroundWindow($procs[0].MainWindowHandle)
        [System.Windows.Forms.SendKeys]::Send([String]$_.KeyCode)
        [Window.Utils]::SetForegroundWindow($procs[1].MainWindowHandle)
        [System.Windows.Forms.SendKeys]::Send([String]$_.KeyCode)
        [Window.Utils]::SetForegroundWindow($f.Handle)
    }
})
$f.Add_Closed({
    $tabber.running = $false
    $pow.EndInvoke($job)
    #[Window.Utils]::TerminateProcess($procs[0].Handle,0)
    #[Window.Utils]::TerminateProcess($procs[1].Handle,0)
})

$run = [runspacefactory]::CreateRunspace()
$run.Open()
$pow = [powershell]::create()
$pow.runspace = $run
$pow.AddScript({
    Param($tabber,$procs,$main)

    Add-Type -AssemblyName Microsoft.VisualBasic

    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    Add-Type -MemberDefinition '
        [StructLayout(LayoutKind.Sequential)]
        public struct RECT
        {
             public int Left;        // x position of upper-left corner
             public int Top;         // y position of upper-left corner
             public int Right;       // x position of lower-right corner
             public int Bottom;      // y position of lower-right corner
        }

        [DllImport("user32.dll", SetLastError = true)]
        public static extern IntPtr SetParent(IntPtr hWndChild, IntPtr hWndNewParent);

        [DllImport("user32.dll", SetLastError = true)]
        public static extern IntPtr SetWindowLongPtrW(IntPtr hWnd, int nIndex, IntPtr dwNewLong);

        [DllImport("user32.dll", SetLastError = true)]
        public static extern IntPtr GetWindowLongPtrW(IntPtr hWnd, int nIndex);

        [DllImport("user32.dll", SetLastError = true)]
        public static extern bool SetWindowPos(IntPtr hWnd, IntPtr hWndInsertAfter, int X, int Y, int cx, int cy, uint uFlags);

        [DllImport("user32.dll", SetLastError = true)]
        public static extern bool SetForegroundWindow(IntPtr hWnd);

        [DllImport("user32.dll", SetLastError = true)]
        public static extern IntPtr GetForegroundWindow();

        [DllImport("user32.dll", SetLastError = true)]
        public static extern short GetAsyncKeyState(int vKey);

        [DllImport("user32.dll", SetLastError = true)]
        public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);

        [DllImport("user32.dll", SetLastError = true)]
        public static extern bool GetWindowRect(IntPtr hWnd, out RECT LPRECT);

        [DllImport("user32.dll")]
        public static extern void mouse_event(int dwFlags, int dx, int dy, int dwData, int dwExtraInfo);

        [DllImport("kernel32.dll", SetLastError = true)]
        public static extern bool TerminateProcess(IntPtr hProcess, uint uExitCode);
    ' -Namespace Window -Name Utils

    $tabber.running = $true

    While($tabber.running){
        $windowRect = [Window.Utils+RECT]@{
            Left = [long]0;
            Top = [long]0;
            Right = [long]0;
            Bottom = [long]0;
        }

        #[Console]::WriteLine(([Window.Utils]::GetAsyncKeyState(0x09) -band [Window.Utils]::GetAsyncKeyState(0xa2) -band 0x8000))
        if([Window.Utils]::GetAsyncKeyState(0x09) -band [Window.Utils]::GetAsyncKeyState(0xa2) -band [Window.Utils]::GetAsyncKeyState(0xa0) -band 0x8000){
            While([Window.Utils]::GetAsyncKeyState(0x09) -bor [Window.Utils]::GetAsyncKeyState(0xa2) -bor [Window.Utils]::GetAsyncKeyState(0xa0) -band 0x8000){Sleep -Milliseconds 10}
            [Console]::WriteLine('HitPrev')
            [Console]::WriteLine('Current Focus: '+[Window.Utils]::GetForegroundWindow())
            $current = [Window.Utils]::GetForegroundWindow()
            $currInd = ($procs | %{$count = 0}{if($_.MainWindowHandle -eq $current){$count}; $count++})
            $currInd--
            [Console]::WriteLine($currInd)

            #Sleep 1
            if($current -ne $f.handle){
                [Window.Utils]::ShowWindow($procs[$currInd].MainWindowHandle,5)
                [Microsoft.VisualBasic.Interaction]::AppActivate($procs[$currInd].Id)
                [Window.Utils]::GetWindowRect($procs[$currInd].MainWindowHandle, [ref]$windowRect)
            }else{
                [Window.Utils]::ShowWindow($procs[0].MainWindowHandle,5)
                [Microsoft.VisualBasic.Interaction]::AppActivate($procs[0].Id)
                [Window.Utils]::GetWindowRect($procs[0].MainWindowHandle, [ref]$windowRect)
            }
            [Console]::WriteLine(($windowRect | out-String))
            $prevMouse = [System.Windows.Forms.Cursor]::Position
            [System.Windows.Forms.Cursor]::Position = [System.Drawing.Point]::new(($windowRect.Left+5),($windowRect.Top+5))
            [Window.Utils]::mouse_event(2,0,0,0,0)
            [System.Threading.Thread]::Sleep(40)
            [Window.Utils]::mouse_event(4,0,0,0,0)
            [System.Windows.Forms.Cursor]::Position = $prevMouse

            [Console]::WriteLine('Attempt Focus: '+$procs[$currInd].MainWindowHandle)
        }elseif([Window.Utils]::GetAsyncKeyState(0x09) -band [Window.Utils]::GetAsyncKeyState(0xa2) -band 0x8000){
            While([Window.Utils]::GetAsyncKeyState(0x09) -bor [Window.Utils]::GetAsyncKeyState(0xa2) -band 0x8000){Sleep -Milliseconds 10}
            Sleep -Milliseconds 500
            [Console]::WriteLine('HitNext')
            [Console]::WriteLine('Current Focus: '+[Window.Utils]::GetForegroundWindow())
            $current = [Window.Utils]::GetForegroundWindow()
            $currInd = ($procs | %{$count = 0}{if($_.MainWindowHandle -eq $current){$count}; $count++})
            $currInd++
            $next = 0
            if($currInd -lt $procs.Count){$next = $currInd}
            
            #Sleep 1
            if($current -ne $f.handle){
                [Window.Utils]::ShowWindow($procs[$next].MainWindowHandle,5)
                [Microsoft.VisualBasic.Interaction]::AppActivate($procs[$next].Id)
                [Window.Utils]::GetWindowRect($procs[$next].MainWindowHandle, [ref]$windowRect)
            }else{
                [Window.Utils]::ShowWindow($procs[0].MainWindowHandle,5)
                [Microsoft.VisualBasic.Interaction]::AppActivate($procs[0].Id)
                [Window.Utils]::GetWindowRect($procs[0].MainWindowHandle, [ref]$windowRect)
            }
            [Console]::WriteLine(($windowRect | out-String))
            $prevMouse = [System.Windows.Forms.Cursor]::Position
            [System.Windows.Forms.Cursor]::Position = [System.Drawing.Point]::new(($windowRect.Left+5),($windowRect.Top+5))
            [Window.Utils]::mouse_event(2,0,0,0,0)
            [System.Threading.Thread]::Sleep(40)
            [Window.Utils]::mouse_event(4,0,0,0,0)
            [System.Windows.Forms.Cursor]::Position = $prevMouse

            [Console]::WriteLine('Attempt Focus: '+$procs[$next].MainWindowHandle)
            [Console]::WriteLine(($error | out-String))
            Sleep 1
        }elseif([Window.Utils]::GetAsyncKeyState(0xa0) -band [Window.Utils]::GetAsyncKeyState(0xa2) -band [Window.Utils]::GetAsyncKeyState(0xa4) -band 0x8000){
            While([Window.Utils]::GetAsyncKeyState(0xa0) -bor [Window.Utils]::GetAsyncKeyState(0xa2) -bor [Window.Utils]::GetAsyncKeyState(0xa4) -band 0x8000){Sleep -Milliseconds 10}
            
            [Window.Utils]::GetWindowRect($main, [ref]$windowRect)
            [Console]::WriteLine(($windowRect | out-String))
            $prevMouse = [System.Windows.Forms.Cursor]::Position
            [System.Windows.Forms.Cursor]::Position = [System.Drawing.Point]::new(($windowRect.Left+5),($windowRect.Top+5))
            [Window.Utils]::mouse_event(2,0,0,0,0)
            [System.Threading.Thread]::Sleep(40)
            [Window.Utils]::mouse_event(4,0,0,0,0)
            [System.Windows.Forms.Cursor]::Position = $prevMouse

            [Console]::WriteLine('Attempt Focus: '+$main)
            [Console]::WriteLine(($error | out-String))
            Sleep 1
        }
        Sleep -milliseconds 50
    }
})
$pow.AddParameter('tabber',$tabber)
$pow.AddParameter('procs',$procs)
$pow.AddParameter('main',$f.handle)
$job = $pow.BeginInvoke()

#$windowRect = [Window.Utils+RECT]@{
#    Left = [long]0;
#    Top = [long]0;
#    Right = [long]0;
#    Bottom = [long]0;
#}
#[Window.Utils]::GetWindowRect([Window.Utils]::GetForegroundWindow(), [ref]$windowRect)


$f.ShowDialog()
$tabber.running = $false
