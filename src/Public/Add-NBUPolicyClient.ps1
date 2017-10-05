Function Add-NBUPolicyClient
{
    [CmdletBinding()]

    Param
    (
        # Param1 help description
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $false,
            Position = 0)]
        [String]
        $PolicyName,

        # Param2 help description
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 1)]
        [String]
        $ComputerName,

        # Param2 help description
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 2)]
        [String]
        $Hardware,

        # Param2 help description
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 3)]
        [String]
        $OperatingSystem
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
        Write-Verbose "Adding $ComputerName to Policy $PolicyName"
        & "$admincmd\bpplclients.exe" $PolicyName -add $ComputerName $Hardware $OperatingSystem
        # Throws non-teminating error if the computer is already in the policy - might be nice to capture that.
    }
}
