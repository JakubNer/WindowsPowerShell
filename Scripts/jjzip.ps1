<# 
  .Synopsis
    Zip up folder with 7Zip

  .Description
    Zip up folder with 7Zip
	
  jjzip <archive> <folder>
#>

param(
  [string]$archive,
  [string]$folder
)

if ([string]::IsNullOrEmpty($archive)) {
  Get-Help -Name $MyInvocation.MyCommand.Name
  Exit;
}

if ([string]::IsNullOrEmpty($folder)) {
  Get-Help -Name $MyInvocation.MyCommand.Name
  Exit;
}

# loads another script
. "$scripts/utils.ps1"

$folder = if ($folder -like '*\') {"${folder}*"} else {"${folder}\*"};

EX("& 'C:\Program Files\7-Zip\7z.exe' A -tzip ${archive} ${folder}");