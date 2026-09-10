<#
.SYNOPSIS
    Automates Windows 11 system preferences, debloating, privacy tweaks, and application configurations.
.DESCRIPTION
    Applies developer sanity defaults:
    - Dark mode for system and apps
    - Taskbar auto-hide enabled
    - Remove / Disable Windows Copilot & Windows Recall
    - Disable diagnostic telemetry, advertising ID, and tracking services
    - Restore classic Windows 10 full right-click context menu
    - Enable Windows Developer Mode (unrestricted symlink creation)
    - Remove Taskbar clutter (Widgets and Teams Chat)
    - Disable Start Menu & Settings suggestions, tips, and promotional ads
    - Set File Explorer to show extensions, hidden files, and open to "This PC"
    - Disable Start Menu web/Bing search clutter
    - Disable Sticky Keys prompt (5x Shift)
    - Performance tweaks: Disable Fast Startup and add Windows Defender WSL exclusions
    - Deploy Windows Terminal settings.json (JetBrains Mono Nerd Font, Quake Mode, NixOS default)
    - Deploy global WSL2 .wslconfig (RAM limit, memory reclaim, mirrored networking)
    - Configure Git identity on Windows host
    - Enable NTFS long paths (if run as Administrator)
#>

Clear-Host
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "         Windows 11 Setup & Developer Configuration       " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "[WARNING] Script is running without Administrator privileges." -ForegroundColor DarkYellow
    Write-Host "          User-level tweaks (HKCU) will succeed." -ForegroundColor DarkGray
    Write-Host "          System policies (HKLM services/telemetry/DeveloperMode) will be skipped." -ForegroundColor DarkGray
    Write-Host "          For full debloat and tuning, re-run in PowerShell as Administrator.`n" -ForegroundColor DarkGray
} else {
    Write-Host "[OK] Running with Administrator privileges. Full system tuning enabled.`n" -ForegroundColor Green
}

# -----------------------------------------------------------------------------
# [1/14] Dark Mode for System and Applications
# -----------------------------------------------------------------------------
Write-Host "[1/14] Configuring Dark Theme..." -ForegroundColor Yellow
$themePath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
if (!(Test-Path $themePath)) { New-Item -Path $themePath -Force | Out-Null }
Set-ItemProperty -Path $themePath -Name "SystemUsesLightTheme" -Value 0 -Type DWord -Force
Set-ItemProperty -Path $themePath -Name "AppsUseLightTheme" -Value 0 -Type DWord -Force
Write-Host "  -> [OK] Dark theme enabled for system and applications." -ForegroundColor Green

# -----------------------------------------------------------------------------
# [2/14] File Explorer Preferences
# -----------------------------------------------------------------------------
Write-Host "[2/14] Configuring File Explorer Preferences..." -ForegroundColor Yellow
$explorerAdvanced = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
if (!(Test-Path $explorerAdvanced)) { New-Item -Path $explorerAdvanced -Force | Out-Null }
Set-ItemProperty -Path $explorerAdvanced -Name "HideFileExt" -Value 0 -Type DWord -Force
Set-ItemProperty -Path $explorerAdvanced -Name "Hidden" -Value 1 -Type DWord -Force
Set-ItemProperty -Path $explorerAdvanced -Name "LaunchTo" -Value 1 -Type DWord -Force
Write-Host "  -> [OK] File extensions: Visible." -ForegroundColor Green
Write-Host "  -> [OK] Hidden files: Visible." -ForegroundColor Green
Write-Host "  -> [OK] Default launch location: 'This PC'." -ForegroundColor Green

# -----------------------------------------------------------------------------
# [3/14] Restore Classic Full Right-Click Context Menu
# -----------------------------------------------------------------------------
Write-Host "[3/14] Restoring Classic Context Menu..." -ForegroundColor Yellow
$classicMenuPath = "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32"
if (!(Test-Path $classicMenuPath)) { New-Item -Path $classicMenuPath -Force | Out-Null }
Set-Item -Path $classicMenuPath -Value "" -Force
Write-Host "  -> [OK] Classic Windows 10 right-click menu restored (no 'Show more options')." -ForegroundColor Green

