
#Private Variables
$BaseURI = "https://api.meraki.com/api/v0"

#Public
enum CategoryListSize {
    topSites;
    fullList
}

enum productTypes{
    wireless;
    appliance;
    switch;
    systemManager;
    camera;
    cellularGateway
}

<#
.Description
Creates a file in the user profile folder un the .meraki folder named config.json.
This file contains the users Meraki API Key and the default Organization ID
#>
function Set-MerakiAPI() {
    Param(
        [string]$APIKey,
        [string]$OrgID
    )

    if (-not $APIKey) {
        $APIKey = Read-Host -Prompt "API Key: "
    }

    if (-not $OrgID) {
        $OrgID = Read-Host -Prompt  "Organization ID"
    }

    $objConfig = @{
        APIKey = $APIKey
        OrgID = $OrgID
    }
    $configPath = "{0}/.meraki" -f $env:userProfile

    if (-not (Test-Path -Path $configPath)) {
        mkdir -Path $configPath
    }

    $objConfig | ConvertTo-Json | Out-File -FilePath "$configPath/config.json"
}
function Read-Config () {
    $ConfigPath = "$($env:USERPROFILE)/.meraki/config.json"
    $config = Get-Content -Raw -Path $ConfigPath | ConvertFrom-Json
    return $config
}

function Get-Headers() {
    $config = Read-Config
    $Headers = @{
        "X-Cisco-Meraki-API-Key" = $config.APIKey
        "Content-Type" = 'application/json'
    }
    return $Headers
}

<#
.Description
Retrieves the Organization nformation thet the provided Meraki API Key has access to. This will retrieve the Organization ID.
#>
function Get-MerakiOrganizations() {
    Param(
        [Parameter(Mandatory = $true)]
        [string]$APIKey
    )

    $Uri = "{0}/organizations" -f $BaseURI
    $Headers = @{
        "X-Cisco-Meraki-API-Key" = $APIKey
        "Content-Type" = 'application/json'
    }
    
    $response = Invoke-RestMethod -Method GET -Uri $Uri -Headers $Headers
    
    return $response

}

<#
.Description
Retrieves all Networks for a Meraki Organization
#>
function Get-MerakiNetworks() {
    $config = Read-Config
    $Uri = "{0}/organizations/{1}/networks" -f $BaseURI, $config.OrgID
    $Headers = Get-Headers

    $response = Invoke-RestMethod -Method GET -Uri $Uri -Headers $Headers

    return $response
}

<#
.Description
Retrieves a specific Network
#>
function Get-MerakiNetwork() {
    Param(
        [Parameter(
            Mandatory = $true
        )]
        [String]$NetworkID
    )
    $Uri = "{0}/networks/{1}" -f $BaseURI, $NetworkID
    $Headers = Get-Headers

    $Response = Invoke-RestMethod -Method GET -Uri $Uri -Headers $Headers

    return $Response
}

<#
.Description
Retrieves all devices for a Network
#>
function Get-MerakiNetworkDevices () {
    [cmdletbinding()]
    Param (
        [Parameter(
            Mandatory   = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $True)]
        [string]$id
    )

    Begin {
        $Headers = Get-Headers
    }

    Process {
    
        $Uri = "{0}/networks/{1}/devices" -f $BaseURI, $id
        $response = Invoke-RestMethod -Method GET -Uri $Uri -Headers $Headers
        return $response
    }
}

<#
.Description
Retrieves a specific Device
#>
function Get-MerakiNetworkDevice() {
    [CmdletBinding()]
    Param(
        [Parameter(
            Mandatory = $true)]
        [string]$NetworkID,
        [Parameter(
            Mandatory = $true)]
        [string]$DeviceID
    )

    $Uri = "{0}/networks/{1}/devices/{2}" -f $BaseURI, $NetworkID, $DeviceID
    $Headers = Get-Headers

    $response = Invoke-RestMethod -Method GET -Uri $Uri -Headers $Headers

    return $response
}

function Get-MerakiNetworkDeviceUplink() {
    [CmdletBinding()]
    Param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [String]$networkId,
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [String]$serial
    )

    $Uri = "{0}/networks/{1}/devices/{2}/uplink" -f $BaseURI, $networkId, $serial
    $Headers = Get-Headers

    $response = Invoke-RestMethod -Method GET -Uri $Uri -Headers $Headers

    return $response
}

