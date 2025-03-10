Add-Type -AssemblyName System.Windows.Forms

# Function to create the main form
function Create-MainForm {
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Winget Application Installer"
    $form.Size = New-Object System.Drawing.Size(400, 500)
    $form.StartPosition = "CenterScreen"
    $form.FormBorderStyle = "FixedDialog"  # Prevent resizing
    return $form
}

# Function to create the application selection TreeView
function Create-TreeView {
    $treeView = New-Object System.Windows.Forms.TreeView
    $treeView.Size = New-Object System.Drawing.Size(350, 300)
    $treeView.Location = New-Object System.Drawing.Point(20, 20)
    $treeView.CheckBoxes = $true  # Allows selection of applications
    return $treeView
}

# Function to populate the TreeView with categorized applications
function Populate-TreeView {
    param($treeView, $appsByCategory)
    foreach ($category in $appsByCategory.Keys) {
        $categoryNode = New-Object System.Windows.Forms.TreeNode($category)
        foreach ($appName in $appsByCategory[$category].Keys) {
            $appNode = New-Object System.Windows.Forms.TreeNode($appName)
            $appNode.Tag = $appsByCategory[$category][$appName]  # Store winget ID for installation
            $categoryNode.Nodes.Add($appNode)
        }
        $treeView.Nodes.Add($categoryNode)
    }
}

# Function to handle checking/unchecking of parent and child nodes
function Configure-TreeViewEvents {
    param($treeView)
    $treeView.add_AfterCheck({
        param($sender, $e)
        if ($e.Action -ne 'ByMouse') { return }  # Prevent infinite loops
        
        $node = $e.Node
        $isChecked = $node.Checked
        
        # Check/uncheck all child nodes when parent is checked/unchecked
        foreach ($childNode in $node.Nodes) {
            $childNode.Checked = $isChecked
        }
        
        # If all child nodes are checked, check the parent node as well
        if ($node.Parent -ne $null) {
            $allChecked = $true
            foreach ($sibling in $node.Parent.Nodes) {
                if (-not $sibling.Checked) {
                    $allChecked = $false
                    break
                }
            }
            $node.Parent.Checked = $allChecked
        }
    })
}

# Function to create the installation status label
function Create-StatusLabel {
    $statusLabel = New-Object System.Windows.Forms.Label
    $statusLabel.Size = New-Object System.Drawing.Size(350, 20)
    $statusLabel.Location = New-Object System.Drawing.Point(20, 330)
    $statusLabel.Text = "Waiting for installation..."
    return $statusLabel
}

# Function to create the install button
function Create-InstallButton {
    param($treeView, $statusLabel)
    $installButton = New-Object System.Windows.Forms.Button
    $installButton.Text = "Install Selected"
    $installButton.Size = New-Object System.Drawing.Size(350, 30)
    $installButton.Location = New-Object System.Drawing.Point(20, 360)
    
    $installButton.Add_Click({
        $selectedApps = @()
        foreach ($categoryNode in $treeView.Nodes) {
            foreach ($appNode in $categoryNode.Nodes) {
                if ($appNode.Checked) {
                    $selectedApps += $appNode.Tag  # Collect selected app IDs
                }
            }
        }
        
        if ($selectedApps.Count -eq 0) {
            [System.Windows.Forms.MessageBox]::Show("No applications selected.", "Warning", "OK", "Warning")
        } else {
            $total = $selectedApps.Count
            foreach ($app in $selectedApps) {
                $index = [array]::IndexOf($selectedApps, $app) + 1
                for ($i = 0; $i -lt 10; $i++) {  # Animation loop (adjust iterations as needed)
                    $dots = "." * (($i % 3) + 1)  # Cycles between ., .., ...
                    $statusLabel.Text = "Installing ($index of $total): $app$dots"
                    Start-Sleep -Milliseconds 500
                }
                Start-Process "winget" -ArgumentList "install --id=$app --accept-package-agreements --accept-source-agreements" -NoNewWindow -Wait
            }
            $statusLabel.Text = "Installation complete."
        }
    })
    return $installButton
}

# Function to create additional buttons
function Create-TitusButton {
    param($text, $xPos)
    
    $button = New-Object System.Windows.Forms.Button
    $button.Text = $text
    $button.Size = New-Object System.Drawing.Size(170, 30)
    $button.Location = New-Object System.Drawing.Point($xPos, 400)

    # Properly define the click event to use the captured variable
    $button.Add_Click([System.EventHandler]{
        Start-Process PowerShell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"iwr -useb https://christitus.com/win | iex`"" -NoNewWindow
    })

    return $button
}

function Create-ActivateButton {
    param($text, $xPos)
    
    $button = New-Object System.Windows.Forms.Button
    $button.Text = $text
    $button.Size = New-Object System.Drawing.Size(170, 30)
    $button.Location = New-Object System.Drawing.Point($xPos, 400)

    # Properly define the click event to use the captured variable
    $button.Add_Click([System.EventHandler]{
        Start-Process PowerShell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"irm https://get.activated.win | iex`"" -NoNewWindow
    })

    return $button
}

# Initialize form and UI elements
$form = Create-MainForm
$treeView = Create-TreeView
$statusLabel = Create-StatusLabel
$installButton = Create-InstallButton -treeView $treeView -statusLabel $statusLabel
$button1 = Create-TitusButton -text "Chris Titus Script" -xPos 20
$button2 = Create-ActivateButton -text "Activate Windows" -xPos 200

# Application categories and IDs
$appsByCategory = @{ 
    "Browsers" = @{ 
        "Google Chrome" = "Google.Chrome"
        "Mozilla Firefox" = "Mozilla.Firefox"
        "Opera GX" = "Opera.OperaGX"
    } 
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

# Populate and configure UI elements
Populate-TreeView -treeView $treeView -appsByCategory $appsByCategory
Configure-TreeViewEvents -treeView $treeView

# Add elements to the form
$form.Controls.Add($treeView)
$form.Controls.Add($statusLabel)
$form.Controls.Add($installButton)
$form.Controls.Add($button1)
$form.Controls.Add($button2)

# Show the Form
$form.ShowDialog()
