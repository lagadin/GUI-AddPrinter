### Variables

    #Printserver
        $printserver = ""


### Hide PowerShell Console
Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();
[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'
$consolePtr = [Console.Window]::GetConsoleWindow()
[Console.Window]::ShowWindow($consolePtr, 0)

### GUI
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$Form                                = New-Object system.Windows.Forms.Form
$Form.ClientSize                     = '350,237'
$Form.text                           = "Form"
$Form.TopMost                        = $false

$btn_Cancel                          = New-Object system.Windows.Forms.Button
$btn_Cancel.text                     = "Cancel"
$btn_Cancel.width                    = 110
$btn_Cancel.height                   = 30
$btn_Cancel.location                 = New-Object System.Drawing.Point(202,181)
$btn_Cancel.Font                     = 'Microsoft Sans Serif,10'

$btn_Install                         = New-Object system.Windows.Forms.Button
$btn_Install.text                    = "Install printer"
$btn_Install.width                   = 110
$btn_Install.height                  = 30
$btn_Install.location                = New-Object System.Drawing.Point(202,133)
$btn_Install.Font                    = 'Microsoft Sans Serif,10'

$txtBox_Location                     = New-Object system.Windows.Forms.TextBox
$txtBox_Location.multiline           = $false
$txtBox_Location.width               = 147
$txtBox_Location.height              = 20
$txtBox_Location.location            = New-Object System.Drawing.Point(179,35)
$txtBox_Location.Font                = 'Microsoft Sans Serif,8'

$listBox_Printers                    = New-Object system.Windows.Forms.ListBox
$listBox_Printers.text               = "listBox"
$listBox_Printers.width              = 159
$listBox_Printers.height             = 192
$listBox_Printers.location           = New-Object System.Drawing.Point(11,35)

$lbl_ChoosePrinter                   = New-Object system.Windows.Forms.Label
$lbl_ChoosePrinter.text              = "Choose a printer"
$lbl_ChoosePrinter.AutoSize          = $true
$lbl_ChoosePrinter.width             = 25
$lbl_ChoosePrinter.height            = 10
$lbl_ChoosePrinter.location          = New-Object System.Drawing.Point(11,16)
$lbl_ChoosePrinter.Font              = 'Microsoft Sans Serif,10'

$lbl_PrinterLoc                      = New-Object system.Windows.Forms.Label
$lbl_PrinterLoc.text                 = "Printer location"
$lbl_PrinterLoc.AutoSize             = $true
$lbl_PrinterLoc.width                = 25
$lbl_PrinterLoc.height               = 10
$lbl_PrinterLoc.location             = New-Object System.Drawing.Point(179,16)
$lbl_PrinterLoc.Font                 = 'Microsoft Sans Serif,10'

$Form.controls.AddRange(@($btn_Cancel,$btn_Install,$txtBox_Location,$listBox_Printers,$lbl_ChoosePrinter,$lbl_PrinterLoc))


### Eventhandlers 

$listBox_Printers.Add_SelectedIndexChanged({ 
    $printName = $listBox_Printers.SelectedItem
write-host $printName
    $txtBox_Location.Text = Get-Printer -ComputerName $printserver -Name $printName | Select-Object -ExpandProperty "Location"

})

$btn_Cancel.Add_Click({ 
    $Form.Close() 
})

$btn_Install.Add_Click({ 
    $printName = $listBox_Printers.SelectedItem
    get-wmiobject -class win32_printer -computer $printserver
    rundll32 printui.dll,PrintUIEntry /in /n \\Printserver\$printName
    
})


### Main
$printName = $listBox_Printers.SelectedItem
$printLoc = ""
$printers = Get-Printer -ComputerName $printserver | Select-Object -Property "Location", "Name"

foreach($printer in $printers){
    $listBox_Printers.Items.Add($printer.Name)
}


[void]$Form.ShowDialog()