where /q winget
if %ERRORLEVEL% neq 0 (
    echo winget is not installed. Please install winget and try again.
    echo https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.4#install-powershell-using-winget-recommended
    exit /b
)
where /q pwsh
if %ERRORLEVEL% eq 0 (
    echo PowerShell is installed.
    exit /b
)
winget install --id Microsoft.PowerShell --source winget
