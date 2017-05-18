asnp VeeamPSSnapIn

$Job = Get-VBRJob -name "Name of backup job"
$Options = $Job.GetOptions()
$Options.BackupStorageOptions.RetainCycles = 18
$Job.SetOptions($Options)
