asnp VeeamPsSnapin

foreach ($job in Get-VBRJob){
    $options = $job.GetOptions()
    $options.EnableDeletedVmDataRetention = $true
    $options.BackupStorageOptions.RetainDays = 5
    $job.SetOptions($options) | Out-Null
    }

#modifica
