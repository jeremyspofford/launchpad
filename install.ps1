# Windows Application Installer
# To find package id, run: winget search <app name>

function Test-AdminRights {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Test-WingetAvailable {
    try {
        winget --version | Out-Null
        return $true
    }
    catch {
        Write-Error "Winget is not available. Please install App Installer from Microsoft Store."
        return $false
    }
}

function Install-App {
    param (
        [string]$PackageId
    )

    if (-not (winget list --id $PackageId | Select-String $PackageId)) {
        Write-Host "Installing $PackageId..." -ForegroundColor Green
        winget install --id=$PackageId --accept-source-agreements --accept-package-agreements
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "Failed to install $PackageId"
        }
    } else {
        Write-Host "$PackageId is already installed." -ForegroundColor Yellow
    }
}

function Install-WSL {
    Write-Host "Installing WSL and Ubuntu 24.04..." -ForegroundColor Green
    wsl --install --distribution Ubuntu-24.04
    Write-Host "Please complete Ubuntu setup (username/password) when prompted."
    Read-Host "After Ubuntu setup is complete, press ENTER to continue"
}

function Install-PersonalApps {
    Write-Host "Installing personal applications..." -ForegroundColor Cyan
    Install-App "Valve.Steam"
    # Add more personal apps here as needed
}

function Setup-WSL {
    Write-Host "Setting up WSL environment..." -ForegroundColor Cyan
    
    # Update Ubuntu packages
    wsl -d Ubuntu-24.04 -- bash -c "sudo apt update -y && sudo apt upgrade -y"
    
    # Clone dotfiles repo and run setup
    $repoUrl = "https://github.com/jeremyspofford/dotfiles.git"
    wsl -d Ubuntu-24.04 -- bash -c "if [ ! -d ~/dotfiles ]; then git clone $repoUrl ~/dotfiles; fi"
    wsl -d Ubuntu-24.04 -- bash -c "cd ~/dotfiles && ./init.sh"
}

function Install-ProtonApps {
    Write-Host "Installing Proton applications..." -ForegroundColor Cyan
    Install-App "Proton.ProtonDrive"
    Install-App "Proton.ProtonMail"
    Install-App "Proton.ProtonPass"
    Install-App "Proton.ProtonVPN"
}

function Main {
    Write-Host "Windows Development Environment Setup" -ForegroundColor Magenta
    Write-Host "====================================" -ForegroundColor Magenta
    
    # Check prerequisites
    if (-not (Test-WingetAvailable)) {
        exit 1
    }
    
    if (-not (Test-AdminRights)) {
        Write-Warning "Some operations may require administrator privileges."
    }
    
    # Install core applications
    Write-Host "Installing core development tools..." -ForegroundColor Cyan
    Install-App "AgileBits.1Password"
    Install-App "Obsidian.Obsidian"
    Install-App "Joplin.Joplin"
    Install-App "Brave.Brave"
    Install-App "Anysphere.Cursor"
    Install-App "Docker.DockerDesktop"
    
    # Install Proton suite
    Install-ProtonApps
    
    # Optionally install personal apps
    $installPersonal = Read-Host "Install personal applications? (y/N)"
    if ($installPersonal -eq 'y' -or $installPersonal -eq 'Y') {
        Install-PersonalApps
    }
    
    # Optionally setup WSL
    $setupWSL = Read-Host "Setup WSL and development environment? (y/N)"
    if ($setupWSL -eq 'y' -or $setupWSL -eq 'Y') {
        Install-WSL
        Setup-WSL
    }
    
    Write-Host "Setup complete!" -ForegroundColor Green
}

# Run main function
Main