<#
.Description
Retrieves all devices in an organization
#>
function Get-MerakiOrganizationDevices() {
    Param(
        [string]$OrgID
    )

    If (-not $OrgID) {
        $config = Read-Config
        $OrgID = $config.OrgID
    }

    $Uri = "{0}/organizations/{1}/devices" -f $BaseURI, $config.OrgID
    $Headers = Get-Headers

    $response = Invoke-RestMethod -Method GET -Uri $Uri -Headers $Headers

    return $response
}

<#
.Description
Retrieves all VLAN for a network.
#>
function Get-MerakiNetworkVLANS() {
    [cmdletbinding()]
    Param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [string]$id,
        [switch]$NoProgress
    )
        $Headers = Get-Headers       
        $responses = New-Object System.Collections.Generic.List[psobject]     
        $i = 1
        $count = $input.Count
        $input | ForEach-Object {
            $Uri = "{0}/networks/{1}/vlans" -f $BaseURI, $_.id
            If (-not $NoProgress) {
                Write-Progress -Activity "Getting Progress for: " -Status $_.Name -PercentComplete ($i/$count*100)
            }
            try {
                $response = Invoke-RestMethod -Method GET -Uri $Uri -Headers $Headers 
                if ($response.id) {
                    $responses.add($response)   
                }
            } catch {
                #$_.Exception
            }
            $i += 1
        }

        return $responses.toArray()
    
}

<#
.Description
Retrieve a specific VLAN
#>
function Get-MerakiNetworkVLAN() {
    [cmdletbinding()]    
    Param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [String]$networkId,
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [string]$id
    )
    
    $Uri = "{0}/networks/{1}/vlans{2}" -f $BaseURI, $networkId, $id
    $Headers = Get-Headers

    $response = Invoke-RestMethod -Method GET -Uri $Uri -Headers $Headers

    return $response

}

<#
.Description
Retrieve all switch settings in a network
#>
function Get-MerakiDeviceSwitchSettings() {
    [cmdletbinding()]
    Param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [string]$id
    )

    $Uri = "{0}/networks/{1}/switch/settings" -f $BaseURI, $id
    $Headers = Get-Headers

    $response = Invoke-RestMethod -Method GET -Uri $Uri -headers $Headers

    return $response
}

<#
.Description
Retrieve Switch Port settigs for a switch
#>
function Get-MerakiDeviceSwitchPorts() {
    [CmdletBinding()]
    Param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [string]$serial
    )

    $Headers = Get-Headers
    $responses = New-Object System.Collections.Generic.List[psobject]
    if ($input.Length -eq 0) {
        $Uri = "{0}/devices/{1}/switchPorts" -f $BaseURI, $serial
        $response = Invoke-RestMethod -Method GET -Uri $Uri -Headers $Headers
        return $response
    } 
    $input | ForEach-Object {
        if ($input.model -like "MS*") { 
            $Uri = "{0}/devices/{1}/switchPorts" -f $BaseURI, $input.serial
            $deviceName = $input.name
            $response = Invoke-RestMethod -Method GET -Uri $Uri -Headers $Headers
            $response | ForEach-Object {
            $_ | add-member  -MemberType NoteProperty -Name "Device" -Value $deviceName
            }        
            $responses.Add($response)        
        }
    }
    return $responses.ToArray()
}

function Get-MerakiApplianceVlanPorts() {
    [cmdletbinding()]
    Param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [string]$id
    )

    Begin {
        $Headers = Get-Headers
    }

    Process {
        $Uri = "{0}/networks/{1}/appliancePorts" -f $BaseURI, $id
        $response = Invoke-RestMethod -Method GET -Uri $Uri -Headers $Headers
        return $response
    }
}

function Get-MerakiSSIDs() {
    [CmdletBinding()]
    Param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [string]$id
    )

    $Uri = "{0}/networks/{1}/ssids" -f $BaseURI, $id
    $Headers = Get-Headers

    $response = Invoke-RestMethod -Method GET -Uri $Uri -Headers $Headers

    return $response
}

