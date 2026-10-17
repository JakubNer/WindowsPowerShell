param($url,$path)

# A PowerShell script to wget from URI to a path.

$client = New-Object System.Net.WebClient
Invoke-WebRequest -Uri $url -OutFile $path