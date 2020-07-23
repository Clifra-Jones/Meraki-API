
#Private Variables
$BaseURI = "https://api.meraki.com/api/v0"

#Public
enum CategoryListSize {
    topSites;
    fullList
}

<#
.Description
Creates a file in the user profile folder un the .meraki folder named config.json.
This file contains the users Meraki API Key and the default Organization ID
#>
function Set-MerakiAP() {
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
    $Uri = "{0}/networks{1}/devices" -f $BaseURI, $id
    $Headers = Get-Headers

    $response = Invoke-RestMethod -Method GET -Uri $Uri -Headers $Headers

    return $response
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

<#
.Description
Retrieves all devices in an organization
#>
function Get-MerakiOrganizationDevices() {
    $config = Read-Config
    $Uri = "{0}/organizations/{1}/devices" -f $BaseURI, $config.OrgID
    $Headers = Get-Headers

    $response = Invoke-RestMethod -Method GET -Uri $Uri -Headers $Headers

    return $response
}

<#
.Description
Retrieves all VLAN for a network
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
                $responses.add($response)
            } catch {
                $_.Exception
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

    $Uri = "{0}/devices/{1}/switchPorts" -f $BaseURI, $serial
    $Headers = Get-Headers

    $response = Invoke-RestMethod -Method GET -Uri $Uri -Headers $Headers
    
    return $response
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
        [string[]]$allowedURLPatterns,
        [string[]]$blockedURLPatterns,
        [string[]]$blockedUrlCategories,
        [ValidateSet("topSites","fullList")]
        [CategoryListSize]$urlCategoryListSize
    )
    $Uri = "{0}/networks/{1}/contentFiltering" -f $BaseURI, $id
    $Headers = Get-Headers

    $psBody = [PSCustomObject]@{
        allowedUrlPatterns = $allowedURLPatterns
        blockedUrlPatterns = $blockedURLPatterns
        blockedUrlCategories = $blockedUrlCategories
        urlCategoryListSize = $urlCategoryListSize
    }
    
    $body = $psBody | ConvertTo-Json

    $response = Invoke-RestMethod -Method PUT -Uri $Uri -Body $body -Headers $Headers

    return $response
}

<# Export-ModuleMember    -Function    Get-MerakiNetworks, Get-MerakiNetworks, `
                                    Get-MerakiNetworkDevices, Get-MerakiNetworkDevice, `
                                    Get-MerakiOrganizationDevices, Get-MerakiNetworkVLAN, Get-MerakiNetworkVLANS, `
                                    Get-MerakiDeviceSwitchSettings, Get-MerakiDeviceSwitchPorts, Get-MerakiOrganizations, `
                                    Get-MerakiNetworkContentFilteringRules, Update-MerakiNetworkContentFiltering, Set-MerakiAP, Get-MerakiNetwork `
                        -Variable  CategoryListSize #>
                        

