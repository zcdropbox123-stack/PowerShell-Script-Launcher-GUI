# ============================================================
# Simple PowerShell Script Launcher GUI
# Generic GitHub-ready version
# For non-technical users
# ============================================================

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ----------------------------
# App Settings
# ----------------------------

$AppName = "Script Launcher"
$AppRoot = Join-Path $env:ProgramData "SimpleScriptLauncher"
$ScriptFolder = Join-Path $AppRoot "Scripts"
$ConfigPath = Join-Path $AppRoot "buttons.json"

$DesktopPath = [Environment]::GetFolderPath("Desktop")
$UserFilesRoot = Join-Path $DesktopPath "Script Launcher Files"
$InputPath = Join-Path $UserFilesRoot "Input"
$OutputPath = Join-Path $UserFilesRoot "Output"

# ----------------------------
# Create Required Folders
# ----------------------------

foreach ($folder in @($AppRoot, $ScriptFolder, $UserFilesRoot, $InputPath, $OutputPath)) {
    if (-not (Test-Path $folder)) {
        New-Item -ItemType Directory -Path $folder -Force | Out-Null
    }
}

# ----------------------------
# Helper Functions
# ----------------------------

function Show-Message {
    param (
        [string]$Message,
        [string]$Title = "Message",
        [string]$Icon = "Information"
    )

    [System.Windows.Forms.MessageBox]::Show(
        $Message,
        $Title,
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::$Icon
    )
}

function Get-SafeFileName {
    param (
        [string]$Name
    )

    $invalidChars = [System.IO.Path]::GetInvalidFileNameChars()

    foreach ($char in $invalidChars) {
        $Name = $Name.Replace($char, "_")
    }

    $Name = $Name.Trim()

    if ([string]::IsNullOrWhiteSpace($Name)) {
        $Name = "NewScript"
    }

    return $Name
}

function Load-ScriptButtons {
    if (-not (Test-Path $ConfigPath)) {
        return @()
    }

    try {
        $json = Get-Content $ConfigPath -Raw

        if ([string]::IsNullOrWhiteSpace($json)) {
            return @()
        }

        $items = $json | ConvertFrom-Json

        if ($null -eq $items) {
            return @()
        }

        if ($items -isnot [System.Array]) {
            return @($items)
        }

        return $items
    }
    catch {
        Show-Message `
            "The button configuration file could not be read.`n`n$($_.Exception.Message)" `
            "Configuration Error" `
            "Error"

        return @()
    }
}

function Save-ScriptButtons {
    param (
        [array]$Buttons
    )

    try {
        $Buttons |
            ConvertTo-Json -Depth 5 |
            Set-Content -Path $ConfigPath -Encoding UTF8
    }
    catch {
        Show-Message `
            "The button configuration file could not be saved.`n`n$($_.Exception.Message)" `
            "Configuration Error" `
            "Error"
    }
}

function Add-ScriptButtonToPanel {
    param (
        [string]$Title,
        [string]$FileName
    )

    $scriptPath = Join-Path $ScriptFolder $FileName

    $button = New-Object System.Windows.Forms.Button
    $button.Text = $Title
    $button.Width = 430
    $button.Height = 60
    $button.Margin = New-Object System.Windows.Forms.Padding(10)
    $button.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
    $button.BackColor = [System.Drawing.Color]::White
    $button.FlatStyle = "Standard"

    $button.Add_Click({

        if (-not (Test-Path $scriptPath)) {
            Show-Message `
                "The script file could not be found.`n`nExpected location:`n$scriptPath" `
                "Script Missing" `
                "Error"

            return
        }

        $confirm = [System.Windows.Forms.MessageBox]::Show(
            "Run this script?`n`n$Title",
            "Confirm Script",
            [System.Windows.Forms.MessageBoxButtons]::YesNo,
            [System.Windows.Forms.MessageBoxIcon]::Question
        )

        if ($confirm -ne [System.Windows.Forms.DialogResult]::Yes) {
            return
        }

        $StatusLabel.Text = "Running: $Title"
        $MainForm.Refresh()

        try {
            # -NoExit keeps the PowerShell window open so the user/support can see output/errors.
            # Remove -NoExit if you want script windows to close automatically.
            $argumentList = "-NoProfile -ExecutionPolicy Bypass -NoExit -File `"$scriptPath`""

            Start-Process `
                -FilePath "powershell.exe" `
                -ArgumentList $argumentList `
                -WorkingDirectory (Split-Path $scriptPath)

            $StatusLabel.Text = "Started: $Title"
        }
        catch {
            $StatusLabel.Text = "Error running script."

            Show-Message `
                "The script could not be started.`n`n$($_.Exception.Message)" `
                "Script Error" `
                "Error"
        }

    }.GetNewClosure())

    $ScriptButtonPanel.Controls.Add($button)
}