# -----------------------------------------------------------------------------
# [4/14] Taskbar Configuration (Auto-Hide & Clutter Removal)
# -----------------------------------------------------------------------------
Write-Host "[4/14] Configuring Taskbar..." -ForegroundColor Yellow
# Auto-hide taskbar
$stuckRectsPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3"
if (Test-Path $stuckRectsPath) {
    try {
        $settings = (Get-ItemProperty -Path $stuckRectsPath -Name Settings -ErrorAction Stop).Settings
        if ($null -ne $settings -and $settings.Length -gt 8) {
            $settings[8] = 3 # 3 = Auto-hide enabled
            Set-ItemProperty -Path $stuckRectsPath -Name Settings -Value $settings
            Write-Host "  -> [OK] Taskbar auto-hide: Enabled." -ForegroundColor Green
        }
    } catch {
        Write-Host "  -> [WARNING] Could not update taskbar auto-hide: $_" -ForegroundColor DarkYellow
    }
}
# Disable Widgets, Teams Chat, and Copilot taskbar icons
Set-ItemProperty -Path $explorerAdvanced -Name "TaskbarDa" -Value 0 -Type DWord -Force
Set-ItemProperty -Path $explorerAdvanced -Name "TaskbarMn" -Value 0 -Type DWord -Force
Set-ItemProperty -Path $explorerAdvanced -Name "ShowCopilotButton" -Value 0 -Type DWord -Force
Write-Host "  -> [OK] Taskbar buttons removed: Widgets, Teams Chat, Copilot." -ForegroundColor Green

# -----------------------------------------------------------------------------
# [5/14] Remove & Disable Windows Copilot and Recall
# -----------------------------------------------------------------------------
Write-Host "[5/14] Disabling Windows Copilot and Windows Recall..." -ForegroundColor Yellow
$copilotPolicyUser = "HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot"
if (!(Test-Path $copilotPolicyUser)) { New-Item -Path $copilotPolicyUser -Force | Out-Null }
Set-ItemProperty -Path $copilotPolicyUser -Name "TurnOffWindowsCopilot" -Value 1 -Type DWord -Force

$recallPolicyUser = "HKCU:\Software\Policies\Microsoft\Windows\WindowsAI"
if (!(Test-Path $recallPolicyUser)) { New-Item -Path $recallPolicyUser -Force | Out-Null }
Set-ItemProperty -Path $recallPolicyUser -Name "DisableAIDataAnalysis" -Value 1 -Type DWord -Force

if ($isAdmin) {
    $copilotPolicyMachine = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot"
    if (!(Test-Path $copilotPolicyMachine)) { New-Item -Path $copilotPolicyMachine -Force | Out-Null }
    Set-ItemProperty -Path $copilotPolicyMachine -Name "TurnOffWindowsCopilot" -Value 1 -Type DWord -Force

    $recallPolicyMachine = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI"
    if (!(Test-Path $recallPolicyMachine)) { New-Item -Path $recallPolicyMachine -Force | Out-Null }
    Set-ItemProperty -Path $recallPolicyMachine -Name "DisableAIDataAnalysis" -Value 1 -Type DWord -Force
}

# Uninstall Copilot Appx packages
Get-AppxPackage -Name "*Microsoft.Copilot*" -ErrorAction SilentlyContinue | Remove-AppxPackage -ErrorAction SilentlyContinue
Get-AppxPackage -Name "*WindowsCopilot*" -ErrorAction SilentlyContinue | Remove-AppxPackage -ErrorAction SilentlyContinue
if ($isAdmin) {
    Get-AppxPackage -AllUsers -Name "*Microsoft.Copilot*" -ErrorAction SilentlyContinue | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
    Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Where-Object DisplayName -like "*Copilot*" | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
}
Write-Host "  -> [OK] Windows Copilot policies applied and packages removed." -ForegroundColor Green
Write-Host "  -> [OK] Windows Recall AI screen indexing disabled." -ForegroundColor Green

# -----------------------------------------------------------------------------
# [6/14] Disable Diagnostic Telemetry & Privacy Tracking
# -----------------------------------------------------------------------------
Write-Host "[6/14] Disabling Diagnostic Telemetry and Tracking..." -ForegroundColor Yellow
$adPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo"
if (!(Test-Path $adPath)) { New-Item -Path $adPath -Force | Out-Null }
Set-ItemProperty -Path $adPath -Name "Enabled" -Value 0 -Type DWord -Force

$privacyPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy"
if (!(Test-Path $privacyPath)) { New-Item -Path $privacyPath -Force | Out-Null }
Set-ItemProperty -Path $privacyPath -Name "TailoredExperiencesWithDiagnosticDataEnabled" -Value 0 -Type DWord -Force
Write-Host "  -> [OK] Advertising ID and Tailored Experiences disabled." -ForegroundColor Green

