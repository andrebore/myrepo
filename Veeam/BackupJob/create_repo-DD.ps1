Add-PSSnapIn VeeamPsSnapin

$bckserver = get-vbrserver -name "backup server"
$mountserver1 = get-vbrserver -name "mount server 1"
$mountserver2 = get-vbrserver -name "mount server 2"
$cred = get-vbrcredentials -name "utente ddboost"


foreach ( $proxy in get-vbrserver -name "veeamvcdprxas*") {
$reponame = "DD2500mi_VcdRepo" + $proxy.Name.Substring(13,$proxy.Name.Length)
write-host $reponame
#Add-VBRBackupRepository -Name $reponame -Server $bckserver -MountServer $mountserver1 -Type "DataDomain" -DDServerName "DNS name" -Credentials $cred -UsePerVMFile -DecompressDataBlocks
}