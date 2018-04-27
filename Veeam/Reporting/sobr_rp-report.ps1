#report per vedere in quale extent sono gli ultimi 3 restore point di una VM


asnp VeeamPSSnapin

foreach ($job in Get-VBRJob) {
       $lastsession=$job.FindLastSession()
       $sessionobjs=$lastsession.GetTaskSessions()

       foreach ($vm in $sessionobjs.Name){
             $rps=Get-VBRRestorePoint -Name $vm | Select -Last 3

             $table = ForEach ($rp in $rps) {

                [PSCustomObject]@{
                     VM = $vm
                      Extent = $rp.FindChainRepositories().Name
                      RestorePoint = $rp.CreationTime
                      Type = $rp.Type
                   }
             }

             $table | Sort-Object -Property RestorePoint -Descending | Format-Table -AutoSize
       }

}