function Get-MerakiNetworkContentFilteringCategories() {
    [CmdletBinding()]
    Param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [string]$id
    )

    $Uri = "{0}/networks/{1}/contentFiltering/categories" -f $BaseURI, $id
    $Headers = Get-Headers

    $response = Invoke-RestMethod -Method GET -Uri $Uri -Headers $Headers

    return $response
}

<#
.Description
Retrieve content filtering Rules for a network
#>
function Get-MerakiNetworkContentFilteringRules() {
    [CmdletBinding()]
    Param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [string]$id
    )

    $Uri = "{0}/networks/{1}/contentFiltering" -f $BaseURI, $id
    $headers = Get-Headers

    $response = Invoke-RestMethod -Method GET -Uri $Uri -Headers $headers

    return $response    
}

<#
.Description
Update content filtering rules for a network
#>
function Update-MerakiNetworkContentFiltering() {
    [CmdletBinding()]
    Param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [string]$id,
        [Parameter(
            ParameterSetName = "values",
            Mandatory = $true
        )]
        [string[]]$allowedURLPatterns,
        [Parameter(
            Mandatory=$true,
            ParameterSetName = "values"            
        )]
        [string[]]$blockedURLPatterns,
        [Parameter(
            ParameterSetName = "values",
            Mandatory = $true
        )]
        [psObject]$blockedUrlCategories,
        [Parameter(
            Mandatory = $true, ParameterSetName = 'values'
        )]
        [string]$urlCategoryListSize,
        [Parameter(
            Mandatory = $true, ParameterSetName = "object"
        )]
        [psObject]$ContentFilteringRules
    )
    $Uri = "{0}/networks/{1}/contentFiltering" -f $BaseURI, $id
    $Headers = Get-Headers

    if ($ContentFilteringRules) {
        $allowedURLPatterns = $ContentFilteringRules.allowedUrlPatterns
        $blockedURLPatterns = $ContentFilteringRules.blockedUrlPatterns
        $blockedUrlCategories = $ContentFilteringRules.blockedUrlCategories
        $urlCategoryListSize = $ContentFilteringRules.urlCategoryListSize
    }


    $psBody = [PSCustomObject]@{
        allowedUrlPatterns = $allowedURLPatterns
        blockedUrlPatterns = $blockedURLPatterns
        blockedUrlCategories = $blockedUrlCategories | ForEach-Object {$_.id}
        urlCategoryListSize = $urlCategoryListSize
    }
    
    $body = $psBody | ConvertTo-Json

    $response = Invoke-RestMethod -Method PUT -Uri $Uri -Body $body -Headers $Headers

    return $response
}

<#
.Description
Get Organization Admins
#>
function Get-MerakiOrganizationAdmins() {
    Param(
        [string]$OrgID
    )

    If (-not $orgID) {
        $config = Read-Config
        $OrgID = $config.OrgID
    }

    $Uri = "{0}/organizations/{1}/admins" -f $BaseURI, $OrgID
    $Headers = Get-Headers

    $response = Invoke-RestMethod -Method GET -Uri $uri -Headers $Headers

    return $response
}

<#
.Description
Get Organization configuration Changes
#>
function Get-MerakiOrganizationConfigurationChanges() {
    [CmdletBinding(DefaultParameterSetName = 'TimeSpan')]
    Param(                 
        [string]$OrgID,
        [Parameter(ParameterSetName = 'StartEnd')]
        [ValidateScript({$_ -as [DateTime]})]
        [datetime]$StartTime,
        [Parameter(ParameterSetName = 'StartEnd')]
        [ValidateScript({$_ -as [DateTime]})]
        [DateTime]$EndTime,
        [Parameter(ParameterSetName = 'TimeSpan')]
        [ValidateScript({$_ -as [long]})]
        [long]$TimeSpan,
        [ValidateScript({$_ -as [int]})]
        [int]$PerPage,
        [string]$NetworkID,
        [string]$AdminID
    )
    
    If (-not $OrgID) {
        $config = Read-Config
        $OrgID = $config.OrgID
    }

    $Uri = "{0}/organizations/{1}/configurationChanges" -f $BaseURI, $OrgID
    $Headers = Get-Headers

    $psBody = @{}
    if ($StartTime) {
        $T0 = "{0:s}" -f $StartTime
        $psBody.Add("t0", $T0)
    }

    if ($EndTime) {
        $T1 = "{0:s}" -f $EndTime
        $psBody.add("t1", $T1)
    }

    if ($TimeSpan) {
        $seconds = [timespan]::FromDays($timespan).TotalSeconds
        $psBody.Add("timespan", $seconds)
    }

    if ($PerPage) {
        $psBody.Add("perPage", $PerPage)
    }

    if ($NetworkID) {
        $psBody.Add("networkId", $NetworkID)
    }

    if ($AdminID) {
        $psBody.Add("adminId", $AdminID)
    }

    $Body = $psBody | ConvertTo-Json

    $response = Invoke-RestMethod -Method GET -Uri $Uri -body $Body -Headers $Headers

    return $response
    
}

