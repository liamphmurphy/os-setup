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
    - Deploy Windows Terminal settings.json (JetBrains Mono Nerd Font, NixOS default)
    - Enable NTFS long paths (if run as Administrator)
#>

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "[NOTE] Running without Administrator privileges. User-level tweaks (HKCU) will succeed; machine-level policies (HKLM services/telemetry/DeveloperMode) will be skipped. Re-run as Administrator for full system debloat." -ForegroundColor DarkYellow
}

Write-Host "=== Setting up Windows 11 Preferences ===" -ForegroundColor Cyan

# 1. Dark Mode for System and Applications
Write-Host "Configuring Dark Theme..." -ForegroundColor Yellow
$themePath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
if (!(Test-Path $themePath)) { New-Item -Path $themePath -Force | Out-Null }
Set-ItemProperty -Path $themePath -Name "SystemUsesLightTheme" -Value 0 -Type DWord -Force
Set-ItemProperty -Path $themePath -Name "AppsUseLightTheme" -Value 0 -Type DWord -Force

# 2. File Explorer Preferences
Write-Host "Configuring File Explorer..." -ForegroundColor Yellow
$explorerAdvanced = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
if (!(Test-Path $explorerAdvanced)) { New-Item -Path $explorerAdvanced -Force | Out-Null }
# Show file extensions & hidden files
Set-ItemProperty -Path $explorerAdvanced -Name "HideFileExt" -Value 0 -Type DWord -Force
Set-ItemProperty -Path $explorerAdvanced -Name "Hidden" -Value 1 -Type DWord -Force
# Open File Explorer to 'This PC' (1) instead of 'Home' (2)
Set-ItemProperty -Path $explorerAdvanced -Name "LaunchTo" -Value 1 -Type DWord -Force

# 3. Restore Classic Full Right-Click Context Menu
Write-Host "Restoring classic right-click context menu..." -ForegroundColor Yellow
$classicMenuPath = "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32"
if (!(Test-Path $classicMenuPath)) { New-Item -Path $classicMenuPath -Force | Out-Null }
Set-Item -Path $classicMenuPath -Value "" -Force
Write-Host "  -> Classic context menu restored." -ForegroundColor Green

# 4. Taskbar Configuration (Auto-Hide & Remove Clutter)
Write-Host "Configuring Taskbar..." -ForegroundColor Yellow
# Auto-hide taskbar
$stuckRectsPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3"
if (Test-Path $stuckRectsPath) {
    try {
        $settings = (Get-ItemProperty -Path $stuckRectsPath -Name Settings -ErrorAction Stop).Settings
        if ($null -ne $settings -and $settings.Length -gt 8) {
            $settings[8] = 3 # 3 = Auto-hide enabled (2 = disabled)
            Set-ItemProperty -Path $stuckRectsPath -Name Settings -Value $settings
            Write-Host "  -> Taskbar auto-hide set to ON." -ForegroundColor Green
        }
    } catch {
        Write-Warning "Could not update taskbar auto-hide setting: $_"
    }
}
# Disable Widgets (News and Interests) and Teams Chat buttons
Set-ItemProperty -Path $explorerAdvanced -Name "TaskbarDa" -Value 0 -Type DWord -Force
Set-ItemProperty -Path $explorerAdvanced -Name "TaskbarMn" -Value 0 -Type DWord -Force
# Hide Copilot button
Set-ItemProperty -Path $explorerAdvanced -Name "ShowCopilotButton" -Value 0 -Type DWord -Force

# 5. Remove & Disable Windows Copilot & Recall
Write-Host "Disabling Windows Copilot & Recall..." -ForegroundColor Yellow
# Copilot policies
$copilotPolicyUser = "HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot"
if (!(Test-Path $copilotPolicyUser)) { New-Item -Path $copilotPolicyUser -Force | Out-Null }
Set-ItemProperty -Path $copilotPolicyUser -Name "TurnOffWindowsCopilot" -Value 1 -Type DWord -Force

# Recall policies
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

# Remove Copilot Appx packages
Get-AppxPackage -Name "*Microsoft.Copilot*" -ErrorAction SilentlyContinue | Remove-AppxPackage -ErrorAction SilentlyContinue
Get-AppxPackage -Name "*WindowsCopilot*" -ErrorAction SilentlyContinue | Remove-AppxPackage -ErrorAction SilentlyContinue
if ($isAdmin) {
    Get-AppxPackage -AllUsers -Name "*Microsoft.Copilot*" -ErrorAction SilentlyContinue | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
    Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Where-Object DisplayName -like "*Copilot*" | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
}
Write-Host "  -> Copilot and Recall disabled." -ForegroundColor Green

