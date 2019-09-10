Configuration HyperVFabricSettings {
    Import-DscResource -ModuleName 'PSDscResources'
    Import-DscResource -ModuleName 'ComputerManagementDsc'
    Import-DscResource -ModuleName 'xRemoteDesktopAdmin'
    Import-DscResource -ModuleName 'NetworkingDsc'
	Import-DscResource -ModuleName 'xHyper-V'
	Import-DscResource -ModuleName 'DataCenterBridging'
    Import-DscResource -ModuleName 'VMNetworkAdapter'
	#Import-DscResource -ModuleName 'cHyper-V' #needed just for cVMNetworkAdpterVlan

	<# Begin Section Windows Features #>
	node $AllNodes.Where{$_.Role -contains "ClusterNode"}.NodeName
    {
        WindowsFeatureSet Clustering
        {
            Name = @("Failover-Clustering", "RSAT-Clustering-PowerShell")
            Ensure = 'Present'
        }

		# TODO: Add Failover Clustering firewall rules (normally enabled anyway but good to check)
    }

    node $AllNodes.Where{$_.Role -contains "GuardedHost"}.NodeName
    {
        WindowsFeature GuardedHost
        {
            Name = "HostGuardian"
            Ensure = 'Present'
        }

        WindowsFeatureSet BitLocker
        {
            Name = "BitLocker","RSAT-Feature-Tools-BitLocker"
            Ensure = 'Present'
        }
    }

    node $AllNodes.Where{$_.Role -contains "MPIO"}.NodeName
    {
        WindowsFeature MultipathIO
        {
            Name = "Multipath-IO"
            Ensure = 'Present'
        }
    }

	node $AllNodes.Where{$_.Role -contains "S2D"}.NodeName
    {
        WindowsFeature MultipathIO
        {
            Name = "Multipath-IO"
            Ensure = 'Absent'
        }
    }

    node $AllNodes.Where{$_.Role -contains "HyperV"}.NodeName
    {
		WindowsFeatureSet HyperV
        {
            Name = @("Hyper-V", "Hyper-V-PowerShell")
            Ensure = 'Present'
        }
    }

	node $AllNodes.Where{$_.Role -contains "SOFS"}.NodeName
    {
		WindowsFeatureSet FileServer
        {
            Name = @("FS-FileServer", "FS-Data-Deduplication")
            Ensure = 'Present'
        }
	}

	<# End Windows Feature Section #>

	node $AllNodes.NodeName {
		$configSet = $ConfigurationData.ConfigSet.Where{$_.ConfigName -eq $Node.Config}

        TimeZone TimeZone
        {
            IsSingleInstance = 'Yes'
            TimeZone = $configSet.TimeZone
        }
        
		# Make sure SMB1 is removed
        WindowsFeature SMB1 {
            Name = 'FS-SMB1'
            Ensure = 'Absent'
        }
    
		# Turn on Remote Desktop with Network Level Authentication
        xRemoteDesktopAdmin RemoteDesktopSettings
        {
           Ensure = 'Present'
           UserAuthentication = 'Secure'
        }

		Firewall AllowRemoteDesktopTCP
        {
            Name = 'RemoteDesktop-UserMode-In-TCP'
            Ensure = 'Present'
            Enabled = 'True'
        }

        Firewall AllowRemoteDesktopUDP
        {
            Name = 'RemoteDesktop-UserMode-In-UDP'
            Ensure = 'Present'
            Enabled = 'True'
        }

        Firewall AllowRemoteDesktopShadow
        {
            Name = 'RemoteDesktop-Shadow-In-TCP'
            Ensure = 'Present'
            Enabled = 'True'
        }

		# Make sure the firewall is enabled
        FirewallProfile FirewallProfileDomain
        {
            Name = 'Domain'
            Enabled = 'True'
            AllowInboundRules = 'True'
            DefaultInboundAction = 'Block'
            DefaultOutboundAction = 'Allow'
            AllowLocalFirewallRules = 'True'
        }

        FirewallProfile FirewallProfilePrivate
        {
            Name = 'Private'
            Enabled = 'True'
            AllowInboundRules = 'True'
            DefaultInboundAction = 'Block'
            DefaultOutboundAction = 'Allow'
            AllowLocalFirewallRules = 'True'
        }

        FirewallProfile FirewallProfilePublic
        {
            Name = 'Public'
            Enabled = 'True'
            AllowInboundRules = 'True'
            DefaultInboundAction = 'Block'
            DefaultOutboundAction = 'Allow'
            AllowLocalFirewallRules = 'True'
        }

        #Firewall DisplayGroup "Windows Management Instrumentation (WMI)"
        Firewall AllowWMIRPC
        {
            Name = 'WMI-RPCSS-In-TCP'
            Ensure = 'Present'
            Enabled = 'True'
        }

        Firewall AllowWMIIn
        {
            Name = 'WMI-WINMGMT-In-TCP'
            Ensure = 'Present'
            Enabled = 'True'
        }

        Firewall AllowWMIOut
        {
            Name = 'WMI-WINMGMT-Out-TCP'
            Ensure = 'Present'
            Enabled = 'True'
        }

        Firewall AllowWMIASync
        {
            Name = 'WMI-ASYNC-In-TCP'
            Ensure = 'Present'
            Enabled = 'True'
        }
        #End WMI Group

        #Firewall DisplayGroup "Remote Service Management"
        Firewall AllowRemoteSvcIn
        {
            Name = 'RemoteSvcAdmin-In-TCP'
            Ensure = 'Present'
            Enabled = 'True'
        }

        Firewall AllowRemoteSvcNP
        {
            Name = 'RemoteSvcAdmin-NP-In-TCP'
            Ensure = 'Present'
            Enabled = 'True'
        }

        Firewall AllowRemoteSvcRPC
        {
            Name = 'RemoteSvcAdmin-RPCSS-In-TCP'
            Ensure = 'Present'
            Enabled = 'True'
        }
        #End Remote Service Management

		# File Server rules (ping and SMB)
		Firewall AllowICMPv4
		{
			Name = 'FPS-ICMP4-ERQ-In'
			Ensure = 'Present'
			Enabled = 'True'
		}

		Firewall AllowICMPv4Out
		{
			Name = 'FPS-ICMP4-ERQ-Out'
			Ensure = 'Present'
			Enabled = 'True'
		}

		Firewall AllowICMPv6
		{
			Name = 'FPS-ICMP6-ERQ-In'
			Ensure = 'Present'
			Enabled = 'True'
		}

		Firewall AllowICMPv6Out
		{
			Name = 'FPS-ICMP6-ERQ-Out'
			Ensure = 'Present'
			Enabled = 'True'
		}

		Firewall AllowSMB
		{
			Name = 'FPS-SMB-In-TCP'
			Ensure = 'Present'
			Enabled = 'True'
		}

		Firewall AllowSMBOut
		{
			Name = 'FPS-SMB-Out-TCP'
			Ensure = 'Present'
			Enabled = 'True'
		}
		
        #Firewall Display Group "Remove Event Log Management"
        Firewall AllowRemoteEventLogSvc
        {
            Name = 'RemoteEventLogSvc-In-TCP'
            Ensure = 'Present'
            Enabled = 'True'
        }

        Firewall AllowRemoteEventLogSvcNP
        {
            Name = 'RemoteEventLogSvc-NP-In-TCP'
            Ensure = 'Present'
            Enabled = 'True'
        }

        Firewall AllowRemoteEventLogSvcRPCSS
        {
            Name = 'RemoteEventLogSvc-RPCSS-In-TCP'
            Ensure = 'Present'
            Enabled = 'True'
        }
        #End Remote Event Log Management

		# These rules are needed for Cluster-Aware Updating to work properly
        Firewall AllowRemoteShutdown
        {
            Name = 'Wininit-Shutdown-In-Rule-TCP-RPC'
            Ensure = 'Present'
            Enabled = 'True'
        }

        Firewall AllowRemoteShutdownEP
        {
            Name = 'Wininit-Shutdown-In-Rule-TCP-RPC-EPMapper'
            Ensure = 'Present'
            Enabled = 'True'
        }

		# Disable NetBIOS and other legacy protocols
		Firewall DisableNBDgamIn
		{
			Name = 'FPS-NB_Datagram-In-UDP'
			Ensure = 'Present'
			Enabled = 'False'
		}

		Firewall DisableNBDgamOut
		{
			Name = 'FPS-NB_Datagram-Out-UDP'
			Ensure = 'Present'
			Enabled = 'False'
		}

		Firewall DisableNBNameIn
		{
			Name = 'FPS-NB_Name-In-UDP'
			Ensure = 'Present'
			Enabled = 'False'
		}

		Firewall DisableNBNameOut
		{
			Name = 'FPS-NB_Name-Out-UDP'
			Ensure = 'Present'
			Enabled = 'False'
		}

		Firewall DisableNBSessionIn
		{
			Name = 'FPS-NB_Session-In-TCP'
			Ensure = 'Present'
			Enabled = 'False'
		}

		Firewall DisableNBSessionOut
		{
			Name = 'FPS-NB_Session-Out-TCP'
			Ensure = 'Present'
			Enabled = 'False'
		}

		Firewall DisableLLMNRIn
		{
			Name = 'FPS-LLMNR-In-UDP'
			Ensure = 'Present'
			Enabled = 'False'
		}

		Firewall DisableLLMNROut
		{
			Name = 'FPS-LLMNR-Out-UDP'
			Ensure = 'Present'
			Enabled = 'False'
		}

        # Disable unnecessary rules in 2016
        Firewall DisableAllJoynTCPIn
        {
            Name = 'AllJoyn-Router-In-TCP'
            Ensure = 'Present'
            Enabled = 'False'
        }

        Firewall DisableAllJoynUDPIn
        {
            Name = 'AllJoyn-Router-In-UDP'
            Ensure = 'Present'
            Enabled = 'False'
        }

        Firewall DisableAllJoynTCPOut
        {
            Name = 'AllJoyn-Router-Out-TCP'
            Ensure = 'Present'
            Enabled = 'False'
        }

        Firewall DisableAllJoynUDPOut
        {
            Name = 'AllJoyn-Router-Out-UDP'
            Ensure = 'Present'
            Enabled = 'False'
        }

        Firewall DisablemDNSIn
        {
            Name = 'MDNS-In-UDP'
            Ensure = 'Present'
            Enabled = 'False'
        }

        Firewall DisablemDNSOut
        {
            Name = 'MDNS-Out-UDP'
            Ensure = 'Present'
            Enabled = 'False'
        }

        Registry FullCrashDumpEnabled
        {
            Key = 'HKLM:\System\CurrentControlSet\Control\CrashControl'
            Ensure = 'Present'
            ValueName = 'CrashDumpEnabled'
            ValueType = 'DWord'
            ValueData = '1'
            Force = $true
        }

        # https://blog.workinghardinit.work/2016/07/26/windows-server-2016-active-memory-dump/
        Registry ActiveMemoryDumpEnabled
        {
            Key = 'HKLM:\System\CurrentControlSet\Control\CrashControl'
            Ensure = 'Present'
            ValueName = 'FilterPages'
            ValueType = 'DWord'
            ValueData = '1'
            Force = $true
        }

        #Enable NMI Dump https://support.microsoft.com/en-us/help/927069
        Registry NMIDumpEnabled
        {
            Key = 'HKLM:\System\CurrentControlSet\Control\CrashControl'
            Ensure = 'Present'
            ValueName = 'NMICrashDump'
            ValueType = 'DWord'
            ValueData = '1'
            Force = $true
        }

        #https://blogs.msdn.microsoft.com/clustering/2016/03/02/troubleshooting-hangs-using-live-dump/
        Registry AlwaysKeepLiveMemoryDump
        {
            Key = 'HKLM:\System\CurrentControlSet\Control\CrashControl'
            Ensure = 'Present'
            ValueName = 'AlwaysKeepMemoryDump'
            ValueType = 'DWord'
            ValueData = '1'
            Force = $true
        }

        # TODO: Investigate Defender exclusions, it appears they may be covered automatically
        # https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-defender-antivirus/configure-server-exclusions-windows-defender-antivirus
        # https://support.microsoft.com/en-us/help/3105657/recommended-antivirus-exclusions-for-hyper-v-hosts
  
        WinsSetting DisableWins
        {
            IsSingleInstance = "Yes"
            EnableLMHOSTS = $false
            EnableDNS = $false
        }

		PowerPlan SetPowerPlan
        {
            IsSingleInstance = 'Yes'
            Name             = $configSet.PowerPlan
        }

		if($configSet.EnableDCB -eq $true)
		{
			WindowsFeatureSet DCB
			{
				Name = @("Data-Center-Bridging", "RSAT-DataCenterBridging-LLDP-Tools")
				Ensure = 'Present'
			}

            DCBNetQosDcbxSetting DisableDcbxWilling
            {
                Ensure = 'Absent'
				DependsOn = '[WindowsFeatureSet]DCB'
            }

            DCBNetQosPolicy NetQosPolicySMBDirect
            {
                Name = 'SMB Direct'
                Ensure = 'Present'
                PriorityValue8021Action = 3
                NetDirectPortMatchCondition = 445
				DependsOn = '[WindowsFeatureSet]DCB'
            }

            DCBNetQosTrafficClass NetQosTrafficClassSMBDirect
            {
                Name = 'SMB Direct'
                Ensure = 'Present'
                Priority = 3
                BandwidthPercentage = 50
                Algorithm = 'ETS'
				DependsOn = '[WindowsFeatureSet]DCB'
            }

            DCBNetQosPolicy NetQosPolicySMB
            {
                Name = 'SMB'
                Ensure = 'Present'
                PriorityValue8021Action = 2
                Template = 'SMB'
				DependsOn = '[WindowsFeatureSet]DCB'
            }

            DCBNetQosTrafficClass NetQosTrafficClassSMB
            {
                Name = 'SMB'
                Ensure = 'Present'
                Priority = 2
                BandwidthPercentage = 30
                Algorithm = 'ETS'
				DependsOn = '[WindowsFeatureSet]DCB'
            }

            DCBNetQosPolicy NetQosPolicyCluster
            {
                Name = 'Cluster'
                Ensure = 'Present'
                PriorityValue8021Action = 7
                Template = 'Cluster'
				DependsOn = '[WindowsFeatureSet]DCB'
            }

            DCBNetQosTrafficClass NetQosTrafficClassCluster
            {
                Name = 'Cluster'
                Ensure = 'Present'
                Priority = 7
                BandwidthPercentage = 1
                Algorithm = 'ETS'
				DependsOn = '[WindowsFeatureSet]DCB'
            }

            DCBNetQosFlowControl DisableFlowControlPriority0
            {
                Priority = 0
                Ensure = 'Absent'
				DependsOn = '[WindowsFeatureSet]DCB'
            }

            DCBNetQosFlowControl DisableFlowControlPriority1
            {
                Priority = 1
                Ensure = 'Absent'
				DependsOn = '[WindowsFeatureSet]DCB'
            }

            DCBNetQosFlowControl DisableFlowControlPriority2
            {
                Priority = 2
                Ensure = 'Absent'
				DependsOn = '[WindowsFeatureSet]DCB'
            }

            DCBNetQosFlowControl EnableFlowControlPriority3
            {
                Priority = 3
                Ensure = 'Present'
				DependsOn = '[WindowsFeatureSet]DCB'
            }

            DCBNetQosFlowControl DisableFlowControlPriority4
            {
                Priority = 4
                Ensure = 'Absent'
				DependsOn = '[WindowsFeatureSet]DCB'
            }

            DCBNetQosFlowControl DisableFlowControlPriority5
            {
                Priority = 5
                Ensure = 'Absent'
				DependsOn = '[WindowsFeatureSet]DCB'
            }

            DCBNetQosFlowControl DisableFlowControlPriority6
            {
                Priority = 6
                Ensure = 'Absent'
				DependsOn = '[WindowsFeatureSet]DCB'
            }

            DCBNetQosFlowControl DisableFlowControlPriority7
            {
                Priority = 7
                Ensure = 'Absent'
				DependsOn = '[WindowsFeatureSet]DCB'
            }
		}

		$jumboPacket = 1514
		if($configSet.JumboFrames -eq $true)
		{
			$jumboPacket = 9014
		}

		$nicList = @()
		$teamDepends = @()

		# Loop through NIC settings
		for($i = 1; $i -le $configSet.NIC_COUNT; $i++)
		{
			$nicName = $Node."NIC_$($i)_Name"
			if($nicName -eq $null)
			{
				$nicName = $configSet."NIC_$($i)_DefaultName" # Grab Default name if not specified
			}
			$nicList += $nicName
			$teamDepends += "[NetAdapterName]RenameNIC$i"

			NetAdapterName "RenameNIC$i"
			{
				NewName = $nicName
				MacAddress = $Node."NIC_$($i)_MacAddr"
				PhysicalMediaType = '802.3'
			}

			if($Node.Role -contains "HyperV")
			{
				$vmq = 1
				if($Node."NIC_$($i)_Type" -eq "Generic1g") # disable VMQ on 1gig NICs
				{
					$vmq = 0
				}

				NetAdapterAdvancedProperty "VMQNic$i"
				{
					NetworkAdapterName = $nicName
					RegistryKeyword = "*VMQ"
					RegistryValue = $vmq
					DependsOn = "[NetAdapterName]RenameNIC$i"
				}


				$sriov = 0
				if($configSet.SRIOV -eq $true)
				{
					$sriov = 1
				}

				NetAdapterAdvancedProperty "SRIOVNic$i"
				{
					NetworkAdapterName = $nicName
					RegistryKeyword = "*SRIOV"
					RegistryValue = $sriov
					DependsOn = "[NetAdapterName]RenameNIC$i"
				}

				if($configSet.Has_Virtual_SMB_NIC)
				{
					# Only enable jumbo packets on the host NIC if there are virtual SMB NICs
					NetAdapterAdvancedProperty "JumboPacketNic$i"
					{
						NetworkAdapterName = $nicName
						RegistryKeyword = "*JumboPacket"
						RegistryValue = $jumboPacket
						DependsOn = "[NetAdapterName]RenameNIC$i"
					}

					if($configSet."NIC_$($i)_Type" -notin("Generic1g","Generic10g"))
					{
						NetAdapterRdma "EnableRDMANIC$i"
						{
							Name = $nicName
							Enabled = $true
							DependsOn = "[NetAdapterName]RenameNIC$i"
						}

						if($configSet.EnableDCB)
						{
							DCBNetAdapterQos "EnableQosNIC$i"
							{
								InterfaceName = $nicName
								Ensure = 'Present'
								DependsOn = '[WindowsFeatureSet]DCB', '[DCBNetQosDcbxSetting]DisableDcbxWilling', 
								'[DCBNetQosPolicy]NetQosPolicySMBDirect','[DCBNetQosTrafficClass]NetQosTrafficClassSMBDirect',
								'[DCBNetQosPolicy]NetQosPolicyCluster','[DCBNetQosTrafficClass]NetQosTrafficClassCluster',
								'[DCBNetQosFlowControl]EnableFlowControlPriority3', "[NetAdapterName]RenameNIC$i"
							}
						}
					}
					<#else #this doesn't work if the NIC doesn't support RDMA
					{
						NetAdapterRdma "DisableRDMANIC$i"
						{
							Name = $nicName
							Enabled = $true
							DependsOn = "[NetAdapterName]RenameNIC$i"
						}
					}#>
				}
			}
			elseif($Node.Role -contains "SOFS")
			{
				# VMQ and SRIOV are not needed on SOFS nodes
				NetAdapterAdvancedProperty "VMQDisableNic$i"
				{
					NetworkAdapterName = $nicName
					RegistryKeyword = "*VMQ"
					RegistryValue = 0
					DependsOn = "[NetAdapterName]RenameNIC$i"
				}

				NetAdapterAdvancedProperty "SRIOVDisableNic$i"
				{
					NetworkAdapterName = $nicName
					RegistryKeyword = "*SRIOV"
					RegistryValue = 0
					DependsOn = "[NetAdapterName]RenameNIC$i"
				}
			}
		}

		if($Node.Role -contains "HyperV")
		{
			# This may not work to correctly create the VM switch to comply with VMM's settings
			# For now, don't apply this configuration until VMM has created the virtual switch
			xVMSwitch HyperVVMSwitch
			{
				Name = $configSet.HyperVSwitchName
				Type = 'External'
				NetAdapterName = [string[]]$nicList
				AllowManagementOS = $true
				EnableEmbeddedTeaming = $true
				BandwidthReservationMode = 'Weight'
				LoadBalancingAlgorithm = 'HyperVPort'
				DependsOn = '[WindowsFeatureSet]HyperV', $teamDepends
			}

			#TODO: Create Host VMNetworkAdapter

			<#cVMNetworkAdapterVlan HyperVHostvNICVlan
			{
				Id = $configSet.HyperVHostVNicName # This property seems to not be used by the module
				AdapterMode = 'Access'
				VlanId = $configSet.HostVLAN
				VMName = 'ManagementOS'
				Name = $configSet.HyperVHostVNicName
				DependsOn = '[xVMSwitch]HyperVVMSwitch'
			}#>
		}

		$hasIwarp = $false
		$hasRoce = $false

		# Loop through SMB NIC settings
		for($i = 1; $i -le $configSet.SMB_NIC_COUNT; $i++)
		{
			if($configSet."SMB_NIC_$($i)_Mode" -eq "iWARP")
			{
				$hasIwarp = $true
			}
			elseif($configSet."SMB_NIC_$($i)_Mode" -eq "RoCEv1")
			{
				$hasRoce = $true
			}
			elseif($configSet."SMB_NIC_$($i)_Mode" -eq "RoCEv2")
			{
				$hasRoce = $true
			}

			$nicName = $Node."SMB_NIC_$($i)_Name"
			if($nicName -eq $null)
			{
				$nicName = $configSet."SMB_NIC_$($i)_DefaultName" # Grab Default name if not specified
			}

			# set properties only applicable to non-virtual SMB NICs
			if($configSet."SMB_NIC_$($i)_Type" -ne "Virtual")
			{
				NetAdapterName "RenameSMBNIC$i"
				{
					NewName = $nicName
					MacAddress = $Node."SMB_NIC_$($i)_MacAddr"
					PhysicalMediaType = '802.3'
				}

				NetAdapterAdvancedProperty "VlanSMBNic$i"
				{
					NetworkAdapterName = $nicName
					RegistryKeyword = "VlanID" 
					RegistryValue = $configSet."SMB_NIC_$($i)_VLAN"
					DependsOn = "[NetAdapterName]RenameSMBNIC$i"
				}

				NetAdapterAdvancedProperty "VMQDisableSMBNic$i"
				{
					NetworkAdapterName = $nicName
					RegistryKeyword = "*VMQ"
					RegistryValue = 0
					DependsOn = "[NetAdapterName]RenameSMBNIC$i"
				}

				NetAdapterAdvancedProperty "SRIOVDisableSMBNic$i"
				{
					NetworkAdapterName = $nicName
					RegistryKeyword = "*SRIOV"
					RegistryValue = 0
					DependsOn = "[NetAdapterName]RenameSMBNIC$i"
				}

                if($configSet.EnableDCB -and $configSet."SMB_NIC_$($i)_Mode" -in('iWARP','RoCEv1','RoCEv2'))
                {
                    DCBNetAdapterQos "EnableQosSMBNIC$i"
                    {
                        InterfaceName = $nicName
                        Ensure = 'Present'
						DependsOn = '[WindowsFeatureSet]DCB', "[NetAdapterName]RenameSMBNIC$i",
						'[DCBNetQosDcbxSetting]DisableDcbxWilling', 
						'[DCBNetQosPolicy]NetQosPolicySMBDirect','[DCBNetQosTrafficClass]NetQosTrafficClassSMBDirect',
						'[DCBNetQosPolicy]NetQosPolicyCluster','[DCBNetQosTrafficClass]NetQosTrafficClassCluster',
						'[DCBNetQosFlowControl]EnableFlowControlPriority3'
                    }
                }
			}
			else # set properties only applicable to virtual SMB NICs
			{
				$vnicName = $nicName.Replace("vEthernet (","").Replace(")","") # Remove 'vEthernet' from NIC name to get VMNicName
                #TODO: Create VMNetworkAdapter and set Vlan to match VMM

                # Map VM NIC to matching host NIC
                $hostNicName = $Node."NIC_$($i)_Name"
			    if($hostNicName -eq $null)
			    {
				    $hostNicName = $configSet."NIC_$($i)_DefaultName" # Grab Default name if not specified
			    }

				<#cVMNetworkAdapterVlan "SMBvNICVLAN$I"
				{
					Id = $vnicName
					AdapterMode = 'Access'
					VlanId = $configSet."SMB_NIC_$($i)_VLAN"
					VMName = 'ManagementOS'
					Name = $vnicName
					DependsOn = '[xVMSwitch]HyperVVMSwitch'
				}#>

                VMNetworkAdapterTeamMapping "SMBvNICMapping$i"
                {
                    Ensure = 'Present'
                    VMNetworkAdapterName = $vnicName
                    PhysicalNetAdapterName = $hostNicName
                    DependsOn = '[WindowsFeatureSet]HyperV', '[xVMSwitch]HyperVVMSwitch'
                }

                if($configSet.EnableDCB)
                {
					# Ensule priority tag is passed to the physical NIC
                    VMNetworkAdapterSettings "SMBvNICIeeePriority$i"
                    {
                        VMName = 'ManagementOS'
                        VMNetworkAdapterName = $vnicName
                        IeeePriorityTag = 'On'
                        DependsOn = '[WindowsFeatureSet]HyperV', '[xVMSwitch]HyperVVMSwitch'
                    }
                }
			}

			NetBios "DisableNetBiosSMBNIC$i"
			{
				InterfaceAlias = $nicName
				Setting = "Disable"
			}

			NetIPInterface "DisableDhcpSMBNIC$i"
			{
				InterfaceAlias = $nicName
				AddressFamily = 'IPv4'
				Dhcp = 'Disabled'
			}

			IPAddress "IPAddrSMBNIC$i"
			{
				IPAddress = $Node."SMB_NIC_$($i)_IP"
				InterfaceAlias = $nicName
				AddressFamily = 'IPv4'
			}

			NetAdapterAdvancedProperty "JumboPacketSMBNic$i"
			{
				NetworkAdapterName = $nicName
				RegistryKeyword = "*JumboPacket"
				RegistryValue = $jumboPacket
			}

			if($configSet."SMB_NIC_$($i)_Mode" -in("iWARP","RoCEv1","RoCEv2"))
			{
				NetAdapterRdma "EnableRDMASMBNIC$i"
				{
					Name = $nicName
					Enabled = $true
				}
			}
			<#else #this doesn't work if the NIC doesn't support RDMA
			{
				NetAdapterRdma "DisableRDMASMBNIC$i"
				{
					Name = $nicName
					Enabled = $false
				}
			}#>
		}

		if($hasIwarp)
		{
			Firewall AllowFileSharingDirectiWARP
			{
				Name = 'FPSSMBD-iWARP-In-TCP'
				Ensure = 'Present'
				Enabled = 'True'
			}
		}

		if($Node.Role -contains "HyperV")
		{
			if($hasIwarp -or $hasRoCe)
			{
				# Currently Microsoft recommends 2 simultanous live migrations when doing RDMA
				# https://techcommunity.microsoft.com/t5/Failover-Clustering/Optimizing-Hyper-V-Live-Migrations-on-an-Hyperconverged/ba-p/396609
				xVMHost VMHostSettingsRDMA
				{
					IsSingleInstance = 'Yes'
					EnableEnhancedSessionMode = $true
					MaximumStorageMigrations = 2
					MaximumVirtualMachineMigrations = 2
					NumaSpanningEnabled = $false
					VirtualMachineMigrationEnabled = $true
					VirtualMachineMigrationAuthenticationType = "CredSSP"
					VirtualMachineMigrationPerformanceOption = "SMB"
					#UseAnyNetworkForMigration = $true # Won't stick when server is in a cluster
                    #VirtualHardDiskPath = 'C:\Hyper-V'
                    #VirtualMachinePath = 'C:\Hyper-V'
                    DependsOn = '[WindowsFeatureSet]HyperV'
				}
			}
			else
			{
				xVMHost VMHostSettingsNoRDMA
				{
					IsSingleInstance = 'Yes'
					EnableEnhancedSessionMode = $true
					MaximumStorageMigrations = 4
					MaximumVirtualMachineMigrations = 4
					NumaSpanningEnabled = $false
					VirtualMachineMigrationEnabled = $true
					VirtualMachineMigrationAuthenticationType = "CredSSP"
					VirtualMachineMigrationPerformanceOption = "Compression"
					#UseAnyNetworkForMigration = $true # Won't stick when server is in a cluster
                    #VirtualHardDiskPath = 'C:\Hyper-V'
                    #VirtualMachinePath = 'C:\Hyper-V'
                    DependsOn = '[WindowsFeatureSet]HyperV'
				}
			}

			Firewall AllowVMMonitorICMPv4
			{
				Name = 'vm-monitoring-icmpv4'
				Ensure = 'Present'
				Enabled = 'True'
			}

			Firewall AllowVMMonitorICMPv6
			{
				Name = 'vm-monitoring-icmpv6'
				Ensure = 'Present'
				Enabled = 'True'
			}

			Firewall AllowVMMonitorDCOM
			{
				Name = 'vm-monitoring-dcom'
				Ensure = 'Present'
				Enabled = 'True'
			}

			Firewall AllowVMMonitorRPC
			{
				Name = 'vm-monitoring-rpc'
				Ensure = 'Present'
				Enabled = 'True'
			}

			# For now, we'll enabled Hyper-V Replica firewall rules on all hosts, even though it's not needed everywhere
			Firewall AllowHVReplicaHTTP
			{
				Name = 'VIRT-HVRHTTPL-In-TCP-NoScope'
				Ensure = 'Present'
				Enabled = 'True'
			}

			Firewall AllowHVReplicaHTTPS
			{
				Name = 'VIRT-HVRHTTPSL-In-TCP-NoScope'
				Ensure = 'Present'
				Enabled = 'True'
			}

			NetBios DisableNetBiosHostvNIC
			{
				InterfaceAlias = "vEthernet ($($configSet.HyperVSwitchName))"
				Setting = "Disable"
				DependsOn = '[WindowsFeatureSet]HyperV','[xVMSwitch]HyperVVMSwitch'
			}

			NetIPInterface DisableDhcpHostvNIC
			{
				InterfaceAlias = "vEthernet ($($configSet.HyperVSwitchName))"
				AddressFamily = 'IPv4'
				Dhcp = 'Disabled'
				DependsOn = '[WindowsFeatureSet]HyperV','[xVMSwitch]HyperVVMSwitch'
			}

			IPAddress IPAddrHostvNIC
			{
				IPAddress = $Node.HostIP
				InterfaceAlias = "vEthernet ($($configSet.HyperVSwitchName))"
				AddressFamily = 'IPv4'
				DependsOn = '[WindowsFeatureSet]HyperV','[xVMSwitch]HyperVVMSwitch'
			}

			$ip = $Node.HostIP.Split("/")[0]
			if($ip.Substring($ip.LastIndexOf('.') +1) % 2 -eq 1) # swap the DNS Server IPs
			{
				DnsServerAddress DNSServers
				{
					Address = $configSet.DNS_IP_1, $configSet.DNS_IP_2
					InterfaceAlias = "vEthernet ($($configSet.HyperVSwitchName))"
					AddressFamily = "IPv4"
					Validate = $true
				}
			}
			else
			{
				DnsServerAddress DNSServers
				{
					Address = $configSet.DNS_IP_2, $configSet.DNS_IP_1
					InterfaceAlias = "vEthernet ($($configSet.HyperVSwitchName))"
					AddressFamily = "IPv4"
					Validate = $true
				}
			}

		}
		elseif($Node.Role -contains "SOFS")
		{
			if($configSet.SOFS_NetLbfoTeamMode -eq 'SwitchIndependent')
			{
				$LoadBalancingAlgorithm = 'Dynamic'
			}
			else
			{
				$LoadBalancingAlgorithm = 'TransportPorts' #Note: When using LACP, DSC does not configure the Lacp Timer
			}

			NetworkTeam HostNetworkTeam
			{
				Name                   = $configSet.SOFS_NetLbfoTeamName
				TeamingMode            = $configSet.SOFS_NetLbfoTeamMode
				LoadBalancingAlgorithm = $LoadBalancingAlgorithm
				TeamMembers            = $nicList
				Ensure                 = 'Present'
				DependsOn = $teamDepends
			}

			WaitForNetworkTeam WaitForHostTeam
			{
				Name      = $configSet.SOFS_NetLbfoTeamName
				DependsOn = '[NetworkTeam]HostNetworkTeam'

			}

			NetBios DisableNetBiosHostvNIC
			{
				InterfaceAlias = $configSet.SOFS_NetLbfoTeamName
				Setting = "Disable"
				DependsOn = '[WaitForNetworkTeam]WaitForHostTeam'
			}

			NetIPInterface DisableDhcpHostvNIC
			{
				InterfaceAlias = $configSet.SOFS_NetLbfoTeamName
				AddressFamily = 'IPv4'
				Dhcp = 'Disabled'
				DependsOn = '[WaitForNetworkTeam]WaitForHostTeam'
			}

			IPAddress IPAddrHostvNIC
			{
				IPAddress = $Node.HostIP
				InterfaceAlias = $configSet.SOFS_NetLbfoTeamName
				AddressFamily = 'IPv4'
				DependsOn = '[WaitForNetworkTeam]WaitForHostTeam'
			}
		}
    }

	node $AllNodes.Where{$_.OS -eq "2016"}.NodeName
	{
		#https://blogs.msdn.microsoft.com/clustering/2016/03/02/troubleshooting-hangs-using-live-dump/
		Registry LiveDump_SystemThrottle_2016
        {
            Key = 'HKLM:\Software\Microsoft\Windows\Windows Error Reporting\FullLiveKernelReports'
            Ensure = 'Present'
            ValueName = 'SystemThrottleThreshold'
            ValueType = 'DWord'
            ValueData = '0'
            Force = $true
        }

        Registry LiveDump_ComponentThrottle_2016
        {
            Key = 'HKLM:\Software\Microsoft\Windows\Windows Error Reporting\FullLiveKernelReports'
            Ensure = 'Present'
            ValueName = 'ComponentThrottleThreshold'
            ValueType = 'DWord'
            ValueData = '0'
            Force = $true
        }

        Registry LiveDump_MaxReports_2016
        {
            Key = 'HKLM:\Software\Microsoft\Windows\Windows Error Reporting\FullLiveKernelReports'
            Ensure = 'Present'
            ValueName = 'FullLiveReportsMax'
            ValueType = 'DWord'
            ValueData = '10'
            Force = $true
        }
	}

    node $AllNodes.Where{$_.OS -eq "2019"}.NodeName
    {
        WindowsFeature SystemInsights
        {
            Name = "System-Insights"
            Ensure = 'Present'
        }

		Firewall AllowSystemInsights
		{
			Name = 'SystemInsights-Allow-In'
			Ensure = 'Present'
			Enabled = 'True'
		}

		#https://blogs.msdn.microsoft.com/clustering/2016/03/02/troubleshooting-hangs-using-live-dump/
        Registry LiveDump_SystemThrottle_1709
        {
            Key = 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl\FullLiveKernelReports'
            Ensure = 'Present'
            ValueName = 'SystemThrottleThreshold'
            ValueType = 'DWord'
            ValueData = '0'
            Force = $true
        }

        Registry LiveDump_ComponentThrottle_1709
        {
            Key = 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl\FullLiveKernelReports'
            Ensure = 'Present'
            ValueName = 'ComponentThrottleThreshold'
            ValueType = 'DWord'
            ValueData = '0'
            Force = $true
        }

        Registry LiveDump_MaxReports_1709
        {
            Key = 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl\FullLiveKernelReports'
            Ensure = 'Present'
            ValueName = 'FullLiveReportsMax'
            ValueType = 'DWord'
            ValueData = '10'
            Force = $true
        }
    }
}

# Compile with data
HyperVFabricSettings -ConfigurationData AllNodes.psd1