<#
.Description
Get Network Uplink Setting
#>
function Get-MerakiNetworkUplinkSettings() {
    [CmdletBinding()]
    Param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [string]$id
    )
    $Uri = "{0}/networks/{1}/uplinkSettings" -f $BaseURI, $id
    $Headers = Get-Headers

    $response = Invoke-RestMethod -Method Get -Uri $Uri -Headers $headers

    return $response
}

<#
.Description
Get Organization Configuration Templates
#>
function Get-MerakiOrganizationConfigTemplates() {
    Param(
        [String]$OrgID
    )

    if (-not $OrgID) {
        $config = Read-Config
        $OrgID = $config.OrgID
    }

    $Uri = "{0}/organizations/{1}/configTemplates" -f $BaseURI, $OrgID
    $headers = Get-Headers

    $response = Invoke-RestMethod -Method GET -Uri $Uri -Headers $headers

    return $response
}

<#
.Description
Get Network Site-to-Site VPN Settings
#>
function Get-MerakiNetworkSiteToSiteVPN() {
    [CmdletBinding()]
    Param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [string]$id
    )

    $Uri = "{0}/networks/{1}/siteToSiteVpn" -f $BaseURI, $id
    $Headers = Get-Headers

    $response = Invoke-RestMethod -Method GET -Uri $Uri -Headers $Headers

    return $response
}

<#
.Description
Get network events
#>
function Get-MerakiNetworkEvents() {
    [cmdletbinding()]
    Param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]    
        [string]$id,
        [Parameter(
            Mandatory = $true
        )]
        [productTypes]$ProductType,
        [string[]]$IncludedEventTypes,
        [string[]]$excludedEventTypes,
        [string]$deviceMac,
        [string]$deviceName,
        [string]$clientName,
        [string]$clientIP,
        [string]$clientMac,
        [string]$smDeviceName,
        [string]$smDeviceMac,
        [int]$perPage,
        [datetime]$startingAfter,
        [datetime]$endingAfter
    )

    Begin {
        $Headers = Get-Headers
    }

    Process {
        $Uri = "{0}/networks/{1}/events" -f $BaseURI, $id

        $oBody = @{}
        If ($ProductType) {
            $oBody.Add("productType", $ProductType.ToString())
        }
        if ($IncludedEventTypes) {
            $oBody.Add("includedEventTypes", $IncludedEventTypes)
        }
        if ($excludedEventTypes) {
            $oBody.Add("excludedEventTypes", $excludedEventTypes)
        }
        if ($deviceMac) {
            $oBody.Add("deviceMac", $deviceMac)
        }
        if ($deviceName) {
            $oBody.Add("deviceMac", $deviceMac)
        }
        if ($clientName) {
            $oBody.Add("clientName", $clientName)
        }
        if ($clientIP) {
            $obody.add("clientIP", $clientIP)
        }
        if ($ClientMac) {
            $oBody.Add("clientMac", $ClientMac)
        }
        if ($smDeviceName) {
            $oBody.Add("smDeviceName", $smDeviceName)
        }
        if ($smDeviceMac) {
            $oBody.Add("smDeviceMac", $smDeviceMac)
        }
        if ($perPage) {
            $oBody.Add("perPage", $perPage)
        }
        if ($startingAfter) {
            $oBody.add("startingAfter", "{0:s}" -f $startingAfter)
        }
        if ($endingAfter) {
            $obody.add("endingAfter", "{0:s}" -f $endingAfter)
        }

        $body = $oBody | ConvertTo-Json

        $response = Invoke-RestMethod -Method GET -Uri $Uri -Body $body -Headers $Headers

        return $response.events
    }
}

