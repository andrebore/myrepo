
# +----------------------------------------------------------------------------+
# |NAME: MailEndpointSummary.ps1                                               |
# |AUTHOR: Alessandro                                                          |
# |DATE: 17/05/2017                                                            |
# |VERSION: 1.1                                                                |
# |                                                                            |
# |KEYWORDS:  Veeam, notification, backup, Eventlog, Endpoint                  |
# |                                                                            |
# |COMMENTS: mail the event success\not from windows Event log                 |
# |                                                                            |
# |PARAMETER :                                                                 |
# |    smtpserver use this to change the default smtp server                   |
# |    from: you can specify a dif sender email address                        |
# |    to: same like from                                                      |
# | emailLog:If you whan to send the repport by a email; you need              |
# |                smtpserver, from and to varibale                            |
# |    outpufile: if you prefere have file for the repport                     |
# |                                                                            |
# |NEED : none                                                                 |
# +----------------------------------------------------------------------------+
# +----------------------------------------------------------------------------+
# | Maintenance History                                                        |
# | -------------------                                                        |
# | Name                   Date       Version     Description                  |
# | ---------------------------------------------------------------------------+
# | Alessandro Bellini 08/12/2015 1.0  Endpoint version Notification           |
# | Alessandro Bellini 17/05/2017 1.1  Updated version for new Veeam Agent     |
# +----------------------------------------------------------------------------+
#paramter of the script fonction
Param (
	$computers,
	[string]$SmtpServer = "10.153.42.1",
	[string]$From = "Sharjah-Veeam-Backup@veolia.com",
	[string]$To = "alessandro.bellini@veolia.com",
	[switch]$EmailLog,
	[string]$Outpufilehtml
)
#start
Begin
{
	$script:CurrentErrorActionPreference = $ErrorActionPreference
	$script:Output = @()
	$script:ProcessedServers = @()
	$ErrorActionPreference = "SilentlyContinue"
	$script:Subject = @()
	$script:TimeGeneratedJob = @()
	$script:MessageJob = @()
	$script:Status = 1
	$script:ErrorMessage = 0
	$script:WarningMessage = 0
	$script:EnabledMessage = 0
	$script:NbSrvMessage = 0
	# table style for the Email
	$Table = @{ Name = "Server Name"; expression = { $_.servername } }, @{ Name = "Job start"; expression = { $_.TimeGenerated } }, @{ Name = "Job finish"; expression = { $_.TimeGeneratedJob } }, @{ Name = "EntryType"; expression = { $_.EntryType } }, @{ Name = "Source"; expression = { $_.Source } }, @{ Name = "InstanceID"; expression = { $_.InstanceID } }, @{ Name = "Message"; expression = { $_.Message } }
	
	if ($computers)
	{
		if (Test-Path $computers[0]) { $ServerList = Get-Content -Path $computers}
		else { $ServerList = $computers }
	}
	
	########## START FUNCTION SECTION ###############
	#fonction from website to Set the color line in table
	Function AlternatingRows
	{
		[CmdletBinding()]
		Param (
			[Parameter(Mandatory,
                ValueFromPipeline)]
			[string]$Line
		)
		Begin
		{
			$ClassName = 1
		}
		Process
		{
			If ($Line.Contains("<tr>"))
			{
				If ($ClassName)
				{
					$ClassName = 0
					$ClassColor = "background-color:#3d7e00;"
				}
				Else
				{
					$ClassName = 1
					$ClassColor = "background-color:#afff61;"
				}
				If ($Line.Contains("Warning"))
				{
					$ClassColor = "background-color:#FFD700;"
				}
				If ($Line.Contains("Failed"))
				{
					$ClassColor = "background-color:#fc0200;"
				}
				$Line = $Line.Replace("<tr>", "<tr style=""$ClassColor"">")
			}
			Return $Line
		}
	}
	
	If ($EmailLog)
	{
		
		Function SendEmailStatus($From, $To, $Subject, $SmtpServer, $BodyAsHtml, $Body)
		{
			$SmtpMessage = New-Object System.Net.Mail.MailMessage $From, $To, $Subject, $Body
			$SmtpMessage.IsBodyHTML = $BodyAsHtml
			$SmtpClient = New-Object System.Net.Mail.SmtpClient $SmtpServer
			$SmtpClient.Send($SmtpMessage)
			If ($? -eq $False) { Write-Warning "$($Error[0].Exception.Message) | $($Error[0].Exception.GetBaseException().Message)" }
			$SmtpMessage.Dispose()
			rv SmtpClient
			rv SmtpMessage
		}
	}
	
	
	function GetEventlog
	{
		Param ($SServer
		)
		# Put most info into the body of the email:
		$TimeGeneratedJob = (get-eventlog -ComputerName $SServer -LogName "Veeam Agent" -InstanceId 190 -newest 1 -entrytype Information, Warning, Error -source "Veeam Agent" | Format-List -property TimeGenerated | out-string).substring(20)
		$MessageJob = (get-eventlog -ComputerName $SServer -LogName "Veeam Agent" -InstanceId 190 -newest 1 -entrytype Information, Warning, Error -source "Veeam Agent" | Format-List -property Message | out-string).substring(14)
		$TimeGenerated = (get-eventlog -ComputerName $SServer -LogName "Veeam Agent" -InstanceId 150, 110 -newest 1 -entrytype Information, Warning, Error -source "Veeam Agent" | Where { $_.message -match $SServer } | Format-List -property TimeGenerated | out-string).substring(20)
		$Source = (get-eventlog -ComputerName $SServer -LogName "Veeam Agent" -InstanceId 150, 110 -newest 1 -entrytype Information, Warning, Error -source "Veeam Agent" | Where { $_.message -match $SServer } | Format-List -property Source | out-string).substring(13)
		$EntryType = (get-eventlog -ComputerName $SServer -LogName "Veeam Agent" -InstanceId 150, 110 -newest 1 -entrytype Information, Warning, Error -source "Veeam Agent" | Where { $_.message -match $SServer } | Format-List -property EntryType | out-string).substring(16)
		$Message = (get-eventlog -ComputerName $SServer -LogName "Veeam Agent" -InstanceId 150, 110 -newest 1 -entrytype Information, Warning, Error -source "Veeam Agent" | Where { $_.message -match $SServer } | Format-List -property Message | out-string).substring(14)
		$InstanceID = (get-eventlog -ComputerName $SServer -LogName "Veeam Agent" -InstanceId 150, 110 -newest 1 -entrytype Information, Warning, Error -source "Veeam Agent" | Where { $_.message -match $SServer } | Format-List -property InstanceID | out-string).substring(17)
		#check if the value is empty frome the Evente log
		if (!$TimeGenerated)
		{ $TimeGenerated = "no info" }
		if (!$Source)
		{ $Source = "no info" }
		if (!$EntryType)
		{ $EntryType = "no info" }
		if (!$Message)
		{ $Message = "no info" }
		if (!$InstanceID)
		{ $InstanceID = "no info" }
		
		#Created the PS object for store date in table. and # result screen     
		$Object = New-Object psobject
		$Object | Add-Member NoteProperty Servername $SServer -PassThru | Add-Member NoteProperty TimeGenerated $TimeGenerated -PassThru | Add-Member NoteProperty TimeGeneratedJob $TimeGeneratedJob -PassThru | Add-Member NoteProperty Source $Source -PassThru |
		Add-Member NoteProperty EntryType $EntryType -PassThru | Add-Member NoteProperty Message $MessageJob -PassThru | Add-Member NoteProperty InstanceID $InstanceID -PassThru
				
		# Determine the subject according to the result of the backup:
		if ($MessageJob.contains("Success"))
		{
			$subject1 = "Veeam Agent Backup finished with Success."
		}
		else
		{
			if ($MessageJob.contains("no info"))
			{
				$subject1 = "Veeam Agent Backup finished with Warning!! Check Body for details."
				$script:WarningMessage += 1
			}
			else
			{
				#$subject1 = "Veeam Endpoint Backup failed!! Check Body for details."
				#$script:ErrorMessage += 1
			}
		}
		
		if ($MessageJob.contains("Failed"))
		{
			$subject1 = "Veeam Agent Backup Job failed, Check Body for details."
			$script:ErrorMessage += 1
		}
		elseif ($MessageJob.contains("Warning"))
		{
			$subject1 = "Veeam Agent Backup Job finished with Warning Check Body for details."
			$script:WarningMessage += 1
		}
		$subject = "Veeam Agent Backup"
                #Export values
		$script:NbSrvMessage +=1
		$script:Output += $Object
		$script:subject = $subject
		$script:TimeGeneratedJob = $TimeGeneratedJob
		$script:MessageJob = $Message
		
	}
}
#process of the script
Process
{
	if ($ServerList)
	{
		foreach ($computer in $ServerList)
		{
			GetEventlog $computer
		}
		#output message resulte
		Write-Host "Script finished with : " $script:subject
		write-host "Job Message : " $script:MessageJob
		write-host "Finished Time Job at : "  $script:TimeGeneratedJob
	}
}
# the end process task
	End
	{
		# created the header og the email
			#definir the color
	if ($script:WarningMessage) { $Status = 2 }
	if ($script:ErrorMessage) { $Status = 0 }
		
	if ($Status -eq 1)
		{
			$colorTagTable = "background-color:#3d7e00"
			$messageinfo = "Success"
		}
		elseif ($Status -eq 2)
		{
			$colorTagTable = "background-color:#FFD700"
			$messageinfo = "Warning"
		}
		else
		{
			$colorTagTable = "background-color:#fc0200"
			$messageinfo = "Error"
		}
		
		# the header
		$htmlbody = ""
		$date = Get-Date
		$header = @"
 
<table cellspacing="0" cellpadding="0" width="100%" border="0">
 
     <tr>
         <td style="width: 80%;border: none;$colorTagTable;" ><H2>Veeam Endpoint Backup</H2>
       </br>  
	<div><b>Total : $script:NbSrvMessage Servers</div></b>  
            </br>
             <div>Created by $env:username at $date.</div>
         </td>
          <td style="border: none;$colorTagTable;" >
             finished with: <b>$messageinfo</b>
					<div>
					<div>			<b>Errors: $script:ErrorMessage Backup error</b></div>
					<div>			<b>Warning: $script:WarningMessage  Backup warning</b></div>
        </td>
    </tr>
</table>
"@
		#merge body
		$htmlbody += $header
		#Formating the result in HTML format converting for google mail
		$Body = $Output | Select $Table | ConvertTo-HTML -Body $htmlbody
		$Body = $Body | AlternatingRows
		$Body = $Body -replace '<body>', '<body style = "font-size:12px;font-family:Arial;color:#000000;font-weight:normal">'
		$Body = $Body -replace '<table>', '<table style = "border-width:1px;cellpadding=10;border-style:solid;border-collapse:collapse;width:100%">'
		$Body = $Body -replace '<th>', '<th style = "font-size:12px;border-width:1px;padding:10px;border-style:solid;background-color:#96C5EC">'
		$Body = $Body -replace '<td>', '<td style = "font-size:10px;border-width:1px;padding:10px;border-style:solid">'
		
		Add-Type -AssemblyName System.Web
		$Body = [System.Web.HttpUtility]::HtmlDecode($Body) # this line made the link clickable
		
		#fonction to sending the email
		If ($EmailLog)
		{
			SendEmailStatus -From $From -To $To -Subject $script:Subject -SmtpServer $SmtpServer -BodyAsHtml $true -Body $Body
		}
		
		#or in a outpute file
		if ($Outpufilehtml)
		{
			$Body | Out-File $OutpufileHtml
			
		}
		$ErrorActionPreference = $script:CurrentErrorActionPreference
	}