function Refresh-ScriptButtons {
    $ScriptButtonPanel.Controls.Clear()

    $buttons = @(Load-ScriptButtons)

    if ($buttons.Count -eq 0) {
        $emptyLabel = New-Object System.Windows.Forms.Label
        $emptyLabel.Text = "No script buttons have been added yet."
        $emptyLabel.Width = 430
        $emptyLabel.Height = 40
        $emptyLabel.Margin = New-Object System.Windows.Forms.Padding(10)
        $emptyLabel.Font = New-Object System.Drawing.Font("Segoe UI", 11)
        $ScriptButtonPanel.Controls.Add($emptyLabel)
        return
    }

    foreach ($item in $buttons) {
        Add-ScriptButtonToPanel -Title $item.Title -FileName $item.FileName
    }
}

function Show-AddScriptForm {

    $AddForm = New-Object System.Windows.Forms.Form
    $AddForm.Text = "Add New Script Button"
    $AddForm.Size = New-Object System.Drawing.Size(760, 620)
    $AddForm.StartPosition = "CenterScreen"
    $AddForm.FormBorderStyle = "FixedDialog"
    $AddForm.MaximizeBox = $false
    $AddForm.MinimizeBox = $false
    $AddForm.BackColor = [System.Drawing.Color]::WhiteSmoke

    $TitleLabel = New-Object System.Windows.Forms.Label
    $TitleLabel.Text = "Button Title:"
    $TitleLabel.Location = New-Object System.Drawing.Point(20, 20)
    $TitleLabel.Size = New-Object System.Drawing.Size(700, 25)
    $TitleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 11)
    $AddForm.Controls.Add($TitleLabel)

    $TitleTextBox = New-Object System.Windows.Forms.TextBox
    $TitleTextBox.Location = New-Object System.Drawing.Point(20, 50)
    $TitleTextBox.Size = New-Object System.Drawing.Size(700, 30)
    $TitleTextBox.Font = New-Object System.Drawing.Font("Segoe UI", 11)
    $AddForm.Controls.Add($TitleTextBox)

    $ScriptLabel = New-Object System.Windows.Forms.Label
    $ScriptLabel.Text = "Paste PowerShell Script Below:"
    $ScriptLabel.Location = New-Object System.Drawing.Point(20, 95)
    $ScriptLabel.Size = New-Object System.Drawing.Size(700, 25)
    $ScriptLabel.Font = New-Object System.Drawing.Font("Segoe UI", 11)
    $AddForm.Controls.Add($ScriptLabel)

    $ScriptTextBox = New-Object System.Windows.Forms.TextBox
    $ScriptTextBox.Location = New-Object System.Drawing.Point(20, 125)
    $ScriptTextBox.Size = New-Object System.Drawing.Size(700, 360)
    $ScriptTextBox.Font = New-Object System.Drawing.Font("Consolas", 10)
    $ScriptTextBox.Multiline = $true
    $ScriptTextBox.ScrollBars = "Both"
    $ScriptTextBox.WordWrap = $false
    $ScriptTextBox.AcceptsReturn = $true
    $ScriptTextBox.AcceptsTab = $true
    $AddForm.Controls.Add($ScriptTextBox)

    $SaveButton = New-Object System.Windows.Forms.Button
    $SaveButton.Text = "Save Button"
    $SaveButton.Location = New-Object System.Drawing.Point(500, 510)
    $SaveButton.Size = New-Object System.Drawing.Size(105, 40)
    $SaveButton.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $AddForm.Controls.Add($SaveButton)

    $CancelButton = New-Object System.Windows.Forms.Button
    $CancelButton.Text = "Cancel"
    $CancelButton.Location = New-Object System.Drawing.Point(615, 510)
    $CancelButton.Size = New-Object System.Drawing.Size(105, 40)
    $CancelButton.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $AddForm.Controls.Add($CancelButton)

    $CancelButton.Add_Click({
        $AddForm.Close()
    })

    $SaveButton.Add_Click({

        $buttonTitle = $TitleTextBox.Text.Trim()
        $scriptContent = $ScriptTextBox.Text

        if ([string]::IsNullOrWhiteSpace($buttonTitle)) {
            Show-Message `
                "Please enter a button title." `
                "Missing Button Title" `
                "Warning"

            return
        }

        if ([string]::IsNullOrWhiteSpace($scriptContent)) {
            Show-Message `
                "Please paste a PowerShell script." `
                "Missing Script" `
                "Warning"

            return
        }

        $warningResult = [System.Windows.Forms.MessageBox]::Show(
            "Only save scripts from a trusted source.`n`nPowerShell scripts can change files, install software, and modify the computer.`n`nDo you want to save this script button?",
            "Security Warning",
            [System.Windows.Forms.MessageBoxButtons]::YesNo,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        )

        if ($warningResult -ne [System.Windows.Forms.DialogResult]::Yes) {
            return
        }

        $safeName = Get-SafeFileName $buttonTitle
        $fileName = "$safeName.ps1"
        $scriptPath = Join-Path $ScriptFolder $fileName

        $counter = 1

        while (Test-Path $scriptPath) {
            $fileName = "$safeName-$counter.ps1"
            $scriptPath = Join-Path $ScriptFolder $fileName
            $counter++
        }

        try {
            $scriptContent | Set-Content -Path $scriptPath -Encoding UTF8

            $existingButtons = @(Load-ScriptButtons)

            $newButton = [PSCustomObject]@{
                Title = $buttonTitle
                FileName = $fileName
                Created = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
            }

            $updatedButtons = @($existingButtons + $newButton)

            Save-ScriptButtons -Buttons $updatedButtons

            Refresh-ScriptButtons

            $StatusLabel.Text = "Added button: $buttonTitle"

            Show-Message `
                "New script button added successfully.`n`nButton title:`n$buttonTitle" `
                "Button Added" `
                "Information"

            $AddForm.Close()
        }
        catch {
            Show-Message `
                "The script button could not be saved.`n`n$($_.Exception.Message)" `
                "Save Error" `
                "Error"
        }
    })

    $AddForm.ShowDialog()
}

