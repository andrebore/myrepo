asnp VeeamPsSnapin

$repositories=@("CIFS_Repo0","CIFS_Repo1","CIFS_Repo2")
$week=@("Saturday", "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday")
$day=0
$VSSCredentials = get-vbrcredentials -name "solarsystem\administrator"
$midnight=get-date -hour 0 -minute 0 -Second 0
$minutes=0
$counter=0

#Creazione Job
    foreach ($datastore in get-vbrserver -name atlas.solarsystem.local | Find-VBRViDatastore | Where-Object {$_.Name -notlike '*local'}){
        Add-VBRViBackupJob -Name "Backup-$datastore" -Entity $datastore -BackupRepository $repositories[$counter]
        $counter++
        if ($counter -ge $repositories.count){
            $counter = 0
            }
        }

#Set parametri
foreach ($job in Get-VBRJob -name "Backup-*"){

    #Advanced backup options
        Set-VBRJobAdvancedBackupOptions -Job $job -Algorithm Incremental -TransformIncrementsToSyntethic $false -TransformToSyntethicDays $week[$day] -EnableFullBackup $false
        $day++
        if ($day -ge $week.count){
            $day = 0
            }
    #

    #Storage options
        $Options=$job.GetOptions()
        $Options.SanIntegrationOptions.UseSanSnapshots = $true
        $Options.SanIntegrationOptions.MultipleStorageSnapshotEnabled = $true
        $Options.SanIntegrationOptions.MultipleStorageSnapshotVmsCount = 10
        $Options.SanIntegrationOptions.FailoverFromSan = $false
        $Options.BackupStorageOptions.StgBlockSize="KbBlockSize4096"
        $Options.BackupStorageOptions.EnableDeduplication=$false
        $Options.BackupStorageOptions.CompressionLevel=5
        $job.SetOptions($Options) | Out-Null
    #

    #Schedulazione
        Set-VBRJobSchedule -job $job -Daily -At $midnight.AddMinutes($minutes)
        Enable-VBRJobSchedule -Job $job
        $minutes=$minutes+10
    #

    #VSS
        $jobVSSOptions = Get-VBRJobVSSOptions -job $job
        $jobVSSOptions.Enabled = $true
        foreach ($jobObject in ($job | Get-VBRJobObject)){
            $ObjectVSSOptions = Get-VBRJobObjectVssOptions -ObjectInJob $jobObject
            $ObjectVSSOptions.IgnoreErrors = $true
            $ObjectVSSOptions.VssSnapshotOptions.IsCopyOnly=$true
            Set-VBRJobObjectVssOptions -Object $jobObject -Options $ObjectVSSOptions
            }
        Set-VBRJobVssOptions -job $job -Options $JobVSSOptions
        Set-VBRJobVSSOptions -job $job -Credentials $VSSCredentials
    #
    }
