# Install WSL on Windows VDI
# This script must be run as Administrator
# Author: Claude
# Date: May 3, 2025

# Check if running as Administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "This script requires Administrator privileges. Please re-run as Administrator."
    Exit 1
}

# Function to check Windows version
function Check-WindowsVersion {
    $osInfo = Get-CimInstance -ClassName Win32_OperatingSystem
    $buildNumber = [int]($osInfo.BuildNumber)
    
    if ($buildNumber -lt 19041) {
        Write-Warning "Windows 10 version 2004 (build 19041) or higher is required for WSL 2."
        Write-Warning "Your current build: $buildNumber"
        Write-Warning "Please update Windows before proceeding."
        return $false
    }
    return $true
}

# Function to check virtualization is enabled
function Check-Virtualization {
    $processorInfo = Get-ComputerInfo -Property "HyperVRequirementVirtualizationFirmwareEnabled"
    if ($processorInfo.HyperVRequirementVirtualizationFirmwareEnabled -eq $true) {
        return $true
    }
    else {
        Write-Warning "Hardware virtualization is not enabled in BIOS/UEFI."
        Write-Warning "WSL 2 requires virtualization to be enabled in your system's BIOS/UEFI."
        Write-Warning "In a VDI environment, nested virtualization must be enabled by your administrator."
        return $false
    }
}

# Function to install WSL
function Install-WSL {
    try {
        Write-Host "Installing WSL..."
        
        # Enable Windows features required for WSL
        Write-Host "Enabling required Windows features..."
        Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart -WarningAction SilentlyContinue | Out-Null
        Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart -WarningAction SilentlyContinue | Out-Null
        
        # Install WSL using wsl --install command (supported on newer Windows versions)
        Write-Host "Installing WSL using wsl --install command..."
        wsl --install --no-distribution
        
        # Download and install the WSL2 kernel update package
        Write-Host "Downloading WSL2 Linux kernel update package..."
        $kernelUpdateUrl = "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi"
        $kernelUpdatePath = "$env:TEMP\wsl_update_x64.msi"
        
        Invoke-WebRequest -Uri $kernelUpdateUrl -OutFile $kernelUpdatePath -UseBasicParsing
        
        Write-Host "Installing WSL2 Linux kernel update package..."
        Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$kernelUpdatePath`" /quiet /norestart" -Wait
        
        # Set WSL 2 as the default version
        Write-Host "Setting WSL 2 as the default version..."
        wsl --set-default-version 2
        
        # Install Ubuntu (default distribution)
        Write-Host "Installing Ubuntu distribution (this may take several minutes)..."
        wsl --install -d Ubuntu
        
        Write-Host "WSL installation completed successfully!" -ForegroundColor Green
        Write-Host "Note: You may need to restart your computer to finalize the installation."
        Write-Host "After reboot, the first time you launch Ubuntu, you'll be prompted to create a user account."
        
        return $true
    }
    catch {
        Write-Warning "Error installing WSL: $_"
        return $false
    }
}

# Main script
Clear-Host
Write-Host "WSL Installation Script for Windows VDI" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host

# Check Windows version
if (-not (Check-WindowsVersion)) {
    exit 1
}

# Check virtualization support
if (-not (Check-Virtualization)) {
    Write-Host "Warning: Virtualization check failed. Attempting to proceed anyway..." -ForegroundColor Yellow
}

# Check if WSL is already installed
$wslCheck = wsl --status 2>&1
if ($wslCheck -notlike "*is not recognized*") {
    Write-Host "WSL appears to be already installed." -ForegroundColor Yellow
    Write-Host "Current WSL status:" -ForegroundColor Yellow
    wsl --status
    
    $confirmation = Read-Host "Do you want to reinstall/update WSL? (y/n)"
    if ($confirmation -ne 'y') {
        exit 0
    }
}

# Install WSL
if (Install-WSL) {
    Write-Host
    Write-Host "Installation process completed." -ForegroundColor Green
    Write-Host "You may need to restart your computer to complete the installation."
    
    $restart = Read-Host "Do you want to restart your computer now? (y/n)"
    if ($restart -eq 'y') {
        Restart-Computer -Force
    }
}
else {
    Write-Host "Installation failed. Please check the error messages above." -ForegroundColor Red
}