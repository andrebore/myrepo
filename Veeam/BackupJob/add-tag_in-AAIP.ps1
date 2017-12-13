asnp VeeamPsSnapin

$cred = Get-VBRCredentials -name "FGCORP\A010046"

foreach ($job in Get-VBRJob){
      foreach ($tag in Find-VBRViEntity -Tags -name "metti il nome del tag qui!" ){
        #VSS options
            Add-VBRViJobObject -Job $job -Entities $tag
            $newoij = Get-VBRJobObject -Job $job -Name $tag.Name
            Set-VBRJobObjectVssOptions -Object $newoij -Credentials $cred | Where-Object {$_.Type -like "Include"}
            $newoij.Info.Type = [Veeam.Backup.Model.CDbObjectInJobInfo+EType]::VssChild
            $newoij.VssOptions.Enabled = $false
            Set-VBRJobObjectVssOptions -Object $newoij -Options $newoij.VssOptions
        #
        }
      }
