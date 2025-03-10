Add-Type -AssemblyName System.Windows.Forms

# Create Form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Winget Application Installer"
$form.Size = New-Object System.Drawing.Size(400, 500)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"  # Prevent resizing

# Create TreeView for categorized applications
$treeView = New-Object System.Windows.Forms.TreeView
$treeView.Size = New-Object System.Drawing.Size(350, 300)
$treeView.Location = New-Object System.Drawing.Point(20, 20)
$treeView.CheckBoxes = $true

# Define categorized applications
$appsByCategory = @{ 
    "Browsers" = @{ "Google Chrome" = "Google.Chrome" } 
    "Utilities" = @{ 
        "7-Zip" = "7zip.7zip" 
        "PowerToys" = "Microsoft.PowerToys" 
        "qBittorrent" = "qBittorrent.qBittorrent"
        "AnyBurn" = "PowerSoftware.AnyBurn"
    } 
    "Messaging" = @{
        "Discord" = "Discord.Discord" 
        "Discord PTB" = "Discord.Discord.PTB"
    }
    "Development" = @{ 
        "Git" = "Git.Git" 
        "Visual Studio Code" = "Microsoft.VisualStudioCode" 
        "Unity Hub" = "Unity.UnityHub" 
        "JetBrains Rider" = "JetBrains.Rider"
        "Fork (Git Client)" = "Fork.Fork"
    }
    "Media" = @{ 
        "VLC Media Player" = "VideoLAN.VLC" 
        "Handbrake" = "Handbrake.Handbrake"
    }
    "Gaming" = @{ 
        "Valorant" = "RiotGames.Valorant.AP" 
        "Steam" = "Valve.Steam" 
        "Epic Games Launcher" = "EpicGames.EpicGamesLauncher"
    }
    "Productivity" = @{ "Notion" = "Notion.Notion" }
    "3D Printing" = @{ "PrusaSlicer" = "Prusa3D.PrusaSlicer" }
    "Other" = @{ 
        "TegraRcmGUI" = "eliboa.TegraRcmGUI" 
        "VIA" = "Olivia.VIA" 
    }
}

# Populate TreeView with categorized applications
foreach ($category in $appsByCategory.Keys) {
    $categoryNode = New-Object System.Windows.Forms.TreeNode($category)
    foreach ($appName in $appsByCategory[$category].Keys) {
        $appNode = New-Object System.Windows.Forms.TreeNode($appName)
        $appNode.Tag = $appsByCategory[$category][$appName]  # Store winget ID
        $categoryNode.Nodes.Add($appNode)
    }
    $treeView.Nodes.Add($categoryNode)
}

# Event to check/uncheck child nodes when parent is checked/unchecked
$treeView.add_AfterCheck({
    param($sender, $e)
    if ($e.Action -ne 'ByMouse') { return }  # Prevent infinite loops
    
    $node = $e.Node
    $isChecked = $node.Checked
    
    foreach ($childNode in $node.Nodes) {
        $childNode.Checked = $isChecked
    }
})

$form.Controls.Add($treeView)

# Create ProgressBar
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Size = New-Object System.Drawing.Size(350, 20)
$progressBar.Location = New-Object System.Drawing.Point(20, 330)
$progressBar.Minimum = 0
$progressBar.Maximum = ($appsByCategory.Values | ForEach-Object { $_.Count } | Measure-Object -Sum).Sum
$progressBar.Value = 0
$form.Controls.Add($progressBar)

# Create Install Button
$installButton = New-Object System.Windows.Forms.Button
$installButton.Text = "Install Selected"
$installButton.Size = New-Object System.Drawing.Size(350, 30)
$installButton.Location = New-Object System.Drawing.Point(20, 370)
$form.Controls.Add($installButton)

# Install Button Click Event
$installButton.Add_Click({
    $selectedApps = @()
    foreach ($categoryNode in $treeView.Nodes) {
        foreach ($appNode in $categoryNode.Nodes) {
            if ($appNode.Checked) {
                $selectedApps += $appNode.Tag
            }
        }
    }
    
    if ($selectedApps.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("No applications selected.", "Warning", "OK", "Warning")
    } else {
        $progressBar.Value = 0
        foreach ($app in $selectedApps) {
            Start-Process "winget" -ArgumentList "install --id=$app --silent --accept-package-agreements --accept-source-agreements" -NoNewWindow -Wait
            $progressBar.Value += 1
        }
    }
})

# Create Optimization Script Button
$optimizeButton = New-Object System.Windows.Forms.Button
$optimizeButton.Text = "Run Optimization"
$optimizeButton.Size = New-Object System.Drawing.Size(170, 30)
$optimizeButton.Location = New-Object System.Drawing.Point(20, 410)
$optimizeButton.Add_Click({
    Start-Process PowerShell -ArgumentList "-Command iwr -useb https://christitus.com/win | iex" -NoNewWindow -Wait
})
$form.Controls.Add($optimizeButton)

# Create Activation Script Button
$activateButton = New-Object System.Windows.Forms.Button
$activateButton.Text = "Run Activation"
$activateButton.Size = New-Object System.Drawing.Size(170, 30)
$activateButton.Location = New-Object System.Drawing.Point(200, 410)
$activateButton.Add_Click({
    Start-Process PowerShell -ArgumentList "-Command irm https://get.activated.win | iex" -NoNewWindow -Wait
})
$form.Controls.Add($activateButton)

# Show Form
$form.ShowDialog()