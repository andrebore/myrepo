asnp veeampssnapin

$jobname = "VMware - Veeam Explorers"
$vmname = "demo-AD"
$origfile = "C:\Windows\NTDS"

$rp = Get-VBRBackup -Name $jobname | Get-VBRRestorePoint -name $vmname | Sort-Object creationtime -Descending | Select -First 1 | Start-VBRWindowsFileRestore

#Trovo il mount point per il disco del guest
$flrmountpoint = ($rp.MountSession.MountedDevices | ? {$_.DriveLetter -eq (Split-Path -Qualifier $origfile)}).MountPoint

#Costruisco il path del file da ripristinare
$file = $flrmountpoint + (Split-Path -NoQualifier $origfile)

#Lanciare il ripristino con la copia di Windows
#o usare:
# $session = Get-VBRRestoreSession | ? {$_.Id -eq $rp.MountSession.RestoreSessionInfo.Id}
# $credentials = Get-VBRCredentials -Name "Administrator"
# Start-VBRWindowsGuestItemRestore -Path "file da ripristinare" -Session $session -RestorePolicy Keep -GuestCredentials $credentials
