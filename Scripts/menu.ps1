function DrawMenu {
    ## supportfunction to the Menu function below
    param ([array]$menuItems, $menuPosition, $page, $menuTitel, $footer)
    $fcolor = $host.UI.RawUI.ForegroundColor
    $bcolor = $host.UI.RawUI.BackgroundColor
    $l = $menuItems.length
    cls
    $menuwidth = $menuTitel.length + 4
    Write-Host "`t" -NoNewLine
    Write-Host ("*" * $menuwidth) -fore $fcolor -back $bcolor
    Write-Host "`t" -NoNewLine
    Write-Host "* $menuTitel *" -fore $fcolor -back $bcolor
    Write-Host "`t" -NoNewLine
    Write-Host ("*" * $menuwidth) -fore $fcolor -back $bcolor
    Write-Host ""
    Write-debug "L: $l MenuItems: $menuItems menuPosition: $menuPosition page: $page"
    for ($i = $page * 10; $i -lt $l;$i++) {
        Write-Host "`t" -NoNewLine
        $index = $i % 10;
        if ($i -eq $menuPosition) {
            Write-Host "[$index]  $($menuItems[$i])" -fore $bcolor -back $fcolor
        } else {
            Write-Host "[$index]  $($menuItems[$i])" -fore $fcolor -back $bcolor
        }
        if ($index -eq 9) {break;}
    }
    Write-Host ""
    Write-Host ""
    Write-Host $footer
    Write-Host ""
}

function AmmendMenuTitle {
    param ([array]$items, $page, $title)
    $start = $page * 10 + 1
    $howmany = $items.length
    $stop = $page * 10 + 10
    if ($stop -gt $howmany) {$stop = $howmany}
    Write-Output "$title [$start-$stop/$howmany]"
}

function Menu {
    ## Generate a small "DOS-like" menu.
    ## Choose a menuitem using up and down arrows, select by pressing ENTER
    param ([array]$menuItems, $menuTitel = "MENU", $footer = "", [ref]$keyPressed)
    $page = 0
    $pos = 0
    $vkeycode = 0
    $titel = AmmendMenuTitle $menuItems $page $menuTitel
    DrawMenu $menuItems $pos $page $titel $footer
    While ($vkeycode -ne 13) {
        $press = $host.ui.rawui.readkey("NoEcho,IncludeKeyDown")
        $vkeycode = $press.virtualkeycode
        Write-host "$($press.character)" -NoNewLine
        If ($vkeycode -eq 38 -and $pos % 10 -ne 0) {$pos--}
        If ($vkeycode -eq 40 -and $pos % 10 -ne 9) {$pos++}
        If ($vkeycode -eq 33 -and $page -gt 0) {$page=$page-1;$pos=$page*10}
        If ($vkeycode -eq 34 -and (($page+1)*10) -lt $menuItems.length) {$page=$page+1;$pos=$page*10}
        If ($vkeycode -eq 35) {$pos = $page*10+9; if ($pos -ge $menuItems.length) {$pos = $menuItems.length -1}}
        If ($vkeycode -eq 36) {$pos = $page*10}
        If ($vkeycode -ge 48 -and $vkeycode -le 57) {$pos = ($page*10 + $vkeycode - 48)}
        If ($vkeycode -eq 27) {if ($keyPressed) {$keyPressed.value = "ESC"}; break}
        If ($vkeycode -eq 13) {if ($keyPressed) {$keyPressed.value = "ENTER"}; break}
        If ($vkeycode -eq 32) {if ($keyPressed) {$keyPressed.value = "SPACE"}; break}
        If ($vkeycode -eq 9) {if ($keyPressed) {$keyPressed.value = "TAB"}; break}
        if ($vkeycode -ge 65 -and $vkeycode -le 90) {if ($keyPressed) {$keyPressed.value = $press.character}; break}
        if ($pos -lt 0) {$pos = 0}
        if ($pos -ge $menuItems.length) {$pos = $menuItems.length -1}
        $titel = AmmendMenuTitle $menuItems $page $menuTitel
        DrawMenu $menuItems $pos $page $titel $footer
    }
    if ($menuItems.Count -gt 0) {
        Write-Output $($menuItems[$pos]);
    } 
}
