asnp VeeamPsSnapIn

foreach ($job in Get-VBRJob){
    $obj=$job.GetObjectsInJob() | Where-Object {$_.Type -eq "Exclude" -and $_.Name -like "*whatever*"}
    $obj.Delete()
}
