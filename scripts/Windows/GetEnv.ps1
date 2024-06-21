$env = @{}
$user = wsl sh -c "whoami 2>/dev/null"
$username = $Env:USERNAME
Get-Content $PSScriptRoot/../.env | ForEach-Object {
  $name, $value = $_.split('=')
  if (-not [String]::IsNullOrWhiteSpace($name) -and -not $name.Contains('#')) {
    $env.Keys | ForEach-Object {
        $value = $value.replace("`$USERNAME", "$username")        
        $value = $value.replace("`$USER", "$user")
        $value = $value.replace("`${$_}", "$($env[$_])")
    }
    $env.add($name.Trim(), $value.split('#')[0].Trim())
  }
}
