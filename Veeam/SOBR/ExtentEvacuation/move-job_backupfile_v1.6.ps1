asnp VeeamPsSnapin

function Show-Options
{
  [CmdletBinding()]

  param(
    [Parameter(Mandatory = $true)]
    [string]
    $Message,

    [Parameter(Mandatory = $true)]
    [string[]]
    $Options
  )

  Write-Host -Object "`n$Message`n"
  foreach ($option in $Options)
  {
    Write-Host -Object "`t[$($Options.IndexOf($option) + 1)] $($option)"
  }
}

function Get-UserChoice
{
  [CmdletBinding()]

  param(
    [Parameter(Mandatory = $true)]
    [string]
    $Message,

    [Parameter(Mandatory = $true)]
    [string[]]
    $Options
  )

  $inputIsValid = $false
  do
  {
    try
    {
      [int]$userInput = (Read-Host -Prompt "`n$Message")
    }
    catch
    {
      Write-Host -Object "Invalid input! Must be an integer."
      continue
    }
    if ($userInput -ge 1 -and $userInput -le $Options.Length)
    {
      $inputIsValid = $true
    }
    else
    {
      Write-Host -Object "Invalid input! Must be in the range 1..$($Options.Length)."
    }
  }
  until ($inputIsValid)

  return $userInput - 1
}

function Get-RepositoryFreeSpace
{
  [CmdletBinding()]

  param(
    [Parameter(Mandatory = $true)]
    [Veeam.Backup.Core.CBackupRepository]
    $Repository
  )

  $repoAccessor = [Veeam.Backup.Core.CRepositoryAccessorFactory]::Create($Repository)
  $fsDriveInfo = $repoAccessor.FileCommander.FindDirInfo($Repository.FriendlyPath)

  return $fsDriveInfo.FreeSpace

}

$allRepos = Get-VBRBackupRepository -ScaleOut

if (!$allRepos)
{
  Write-Host -Object "Backup server has no scale-out repositories."
  return
}

Show-Options -Message "Scale-out repositories:" -Options $allRepos.Name

$repoIndex = Get-UserChoice -Message "Choose a repository" -Options $allRepos.Name
$repo = $allRepos[$repoIndex]

Show-Options -Message "[$($repo.Name)] > Extents:" -Options $repo.Extent.Name

$sourceExtentIndex = Get-UserChoice -Message "Choose a source extent" -Options $repo.Extent.Name
$sourceExtent = $repo.Extent[$sourceExtentIndex]

$extentWithBackups = New-Object -TypeName System.Collections.Generic.List[PSCustomObject]

$sourceExtentAccessor = [Veeam.Backup.Core.CRepositoryAccessorFactory]::Create($sourceExtent.Repository)
$jobs = Get-VBRJob
foreach ($job in $jobs | Where-Object { $_.FindTargetRepository().Id -eq $repo.Id }) {
  $jobFolderPath = [Veeam.Backup.Model.SPathConverter]::RepositoryPathToString(
    $sourceExtent.Repository.FullPath.Combine($job.TargetFile),
    $sourceExtent.Repository.type
  )

  if ($sourceExtentAccessor.FileCommander.IsExists($jobFolderPath))
  {
    $jobFolderSize = $sourceExtentAccessor.FileCommander.GetDirSize($jobFolderPath)
  }
  else
  {
    $jobFolderSize = 0
  }
  if ($jobFolderSize)
  {
    $jobStats = [pscustomobject]@{
      jobName = $job.Name.ToString();
      jobFolder = $jobFolderPath.ToString();
      jobFolderSize = $jobFolderSize
    }
    $extentWithBackups.Add($jobStats)
  }
}

if (!$extentWithBackups)
{
  Write-Host -Object "`n[$($sourceExtent.Name)] has no backups."
  return
}

Show-Options -Message "[$($sourceExtent.Name)] > Backup job in this extent:" -Options ($extentWithBackups |
  ForEach-Object -Process { "$($_.jobName) ($([System.Math]::Round($_.jobFolderSize / 1GB, 2)) GB used)" })