# 6. Disable Diagnostic Telemetry & Privacy Tracking
Write-Host "Disabling Telemetry and Tracking..." -ForegroundColor Yellow
$adPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo"
if (!(Test-Path $adPath)) { New-Item -Path $adPath -Force | Out-Null }
Set-ItemProperty -Path $adPath -Name "Enabled" -Value 0 -Type DWord -Force

$privacyPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy"
if (!(Test-Path $privacyPath)) { New-Item -Path $privacyPath -Force | Out-Null }
Set-ItemProperty -Path $privacyPath -Name "TailoredExperiencesWithDiagnosticDataEnabled" -Value 0 -Type DWord -Force

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
            Write-Host "  -> Service '$svc' stopped and disabled." -ForegroundColor Green
        }
    }
}

# 7. Disable Start Menu & Settings Suggestions / Ads
Write-Host "Disabling Start Menu web search clutter & system suggestions..." -ForegroundColor Yellow
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

# 8. Disable Sticky Keys Pop-up (Tap Shift 5x)
Write-Host "Disabling Sticky Keys shortcut pop-up..." -ForegroundColor Yellow
$stickyPath = "HKCU:\Control Panel\Accessibility\StickyKeys"
if (!(Test-Path $stickyPath)) { New-Item -Path $stickyPath -Force | Out-Null }
Set-ItemProperty -Path $stickyPath -Name "Flags" -Value "506" -Force

# 9. Developer Mode & NTFS Long Paths
if ($isAdmin) {
    Write-Host "Enabling Developer Mode (unprompted symlinks) & Long Paths..." -ForegroundColor Yellow
    $appUnlock = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"
    if (!(Test-Path $appUnlock)) { New-Item -Path $appUnlock -Force | Out-Null }
    Set-ItemProperty -Path $appUnlock -Name "AllowDevelopmentWithoutDevLicense" -Value 1 -Type DWord -Force

    $fsPath = "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem"
    if (Test-Path $fsPath) {
        Set-ItemProperty -Path $fsPath -Name "LongPathsEnabled" -Value 1 -Type DWord -ErrorAction SilentlyContinue
    }
}

# 10. Performance Optimizations (Fast Startup & Defender WSL Exclusions)
if ($isAdmin) {
    Write-Host "Configuring performance optimizations (Defender exclusions & Fast Startup)..." -ForegroundColor Yellow
    # Disable Fast Startup (prevents kernel hibernation & WSL virtualization state bugs)
    $powerPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power"
    if (Test-Path $powerPath) {
        Set-ItemProperty -Path $powerPath -Name "HiberbootEnabled" -Value 0 -Type DWord -Force
        Write-Host "  -> Fast Startup disabled (ensures clean cold boots for WSL)." -ForegroundColor Green
    }

    # Windows Defender real-time scanning exclusions for WSL (3-5x disk build speedup)
    try {
        Add-MpPreference -ExclusionProcess "wsl.exe", "wslhost.exe" -ErrorAction SilentlyContinue
        Add-MpPreference -ExclusionPath "\\wsl$\*", "\\wsl.localhost\*" -ErrorAction SilentlyContinue
        Write-Host "  -> Windows Defender exclusions added for WSL processes and network paths." -ForegroundColor Green
    } catch {
        Write-Warning "Could not update Windows Defender preferences: $_"
    }
}

# 11. Deploy Windows Terminal Settings
$terminalSource = Join-Path $PSScriptRoot "configs\terminal\settings.json"
$terminalDestDir = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
$terminalDestFile = Join-Path $terminalDestDir "settings.json"

if (Test-Path $terminalSource) {
    Write-Host "Deploying Windows Terminal settings..." -ForegroundColor Yellow
    if (Test-Path $terminalDestDir) {
        Copy-Item -Path $terminalSource -Destination $terminalDestFile -Force
        Write-Host "  -> Windows Terminal settings deployed." -ForegroundColor Green
    } else {
        Write-Host "  -> Windows Terminal data folder not found (launch Windows Terminal once first)." -ForegroundColor DarkGray
    }
}

# 12. Deploy Global WSL2 Configuration (.wslconfig)
$wslConfigSource = Join-Path $PSScriptRoot "configs\wsl\.wslconfig"
$wslConfigDest = Join-Path $env:USERPROFILE ".wslconfig"

if (Test-Path $wslConfigSource) {
    Write-Host "Deploying WSL2 configuration (.wslconfig)..." -ForegroundColor Yellow
    Copy-Item -Path $wslConfigSource -Destination $wslConfigDest -Force
    Write-Host "  -> .wslconfig deployed to $wslConfigDest" -ForegroundColor Green
}

# 13. Restart File Explorer to apply changes
Write-Host "Restarting File Explorer to refresh settings..." -ForegroundColor Yellow
Stop-Process -Name explorer -Force

Write-Host "=== Setup completed successfully! ===" -ForegroundColor Green
