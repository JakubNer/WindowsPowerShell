<# 
  .Synopsis
    Touch file

  .Description
    Touch file
	
  jjtouch <string> WHERE <string> IS:

  .. some file
#>

param(
    [string]$filename
)

# loads another script
. "$scripts/utils.ps1"

function helpfn {
	Get-Help -Name $MyInvocation.ScriptName
}

if ([string]::IsNullOrEmpty($filename)) {
    helpfn;
    Exit(1);
}


(Get-Item $filename).LastWriteTime = Get-Date