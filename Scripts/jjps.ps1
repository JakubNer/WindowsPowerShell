<# 
  .Synopsis
    Get process ID and process path based on a string match

  .Description
    Get process ID and process path based on a string match
	
  jjps <string> WHERE <string> IS:

  .. some string to be matched in the process path.
#>

param(
    [string]$part
)

# loads another script
. "$scripts/utils.ps1"

function helpfn {
	Get-Help -Name $MyInvocation.ScriptName
}

if ([string]::IsNullOrEmpty($part)) {
    helpfn;
    Exit(1);
}

Get-WmiObject win32_process -Filter "name like '%${part}%'" | select processid,commandline
