if ! command -v pwsh &> /dev/null
then
    echo "PowerShell is not installed. Installing..."
    wget -q "https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb"
    sudo dpkg -i packages-microsoft-prod.deb
    rm packages-microsoft-prod.deb
    sudo apt-get update
    sudo apt-get install -y powershell
else
    echo "PowerShell is installed."
fi
