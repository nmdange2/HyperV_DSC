param(
	[Parameter(Mandatory=$true)]
	[String]
	$computer
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

Write-Host "Adding virtual switch to $computer"

$jobGroupId = [Guid]::NewGuid()
$vmHost = Get-SCVMHost -ComputerName $computer

# Get virtual switch name from DSC configuration
$vmSwitch = Get-SCLogicalSwitch -Name $configSet.HyperVSwitchName

# Get uplink profile associated with vitual switch
$uplink = Get-SCUplinkPortProfileSet -LogicalSwitch $vmSwitch

# Get the VMM-based NIC object for the host's NICs
$nicList = @()
for($i = 1; $i -le $configSet.NIC_COUNT; $i++)
{
	$nicName = $node."NIC_$($i)_Name"
	if($nicName -eq $null)
	{
		$nicName = $configSet."NIC_$($i)_DefaultName" # Grab Default name if not specified
	}

	$nicMac = ($node."NIC_$($i)_MacAddr").Replace("-",":") #VMM uses : in Mac addresses instead of - like Windows
	$vmmNic = Get-SCVMHostNetworkAdapter -VMHost $vmHost | Where-Object {$_.ConnectionName -eq $nicName -and $_.MacAddress -eq $nicMac} #make sure both name and mac are correct
	if($vmmNic -eq $null)
	{
		Write-Host "NIC Not Found!" -ForegroundColor Red
		return
	}

	Set-SCVMHostNetworkAdapter -VMHostNetworkAdapter $vmmNic -UplinkPortProfileSet $uplink -JobGroup $jobGroupId
	$nicList += $vmmNic
}

New-SCVirtualNetwork -VMHost $vmHost -VMHostNetworkAdapters $nicList -LogicalSwitch $vmSwitch -DeployVirtualNetworkAdapters -JobGroup $jobGroupId

Set-SCVMHost -VMHost $vmHost -JobGroup $jobGroupId
