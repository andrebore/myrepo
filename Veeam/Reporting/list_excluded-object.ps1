asnp VeeamPsSnapin

Foreach ($job in Get-VBRJob){
  $objs=$job.GetObjectsInJob() | Where-Object {$_.Type -eq "Exclude"}

  $table=[PSCustomObject]@{
      Job = $job.Name
      Object = foreach ($obj in $objs){
        $obj.Name
        }
    }
  $table | Sort-Object -Property Job -Descending #| Format-Table -AutoSize
  }
