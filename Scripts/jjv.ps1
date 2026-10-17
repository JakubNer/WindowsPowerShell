$SRV = [System.Diagnostics.Process]::GetCurrentProcess().Id
$FILE = '.'
if ($args.length -eq 1) {
	$FILE = $args[0];
}
if ($args.length -eq 2) {
	$SRV = $args[0];
	$FILE = $args[1];
}
C:\"Program Files (x86)\vim\vim73"\gvim.exe --servername $SRV --remote-tab $FILE
