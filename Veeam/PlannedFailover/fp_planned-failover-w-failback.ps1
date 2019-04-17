asnp VeeamPsSnapin

$fp = Get-VBRFailoverPlan -Name "test-script"
$rplist = @()

#Get RestorePoint list

foreach ($vm in $fp.FailoverPlanObject){
  $rp = Get-VBRRestorePoint -Name $vm | where-object {$_.Type -eq "Snapshot"} | Sort-Object $_.creationtime -Descending | Select -First 1
  $rplist += @($rp)
}

foreach ($restorepoint in $rplist){
  $status = Get-VBRReplicaStatus -RestorePoint $restorepoint
  if ($status -eq "Failover"){
    Start-VBRViReplicaFailback -RestorePoint $restorepoint -PowerOn -RunAsync
    } else {
      write-host "Replica not processed"
      }
}


#Commit failback

Read-Host -Prompt "Press any key to commit failback or CTRL-C to exit"

foreach ($restorepoint in $rplist){
  $status = Get-VBRReplicaStatus -RestorePoint $restorepoint
  if ($status -eq "Failback"){
    Start-VBRViReplicaFailback -RestorePoint $restorepoint -Complete -RunAsync
    } else {
      write-host "Replica not processed"
      }
}