<#
.SYNOPSIS
    Get one or all of the NetBackup Storage Units in the domain
.DESCRIPTION
    Long description
.EXAMPLE
    PS C:\> Get-NBUStorageUnit
.EXAMPLE
    PS C:\> Get-NBUStorageUnit -Label SomeStorageUnit
.INPUTS
    Inputs to this cmdlet (if any)
.OUTPUTS
    Output from this cmdlet (if any)
.NOTES
    General notes
.COMPONENT
    The component this cmdlet belongs to
.ROLE
    The role this cmdlet belongs to
.FUNCTIONALITY
    The functionality that best describes this cmdlet
#>
function Get-NBUStorageUnit
{
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    Param (
        # Param1 help description
        [Parameter(Mandatory = $false,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [string]
        $Label
    )

    begin
    {
        $NBUbin = "C:\Program Files\Veritas\NetBackup\bin"
    }

    process
    {
        try
        {
            if ($PSBoundParameters['Label'])
            {
                $bpstulist = & "$NBUbin\admincmd\bpstulist.exe" -label $Label -l
            }
            else
            {
                $bpstulist = & "$NBUbin\admincmd\bpstulist.exe" -l
            }

            $bpstulist = bpstulist.exe -l

            foreach ($StorageUnit in $bpstulist)
            {
                $items = $StorageUnit -split "\s"
                [pscustomobject]@{
                    Label           = $items[0]
                    Type            = $items[1]
                    Host            = $items[2]
                    Density         = $items[3]
                    ConcurrentJobs  = $items[4]
                    InitialMPX      = $items[5]
                    Path            = $items[8]
                    OnDemandOnly    = $items[7]
                    MaxMPX          = ''
                    MaxFragmentSize = $items[11]
                    NDMPAttachHost  = $items[12]
                    Throttle        = ''
                    SubType         = ''
                    DiskFlags       = $items[13]
                    HighWaterMark   = $items[16]
                    LowWaterMark    = $items[17]
                    OKOnRoot        = $items[18]
                    DiskPool        = $items[19]
                    HostList        = $items[20]
                    Something       = $items[21]
                }
            }
        }
        Catch
        {
            Write-Warning -Message "[PROCESS] Something wrong happened"
			Write-Warning -Message $Error[0].Exception.Message
        }
    }

    end {
    }
    }

