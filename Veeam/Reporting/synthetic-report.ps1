Add-PSSnapIn VeeamPsSnapin

connect-vbrserver -server 'xxxxxxxxxxxxx'

foreach ($job in Get-VBRJob | Where-Object { $_.SourceType -eq 'VDDK' }) {
    $job.GetOptions() | Select-Object -Property `
    @{N = "BackupJob"; E = { $job.Name }}, `
    @{N = "Backup Method"; E = { $_.BackupTargetOptions.Algorithm }}, `
    @{N = "Synthetic Enabled"; E = { $_.BackupTargetOptions.TransformFullToSyntethic }}, `
    @{N = "Synthetic Day"; E = { $_.BackupTargetOptions.TransformToSyntethicDays }} | Sort-Object BackupJob -Descending | Format-Table
    
}