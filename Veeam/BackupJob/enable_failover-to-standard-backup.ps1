asnp VeeamPSSNapin

$jobs = Get-VBRJob
foreach ($job in $jobs){
$Options = $job.GetOptions()
$Options.SanIntegrationOptions.FailoverFromSan = $True
$Job.SetOptions($Options)
}
