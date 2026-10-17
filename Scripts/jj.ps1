<# 
  .Synopsis
    Quick sample for writing other PS scripts.

  .Description
    All parameters optional.  Without any parameters prints out help.
	
  jj <action> WHERE <action> IS:

  [help] to print help
  [dostuff] to do stuff
#>

param(
	[ValidateSet(
		"help", 
		"dostuff"
	)] [string]$action="help",
	[parameter(ValueFromRemainingArguments=$true)]$remaining_args
)

# loads another script
. "$scripts/utils.ps1"

function helpfn {
	Get-Help -Name $MyInvocation.ScriptName
}

function help_dostuff {
	param ([string]$dostuff_args)
	if ($dostuff_args.length -ne 0) {return;}
	write-host @"
...dostuff <path> <choice> WHERE <choice> IS:
		[xxx] ...
		[yyy] ...
		[zzz] ...
"@
	Exit;
}

function dostuff
{
	param(
		[Parameter(Mandatory=$false)][string]$mypath=".",
		[parameter(mandatory=$true)][ValidateSet(
			"xxx", 
			"yyy",
			"zzz"
		)][string]$choice
	)
	
	# uses defines from that other script
	EX "& dir $mypath";
	
	Write-Host "Chosen $choice";

	# binds a global variable
	$global:mypath = $mypath
}

switch ($action) {
	"help" {helpfn}
	"dostuff" {help_dostuff $remaining_args; dostuff @remaining_args}
}



#
# The above works on the assumption we want an "action" and default to the get "help" action.
#
# If we have a simple script and just want to validate we have some parameters we can replace all of the above with:
#
#      param(
#        [string]$number_files,
#      	[string]$target_folder
#      )
#      
#      if ([string]::IsNullOrEmpty($number_files)) {
#        Get-Help -Name $MyInvocation.MyCommand.Name
#        Exit;
#      }
#      
#      if ([string]::IsNullOrEmpty($target_folder)) {
#        Get-Help -Name $MyInvocation.MyCommand.Name
#        Exit;
#      }
#



# Notice jjtestbar has a mandatory enum
#
# This function is now available on the command prompt.  Uses global bind above.
#
# Notice the `t tabs and `n newline
#
# Write jjtestfoo -? to get help, or get-help jjtestfoo
function global:jjtestfoo
{ 
	<# 
	  .Synopsis
		A bound method

	  .Parameter noun
		[mandatory] One of "World", "Galaxy", "Universe".
		
	  .Parameter num
		Number between 21 and 65
		
	  .Parameter path
		Valid folder.
	#>
	[CmdletBinding()]
    Param( 
		[Parameter(Mandatory=$true)]
        [ValidateSet("World", "Galaxy", "Universe")] 
        [String] 
        $noun
    , 
        [ValidateRange(21,65)] 
        [Int] 
        $num
    , 
        [ValidateScript({Test-Path $_ -PathType 'Container'})] 
        [string] 
        $path 
    ) 

	write-host "`t`tHello, " $noun " :: " $num " :: " $path " `n`t`t`t...from $global:mypath"
}