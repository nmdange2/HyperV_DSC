<#
Run this script on the Hyper-V host to configure initial pre-reqs

It is safe to run the script multiple times if one step has an error.
#>

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
elseif($computer.Length -gt 15) # Windows computer names should be 15 characters or less
{
	Write-Host "Computer name too long!" -ForegroundColor Red
	return
}


$Data = Import-PowerShellDataFile "$PSScriptRoot\AllNodes.psd1"

Write-Host "Beginning initial config steps on new host $computer"

$node = $Data.AllNodes.Where{$_.NodeName -eq $computer}

if($node -eq $null)
{
	Write-Host "Could not find Node configuration" -ForegroundColor Red
	return
}

$configSet = $Data.ConfigSet.Where{$_.ConfigName -eq $node.Config}

if($configSet -eq $null)
{
	Write-Host "Could not find ConfigSet" -ForegroundColor Red
	return
}

Write-Host "Install Latest NIC Driver prior to continuing" -ForegroundColor Cyan
Read-Host -Prompt "Press enter when driver installed to continue"

# Enable Remote Desktop
Write-Host "Enabling RDP with Network Level Authentication" -ForegroundColor Green
New-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\' -Name "fDenyTSConnections" -Value 0 -PropertyType dword -Force
New-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp\' -Name "UserAuthentication" -Value 1 -PropertyType dword -Force
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

# Installing features here instead of using DSC allows DSC policy to be applied without requiring a reboot half-way through
# Install Hyper-V feature if required
if($node.Role -contains "HyperV")
{
	Write-Host "Installing Hyper-V Feature" -ForegroundColor Green
	Install-WindowsFeature "Hyper-V" -IncludeManagementTools
}

# Install Guarded Host feature if required
if($node.Role -contains "GuardedHost")
{
	Write-Host "Installing Hyper-V Guarded Host Feature" -ForegroundColor Green
	Install-WindowsFeature "HostGuardian" -IncludeManagementTools
}

# Install Failover Clustering feature if required
if($node.Role -contains "ClusterNode")
{
	Write-Host "Installing Failover Clustering Feature" -ForegroundColor Green
	Install-WindowsFeature "Failover-Clustering" -IncludeManagementTools
}

# Install Data Center Bridging feature if required
if($configSet.EnableDCB)
{
	Write-Host "Installing Data Center Bridging Feature" -ForegroundColor Green
	Install-WindowsFeature "Data-Center-Bridging" -IncludeManagementTools
}

# Rename NICs
Write-Host "Checking NIC names"

$nicList = @()
for($i = 1; $i -le $configSet.NIC_COUNT; $i++)
{
	$nicName = $node."NIC_$($i)_Name"
	if($nicName -eq $null)
	{
		$nicName = $configSet."NIC_$($i)_DefaultName" # Grab Default name if not specified
	}


	$nicCurrName = (Get-NetAdapter -Physical | Where-Object {$_.MacAddress -eq $node."NIC_$($i)_MacAddr"}).Name
	if($nicCurrName -ne $nicName)
	{
		Write-Host "Renaming NIC $($i) $($nicCurrName) to $($nicName)" -ForegroundColor Yellow
		Rename-NetAdapter -Name $nicCurrName -NewName $nicName
	}
	else
	{
		Write-Host "NIC $($i) name already correct!" -ForegroundColor Green
	}
	$nicList += $nicName
}

# Pick DNS IPs, make sure they are reversed for every other host
$ip = $node.HostIP.Split("/")[0]
$ipsubnet = $node.HostIP.Split("/")[1]
$gateway = $ip.Substring(0,$ip.LastIndexOf('.')) + ".1"
if($ip.Substring($ip.LastIndexOf('.') +1) % 2 -eq 1)
{
	$dnsIP1 = $configSet.DNS_IP_1
	$dnsIP2 = $configSet.DNS_IP_2
}
else
{
	$dnsIP1 = $configSet.DNS_IP_2
	$dnsIP2 = $configSet.DNS_IP_1
}

