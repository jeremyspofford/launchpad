# To find package id, run: winget search <app name>

function Install-App {
    param (
        [string]$PackageId
    )

    if (-not (winget list --id $PackageId | Select-String $PackageId)) {
        Write-Host "Installing $PackageId..."
        winget install --id=$PackageId --accept-source-agreements --accept-package-agreements
    } else {
        Write-Host "$PackageId is already installed."
    }
}

function Install-WSL {
    wsl install
    wsl.exe --install "Ubuntu-24.04"
    Read-Host "Complete Ubuntu setup (username/password), then press ENTER to continue."
}

function Personal-Apps {
    Install-App "Valve.Steam"
# BitDefender
}

function Setup-WSL {
   wsl -d Ubuntu-24.04 -- bash -c "sudo apt update -y && sudo apt upgrade -y"
#   wsl -d Ubuntu-24.04 -- bash -c "sudo apt install -y ...."
# clone repo
# # Clone dotfiles repo (replace with yours)
# wsl -d Ubuntu -- bash -c "git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/dotfiles"

# Run a bootstrap script from your dotfiles
# wsl -d Ubuntu -- bash -c "cd ~/dotfiles && ./bootstrap.sh"
}

function Install-Proton {
    Install-App "Proton.ProtonDrive"
    Install-App "Proton.ProtonMail"
    Install-App "Proton.ProtonPass"
    Install-App "Proton.ProtonVPN"
}

Install-App "AgileBits.1Password"
Install-App "Obsidian.Obsidian"
Install-App "Joplin.Joplin"
Install-App "Brave.Brave"
Install-App "Anysphere.Cursor"
Install-Proton
Install-App "Docker.DockerDesktop"
