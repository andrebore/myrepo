Add-PsSnapin -Name VeeamPSSnapIn -ErrorAction SilentlyContinue

$serverName = "This server"
$server = Get-VBRServer -Name $serverName

foreach ($job in Get-VBRJob){
Set-VBRJobAdvancedStorageOptions -Job $job -CompressionLevel 5 -EnableDeduplication True -StorageBlockSize 1
}
