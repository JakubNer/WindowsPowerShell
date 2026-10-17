<# 
  .Synopsis
   Run ctags on a folder.

  .Description
   Uses $scripts\.ctags.
  
  .Parameter tagsFileName
   Name of tags file to creates.  Probably ./TAGS
  
  .Parameter folderToTag
   Path to folder to tag.  Probably .
#>

param(
	[Parameter(Mandatory=$true)][string]$tagsFileName,
	[Parameter(Mandatory=$true)][ValidateScript({Test-Path $_ -PathType 'Container'})][string]$folderToTag,
	[Parameter(Mandatory=$true)][ValidateSet("PB12","Clojure")][string]$language
)

. "$scripts/utils.ps1"

EX "& J:\usr\ctags\ctags --options=$scripts\.ctags --languages=$language --recurse=yes -f $tagsFileName $folderToTag";