# $find can be a regular expressions, replace all $find in $file and output to $out, $out could be 

param(
	[Parameter(Mandatory=$true)][string]$file,
  [Parameter(Mandatory=$true)][string]$find,
	[Parameter(Mandatory=$true)][string]$replace,
	[Parameter(Mandatory=$false)][string]$out
)

if ([string]::IsNullOrEmpty($out)) {
  (Get-Content -Path $file) -replace $find, $replace
} else {
  (Get-Content -Path $file) -replace $find, $replace | Set-Content $out
}
