Function Get-NBUClientConfig
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