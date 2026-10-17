if ($args.length -gt 0) {
    $which = $args[0]
    C:\"Program Files (x86)\PuTTY"\putty.exe -new_console -load "$which"
} else {
    C:\"Program Files (x86)\PuTTY"\putty.exe -new_console
}