if ($isAdmin) {
    $telemetryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
    if (!(Test-Path $telemetryPath)) { New-Item -Path $telemetryPath -Force | Out-Null }
    Set-ItemProperty -Path $telemetryPath -Name "AllowTelemetry" -Value 0 -Type DWord -Force

    $systemPolicies = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"
    if (!(Test-Path $systemPolicies)) { New-Item -Path $systemPolicies -Force | Out-Null }
    Set-ItemProperty -Path $systemPolicies -Name "EnableActivityFeed" -Value 0 -Type DWord -Force
    Set-ItemProperty -Path $systemPolicies -Name "PublishUserActivities" -Value 0 -Type DWord -Force
    Set-ItemProperty -Path $systemPolicies -Name "UploadUserActivities" -Value 0 -Type DWord -Force

    $services = @("DiagTrack", "dmwappushservice")
    foreach ($svc in $services) {
        if (Get-Service -Name $svc -ErrorAction SilentlyContinue) {
            Stop-Service -Name $svc -Force -ErrorAction SilentlyContinue
            Set-Service -Name $svc -StartupType Disabled -ErrorAction SilentlyContinue
            Write-Host "  -> [OK] Telemetry service '$svc': Stopped and Disabled." -ForegroundColor Green
        }
    }
} else {
    Write-Host "  -> [SKIPPED] Machine-level telemetry policies and services (requires Admin)." -ForegroundColor DarkGray
}

# -----------------------------------------------------------------------------
# [7/14] Disable Start Menu & Settings Suggestions / Ads
# -----------------------------------------------------------------------------
Write-Host "[7/14] Disabling Start Menu & System Suggestions/Ads..." -ForegroundColor Yellow
$searchPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search"
if (!(Test-Path $searchPath)) { New-Item -Path $searchPath -Force | Out-Null }
Set-ItemProperty -Path $searchPath -Name "BingSearchEnabled" -Value 0 -Type DWord -Force
Set-ItemProperty -Path $searchPath -Name "CortanaConsent" -Value 0 -Type DWord -Force

$explorerPolicies = "HKCU:\Software\Policies\Microsoft\Windows\Explorer"
if (!(Test-Path $explorerPolicies)) { New-Item -Path $explorerPolicies -Force | Out-Null }
Set-ItemProperty -Path $explorerPolicies -Name "DisableSearchBoxSuggestions" -Value 1 -Type DWord -Force

# Start Menu recommendations (app promos)
Set-ItemProperty -Path $explorerAdvanced -Name "Start_IrisRecommendations" -Value 0 -Type DWord -Force

# Windows tips and promotional suggestions
$cdmPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
if (!(Test-Path $cdmPath)) { New-Item -Path $cdmPath -Force | Out-Null }
Set-ItemProperty -Path $cdmPath -Name "SoftLandingEnabled" -Value 0 -Type DWord -Force
Set-ItemProperty -Path $cdmPath -Name "SubscribedContent-338389Enabled" -Value 0 -Type DWord -Force
Set-ItemProperty -Path $cdmPath -Name "SubscribedContent-338393Enabled" -Value 0 -Type DWord -Force
Set-ItemProperty -Path $cdmPath -Name "SubscribedContent-310093Enabled" -Value 0 -Type DWord -Force
Write-Host "  -> [OK] Start Menu Bing web search disabled." -ForegroundColor Green
Write-Host "  -> [OK] System tips, promotions, and suggested apps disabled." -ForegroundColor Green

# -----------------------------------------------------------------------------
# [8/14] Disable Sticky Keys Pop-up (5x Shift)
# -----------------------------------------------------------------------------
Write-Host "[8/14] Disabling Sticky Keys Pop-up..." -ForegroundColor Yellow
$stickyPath = "HKCU:\Control Panel\Accessibility\StickyKeys"
if (!(Test-Path $stickyPath)) { New-Item -Path $stickyPath -Force | Out-Null }
Set-ItemProperty -Path $stickyPath -Name "Flags" -Value "506" -Force
Write-Host "  -> [OK] Sticky Keys 5x Shift trigger disabled." -ForegroundColor Green

# -----------------------------------------------------------------------------
# [9/14] Developer Mode & NTFS Long Paths
# -----------------------------------------------------------------------------
Write-Host "[9/14] Configuring Developer Mode & Long Paths..." -ForegroundColor Yellow
if ($isAdmin) {
    $appUnlock = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"
    if (!(Test-Path $appUnlock)) { New-Item -Path $appUnlock -Force | Out-Null }
    Set-ItemProperty -Path $appUnlock -Name "AllowDevelopmentWithoutDevLicense" -Value 1 -Type DWord -Force
    Write-Host "  -> [OK] Developer Mode: Enabled (allows unprompted symlinks)." -ForegroundColor Green

    $fsPath = "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem"
    if (Test-Path $fsPath) {
        Set-ItemProperty -Path $fsPath -Name "LongPathsEnabled" -Value 1 -Type DWord -ErrorAction SilentlyContinue
        Write-Host "  -> [OK] NTFS Long Paths (>260 chars): Enabled." -ForegroundColor Green
    }
} else {
    Write-Host "  -> [SKIPPED] Developer Mode and Long Paths (requires Admin)." -ForegroundColor DarkGray
}

