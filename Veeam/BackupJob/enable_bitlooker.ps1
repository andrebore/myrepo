asnp VeeamPSSNapin

foreach ($Job in Get-VBRJob | where {$_.JobType -eq "Backup" -or $_.JobType -eq "Replica"})
{
$Options = $Job.GetOptions()
$Options.ViSourceOptions.DirtyBlocksNullingEnabled = $True
$Job.SetOptions($Options)
}
