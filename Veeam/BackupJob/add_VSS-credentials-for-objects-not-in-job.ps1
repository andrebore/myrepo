#to be used in job with containers as a source

asnp VeeamPsSnapin

$vms=@("Telesto","Pandora","Saturn")
$cred = Get-VBRCredentials -name "dummy\dummy"

foreach ($job in Get-VBRJob -Name "dummy*"){
    foreach ($vm in $vms){
        $vm_obj = Find-VBRViEntity -Name $vm
        #VSS options
            Add-VBRViJobObject -Job $job -Entities $vm_obj
            $newoij = Get-VBRJobObject -Job $job -Name $vm_obj.Name
            Set-VBRJobObjectVssOptions -Object $newoij -Credentials $cred | Where-Object {$_.Type -like "Include"}
            $newoij.Info.Type = [Veeam.Backup.Model.CDbObjectInJobInfo+EType]::VssChild
            $newoij.VssOptions.Enabled = $true
            $newoij.VssOptions.IgnoreErrors=$true
            $newoij.VssOptions.VssSnapshotOptions.IsCopyOnly=$true
            Set-VBRJobObjectVssOptions -Object $newoij -Options $newoij.VssOptions
        #

        #Credentials
            Add-VBRViJobObject -Job $job -Entities $vm_obj
            $newoij = Get-VBRJobObject -Job $Job -Name $vm_obj.Name | Where-Object {$_.Type -like "Include"}
            $newoij.Info.Type = [Veeam.Backup.Model.CDbObjectInJobInfo+EType]::GuestCredsChild
            $newoij.VssOptions.WinCredsId=$cred.id
            Set-VBRJobObjectVssOptions -Object $newoij -Options $newoij.VssOptions
        #
        }
    }
