asnp VeeamPsSnapin

$VSSCredentials = get-vbrcredentials -name "user here!"


foreach ($job in Get-VBRJob -name "Backup-*"){

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


}