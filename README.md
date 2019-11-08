# HyperV_DSC
A set of sample scripts that use PowerShell DSC for configuring Hyper-V hosts and Scale-Out File Servers.  Can be used with Storage Spaces Direct or any other back-end storage.  In general, these scripts are primarily useful when using SMB for storage, or when setting up a hyper-converged cluster with Storage Spaces Direct.  They can be used with Hyper-V hosts using traditional iSCSI/Fibre Channel storage, but most of the settings won't be applicable.  Only Windows Server 2016 and Windows Server 2019 are supported.

Currently this is a work in progress and the scripts are not complete!

# Scenarios
These scripts are only for configuring individual hosts.  To build a failover cluster, use these scripts to configure the hosts and then create the cluster with PowerShell or Failover Cluster Manager.

## Supported Hyper-V Host configurations
- Only Switch-Embedded Teaming is supported on the virtual switch
- Only a single virtual switch is supported
- Currently the management OS network must be shared with the virtual switch
- Currently the DSC script can't completely deploy a virtual switch, it must be done using System Center Virtual Machine Manager
- On Windows Server 2019, RSS/VMQ settings do not need to be changed.  I have not built the script to apply optimal RSS settings on Windows Server 2016.
- When using RDMA NICs, Live Migration will be configured for SMB.  When not using RDMA NICs, Live Migration will be configured for Compression.
- The GuardedHost role will install the necessary features for supporting Shielded VMs but does not configure the HGS Attestation URLs, Code Integrity Policies, etc.

## Supported Scale-Out File Server configurations
- It is assumed that the Hyper-V Role is NOT installed on SOFS
- LBFO teaming is used on the management network, either in switch-independent or LACP mode
- The script will not do any configuration of the storage itself

## Supported Network configurations
- The scripts can support an arbitrary number of NICs per host
- Both RDMA and non-RDMA NICs are supported
- It is possible to have multiple NICs of different types, for example if an SOFS cluster has both iWARP and RoCE RDMA NICs.
- For RDMA NICs, these scripts have been tested with Chelsio and Mellanox ONLY
- The script can support a configuration with DCB or one without DCB
- The script does not validate the DCB configuration at the switch level
- Both converged networking where storage traffic is shared with the virtual switch, and dedicated storage NICs are supported
- With converged networking, there can't be more virtual storage NICs than actual physical NICs.  Virtual SMB NIC 1 will be mapped to physical NIC 1 and so on.
- It is possible to create a configuration that has both converged storage NICS and dedicated storage NICs but I have not tested this.
- It is assumed that the management network and storage networks are on tagged VLANs, but it should be ok to set the VLAN ID to 0 if not.
- NICs are identified by MAC Address in the configuration to ensure the correct NIC has the correct name
- It is supported for the name of NICs to either be identical on all cluster nodes, or different on all cluster nodes.

# Getting started
Deploying a set of hosts with these scripts is done in the following steps

1. Download the scripts from the repository to your administrative workstation
2. Configure the server hardware, and install Windows Server from OS media
3. Get the MAC Address and NIC information from each server
4. Input the configuration and list of servers into AllNodes.psd1
5. Run Compile-Settings.ps1 to create the PowerShell DSC .MOF files
6. Copy AllNodes.psd1, Start-FirstRun.ps1 and InstallDSCModulesLocal.ps1 to each server using a USB key or other offline media
7. Run Start-FirstRun.ps1 -computer "server name"
8. After the script completes and the server rebootes, join the server to your Active Directory domain using sconfig, and then install the latest Windows Updates
9. Run Start-HostConfig.ps1 from your administrative workstation to apply the configuration.  Currently this only works with SCVMM
10. Follow the normal documentation for creating clusters

# The configuration

## AllNodes.psd1
This is the only file that should need to be modified.  This contains all the settings specific to each environment.

