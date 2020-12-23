Add-PSSnapin VeeamPsSnapin

<#
Restore list can contain file names only (one per line), the FLR will look up for the item (see the
 -recurse option, line 39)

$targetnas must have the same name as it appears in the VBR console (inventory>file shares)

$targetpath is the UNC path of the target share used to recover the files. if the path does not exist,
it will be created automatically.
credentials to connect to the share cannot be set so the user that is running the script must have
either write rights to the target share or connect to the IPC$ beforehand
#>

# VARs that need customization

$restorelist = 'C:\Users\andrea\Desktop\restore-list.txt'
$targetnas = Get-VBRNASServer -Name '\\itlabfs01\software'
$targetpath = '\\itlabfs01\software\restore'
$nasjob = Get-VBRNASBackup -Name 'NAS_itlabfs01'

##

$rplist = Get-VBRNASBackupRestorePoint -NASBackup $nasjob | Sort-Object -Property CreationTime

Write-Host "Select a restore point:" -ForegroundColor Yellow
for ($i = 0; $i -lt $rplist.count; $i++) {
    Write-Host "$($i): $($rplist[$i].CreationTime)"
}

$selection = Read-Host -Prompt "Enter the number of the restore point"

$rp = Get-VBRNASBackupRestorePoint -Id $rplist[$selection].Id
$session = Start-VBRNASBackupFLRSession -RestorePoint $rp

$itemlist = @()

foreach ($file in get-content $restorelist) {
    $itemlist += (Get-VBRNASBackupFLRItem -Session $session -Name $file -Recurse)
}

Save-VBRNASBackupFLRItem -Item $itemlist -Server $targetnas -Path $targetpath

Stop-VBRNASBackupFLRSession -Session $session