<#
.Description
Get network event types
#>
function Get-MerakiNetworkEventTypes() {
    [CmdletBinding()]
    Param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [string]$id
    )

    $Uri = "{0}/networks/{1}/events/eventTypes" -f $BaseURI, $id
    $Headers = Get-Headers

    $response = Invoke-RestMethod -Method GET -Uri $Uri -Headers $Headers

    return $response
}

<#
.Description
Blink Network Device LEDs
#>
function Start-MerakiNetworkDeviceBlink() {
    [CmdletBinding()]
    Param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [string]$networkId,
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [string]$serial,
        [int]$Duration,
        [int]$Duty,
        [int]$Period
    )

    $Uri = "{0}/networks/{1}/devices/{2}/blinkLeds" -f $BaseURI, $networkId, $serial
    $Headers = Get-Headers

    $psBody = @{}
    if ($Duration) {
        $psBody.Add("duration", $Duration)
    }
    if ($Duty) {
        $psBody.Add("duty", $Duty)
    }
    if ($Period) {
        $psBody.aDD("period", $Period)
    }
    $body = $psBody | ConvertTo-Json

    $response = Invoke-RestMethod -Method GET -Uri $Uri -Body $body -Headers $Headers

    return $response
}

<#
.Description
Get organization thrid party VPN peers
#>
function Get-MerakiOrganizationThirdPartyVPNPeers() {
    [CmdletBinding()]
    Param(
        [STRING]$OrgID
    )

    if (-not $OrgID) {
        $config = Read-Config
        $OrgId = $config.OrgID
    }

    $Uri = "{0}/organizations/{1}/thirdPartyVPNPeers" -f $BaseURI, $OrgID
    $Headers = Get-Headers

    $response = Invoke-RestMethod -Method GET -Uri $Uri -Headers $Headers

    return $response
}

<#
.Description
Get organization inventory
#>
function Get-MerakiOrganizationInventory() {
    Param(
        [string]$OrgID
    )

    if (-not $OrgID) {
        $config = Read-Config
        $OrgID = $config.OrgID
    }

    $Uri = "{0}/organizations/{1}/inventory" -f $BaseURI, $OrgID
    $Headers = Get-Headers

    $response = Invoke-RestMethod -Method GET -Uri $Uri -Headers $Headers

    return $response
}

<#
.Description
Get network security events
#>
function Get-MerakiNetworkSecurityEvents() {
    [CmdletBinding()]
    Param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [string]$id
    )

    $Uri = "{0}/networks/{1}/securityEvents" -f $BaseURI, $id
    $Headers = Get-Headers

    $response = Invoke-RestMethod -Method GET -Uri $Uri -Headers $headers

    return $response
}

<#
.Description
Get organization security events
#>
function Get-MerakiOrganizationSecurityEvents() {
    Param(
        [string]$OrgID
    )

    if (-not $OrgID) {
        $config = Read-Config
        $OrgID = $config.OrgID
    }

    $Uri = "{0}/organizations/{1}/securityEvents" -f $BaseURI, $OrgID
    $Headers = Get-Headers

    $response = Invoke-RestMethod -Method GET -Uri $Uri -Headers $Headers

    return $response
}

<# Export-ModuleMember    -Function    Get-MerakiNetworks, Get-MerakiNetworks, `
                                    Get-MerakiNetworkDevices, Get-MerakiNetworkDevice, `
                                    Get-MerakiOrganizationDevices, Get-MerakiNetworkVLAN, Get-MerakiNetworkVLANS, `
                                    Get-MerakiDeviceSwitchSettings, Get-MerakiDeviceSwitchPorts, Get-MerakiOrganizations, `
                                    Get-MerakiNetworkContentFilteringRules, Update-MerakiNetworkContentFiltering, Set-MerakiAP, Get-MerakiNetwork `
                        -Variable  CategoryListSize #>
                        

