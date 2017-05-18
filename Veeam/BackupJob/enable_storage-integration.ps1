asnp VeeamPsSnapIn
 
$jobs=Get-VBRJob
 
foreach ($job in $jobs){
write-host $job.Name
$Options=$job.GetOptions()
$Options.SanIntegrationOptions.UseSanSnapshots = $true
$Options.SanIntegrationOptions.MultipleStorageSnapshotEnabled = $true
$Options.SanIntegrationOptions.MultipleStorageSnapshotVmsCount = 10
$Options.SanIntegrationOptions.FailoverFromSan = $false
$job.SetOptions($Options) | Out-Null
} 
