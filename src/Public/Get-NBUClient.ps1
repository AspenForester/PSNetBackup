<#
.Synopsis
   Gets a full list of Netbackup Clients
.DESCRIPTION
   This cmdlet is currently written to be run on the NBU master server.
   It leverages <install path>\bin\admincmd\bpclient.exe to return a simple
   list of hostnames involved in one or more backup policies.
.EXAMPLE
    PS C:\> Get-BPClient
   172.16.100.46
   172.21.1.27
   172.21.113.31
   ...
   woodwind
   yonkers
   zanzibar
.EXAMPLE
    PS C:\> Get-BPClient -Computername abba
    abba
#>

function Get-BPClient
{
    param(
        # Parameter help description
        [Parameter(Mandatory = $false)]
        [string]
        $Computername
    )
    Begin
    {
        # Test to see if you are on an NBU master or media server.
        $NBUbin = "C:\Program Files\Veritas\NetBackup\bin"
    }
    Process
    {
        if ( -not ($psboundparmeters['Computername']))
        {
            (& "$NBUbin\admincmd\bpclient.exe" -All `
                    | Where {$_ -like "Client Name*"}).replace('Client Name: ', '')
        }
        else
        {
            try
            {
                $ErrorActionPreference = Stop
                (& "$NBUbin\admincmd\bpclient.exe" -client $Computername -l `
                        | Where {$_ -like "Client Name*"}).replace('Client Name: ', '')
            }
            Catch
            {
                Throw "$Computername is not known to this NetBackup Domain"
            }
        }
    }
}