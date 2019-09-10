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

Start-DscConfiguration -Path .\HyperVFabricSettings\ -ComputerName $computer -Wait -Verbose