$jobIndex = Get-UserChoice -Message "Choose the job you want to migrate" -Options $extentWithBackups

#Check whether the job is running or not
##   DEVO USARE QUESTA: $extentWithBackups[$jobIndex].jobName

$jobtostop = Get-VBRJob -Name $extentWithBackups[$jobIndex].jobName
$jobisstopped = $jobtostop.IsStopped()
if ($jobisstopped) {
  Write-Host -Object "`nDisabling job $($jobtostop.Name)"
  $jobtostop | Disable-VBRJob | Out-null
} else {
  Write-host -Object "`n$($jobtostop.Name) is either running or not in stopped state, exiting..."
  return
}

Write-Host -Object "`nJob $($jobs[$jobindex].Name) has been disabled"

#End check - if the job has been disabled then continue

$possibleTargetExtents = $repo.Extent | Where-Object -FilterScript { $_.Id -ne $sourceExtent.Id }

Show-Options -Message "[$($repo.Name)] > Extents:" -Options ($possibleTargetExtents |
  ForEach-Object -Process {
    "$($_.Name) ($([System.Math]::Round((Get-RepositoryFreeSpace -Repository $_.Repository) / 1GB, 2)) GB free)"
  })

$targetExtentIndex = Get-UserChoice -Message "Choose a target extent" -Options $possibleTargetExtents.Name
$targetExtent = $possibleTargetExtents[$targetExtentIndex]

$targetExtentFreeSpace = Get-RepositoryFreeSpace -Repository $targetExtent.Repository
if ($targetExtentFreeSpace -lt $extentWithBackups[$jobIndex].tenantFolderSize)
{
  Write-Host -Object "`nThere is not enough free space on [$($targetExtent.Name)]."
  return
} else {
  Write-Host -Object "`nThe target extent has enough free space. Starting the job..."
}

$jobSrc = [System.IO.File]::ReadAllText("$PSScriptRoot\job_src_v1.6.ps1")
[Veeam.Backup.Common.CStringCoder]::Code($jobSrc,$true) | Out-File -FilePath "$PSScriptRoot\job.txt"

$jobDescription = "Job will move [{0}] backup files from [{1}] to [{2}]" -f
$extentWithBackups[$jobIndex].jobName,
$sourceExtent.Name,
$targetExtent.Name

$jobParams = New-Object -TypeName 'System.Collections.Generic.Dictionary[string, string]'
$jobParams.Add(
  "JobName",[Veeam.Backup.Common.CStringCoder]::Code($extentWithBackups[$jobIndex].jobName,$true)
)
$jobParams.Add("SobrId",[Veeam.Backup.Common.CStringCoder]::Code($repo.Id.ToString(),$true))
$jobParams.Add(
  "SourceExtentId",[Veeam.Backup.Common.CStringCoder]::Code($sourceExtent.Repository.Id.ToString(),$true)
)
$jobParams.Add(
  "JobFolder",
  [Veeam.Backup.Common.CStringCoder]::Code($extentWithBackups[$jobIndex].jobName,$true)
)
$jobParams.Add(
  "TargetExtentId",[Veeam.Backup.Common.CStringCoder]::Code($targetExtent.Repository.Id.ToString(),$true)
)
$jobSpecArgs = @{
  Name = "Move Backup Files";
  description = $jobDescription;
  type = [Veeam.Backup.Model.CPowerShellScriptJobSpec+EResourcesType]::Script;
  resources = @("$PSScriptRoot\job.txt");
  parameters = $jobParams
}
$jobSpec = [Veeam.Backup.Model.CPowerShellScriptJobSpec]::Create(
  $jobSpecArgs.Name,
  $jobSpecArgs.description,
  $jobSpecArgs.type,
  $jobSpecArgs.resources,
  $jobSpecArgs.parameters
)
$jobManagementService = [Veeam.Backup.Core.SVeeamBackupService]::Instance.session.GetJobManagementService()
[void]$jobManagementService.StartPowerShellScriptJob($jobSpec)

Write-Host -Object "`nJob has been started. Job log is available in the VB&R console > HISTORY > Orchestrated Tasks."
