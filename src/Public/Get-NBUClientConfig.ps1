
<#
.SYNOPSIS
    Gets the Client configuration info for a given NetBackup client
.DESCRIPTION
    Gets the client configuration, namely the "VERSIONINFO" of the specified computer, assuming that it is known to Net Backup
.EXAMPLE
    PS C:\> Get-NBUClientConfig -ComputerName abba
    Returns the Version info for the
    ComputerName Hardware OperatingSystem
    ------------ -------- ---------------
    abba         win_x86  Windows2003
.INPUTS
    String
.OUTPUTS
    Output (if any)
.NOTES
    General notes
#>Function Get-NBUClientConfig
{
    [CmdletBinding()]

    Param
    (
        # Param1 help description
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0)]
        [String[]]
        $ComputerName
    )
    Begin
    {
        $bin = 'C:\Program Files\Veritas\NetBackup\bin'
        $admincmd = "$bin\admincmd"

        If (-not (test-path $admincmd))
        {
            Throw "You don't seem to have NetBackup installed on this computer"
        }
    }
    Process
    {
        Foreach ($Computer in $Computername)
        {
            Write-Verbose "Getting Version info for $Computer"
            $VerInfo = & "$bin\nbgetconfig.exe" -M $Computer VERSIONINFO | Out-String

            #$Results = $VerInfo | Select-String -Pattern '\"(\w+)\"' -AllMatches | select -ExpandProperty matches | select -ExpandProperty Value | foreach {$_.replace('"', '')}
            $Results = [regex]::Matches($VerInfo,'(\w+\.?\d+)').value

            [pscustomobject]@{
                ComputerName    = $Computer
                Hardware        = $Results[1]
                OperatingSystem = $Results[0]
            }
        }
    }
}