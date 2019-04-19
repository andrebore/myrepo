Add-PSSnapin VeeamPsSnapin

$repo = Get-Get-VBRBackupRepository -Name "my repo name here!"
Sync-VBRBackupRepository -Repository $repo
