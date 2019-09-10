@{
    AllNodes = @(
        @{
            NodeName = 'SampleClst1_Node1'
            Role = 'HyperV', 'ClusterNode'
            Config = 'Site1_SMB_TCP_Shared'
            #NIC_1_Name = 'Ethernet_1'
			NIC_1_MacAddr = '00-11-22-33-44-55'
            #NIC_2_Name = 'Ethernet_2'
			NIC_2_MacAddr = '00-11-22-33-44-55'
            SMB_NIC_1_IP = '192.168.10.21/24'
            SMB_NIC_2_IP = '192.168.11.21/24'
            HostIP = '192.168.0.21/24'
            OS = '2019'
        },
        @{
            NodeName = 'SameClst1_Node2'
            Role = 'HyperV', 'ClusterNode'
            Config = 'Site1_SMB_TCP_Shared'
            NIC_1_Name = 'Ethernet_1_Port3'
			NIC_1_MacAddr = '00-11-22-33-44-55'
            NIC_2_Name = 'Ethernet_2_Port7'
			NIC_2_MacAddr = '00-11-22-33-44-55'
            SMB_NIC_1_IP = '192.168.10.22/24'
            SMB_NIC_2_IP = '192.168.11.22/24'
            HostIP = '192.168.0.22/24'
            OS = '2019'
        },
        @{
            NodeName = 'SampleClst2_Node1'
            Role = 'HyperV', 'ClusterNode'
            Config = 'Site1_SMB_TCP_Dedicated'
			NIC_1_MacAddr = '00-11-22-33-44-55'
			NIC_2_MacAddr = '00-11-22-33-44-55'
			SMB_NIC_1_MacAddr = '00-11-22-33-44-55'
			SMB_NIC_2_MacAddr = '00-11-22-33-44-55'
            SMB_NIC_1_IP = '192.168.10.51/24'
            SMB_NIC_2_IP = '192.168.11.51/24'
			HostIP = '192.168.0.51/24'
            OS = '2019'
        },
        @{
            NodeName = 'SampleClst2_Node2'
            Role = 'HyperV', 'ClusterNode'
            Config = 'Site1_SMB_TCP_Dedicated'
			NIC_1_MacAddr = '00-11-22-33-44-55'
			NIC_2_MacAddr = '00-11-22-33-44-55'
			SMB_NIC_1_MacAddr = '00-11-22-33-44-55'
			SMB_NIC_2_MacAddr = '00-11-22-33-44-55'
            SMB_NIC_1_IP = '192.168.10.52/24'
            SMB_NIC_2_IP = '192.168.11.52/24'
			HostIP = '192.168.0.52/24'
            OS = '2019'
        },
		@{
			NodeName = 'SampleClst3_Node1'
			Role = 'HyperV', 'S2D', 'ClusterNode', 'GuardedHost'
			Config = 'Site2_SMB_MLNX_Dedicated'
			NIC_1_MacAddr = '00-11-22-33-44-55'
			NIC_2_MacAddr = '00-11-22-33-44-55'
			SMB_NIC_1_IP = '192.168.10.31/24'
			SMB_NIC_1_MacAddr = '00-11-22-33-44-55'
			SMB_NIC_2_IP = '192.168.11.31/24'
			SMB_NIC_2_MacAddr = '00-11-22-33-44-55'
			HostIP = '192.168.1.31/24'
			OS = '2019'
		},
		@{
			NodeName = 'SampleClst3_Node2'
			Role = 'HyperV', 'S2D', 'ClusterNode', 'GuardedHost'
			Config = 'Site2_SMB_MLNX_Dedicated'
			NIC_1_MacAddr = '00-11-22-33-44-55'
			NIC_2_MacAddr = '00-11-22-33-44-55'
			SMB_NIC_1_IP = '192.168.10.32/24'
			SMB_NIC_1_MacAddr = '00-11-22-33-44-55'
			SMB_NIC_2_IP = '192.168.11.32/24'
			SMB_NIC_2_MacAddr = '00-11-22-33-44-55'
			HostIP = '192.168.1.32/24'
			OS = '2019'
		},
        @{
            NodeName = 'SampleClst4_Node1'
            Role = 'HyperV', 'ClusterNode', 'GuardedHost'
            Config = 'Site1_SMB_Chelsio_Shared'
			NIC_1_MacAddr = '00-11-22-33-44-55'
			NIC_2_MacAddr = '00-11-22-33-44-55'
            SMB_NIC_1_IP = '192.168.10.91/24'
            SMB_NIC_2_IP = '192.168.11.91/24'
			HostIP = '192.168.0.91/24'
            OS = '2019'
        },
        @{
            NodeName = 'SampleClst4_Node2'
            Role = 'HyperV', 'ClusterNode', 'GuardedHost'
            Config = 'Site1_SMB_Chelsio_Shared'
			NIC_1_MacAddr = '00-11-22-33-44-55'
			NIC_2_MacAddr = '00-11-22-33-44-55'
            SMB_NIC_1_IP = '192.168.10.92/24'
            SMB_NIC_2_IP = '192.168.11.92/24'
			HostIP = '192.168.0.92/24'
            OS = '2019'
        },
        @{
			NodeName = 'SampleClst5_Node1'
			Role = 'SOFS', 'ClusterNode', 'S2D'
			Config = 'Site1_SMB_Chelsio_Dedicated'
			NIC_1_MacAddr = '00-11-22-33-44-55'
			NIC_2_MacAddr = '00-11-22-33-44-55'
			SMB_NIC_1_IP = '192.168.10.101/24'
			SMB_NIC_1_MacAddr = '00-11-22-33-44-55'
			SMB_NIC_2_IP = '192.168.11.101/24'
			SMB_NIC_2_MacAddr = '00-11-22-33-44-55'
			HostIP = '192.168.0.101/24'
			OS = '2019'
        },
        @{
            NodeName = 'SampleClst5_Node2'
            Role = 'SOFS', 'ClusterNode', 'S2D'
            Config = 'Site1_SMB_Chelsio_Dedicated'
			NIC_1_MacAddr = '00-11-22-33-44-55'
			NIC_2_MacAddr = '00-11-22-33-44-55'
            SMB_NIC_1_IP = '192.168.10.102/24'
			SMB_NIC_1_MacAddr = '00-11-22-33-44-55'
            SMB_NIC_2_IP = '192.168.11.102/24'
			SMB_NIC_2_MacAddr = '00-11-22-33-44-55'
			HostIP = '192.168.0.102/24'
            OS = '2019'
        }
    );

	<#
	NIC Types:
	Generic1g - No RDMA, no VMQ
	Generic10g - No RDMA (any 10gbps or faster NIC)
	Chelsio - iWARP RDMA
	Cavium - iWARP or RoCE RDMA (Cavium/QLogic FastLinQ series)
	Mellanox - RoCE RDMA
	IntelX722 - Intel's iWARP NIC
	virtual - (SMB_NIC only) sharing primary NICs using VMNetworkAdapter

	SMB Modes:
	TCP - no RDMA
	iWARP - Chelsio or Cavium
	RoCEv1 - Mellanox or Cavium
	RoCEv2 - Mellanox or Cavium
	#>
	ConfigSet = @(
		@{
			ConfigName = 'Site1_NoSMB'
			TimeZone = 'Eastern Standard Time'
			SCVMMSiteName = 'Site1'
			SCVMMUplinkName = 'Uplink_Site1'
			HyperVSwitchName = 'Site1_VMSwitch'
			HyperVHostVNicName = 'MGMT'
			PowerPlan = 'High performance'
			HostVLAN = 100
			SRIOV = $false
			JumboFrames = $false
			EnableDCB = $false
			DNS_IP_1 = '192.168.0.2'
			DNS_IP_2 = '192.168.0.3'
			NIC_COUNT = 2
			NIC_1_Type = 'Generic10g'
			NIC_1_DefaultName = 'Ethernet_1'
			NIC_2_Type = 'Generic10g'
			NIC_2_DefaultName = 'Ethernet_2'
			Has_Virtual_SMB_NIC = $false
			SMB_NIC_COUNT = 0
		},
		@{
			ConfigName = 'Site1_SMB_TCP_Shared'
			TimeZone = 'Eastern Standard Time'
			SCVMMSiteName = 'Site1'
			HyperVSwitchName = 'Site1_VMSwitch_SMB'
			HyperVHostVNicName = 'MGMT'
			PowerPlan = 'High performance'
			HostVLAN = 100
			SRIOV = $false
			JumboFrames = $true
			EnableDCB = $false
			DNS_IP_1 = '192.168.0.2'
			DNS_IP_2 = '192.168.0.3'
			NIC_COUNT = 2
			NIC_1_Type = 'Generic10g'
			NIC_1_DefaultName = 'Ethernet_1'
			NIC_2_Type = 'Generic10g'
			NIC_2_DefaultName = 'Ethernet_2'
			Has_Virtual_SMB_NIC = $true
			SMB_NIC_COUNT = 2
			SMB_NIC_1_Type = 'Virtual'
			SMB_NIC_1_VLAN = 101
			SMB_NIC_1_Mode = 'TCP'
			SMB_NIC_1_DefaultName = 'vEthernet (SMB_1)'
			SMB_NIC_2_Type = 'Virtual'
			SMB_NIC_2_VLAN = 102
			SMB_NIC_2_Mode = 'TCP'
			SMB_NIC_2_DefaultName = 'vEthernet (SMB_2)'
		},
		@{
			ConfigName = 'Site1_SMB_TCP_Dedicated'
			TimeZone = 'Eastern Standard Time'
			SCVMMSiteName = 'Site1'
			HyperVSwitchName = 'Site1_VMSwitch'
			HyperVHostVNicName = 'MGMT'
			PowerPlan = 'High performance'
			HostVLAN = 100
			SRIOV = $false
			JumboFrames = $true
			EnableDCB = $false
			DNS_IP_1 = '192.168.0.2'
			DNS_IP_2 = '192.168.0.3'
			NIC_COUNT = 2
			NIC_1_Type = 'Generic10g'
			NIC_1_DefaultName = 'Ethernet_1'
			NIC_2_Type = 'Generic10g'
			NIC_2_DefaultName = 'Ethernet_2'
			Has_Virtual_SMB_NIC = $false
			SMB_NIC_COUNT = 2
			SMB_NIC_1_Type = 'Generic10g'
			SMB_NIC_1_VLAN = 101
			SMB_NIC_1_Mode = 'TCP'
			SMB_NIC_1_DefaultName = 'SMB_1'
			SMB_NIC_2_Type = 'Generic10g'
			SMB_NIC_2_VLAN = 102
			SMB_NIC_2_Mode = 'TCP'
			SMB_NIC_2_DefaultName = 'SMB_2'
			SOFS_NetTeamName = 'MGMT'
			SOFS_NetTeamMode = 'Lacp'
		},
		@{
			ConfigName = 'Site1_SMB_Chelsio_Shared'
			TimeZone = 'Eastern Standard Time'
			SCVMMSiteName = 'Site1'
			HyperVSwitchName = 'Site1_VMSwitch_SMB_iWARP'
			HyperVHostVNicName = 'MGMT'
			PowerPlan = 'High performance'
			HostVLAN = 100
			SRIOV = $false
			JumboFrames = $true
			EnableDCB = $true
			DNS_IP_1 = '192.168.0.2'
			DNS_IP_2 = '192.168.0.3'
			NIC_COUNT = 2
			NIC_1_Type = 'Chelsio'
			NIC_1_DefaultName = 'Ethernet_1'
			NIC_2_Type = 'Chelsio'
			NIC_2_DefaultName = 'Ethernet_2'
			Has_Virtual_SMB_NIC = $true
			SMB_NIC_COUNT = 2
			SMB_NIC_1_Type = 'Virtual'
			SMB_NIC_1_VLAN = 101
			SMB_NIC_1_Mode = 'iWARP'
			SMB_NIC_1_DefaultName = 'vEthernet (SMB_1)'
			SMB_NIC_2_Type = 'Virtual'
			SMB_NIC_2_VLAN = 102
			SMB_NIC_2_Mode = 'iWARP'
			SMB_NIC_2_DefaultName = 'vEthernet (SMB_2)'
		},
		@{
			ConfigName = 'Site1_SMB_Chelsio_Dedicated'
			TimeZone = 'Eastern Standard Time'
			SCVMMSiteName = 'Site1'
			HyperVSwitchName = 'Site1_VMSwitch'
			HyperVHostVNicName = 'PaceNet'
			PowerPlan = 'High performance'
			HostVLAN = 100
			SRIOV = $false
			JumboFrames = $true
			EnableDCB = $true
			DNS_IP_1 = '192.168.0.2'
			DNS_IP_2 = '192.168.0.3'
			NIC_COUNT = 2
			NIC_1_Type = 'Generic10g'
			NIC_1_DefaultName = 'Ethernet_N5k1'
			NIC_2_Type = 'Generic10g'
			NIC_2_DefaultName = 'Ethernet_N5k2'
			Has_Virtual_SMB_NIC = $false
			SMB_NIC_COUNT = 2
			SMB_NIC_1_Type = 'Chelsio'
			SMB_NIC_1_VLAN = 101
			SMB_NIC_1_Mode = 'iWARP'
			SMB_NIC_1_DefaultName = 'SMB_1'
			SMB_NIC_2_Type = 'Chelsio'
			SMB_NIC_2_VLAN = 102
			SMB_NIC_2_Mode = 'iWARP'
			SMB_NIC_2_DefaultName = 'SMB_2'
			SOFS_NetLbfoTeamName = 'MGMT'
			SOFS_NetLbfoTeamMode = 'Lacp'
		},
		@{
			ConfigName = 'Site2_SMB_MLNX_Dedicated'
			TimeZone = 'Pacific Standard Time'
			SCVMMSiteName = 'Site2'
			HyperVSwitchName = 'Site2_VMSwitch'
			HyperVHostVNicName = 'MGMT'
			PowerPlan = 'Balanced'
			HostVLAN = 100
			SRIOV = $false
			JumboFrames = $true
			EnableDCB = $true
			DNS_IP_1 = '192.168.1.2'
			DNS_IP_2 = '192.168.1.3'
			NIC_COUNT = 2
			NIC_1_Type = 'Generic1g'
			NIC_1_DefaultName = 'Ethernet_1'
			NIC_2_Type = 'Generic1g'
			NIC_2_DefaultName = 'Ethernet_2'
			Has_Virtual_SMB_NIC = $false
			SMB_NIC_COUNT = 2
			SMB_NIC_1_Type = 'MLNX'
			SMB_NIC_1_VLAN = 103
			SMB_NIC_1_Mode = 'RoCEv2'
			SMB_NIC_1_DefaultName = 'SMB_1'
			SMB_NIC_2_Type = 'MLNX'
			SMB_NIC_2_VLAN = 104
			SMB_NIC_2_Mode = 'RoCEv2'
			SMB_NIC_2_DefaultName = 'SMB_2'
		}
	)

    NonNodeData =
    @{
        DscModules = 'PSDscResources', 'ComputerManagementDsc', 'NetworkingDsc', 'xHyper-V',  'xRemoteDesktopAdmin', 
            'DataCenterBridging', 'VMNetworkAdapter', 'cHyper-V'
		#, 'WindowsDefender' 'SecurityPolicyDsc', 'xFailOverCluster', 
            #, 'NetQoSDSC', 'HyperVDsc' #These are not made by microsoft and not in Powershell Gallery
    }
}
