if ($global:WindowsPowerShellProfileRepositoryLoaded) {
    return
}
$global:WindowsPowerShellProfileRepositoryLoaded = $true

$profileRepository = Split-Path -Parent $MyInvocation.MyCommand.Path
$mainProfile = Join-Path $profileRepository 'Microsoft.PowerShell_profile.ps1'

. $mainProfile
