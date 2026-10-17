# note to grep command output pipe into: `| out-string -stream | select-string`
# -> Microsoft.PowerShell_profile.ps1 defines "grep" as a function:  function grep {$input | out-string -stream | select-string $args}

param(
	[Parameter(Mandatory=$true)][string]$file,
	[Parameter(Mandatory=$true)][string]$pattern
)
gci -rec -inc "$file" .  | Select-String -Pattern $pattern
