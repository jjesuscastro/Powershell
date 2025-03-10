Set-ExecutionPolicy Bypass -Scope Process -Force
﻿# This 1st portion of the script and up to #WinGet was written by Hammer of the Gods.
# Bypass Execution Policy

# Elevate Script
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
    if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
        $CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
        Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
        Exit
    }
}

# Bypass Execution Policy after elevation
Set-ExecutionPolicy Bypass -Scope Process -Force

# WinGet
Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe

# Loops while there is no internet connection.
# Needed for PCs without ethernet, while it waits for the Wi-Fi to connect.
Write-Host ("`n" * 10)
Write-Host 'Testing for internet connection... Without it, script will hang in loop.'
while (!(Test-Connection -ComputerName google.com -Quiet)) {
    Write-Host 'No internet connection. Trying again in 5 seconds...'
    Start-Sleep -Seconds 5
}

# Setup timeout and winget location
$timeout = [datetime]::Now.AddMinutes(5);
$exe = "$env:LOCALAPPDATA\Microsoft\WindowsApps\winget.exe";

# List of applications to install
$apps = @(
    "Google.Chrome",
    "7zip.7zip",
    "Git.Git",
    "VideoLAN.VLC",
    "eliboa.TegraRcmGUI",
    "Olivia.VIA",
    "Notion.Notion",
    "Discord.Discord",
    "Discord.Discord.PTB",
    "RiotGames.Valorant.AP",
    "Valve.Steam",
    "EpicGames.EpicGamesLauncher",
    "Microsoft.VisualStudioCode",
    "Microsoft.PowerToys",
    "qBittorrent.qBittorrent",
    "Fork.Fork",
    "Unity.UnityHub",
    "Prusa3D.PrusaSlicer",
    "JetBrains.Rider"
)

# Wait for winget.exe to be available
while ($true) {
    if (Test-Path $exe) {
        winget source reset --force

        $total = $apps.Count
        $counter = 1

        foreach ($app in $apps) {
            # Print "Installing..." message
            Write-Host -NoNewline "`rInstalling $app ($counter of $total)..."

            # Run winget and suppress output
            winget install -h -e --id $app --accept-package-agreements --accept-source-agreements *> $null

            # Replace "Installing..." with "Finished installing..."
            Write-Host "`rFinished installing $app ($counter of $total).                      "

            $counter++
        }

        # Ensure the final message appears on a new line
        Write-Host "`nAll applications installed!"
        return;
    }
    if ([datetime]::Now -gt $timeout) {
        'File {0} does not exist.' -f $exe | Write-Warning;
        return;
    }
    Start-Sleep -Seconds 1;
 }
