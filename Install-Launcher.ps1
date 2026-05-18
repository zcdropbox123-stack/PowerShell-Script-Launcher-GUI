# ============================================
# Install Simple PowerShell Script Launcher GUI
# ============================================

$ErrorActionPreference = "Stop"

$DesktopPath = [Environment]::GetFolderPath("Desktop")
$InstallRoot = "C:\ProgramData\SimpleScriptLauncher"

$SourceRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

# Source paths from GitHub/downloaded folder
$GuiSource = Join-Path $SourceRoot "Launcher.ps1"
$IconSource = Join-Path $SourceRoot "assets\Launcher.ico"
$ButtonsSource = Join-Path $SourceRoot "config\buttons.json"
$ScriptsSource = Join-Path $SourceRoot "Scripts"

# Destination paths
$GuiDestination = Join-Path $InstallRoot "Launcher.ps1"
$IconDestination = Join-Path $InstallRoot "Launcher.ico"
$ButtonsDestination = Join-Path $InstallRoot "buttons.json"
$ScriptsDestination = Join-Path $InstallRoot "Scripts"

# User-facing desktop folders
$UserFilesRoot = Join-Path $DesktopPath "Script Launcher Files"
$InputPath = Join-Path $UserFilesRoot "Input"
$OutputPath = Join-Path $UserFilesRoot "Output"

Clear-Host

Write-Host "============================================" -ForegroundColor Cyan
Write-Host " Installing Script Launcher" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Create install folders
foreach ($folder in @($InstallRoot, $ScriptsDestination, $UserFilesRoot, $InputPath, $OutputPath)) {
    if (-not (Test-Path $folder)) {
        New-Item -ItemType Directory -Path $folder -Force | Out-Null
    }
}

# Copy Launcher.ps1
if (Test-Path $GuiSource) {
    Copy-Item -Path $GuiSource -Destination $GuiDestination -Force
    Write-Host "Copied Launcher.ps1." -ForegroundColor Green
}
else {
    Write-Host "ERROR: Launcher.ps1 was not found in the installer folder." -ForegroundColor Red
    Write-Host "Expected location:" -ForegroundColor Yellow
    Write-Host $GuiSource -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

# Copy icon
if (Test-Path $IconSource) {
    Copy-Item -Path $IconSource -Destination $IconDestination -Force
    Write-Host "Copied Launcher.ico." -ForegroundColor Green
}
else {
    Write-Host "WARNING: assets\Launcher.ico was not found. Shortcut will use the default PowerShell icon." -ForegroundColor Yellow
}

# Copy button configuration
if (Test-Path $ButtonsSource) {
    Copy-Item -Path $ButtonsSource -Destination $ButtonsDestination -Force
    Write-Host "Copied buttons.json." -ForegroundColor Green
}
else {
    "[]" | Set-Content -Path $ButtonsDestination -Encoding UTF8
    Write-Host "No config\buttons.json found. Created blank button configuration." -ForegroundColor Yellow
}

# Copy included scripts, if any
if (Test-Path $ScriptsSource) {
    Copy-Item -Path "$ScriptsSource\*" -Destination $ScriptsDestination -Recurse -Force
    Write-Host "Copied included scripts." -ForegroundColor Green
}
else {
    Write-Host "No Scripts folder found. Skipping included scripts." -ForegroundColor Yellow
}

# Create desktop shortcut
$ShortcutPath = Join-Path $DesktopPath "Script Launcher.lnk"

$Shell = New-Object -ComObject WScript.Shell
$Shortcut = $Shell.CreateShortcut($ShortcutPath)

$Shortcut.TargetPath = "powershell.exe"
$Shortcut.Arguments = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$GuiDestination`""
$Shortcut.WorkingDirectory = $InstallRoot

if (Test-Path $IconDestination) {
    $Shortcut.IconLocation = $IconDestination
}

$Shortcut.Save()

Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host " Script Launcher installed successfully" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""
Write-Host "Installed launcher:" -ForegroundColor Cyan
Write-Host $GuiDestination
Write-Host ""
Write-Host "Desktop shortcut:" -ForegroundColor Cyan
Write-Host $ShortcutPath
Write-Host ""
Write-Host "User folders:" -ForegroundColor Cyan
Write-Host $InputPath
Write-Host $OutputPath
Write-Host ""

Read-Host "Press Enter to exit"
