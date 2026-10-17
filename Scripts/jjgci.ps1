param($pattern)
gci -ea SilentlyContinue -rec -inc "$pattern" . 
