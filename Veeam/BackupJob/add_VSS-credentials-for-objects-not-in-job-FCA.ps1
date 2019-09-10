Add-PSSnapIn VeeamPsSnapin

$cred = Get-VBRCredentials -name "FGCORP\A010046"

foreach ($job in Get-VBRJob -Name "Backup-DataStore_VNX5600_LUN_HP_C_1003") {
    foreach ($tag in Find-VBRViEntity -Tags -name "BACKUP_APPAWARE" ) {
        #VSS options
        Add-VBRViJobObject -Job $job -Entities $tag
        $newoij = Get-VBRJobObject -Job $job -Name $tag.Name
        Set-VBRJobObjectVssOptions -Object $newoij -Credentials $cred | Where-Object { $_.Type -like "Include" }
        $newoij.Info.Type = [Veeam.Backup.Model.CDbObjectInJobInfo+EType]::VssChild
        $newoij.VssOptions.Enabled = $true
        $newoij.VssOptions.IgnoreErrors = $true
        $newoij.VssOptions.VssSnapshotOptions.IsCopyOnly = $false
        $newoij.VssOptions.SqlBackupOptions.BackupLogsEnabled = $true
        $newoij.VssOptions.SqlBackupOptions.BackupLogsFrequencyMin = "180"
        Set-VBRJobObjectVssOptions -Object $newoij -Options $newoij.VssOptions
        #

        #Credentials
        Add-VBRViJobObject -Job $job -Entities $tag
        $newoij = Get-VBRJobObject -Job $Job -Name $tag.Name | Where-Object { $_.Type -like "Include" }
        $newoij.Info.Type = [Veeam.Backup.Model.CDbObjectInJobInfo+EType]::GuestCredsChild
        $newoij.VssOptions.WinCredsId = $cred.id
        Set-VBRJobObjectVssOptions -Object $newoij -Options $newoij.VssOptions
        #
    }
}
