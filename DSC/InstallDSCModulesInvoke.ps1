$nuget = (Get-PackageProvider |? Name -eq "NuGet")
if($nuget -eq $null)
{
	Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
}

$Data = Import-PowerShellDataFile "$PSScriptRoot\AllNodes.psd1"

# Install Locally
foreach($moduleName in $Data.NonNodeData.DscModules)
{
    Write-Host $moduleName
    $galleryModule = Find-Module $moduleName
    Write-Host $galleryModule.Version

    $installedModules = @()
    $installedModules += (Get-Module $moduleName -ListAvailable)

    $installed = $false

    foreach($installedModule in $installedModules)
    {
        if($installedModule.Version -eq $galleryModule.Version)
        {
            Write-Host "Latest Module already installed" -ForegroundColor Green
            $installed = $true
        }
        else
        {
            Write-Host "Invalid Module Version " $installedModule.Version -ForegroundColor Red
            $installedModule | Uninstall-Module
        }
    }

    if($installed -eq $false)
    {
        Write-Host "Installing Module" -ForegroundColor Yellow
        Install-Module $moduleName -Force #-Verbose
    }
}

foreach($node in $Data.AllNodes)
{
    #Write-Host $node.NodeName
    Invoke-Command -ComputerName $node.NodeName {
		$nuget = (Get-PackageProvider |? Name -eq "NuGet")
		if($nuget -eq $null)
		{
			Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
		}

        Write-Host $env:COMPUTERNAME
        $Data = $args[0]
        foreach($moduleName in $Data.NonNodeData.DscModules)
        {
            Write-Host $moduleName
            $galleryModule = Find-Module $moduleName
            Write-Host $galleryModule.Version

            $installedModules = @()
            $installedModules += (Get-Module $moduleName -ListAvailable)

            $installed = $false

            foreach($installedModule in $installedModules)
            {
                if($installedModule.Version -eq $galleryModule.Version)
                {
                    Write-Host "Latest Module already installed" -ForegroundColor Green
                    $installed = $true
                }
                else
                {
                    Write-Host "Invalid Module Version " $installedModule.Version -ForegroundColor Red
                    $installedModule | Uninstall-Module
                }
            }

            if($installed -eq $false)
            {
                Write-Host "Installing Module" -ForegroundColor Yellow
                Install-Module $moduleName -Force #-Verbose
            }
        }
    } -ArgumentList $Data
}
