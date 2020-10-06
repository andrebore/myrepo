add-pssnapin VeeamPSSnapin

connect-vbrserver -server 'xxxxxxxxxx'

$days = @("Saturday", "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday")

$d = 0

foreach ($job in Get-VBRJob | Where-Object { $_.SourceType -eq 'VDDK' }) {
    Set-VBRJobAdvancedBackupOptions -Job $job -Algorithm Incremental -TransformFullToSyntethic $true -TransformToSyntethicDays $days[$d] -EnableFullBackup $false
    $d++
    if ($d -ge $days.count) { $d = 0 }
}
