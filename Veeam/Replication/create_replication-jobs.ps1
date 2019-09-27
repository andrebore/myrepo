Add-PSSnapin -Name VeeamPSsnapin

function Split-Array ([object[]]$InputObject,[int]$SplitSize)
{
$length=$InputObject.Length
for ($Index = 0; $Index -lt $length; $Index += $SplitSize)
{
#, encapsulates result in array
#-1 because we index the array from 0
,($InputObject[$index..($index+$splitSize-1)])
}
}

$object = Find-VBRViEntity -VMsAndTemplates -Name ##### | Sort-Object -Property -Name
$objectrnd = $object | Sort-Object { Get-Random }
$vmlist = Split-Array -InputObject $objectrnd -SplitSize 10 #Defines how many VMs per job

$repo = Get-VBRBackupRepository -Name #####
$drhost = Get-VBRServer -Name ####

$starttime = get-date -hour 0 -minute 0 -Second 0
$minutes = 0

#Network mapping
$server = Get-VBRServer -Type ESXi -Name ####
$srcnet1 = Get-VBRViServerNetworkInfo -Server $server | Where-Object {$_.NetworkName -eq '####'}
$tgtnet1 = Get-VBRViServerNetworkInfo -Server $server | Where-Object {$_.NetworkName -eq '####'}
$srcnet2 = Get-VBRViServerNetworkInfo -Server $server | Where-Object {$_.NetworkName -eq '####'}
$tgtnet2 = Get-VBRViServerNetworkInfo -Server $server | Where-Object {$_.NetworkName -eq '####'}

#Job creation
$i=0
while ($i -lt $vmlist.Count){
    $jobname = '####' + "{0:D2}" -f $i
    Add-VBRViReplicaJob -Name $jobname -Server $drhost -Entity $vmlist[$i] -BackupRepository $repo -RestorePointsToKeep 2 -EnableNetworkMapping -SourceNetwork $srcnet1,$srcnet2 -TargetNetwork $tgtnet1,$tgtnet2
    $i++
}

#Job configuration
foreach ($job in Get-VBRJob -name "####" | Sort-Object -Property Name) {
    #Schedule
    Set-VBRJobSchedule -job $job -Daily -At $starttime.AddMinutes($minutes)
    Enable-VBRJobSchedule -Job $job
    $minutes = $minutes + 10
}
