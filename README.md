# PowerShell-Script-Launcher-GUI
Simple Powershell Scripter Launcher GUI. Easily add new scripts and assign a button in the GUI. I will be including a list of scripts that I have used with it.

One goal is to allow non-technical users to run approved PowerShell scripts from large, plain-language buttons.

The launcher supports:
- Adding script buttons by pasting PowerShell code
- Saving scripts locally
- Loading saved buttons automatically
- Deleting saved script buttons
- Creating user-friendly Input and Output folders
- Running scripts from a desktop shortcut


## Quick Start

1. Download this repository as a ZIP file.
2. Extract the ZIP file.
3. Right-click `Install-Launcher.ps1`.
4. Click **Run with PowerShell**.
5. Double-click the new **Script Launcher** desktop shortcut.
6. Click the button for the task you want to run.


## How to Install

This tool is designed for Windows computers.

### Step 1: Download the Launcher

1. Click the green **Code** button near the top of this GitHub page.
2. Click **Download ZIP**.
3. Open your Downloads folder.
4. Right-click the downloaded ZIP file.
5. Click **Extract All**.
6. Open the extracted folder.

### Step 2: Run the Installer

1. Find the file named:

   `Install-Launcher.ps1`

2. Right-click it.
3. Click **Run with PowerShell**.
4. If Windows asks for permission, click **Yes** or **Run**.
5. Wait for the installer to finish.
6. When it says installation is complete, press **Enter** to close the window.

### Step 3: Open the Launcher

After installation, a shortcut should appear on your desktop named:

`Script Launcher`

Double-click **Script Launcher** to open the program.

## What the Launcher Does

The launcher lets you run approved PowerShell scripts by clicking large, clearly named buttons.

Instead of opening PowerShell and typing commands, users can click buttons such as:

- Download Video for ProPresenter
- Extract MP3 Audio from Video
- Combine WMA Files into MP3
- Open Input Folder
- Open Output Folder

## Important Folders

The installer creates a folder on the desktop named:

`Script Launcher Files`

Inside that folder are two important folders:

### Input

Use this folder for files that a script needs before it runs.

Example:

If a script combines WMA files, place the WMA files in:

`Desktop\Script Launcher Files\Input`

### Output

Finished files will usually be saved here:

`Desktop\Script Launcher Files\Output`

If a script creates an MP3, video, report, or converted file, check the Output folder first.

## How to Run a Script

1. Double-click the **Script Launcher** desktop shortcut.
2. Find the button for the task you want.
3. Click the button.
4. Read any instructions that appear.
5. Follow the prompts.
6. When the script is finished, check the Output folder if a file was created.

## How to Add a New Script Button

Only add scripts from a trusted source.

1. Open **Script Launcher**.
2. Click **Add New Script Button**.
3. Enter a clear button title.

   Good examples:

   - Download Video for ProPresenter
   - Extract MP3 Audio from Video
   - Combine WMA Files into MP3

4. Paste the PowerShell script into the large text box.
5. Click **Save Button**.
6. The new button will appear in the launcher.

## How to Delete a Script Button

1. Open **Script Launcher**.
2. Click **Delete Script Button**.
3. Select the button you want to remove.
4. Confirm the deletion.

This removes the button and deletes the saved script file from the launcher.

## If a Script Does Not Run

Try these steps:

1. Close the launcher.
2. Reopen the launcher.
3. Try the button again.
4. If the script uses video or audio tools, run the media dependency installer if one is provided.
5. If the issue continues, contact the person who provided the launcher.

Common causes include:

- The computer does not have permission to run scripts.
- A required tool such as `ffmpeg` or `yt-dlp` is missing.
- The required input files are not in the Input folder.
- The file name already exists in the Output folder.

## Media Tools Note

Some media scripts require extra tools:

- `yt-dlp` for downloading video or audio from links
- `ffmpeg` for converting, combining, or extracting audio/video

If this repository includes:

`Optional Tools\Install-Media-Dependencies.ps1`

run that file before using media-related scripts.

## Safety Notice

Only run scripts from people you trust.

PowerShell scripts can make changes to the computer, including creating files, deleting files, installing software, and changing settings.

Do not paste or save a script unless you know what it does or received it from a trusted person.
