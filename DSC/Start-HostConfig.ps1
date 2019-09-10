param(
	[Parameter(Mandatory=$true)]
	[String]
	$computer
)

<# 
Run this script on admin workstation after the host has been joined to the domain and patched
#>

.\SCVMM-AddHost.ps1 -computer $computer

Read-Host -Prompt "Confirm host was successfully added to SCVMM and press enter to continue"

.\SCVMM-AddHostSwitch -computer $computer

Read-Host -Prompt "Confirm host logical switch was configured successfully in SCVMM and press enter to continue"

Write-Host "Checking settings against PowerShell DSC Configuration"
.\Check-Dsc.ps1 -computer $computer

Read-Host -Prompt "Press enter to confirm applying PowerShell DSC Configuration"
.\Apply-Dsc.ps1 -computer $computer

Start-Sleep -Seconds 5
Write-Host "Restarting host to apply DSC settings"

Restart-Computer -ComputerName $computer -Force

