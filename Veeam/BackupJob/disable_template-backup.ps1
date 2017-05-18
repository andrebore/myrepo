asnp VeeamPsSnapIn
 
foreach ($job in Get-VBRJob -name ""){
$Options=$job.GetOptions()
$Options.ViSourceOptions.BackupTemplates = $false
$job.SetOptions($Options) | Out-Null
} 
