$backupserver = "vbr8.solarsystem.local"
$username = "solarsystem\veeam8"
$password = convertto-securestring -string "V33am.123" -asplaintext -force
$credentials = new-object -typename System.Management.Automation.PSCredential -argumentlist $Username, $Password

#Get failed VM name from VeeamONE
$VMName = $args[0]

#Connect to vCenter Server
add-pssnapin VMware.VimAutomation.Core
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -WarningAction SilentlyContinue -Confirm:$False
connect-viserver -server "vcsa.solarsystem.local" -User "solarsystem\andrea" -Password "V33am.123"
#Set VMs and replica name from vCenter inventory
$VM = Get-VM -Name $VMName
$VMReplica = Get-VM -Name $VMName"_Replica"

#Check if replica is running. If YES, exit
If ($VMReplica.PowerState -eq "PoweredOn"){
    Exit
}


#LOOP (5 retry)
do {
#Test VM connectivity (use FQDN from VMware Tools)
$Hostname = $VM.guest.HostName
$Hostname = $VMName
If ($HostName -ne $null){
    if ((Test-Connection -ComputerName $Hostname -ErrorAction SilentlyContinue -Quiet -Delay "1") -eq $True){
    Exit
    }
}

#VMware Tools Status. If tools are running, exit
$Tools = $VM | Get-View
$ToolsStatus = $Tools.Guest.Toolsrunningstatus.tostring()
if ($ToolsStatus -eq "guestToolsRunning") {
    Exit
    }

#Counter +1 if test is negative
$Counter = $Counter + 1;
Start-Sleep -Seconds "10";
} while ($Counter -ne 5)
#END LOOP

$ScriptBlockContent = {
    #Passing var $VMName to remote powershell (on backup server) as $VMNamePassed
    param ($VMNamePassed)
    Add-PsSnapin -Name VeeamPSSnapIn
    $timestamp=get-date -format s
    #Check if VM was replicated in latest 24h
    #List last replication session
    $session=Get-VBRBackupSession | Where-Object {$_.JobType -eq "Replica" -and $_.EndTime -ge (Get-Date).addhours(-24)};
    #Look for $VMNamePassed in replication job. $f at every cicle is the name of the jobs executed is the latest 24h
    foreach ($f in $session.JobName) {
        $VMinJob=get-vbrjobobject "$f"
        #if found create a failover plan and start it
        if ($VMinJob.Name -contains $VMNamePassed){
            $VMtofailover = Find-VBRViEntity -name $VMNamePassed
            $FailoverObject = New-VBRFailoverPlanObject -Vm $VMtofailover -BootOrder 1  -BootDelay 60
            $FailoverPlan = Add-VBRFailoverPlan -FailoverPlanObject $FailoverObject -Name "$VMNamePassed-Automatic Failover Plan_$timestamp"
            Start-VBRFailoverPlan -FailoverPlan $FailoverPlan
            Exit
        }
        #vm not replicated within latest 24h, exit
        else {
            Exit
        }
    }
}

#Launch command to VBR Server
invoke-command -ComputerName vbr8.solarsystem.local -scriptblock $ScriptBlockContent -ArgumentList $VMName -Credential $credentials
