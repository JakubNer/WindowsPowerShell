<# 
  .Synopsis
    Copy a random subset of music files from the current folder and all subfolders to a destination folder.
  
    Maintains directory structure relative to current directory (copy started from).

  .Description
    Copy a random subset of files from the current folder and all subfolders to a destination folder.
  
    Maintains directory structure relative to current directory (copy started from).
	
  jjmp3 <number> <destination> <subfolder> WHERE:
  
  [number] of files to copy
  [destination] target folder to copy to
  [subfolder] optional subfolder of current folder to copy from
#>

param(
  [string]$number_files,
	[string]$target_folder,
  [string]$subfolder
)

if ([string]::IsNullOrEmpty($number_files)) {
  Get-Help -Name $MyInvocation.MyCommand.Name
  Exit;
}

if ([string]::IsNullOrEmpty($target_folder)) {
  Get-Help -Name $MyInvocation.MyCommand.Name
  Exit;
}

if ([string]::IsNullOrEmpty($subfolder)) {
  $subfolder = "";
}

$target_folder = $target_folder.TrimEnd('\\') + "\\";
$subfolder = $subfolder.TrimStart('.\\') + ".\\";
$ext = ".mp3"

function copy_file_with_folder($what) {
  $targetFile = $target_folder + $what.FullName.SubString($pwd.path.Length + 1); 
  if (-not (Test-Path $targetFile)) {
    New-Item -ItemType File -Path $targetFile -Force;  
    Copy-Item $what.FullName -destination $targetFile;
  }
}

Get-ChildItem -recurse ${subfolder}  | where {$_.extension -eq $ext} | Get-Random -Count $number_files | % { copy_file_with_folder($_) }

