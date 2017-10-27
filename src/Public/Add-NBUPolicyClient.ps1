Function Add-NBUPolicyClient
{
    [CmdletBinding()]

    Param
    (
        # Name of the NetBackup policy that is being updated
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $false,
            Position = 0)]
        [String]
        $PolicyName,

        # Name of the computer being added to the policy
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 1)]
        [String]
        $ComputerName,

        # Hardware designator for the client being added to the policy
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 2)]
        [String]
        $Hardware,

        # OS Designator for the client being added to the policy
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
