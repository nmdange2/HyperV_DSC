param(
	[Parameter(Mandatory=$true)]
	[String]
	$computer
)

if($computer -eq $null)
{
    Write-Host "Missing computer param" -ForegroundColor Red
    return
}
if($computer -eq "ALL")
{
	$computer = $null # Only test all of them if it's explicitly passed as a parameter
}

$results = Test-DscConfiguration -Path .\HyperVFabricSettings\ -ComputerName $computer
$results.ResourcesInDesiredState | ForEach-Object { Write-Host $_.PSComputerName "`tOK`t" $_.ResourceId -ForegroundColor Green }
if($results.ResourcesNotInDesiredState -ne $null) {
    $results.ResourcesNotInDesiredState | ForEach-Object { Write-Host $_.PSComputerName "`tNotOK`t" $_.ResourceId -ForegroundColor Red }
}