function Show-DeleteScriptForm {

    $buttons = @(Load-ScriptButtons)

    if ($buttons.Count -eq 0) {
        Show-Message `
            "There are no script buttons to delete." `
            "No Buttons Found" `
            "Information"

        return
    }

    $DeleteForm = New-Object System.Windows.Forms.Form
    $DeleteForm.Text = "Delete Script Button"
    $DeleteForm.Size = New-Object System.Drawing.Size(520, 220)
    $DeleteForm.StartPosition = "CenterScreen"
    $DeleteForm.FormBorderStyle = "FixedDialog"
    $DeleteForm.MaximizeBox = $false
    $DeleteForm.MinimizeBox = $false
    $DeleteForm.BackColor = [System.Drawing.Color]::WhiteSmoke

    $Label = New-Object System.Windows.Forms.Label
    $Label.Text = "Select the button you want to delete:"
    $Label.Location = New-Object System.Drawing.Point(20, 20)
    $Label.Size = New-Object System.Drawing.Size(460, 25)
    $Label.Font = New-Object System.Drawing.Font("Segoe UI", 11)
    $DeleteForm.Controls.Add($Label)

    $ComboBox = New-Object System.Windows.Forms.ComboBox
    $ComboBox.Location = New-Object System.Drawing.Point(20, 60)
    $ComboBox.Size = New-Object System.Drawing.Size(460, 30)
    $ComboBox.Font = New-Object System.Drawing.Font("Segoe UI", 11)
    $ComboBox.DropDownStyle = "DropDownList"

    foreach ($button in $buttons) {
        [void]$ComboBox.Items.Add($button.Title)
    }

    if ($ComboBox.Items.Count -gt 0) {
        $ComboBox.SelectedIndex = 0
    }

    $DeleteButton = New-Object System.Windows.Forms.Button
    $DeleteButton.Text = "Delete"
    $DeleteButton.Location = New-Object System.Drawing.Point(260, 120)
    $DeleteButton.Size = New-Object System.Drawing.Size(100, 35)
    $DeleteButton.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $DeleteForm.Controls.Add($DeleteButton)

    $CancelButton = New-Object System.Windows.Forms.Button
    $CancelButton.Text = "Cancel"
    $CancelButton.Location = New-Object System.Drawing.Point(380, 120)
    $CancelButton.Size = New-Object System.Drawing.Size(100, 35)
    $CancelButton.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $DeleteForm.Controls.Add($CancelButton)

    $CancelButton.Add_Click({
        $DeleteForm.Close()
    })

    $DeleteButton.Add_Click({

        $selectedTitle = $ComboBox.SelectedItem

        if ([string]::IsNullOrWhiteSpace($selectedTitle)) {
            Show-Message `
                "Please select a button to delete." `
                "No Button Selected" `
                "Warning"

            return
        }

        $selectedButton = $buttons |
            Where-Object { $_.Title -eq $selectedTitle } |
            Select-Object -First 1

        if ($null -eq $selectedButton) {
            Show-Message `
                "The selected button could not be found." `
                "Delete Error" `
                "Error"

            return
        }

        $confirm = [System.Windows.Forms.MessageBox]::Show(
            "Delete this script button?`n`n$selectedTitle`n`nThis will remove the button from the launcher and delete the saved script file.",
            "Confirm Delete",
            [System.Windows.Forms.MessageBoxButtons]::YesNo,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        )

        if ($confirm -ne [System.Windows.Forms.DialogResult]::Yes) {
            return
        }

        $updatedButtons = @($buttons | Where-Object { $_.Title -ne $selectedTitle })

        Save-ScriptButtons -Buttons $updatedButtons

        $scriptPath = Join-Path $ScriptFolder $selectedButton.FileName

        if (Test-Path $scriptPath) {
            Remove-Item -Path $scriptPath -Force
        }

        Refresh-ScriptButtons

        $StatusLabel.Text = "Deleted button: $selectedTitle"

        Show-Message `
            "The script button was deleted successfully." `
            "Button Deleted" `
            "Information"

        $DeleteForm.Close()
    })

    $DeleteForm.ShowDialog()
}

