asnp VeeamPSSnapIn -ErrorAction SilentlyContinue

ForEach ($winrepo in Get-VBRBackupRepository | where Type -eq "WinLocal") {
    $winreponame = $winrepo.GetHost().Name;

    #unc path conversion
    $winrepopath = "\\{0}\{1}" -f ($winreponame, $winrepo.FriendlyPath.Replace(":", "$"));

    #find vbms recursively
    $vbms = Get-ChildItem -Path $winrepopath -Filter "*.vbm" -Recurse -ErrorAction SilentlyContinue -Force

    #import
    ForEach ($vbm in $vbms) {
        $name=$vbm.Name
        $path=$vbm.DirectoryName
        $winrepo.GetHost() | Import-VBRBackup -Filename $path\$name
    }
}

#encrypted backup
$password = Get-Content "C:\cred.txt"
$encryptedrps = Get-VBRImportedEncryptedBackup
Set-VBREncryptedBackupPassword -Backup $encryptedrps -Password $password
