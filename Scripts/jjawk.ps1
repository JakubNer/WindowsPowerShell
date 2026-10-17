# $pattern should have one group match like:  "POSTGRES_PASSWORD:\s*([^\s]+)"

param(
	[Parameter(Mandatory=$true)][string]$file,
	[Parameter(Mandatory=$true)][string]$pattern
)
select-string -Path $file -Pattern $pattern -AllMatches | % { $_.matches.groups[1] } | % { $_.Value }