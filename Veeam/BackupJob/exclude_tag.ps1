Add-PsSnapin -Name VeeamPSSnapIn -ErrorAction SilentlyContinue

$serverName = "This server"
$server = Get-VBRServer -Name $serverName
$VC = Get-VBRServer -Type "VC"
    foreach ($job in Get-VBRJob){
        try
        {
            $entity = Find-VBRViEntity -Server $VC -Tags -Name "no_trans" -ErrorAction Stop
            Add-VBRViJobObject -Job $job -Entities $entity > null
            $exObj = Get-VBRJobObject -Job $job -Name $entity.Name
            Remove-VBRJobObject -Objects $exObj
        }
        Catch
        {
            echo "Error: unable to find the tag"
        }
    }
    echo Done

echo All Done!