function Open-ScriptFolder {
    if (-not (Test-Path $ScriptFolder)) {
        New-Item -ItemType Directory -Path $ScriptFolder -Force | Out-Null
    }

    Start-Process explorer.exe $ScriptFolder
}

function Open-InputFolder {
    if (-not (Test-Path $InputPath)) {
        New-Item -ItemType Directory -Path $InputPath -Force | Out-Null
    }

    Start-Process explorer.exe $InputPath
}

function Open-OutputFolder {
    if (-not (Test-Path $OutputPath)) {
        New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
    }

    Start-Process explorer.exe $OutputPath
}

# ----------------------------
# Main GUI
# ----------------------------

$MainForm = New-Object System.Windows.Forms.Form
$MainForm.Text = $AppName
$MainForm.Size = New-Object System.Drawing.Size(560, 760)
$MainForm.StartPosition = "CenterScreen"
$MainForm.FormBorderStyle = "FixedDialog"
$MainForm.MaximizeBox = $false
$MainForm.BackColor = [System.Drawing.Color]::WhiteSmoke

$HeaderLabel = New-Object System.Windows.Forms.Label
$HeaderLabel.Text = $AppName
$HeaderLabel.Location = New-Object System.Drawing.Point(25, 20)
$HeaderLabel.Size = New-Object System.Drawing.Size(500, 45)
$HeaderLabel.Font = New-Object System.Drawing.Font("Segoe UI", 22, [System.Drawing.FontStyle]::Bold)
$MainForm.Controls.Add($HeaderLabel)

$InstructionLabel = New-Object System.Windows.Forms.Label
$InstructionLabel.Text = "Choose a task below:"
$InstructionLabel.Location = New-Object System.Drawing.Point(30, 70)
$InstructionLabel.Size = New-Object System.Drawing.Size(480, 28)
$InstructionLabel.Font = New-Object System.Drawing.Font("Segoe UI", 12)
$MainForm.Controls.Add($InstructionLabel)