### Node configuration
>AllNodes = @( <br>
> @{ <br>
>&nbsp;&nbsp;&nbsp;&nbsp;NodeName = 'name' <br>

The Node name is the operating system name of the server

>&nbsp;&nbsp;&nbsp;&nbsp;Role = 'Role1', 'Role2' <br>

#### Supported Values for Role:
- Either 'HyperV' or 'SOFS' is *required* to identify if this server will host Hyper-V VMs locally or will act as a Scale-Out File Server
- 'ClusterNode' if the host will be part of a failover cluster.  This should be omitted if it is a standalone Hyper-V host
- 'MPIO' if the server will have traditional SAN storage directly attached, which normally requires Multi-Path I/O to be installed
- 'S2D' if the server will be part of a Storage Spaces Direct cluster, which requires Multi-Path I/O to NOT be installed
- 'GuardedHost' if the server will be hosting Shielded VMs as part of a Guarded Fabric

>&nbsp;&nbsp;&nbsp;&nbsp;Config = 'ConfigSetName' <br>

*Required* The config name should match a name in the ConfigSet section (see below)

>&nbsp;&nbsp;&nbsp;&nbsp;NIC_n_Name = 'NIC n Name' <br>

*Optional* The NetAdapterName for each NIC.  If the name is not specified here, the default name in the ConfigSet will be used insetad.  For Hyper-V, these NICs are added to the Virtual Switch Embedded Team.  For SOFS, these NICs are part of the management LBFO team.

>&nbsp;&nbsp;&nbsp;&nbsp;NIC_n_MacAddr = 'NIC n Mac Address' <br>

*Required*.  Specify the MAC Address of each NIC

>&nbsp;&nbsp;&nbsp;&nbsp;SMB_NIC_n_Name = 'SMB NIC Name' <br>

*Physical NICs only. Optional* Specify the name of the storage NIC.  For virtual NICs, do not override the virtual NIC name.

>&nbsp;&nbsp;&nbsp;&nbsp;SMB_NIC_n_MacAddr = 'SMB NIC Mac addr' <br>

*Physical NICs only.  Required* Specify the MAC Address of the storage NIC

>&nbsp;&nbsp;&nbsp;&nbsp;SMB_NIC_n_IP = 'IP Address/Size' <br>

*Required* Specify the Storage NIC's IP address and subnet mask size.  For example, if it's a class C (255.255.255.0), use /24 for the size.

>&nbsp;&nbsp;&nbsp;&nbsp;HostIP = 'IP Address/Size' <br>

*Required* Specify the management IP address of the server.

>&nbsp;&nbsp;&nbsp;&nbsp;OS = '2019' <br>

*Required* Use either 2016 or 2019 for this to distinguish whether the server is running Windows Server 2016 or Windows Server 2019.  No other values are supported.

>}
>)

