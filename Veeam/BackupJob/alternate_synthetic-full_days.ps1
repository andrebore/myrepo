if ((Get-PSSnapin -Name VeeamPSSnapin -ErrorAction SilentlyContinue) -eq $null) { add-pssnapin VeeamPSSnapin }

$days = @("Saturday", "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday")

$d = 0

$jobs = get-vbrjob | ? { $_.JobType -eq "Backup" } | sort Name
foreach ($job in $jobs) {
    write-host $job.Name $days[$d]
    Set-VBRJobAdvancedBackupOptions -Job $job -Algorithm Incremental -TransformIncrementsToSyntethic $true -TransformIncrementsToSyntethic $false -TransformToSyntethicDays $days[$d] -EnableFullBackup $false
    $d++
    if ($d -ge $days.count) { $d = 0 }
}
