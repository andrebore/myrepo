Asnp VeeamPSSnapin

#$job = Get-VBRJob -Name 

foreach ($job in Get-VBRJob){
if ($job.FindLastSession().Logger.GetLog().UpdatedRecords.Title | Select-String "Synthetic") {write-host "Session Included Synthetic Full”}
if ($job.FindLastSession().Logger.GetLog().UpdatedRecords.Title | Select-String "Transformation") {write-host "Session Included Synthetic Full. Previous restore points have been successfully transformed into rollbacks.”}
}
