<# 
  .Synopsis
    Reset network adapter

  .Description
    All parameters optional.  Without any parameters prints out help.
	
  jjnetreset <action> WHERE <action> IS:

  [determine] print out network adapters 
  [edit] this file with the determined network adapter
  [reset] the network adapter
#>

param(
	[ValidateSet(  
    "help",
		"determine", 
    "edit",
		"reset"
	)] [string]$action="help",
	[parameter(ValueFromRemainingArguments=$true)]$remaining_args
)

# loads another script
. "$scripts/utils.ps1"

function helpfn {
	Get-Help -Name $MyInvocation.ScriptName
}

switch ($action) {
  "help" {helpfn}
	"determine" {Get-NetAdapter}
  "edit" {jjnp $MyInvocation.MyCommand.Definition}
	"reset" {restart-netadapter -InterfaceDescription 'Intel(R) Dual Band Wireless-AC 7265' -Confirm:$false}
}