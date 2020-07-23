# Meraki-API
PowerShell Module to work with the MerakiAPI.

NOTE: This is a work in progress. This module only exposes a very small subset of the Meraki API REST functions. There may be bugs and you should
expect that there are bugs.

INSTALLATION

NOTE: This module will eventually be published to the Powershell Gallery once significant testing has been done.

Windows

Windows Powershell < 6.1
You should install this module inthe User scope unless it is being installed on a shared system.

User Scope Install
Command Prompt
>cd %USERPROFILE%\Documents\WindowsPowershell\Modules
>git clone {path}

Powershell
>cd $env:USERPROFILE\Documents\WindowsPowerShell\Modules
>git clone {path}

System Scope Install
Command Prompt
Open a elevated command prompt
>cd %ProgramFiles%\WindowsPowershell\Modules
>git clone {path}

Powershell
Open an elevated Powershell session
>cd $env:PROGRAMFILES\WindowsPowershell\Modules
>git clone https://github.com/Clifra-Jones/Meraki-API.git

Powershell Core / Powershell 7
User Scope Install
Command Prompt
>cd %UserProfile%\Documents\PowerShell\Modules
>git clone https://github.com/Clifra-Jones/Meraki-API.git

Powershell
>cd $env:USERPROFILE\Documents\PowerShell\Modules
>git clone https://github.com/Clifra-Jones/Meraki-API.git

System Scope Install
Command Prompt
Open an elevated command prompt
>cd %PROGRAMFILES%\PowerShell\7\modules
>git clone https://github.com/Clifra-Jones/Meraki-API.git

Linux/Mac
User Scope Install
>cd ~/.local/share/powershell/Modules
>git clone https://github.com/Clifra-Jones/Meraki-API.git

System Scope Install
>cd /usr/local/share/powershell/Modules
>sudo git clone https://github.com/Clifra-Jones/Meraki-API.git

USAGE
API Access must be anbledon your Meraki Dashboard.
You will need to have a Meraki API key. You gan get your key by logging into your Meraki Dashboard, go to your profile and generate your API key.
Save this key ina safe place.

Once you have your API key you need to obtain the Organization ID for the Organizations you have access to. You can do this with the GetMerakiOrganizations function.

Open Powershell
>Import-Module Meraki-API
>Get-MerakiOrganizations -APIKey '{key string}'

This will produce this:
id     name                         url
--     ----                         ---
XXXXXX {Company Name}               https://nxx.meraki.com/o/LY2ULd/manage/organization/overview

Configure your user profile to use the API.
You must configure your profile to user the API. T odo this use the Set-MerakiAPI function.
>Set-MerakiAPI -APIKey '{key string}' -OrgID 'XXXXXX'
This will create the file .meraki/config.json in your user profile. 

Commands:

Set-MerakiAPI
Description: Save configuration information in the user profile.
Paramters:
  APIKey: Meraki API Key 
  OrgID: Organizational ID

Get-MerakiOrganizations
Description: Retrieve the Organization information the user has access to.
Parameters:
  APIKey: Meraki API Key
  
Get-MerakiNetworks
Description: Retrieve All networks in the Organization

Get-MerakiNetwork
Description: Retrieve a specific network
Parameters
  NetworkID: The ID of the network to retrieve
 
Get-MerakiNetworkDevices
Description: Retrieve all devices in a network.
Parameters:
  id: Network ID
      Accepts Pipeline input
Examples:
Get devices in a specific network
>Get-MerakiNetworkDevices -id N-XXXXXXXXXXXXXXX

Get-Devices using the pipeline
>Get-MerakiNetworks | Get-MerakiDevices

Get-MerakiNetworkDevice
Description: Get a specific Device.
Parameters: 
  DeviceID: The device ID to retrieve
  
Get-MerakiOrganizationDevices
Description: Get all devices in an organization

Get-MerakiNetworkVLANS
Description: Get all VLANS in a Meraki Network
Parameters:
  id: The network ID 
      Accepts Pipeline entry
  NoProgress: Switch to no display progress bar.
Examples: 
Get VLANS in a network
>Get-MerakiNetworkVLANS -id N-XXXXXXXXXXXXXXX

Get VLANS in a Network using the pipeline
>Get-MerakiNetwork -NetworkID N-XXXXXXXXXXXXX | Get-MerakiNetworkVLANS 

Get VLANS from Multiple Networks without the progress bar
>Get-MerakiNetworks | Get-MerakiNetworkVLANS -NoProgress

Get-MerakiNetworkVLAN
Description: Get a specific VLAN
Parameters:
  NetworkID: Network ID
  id: VLAN ID

Get-MerakiDeviceSwitchSettings
Description: Get switch settings for a network
Parameters:
  id: Network ID
      Accepts Pipeline input

Get-MerakiDeviceSwitchPorts
Description: Get Switch port settings for a device
Parameters:
  serial: Serial Number of the device
  
Get-MerakiNetworkContentFilteringRules
Description: Get content filtering rules for a network
Paramters: 
  id: Network ID
      Accepts Pipeline input
      
Update-MerakiNetworkContentFiltering
Description: Update the networks content filtering rules
Parameters:
  id: Network ID
      Accepts Pipelne input
  allowedURLPatterns: String array of URL patterns
  blockedURLPatterns: String array od URL patterns
  blockedURLCategories: String Array of URL Categories
  urlCategoryListSize: Either 'topSites' or 'fullList'
  
  

  