# Temporary host NIC config for Hyper-V (to be replaced by virtual switch later)
if($node.Role -contains "HyperV")
{
	# Set VLAN to PCLOUD host VLAN
	Write-Host "Assigning VLAN to host NICs temporarily"
	foreach($nic in $nicList)
	{
		Set-NetAdapterAdvancedProperty -Name $nic -RegistryKeyword "VlanId" -RegistryValue "892"
	}

	# Give the NIC time to reconnect after changing the VLAN
	Start-Sleep -Seconds 10

	# Assign static IP to NIC1
	Write-Host "Assigning static IP $ip/$ipsubnet gateway $gateway DNS $dnsIP1 $dnsIP2"
	New-NetIPAddress -InterfaceAlias $nicList[0] -AddressFamily IPv4 -IPAddress $ip -PrefixLength $ipsubnet -DefaultGateway $gateway
	Set-DnsClientServerAddress -InterfaceAlias $nicList[0] -ServerAddresses $dnsIP1, $dnsIP2
}
elseif($node.Role -contains "SOFS")
{
	Write-Host "Creating LBFO Team on Host NICs"
	if($configSet.SOFS_NetLbfoTeamMode = 'Lacp')
	{
		New-NetLbfoTeam -Name $configSet.SOFS_NetLbfoTeamName -TeamMembers $nicList -TeamingMode Lacp -LoadBalancingAlgorithm TransportPorts -LacpTimer Slow
	}
	elseif($configSet.SOFS_NetLbfoTeamMode = 'SwitchIndependent')
	{
		New-NetLbfoTeam -Name $configSet.SOFS_NetLbfoTeamName -TeamMembers $nicList -TeamingMode SwitchIndependent -LoadBalancingAlgorithm Dynamic
	}

	# Give the NIC time to reconnect after creating the team
	Start-Sleep -Seconds 10

	Write-Host "Assigning static IP $ip/$ipsubnet gateway $gateway DNS $dnsIP1 $dnsIP2"
	# Assign Static IP address
	New-NetIPAddress -InterfaceAlias $configSet.SOFS_NetLbfoTeamName -AddressFamily IPv4 -IPAddress $ip -PrefixLength $ipsubnet -DefaultGateway $gateway
	Set-DnsClientServerAddress -InterfaceAlias $configSet.SOFS_NetLbfoTeamName -ServerAddresses $dnsIP1, $dnsIP2
}
else
{
	throw 'Server missing role'
}

# Rename NICs
Write-Host "Checking SMB NIC names"

for($i = 1; $i -le $configSet.SMB_NIC_COUNT; $i++)
{
	if($configSet."SMB_NIC_$($i)_Type" -ne "Virtual")
	{
		$nicName = $node."SMB_NIC_$($i)_Name"
		if($nicName -eq $null)
		{
			$nicName = $configSet."SMB_NIC_$($i)_DefaultName" # Grab Default name if not specified
		}

		$nicCurrName = (Get-NetAdapter -Physical | Where-Object {$_.MacAddress -eq $node."SMB_NIC_$($i)_MacAddr"}).Name
		if($nicCurrName -ne $nicName)
		{
			Write-Host "Renaming SMB NIC $($i) $($nicCurrName) to $($nicName)" -ForegroundColor Yellow
			Rename-NetAdapter -Name $nicCurrName -NewName $nicName
		}
		else
		{
			Write-Host "SMB NIC $($i) name already correct!" -ForegroundColor Green
		}
	}
}

# Wait before trying ping
Start-Sleep -Seconds 10

# Check network access
Write-Host "Checking Network connectivity"
$test = Test-NetConnection -RemoteAddress $gateway
if($test.PingSucceeded -eq $true)
{
	# Install NuGet and DSC
	.\InstallDSCModulesLocal.ps1
}
else
{
	Write-Host "Ping failed" -ForegroundColor Red
	return
}

# Do we apply DSC policies now using LCM?  How?

# Rename Computer and reboot
Write-Host "Renaming computer and restarting"
Start-Sleep -Seconds 10 # Give the user a chance to see the restart message
Rename-Computer -NewName $computer -Force -Restart
