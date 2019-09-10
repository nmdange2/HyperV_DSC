param(
	[Parameter(Mandatory=$true)]
	[String]
	$computer<#,
	[Parameter(Mandatory=$true)]
	[ValidateSet("Pleasantville","1PacePlaza","Law School")]
	[String]
	$SiteName,
	[Parameter(Mandatory=$true)]
	[ValidateSet("AMD","Intel")]
	[String]
	$CPU#>
)

If (!(Get-Module VirtualMachineManager))
{
    Import-Module VirtualMachineManager
}

$Data = Import-PowerShellDataFile "$PSScriptRoot\AllNodes.psd1"

$node = $Data.AllNodes.Where{$_.NodeName -eq $computer}

if($node -eq $null)
{
	Write-Host "Could not find Node configuration" -ForegroundColor Red
	return
}

$configSet = $Data.ConfigSet.Where{$_.ConfigName -eq $node.Config}

Write-Host "Checking CPU"

$cpuName = Invoke-Command -ComputerName $computer -ScriptBlock { return (Get-WmiObject Win32_Processor | Select -First 1).Name.Trim(); }

if($cpuName -like "*AMD*")
{
	$CPU = "AMD"
}
elseif($cpuName -like "*Intel*")
{
	$CPU = "Intel"
}
else
{
	Write-Host "CPU Not Found" -ForegroundColor Red
	return
}

Write-Host "Adding $computer to SCVMM"

# Run-As account for SCVMM PCLOUD
$runAsAccount = Get-SCRunAsAccount -ID "a499c033-e43a-4f9c-afd7-bf2bdc755c64"

$hostGroup = Get-SCVMHostGroup -ParentHostGroup $configSet.SCVMMSiteName -Name $CPU
$fqdn = "$computer.pcloud.pace.edu"
Add-SCVMHost -ComputerName $fqdn -VMHostGroup $hostGroup -Credential $runAsAccount
