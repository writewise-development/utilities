if ! command -v pwsh &> /dev/null
then
    echo "PowerShell is not installed. Please install PowerShell and try again."
    echo "https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-linux?view=powershell-7.4"
    exit 1
fi
sudo apt-get update
sudo apt-get upgrade powershell
