asnp VeeamPsSnapin

$today=get-date

foreach ($job in Get-VBRJob -name "SOBR_Backup02"){
    
    (Get-VBRBackup -Name "SOBR_Backup02").GetAllStorages() | where-object {$_.CreationTime -gt $today.AddDays(-1)} | Select-Object -Property `
        @{N="BackupJob";E={$job.Name}},`
        @{N="Name";E={$_.FilePath}},`
        @{N="Date";E={$_.CreationTime}},`
        @{N="Data Size";E={$_.Stats.DataSize}},`
        @{N="Backup Size";E={$_.Stats.BackupSize}},`
        @{N="De-dupe Ratio";E={$_.Stats.DedupRatio}},`
        @{N="Compress Ratio";E={$_.Stats.CompressRatio}} |  Sort Date -Descending | Format-Table
        
        }