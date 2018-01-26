asnp VeeamPsSnapIn

foreach ($job in Get-VBRJob){
    $obj=$job.GetObjectsInJob() | Where-Object {$_.Type -eq "Exclude"}
    $obj.Delete()
}