### Configuration Set
> ConfigSet = @(<br>
> @{<br>
>&nbsp;&nbsp;&nbsp;&nbsp;ConfigName = 'Name'

The name of the configuration set.  This must match the name used at the node level above.

>&nbsp;&nbsp;&nbsp;&nbsp;TimeZone = 'Time Zone Name'

The Time Zone for this configuration.  For a list of possible names, run "Get-TimeZone -ListAvailable" in a PowerShell Window

>&nbsp;&nbsp;&nbsp;&nbsp;SCVMMSiteName = 'Site Name'

The name of the Host Group in SCVMM that Hyper-V hosts should be added to.

>&nbsp;&nbsp;&nbsp;&nbsp;SCVMMUplinkName = 'Uplink Name'

The name of the Uplink Port Group in SCVMM that the logical switch uses.

>&nbsp;&nbsp;&nbsp;&nbsp;HyperVSwitchName = 'Virtual Switch Name'

The name of the VMSwitch in Hyper-V/SCVMM

>&nbsp;&nbsp;&nbsp;&nbsp;HyperVHostVNicName = 'vNIC Name'

The name of the management NIC name in SCVMM.  Note that the host will use the virtual switch name.

>&nbsp;&nbsp;&nbsp;&nbsp;PowerPlan = 'High performance'

The Power Plan should normally be set to 'High performance', but in a power-constrained environment, it might make sense to use 'Balanced' instead.

>&nbsp;&nbsp;&nbsp;&nbsp;HostVLAN = 123

The public VLAN the Hyper-V and SOFS management interface uses.  Set to 0 if using an access port/default VLAN.

>&nbsp;&nbsp;&nbsp;&nbsp;SRIOV = $false

Whether or not the virtual switch will have SR-IOV enabled.

>&nbsp;&nbsp;&nbsp;&nbsp;JumboFrames = $true

Whether or not the physical switches support Jumbo Frames.

>&nbsp;&nbsp;&nbsp;&nbsp;EnableDCB = $true

Whether or not to enable Data Center Bridging/Priority Flow Control on the storage networks.  

>&nbsp;&nbsp;&nbsp;&nbsp;DNS_IP_1 = 'IP address'
>&nbsp;&nbsp;&nbsp;&nbsp;DNS_IP_2 = 'IP address

The IP addresses for the DNS servers the servers will use.

>&nbsp;&nbsp;&nbsp;&nbsp;NIC_COUNT = 2

The number of NICs.  Typically this would be 2.

>&nbsp;&nbsp;&nbsp;&nbsp;NIC_n_Type = 'Type'

The type of NIC used.  

#### Supported Values for NIC Types:
- Generic1g for any NIC running at 1Gbps, which will disable VMQ
- Generic10g for any non-RDMA NIC running at 10Gbps or higher
- Broadcom for the NetExtreme-E that supports RoCE
- Chelsio for any Chelsio T5 or T6-based NIC which supports iWARP
- Cavium for any FastLinQ adapter that supports either iWARP or RoCE
- Intel for the an Intel adapter that supports iWARP (only the X722)
- Mellanox for any Mellanox adapter which supports RoCE

>&nbsp;&nbsp;&nbsp;&nbsp;NIC_n_DefaultName = 'Name'

The default name to use for this NIC if it's not specified at the node-level

>&nbsp;&nbsp;&nbsp;&nbsp;Has_Virtual_SMB_Nic = $false/$true

Set to true if there is at least one virtual storage NIC

>&nbsp;&nbsp;&nbsp;&nbsp;SMB_NIC_COUNT = 2

The number of storage NICs.  Set to 0 if not using SMB traffic, such as on a standalone Hyper-V host, or a cluster with SAN storage

>&nbsp;&nbsp;&nbsp;&nbsp;SMB_NIC_n_Type = 'Type'

Set to 'Virtual' if using converged networking with virtual storage NICs, otherwise use a value from the supported NIC Types above

>&nbsp;&nbsp;&nbsp;&nbsp;SMB_NIC_n_VLAN = 123

The VLAN ID for the storage NIC.  Set to 0 for default VLAN/access port.  When using DCB/PFC, a VLAN is required.

>&nbsp;&nbsp;&nbsp;&nbsp;SMB_NIC_n_Mode = 'Mode'

The SMB mode for this NIC

#### Supported values
- TCP for non-RDMA NICs
- iWARP
- RoCEv1
- RoCEv2

>&nbsp;&nbsp;&nbsp;&nbsp;SMB_NIC_n_DefaultName = 'Name'

The default name of the storage NIC.  For virtual NICs use "vEthernet (Name)"

>&nbsp;&nbsp;&nbsp;&nbsp;SMB_LiveMig_BW_Limit = Number

Optionally specify the SMB Bandwdith Limit for Live Migration

>&nbsp;&nbsp;&nbsp;&nbsp;SOFS_NetLbfoTeamName

The name of the Lbfo Team for the SOFS management interface.  Can be omitted if there are no SOFS clusters using this configuration.

>&nbsp;&nbsp;&nbsp;&nbsp;SOFS_NetLbfoTeamMode

The Lbfo Teaming mode for the SOFS management interface.  Either Lacp or SwitchIndependent.

> } )

## HyperVFabricSettings.ps1
This contains all of the DSC settings.  Additional information regarding the actual settings will be added to this README later.

## Compile-Settings.ps1
Simple script to compile the DSC configuration, useful for automation with something like Azure Pipelines.

## Check-Dsc.ps1
Script to run Test-DscConfiguration and format the output.

## Apply-Dsc.ps1
Script to run Start-DscConfiguration

## InstallDscModulesLocal.ps1 and InstallDscModulesInvoke.ps1
These scripts will download the required DSC Modules from the PowerShell Gallery.

## Start-FirstRun.ps1
This script will do the initial configuration on the host that is needed prior to applying the DSC configuration.

## SCVMM-AddHost.ps1
This script will install the SCVMM Agent to the host

## SCVMM-AddHostSwitch.ps1
This script will deploy the virtual switch to the host from SCVMM