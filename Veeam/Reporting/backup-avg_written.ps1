asnp VeeamPSSnapin


$table = @()

foreach ($job in Get-VBRJob | Where-Object {$_.JobType -eq 'Backup'}){

    $sessions=Get-VBRBackupSession | Where {$_.jobId -eq $job.Id.Guid} | Sort EndTimeUTC -Descending | Select -First 3
    $sum = 0

    foreach ($session in $sessions){
        $sum += $session.Info.BackedUpSize
    }

    $data = New-Object System.Object
    $data | Add-Member -type NoteProperty -Name 'Job' -Value $job.Name
    $data | Add-Member -type NoteProperty -Name 'Avg. Written' -Value $(($sum / $sessions.count) / 1GB)
    $table += $data
        
}

$table