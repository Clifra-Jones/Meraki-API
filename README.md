# Meraki-API
PowerShell Module to work with the MerakiAPI.

NOTE: This is a work in progress. This module only exposes a very small subset of the Meraki API REST functions. There may be bugs and you should
expect that there are bugs.

INSTALLATION

NOTE: This module will eventually be published to the Powershell Gallery once significant testing has been done.

Windows

Windows Powershell <= 6.1

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

ZIP FILE INSTALLATION

Same as above, just make a directory called Meraki-API in one of the above folders and unzip the file into thagt directory.

USAGE

API Access must be enabled on your Meraki Dashboard.

You will need to have a Meraki API key. You gan get your key by logging into your Meraki Dashboard, go to your profile and generate your API key.
Save this key in a safe place.

Once you have your API key you need to obtain the Organization ID for the Organizations you have access to. You can do this with the GetMerakiOrganizations function.

Open Powershell
>Import-Module Meraki-API

>Get-MerakiOrganizations -APIKey '{key string}'

Configure your user profile to use the API.

You must configure your profile to use the API module. To do this use the Set-MerakiAPI function.

>Set-MerakiAPI -APIKey '{key string}' -OrgID 'XXXXXX'

This will create the file .meraki/config.json in your user profile. 

See Wiki for documentation.
