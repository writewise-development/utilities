if (!(Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Output "winget is not installed. Please install winget and try again."
    Write-Output "https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.4#install-powershell-using-winget-recommended"
    exit 1
}
winget upgrade --id Microsoft.PowerShell -e
