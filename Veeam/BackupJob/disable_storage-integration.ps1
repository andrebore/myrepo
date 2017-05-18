asnp VeeamPsSnapIn
 
$jobs=Get-VBRJob
 
foreach ($job in $jobs){
write-host $job.Name
$Options=$job.GetOptions()
$Options.SanIntegrationOptions.UseSanSnapshots = $false
$Options.SanIntegrationOptions.MultipleStorageSnapshotEnabled = $false
$job.SetOptions($Options) | Out-Null
} 