$ScriptButtonPanel = New-Object System.Windows.Forms.FlowLayoutPanel
$ScriptButtonPanel.Location = New-Object System.Drawing.Point(40, 110)
$ScriptButtonPanel.Size = New-Object System.Drawing.Size(470, 330)
$ScriptButtonPanel.AutoScroll = $true
$ScriptButtonPanel.FlowDirection = "TopDown"
$ScriptButtonPanel.WrapContents = $false
$ScriptButtonPanel.BackColor = [System.Drawing.Color]::Gainsboro
$MainForm.Controls.Add($ScriptButtonPanel)

$AddScriptButton = New-Object System.Windows.Forms.Button
$AddScriptButton.Text = "Add New Script Button"
$AddScriptButton.Location = New-Object System.Drawing.Point(60, 460)
$AddScriptButton.Size = New-Object System.Drawing.Size(420, 40)
$AddScriptButton.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$MainForm.Controls.Add($AddScriptButton)

$DeleteScriptButton = New-Object System.Windows.Forms.Button
$DeleteScriptButton.Text = "Delete Script Button"
$DeleteScriptButton.Location = New-Object System.Drawing.Point(60, 510)
$DeleteScriptButton.Size = New-Object System.Drawing.Size(420, 40)
$DeleteScriptButton.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$MainForm.Controls.Add($DeleteScriptButton)

$OpenScriptFolderButton = New-Object System.Windows.Forms.Button
$OpenScriptFolderButton.Text = "Open Saved Scripts Folder"
$OpenScriptFolderButton.Location = New-Object System.Drawing.Point(60, 560)
$OpenScriptFolderButton.Size = New-Object System.Drawing.Size(420, 40)
$OpenScriptFolderButton.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$MainForm.Controls.Add($OpenScriptFolderButton)

$OpenInputFolderButton = New-Object System.Windows.Forms.Button
$OpenInputFolderButton.Text = "Open Input Folder"
$OpenInputFolderButton.Location = New-Object System.Drawing.Point(60, 610)
$OpenInputFolderButton.Size = New-Object System.Drawing.Size(205, 40)
$OpenInputFolderButton.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$MainForm.Controls.Add($OpenInputFolderButton)

$OpenOutputFolderButton = New-Object System.Windows.Forms.Button
$OpenOutputFolderButton.Text = "Open Output Folder"
$OpenOutputFolderButton.Location = New-Object System.Drawing.Point(275, 610)
$OpenOutputFolderButton.Size = New-Object System.Drawing.Size(205, 40)
$OpenOutputFolderButton.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$MainForm.Controls.Add($OpenOutputFolderButton)

$ExitButton = New-Object System.Windows.Forms.Button
$ExitButton.Text = "Exit"
$ExitButton.Location = New-Object System.Drawing.Point(60, 660)
$ExitButton.Size = New-Object System.Drawing.Size(420, 40)
$ExitButton.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$MainForm.Controls.Add($ExitButton)

$StatusLabel = New-Object System.Windows.Forms.Label
$StatusLabel.Text = "Ready."
$StatusLabel.Location = New-Object System.Drawing.Point(30, 710)
$StatusLabel.Size = New-Object System.Drawing.Size(500, 25)
$StatusLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$StatusLabel.ForeColor = [System.Drawing.Color]::DarkSlateGray
$MainForm.Controls.Add($StatusLabel)

# ----------------------------
# Button Actions
# ----------------------------

$AddScriptButton.Add_Click({
    Show-AddScriptForm
})

$DeleteScriptButton.Add_Click({
    Show-DeleteScriptForm
})

$OpenScriptFolderButton.Add_Click({
    Open-ScriptFolder
})

$OpenInputFolderButton.Add_Click({
    Open-InputFolder
})

$OpenOutputFolderButton.Add_Click({
    Open-OutputFolder
})

$ExitButton.Add_Click({
    $MainForm.Close()
})

# ----------------------------
# Load Buttons and Start GUI
# ----------------------------

Refresh-ScriptButtons

[void]$MainForm.ShowDialog()