# -----------------------------------------------------------------------------
# [10/14] Performance Optimizations (Fast Startup & Defender WSL Exclusions)
# -----------------------------------------------------------------------------
Write-Host "[10/14] Configuring Performance Optimizations..." -ForegroundColor Yellow
if ($isAdmin) {
    # Disable Fast Startup (prevents kernel hibernation & WSL virtualization bugs)
    $powerPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power"
    if (Test-Path $powerPath) {
        Set-ItemProperty -Path $powerPath -Name "HiberbootEnabled" -Value 0 -Type DWord -Force
        Write-Host "  -> [OK] Fast Startup: Disabled (clean cold boots for hypervisor & WSL)." -ForegroundColor Green
    }

    # Windows Defender real-time scanning exclusions for WSL (prevents build slowdowns)
    try {
        Add-MpPreference -ExclusionProcess "wsl.exe", "wslhost.exe" -ErrorAction SilentlyContinue
        Add-MpPreference -ExclusionPath "\\wsl$\*", "\\wsl.localhost\*" -ErrorAction SilentlyContinue
        Write-Host "  -> [OK] Windows Defender exclusions added for WSL processes and network paths." -ForegroundColor Green
    } catch {
        Write-Host "  -> [WARNING] Could not set Windows Defender exclusions: $_" -ForegroundColor DarkYellow
    }
} else {
    Write-Host "  -> [SKIPPED] Fast Startup and Defender exclusions (requires Admin)." -ForegroundColor DarkGray
}

# -----------------------------------------------------------------------------
# [11/14] Deploy Windows Terminal Settings
# -----------------------------------------------------------------------------
Write-Host "[11/14] Deploying Windows Terminal Configuration..." -ForegroundColor Yellow
$terminalSource = Join-Path $PSScriptRoot "configs\terminal\settings.json"
$terminalDestDir = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
$terminalDestFile = Join-Path $terminalDestDir "settings.json"

if (Test-Path $terminalSource) {
    if (Test-Path $terminalDestDir) {
        Copy-Item -Path $terminalSource -Destination $terminalDestFile -Force
        Write-Host "  -> [OK] Windows Terminal settings deployed (JetBrains Mono Nerd Font, Quake Mode, NixOS default)." -ForegroundColor Green
    } else {
        Write-Host "  -> [INFO] Windows Terminal folder not found. (Launch Windows Terminal once, then re-run)." -ForegroundColor DarkGray
    }
} else {
    Write-Host "  -> [WARNING] Source file not found: $terminalSource" -ForegroundColor DarkYellow
}

# -----------------------------------------------------------------------------
# [12/14] Deploy Global WSL2 Configuration (.wslconfig)
# -----------------------------------------------------------------------------
Write-Host "[12/14] Deploying WSL2 Configuration (.wslconfig)..." -ForegroundColor Yellow
$wslConfigSource = Join-Path $PSScriptRoot "configs\wsl\.wslconfig"
$wslConfigDest = Join-Path $env:USERPROFILE ".wslconfig"

if (Test-Path $wslConfigSource) {
    Copy-Item -Path $wslConfigSource -Destination $wslConfigDest -Force
    Write-Host "  -> [OK] .wslconfig deployed to $wslConfigDest (16GB RAM limit, memory reclaim, mirrored network)." -ForegroundColor Green
} else {
    Write-Host "  -> [WARNING] Source file not found: $wslConfigSource" -ForegroundColor DarkYellow
}

# -----------------------------------------------------------------------------
# [13/14] Configure Git Identity on Windows Host
# -----------------------------------------------------------------------------
Write-Host "[13/14] Configuring Git Identity on Windows..." -ForegroundColor Yellow
if (Get-Command git -ErrorAction SilentlyContinue) {
    git config --global user.name "Liam Murphy"
    git config --global user.email "liam@phmurphy.com"
    Write-Host "  -> [OK] Git identity configured: Liam Murphy <liam@phmurphy.com>" -ForegroundColor Green
} else {
    Write-Host "  -> [INFO] Git command not found yet. Run 'winget import -i winget.json' first." -ForegroundColor DarkGray
}

# -----------------------------------------------------------------------------
# [14/14] Restart File Explorer to apply changes
# -----------------------------------------------------------------------------
Write-Host "[14/14] Refreshing File Explorer..." -ForegroundColor Yellow
Stop-Process -Name explorer -Force
Write-Host "  -> [OK] File Explorer restarted. Registry changes applied." -ForegroundColor Green

Write-Host "`n==========================================================" -ForegroundColor Cyan
Write-Host "             Setup completed successfully!                " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
