if ($ErrorActionPreference -like "SilentlyContinue") {
	Write-Host "Enabling Errors"
	Set-Variable -Name "ErrorActionPreference" -Value "Stop" -Scope Global
} else {
	Write-Host "Disabling Errors"
	Set-Variable -Name "ErrorActionPreference" -Value "SilentlyContinue" -Scope Global
}
