$srcfile = Resolve-Path "IKLG.VM"

& "C:\Games\Gothic2\_work\Tools\VDFS\GothicVDFS.exe" -b $srcfile | Out-Null

$binfile = Resolve-Path "IKLG.DATA"

$addr = 0x118
$bytes = [System.IO.File]::ReadAllBytes($binfile);
$bytes[$addr] = 0x7D;
$bytes[$addr+1] = 0xBF;
$bytes[$addr+2] = 0x9F;
$bytes[$addr+3] = 0x7F;

[System.IO.File]::WriteAllBytes($binfile, $bytes);

$dest = Get-Content -Path outpath.txt
remove-item "$dest\IKLG.DATA"
move-item -path $binfile -destination $dest
