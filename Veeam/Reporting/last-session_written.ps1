asnp VeeamPsSnapin

foreach ($job in Get-VBRJob) {
	$lastsession=$job.FindLastSession()

	$backedupsize=$lastsession.SessionInfo.BackedUpSize

    $obj = new-object psobject -Property @{
                   Job = $job.Name
                   BackedupSize = $backedupsize

        }

    $obj | Format-List Job, BackedupSize    

	}
