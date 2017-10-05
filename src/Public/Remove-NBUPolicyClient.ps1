Function Remove-NBUPolicyClient
{
    [CmdletBinding(SupportsShouldProcess = $true,
        ConfirmImpact = 'High')]

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
        if ($pscmdlet.ShouldProcess("$ComputerName", "Remove from Policy $PolicyName"))
        {
            & "$admincmd\bpplclients.exe" $PolicyName -delete $ComputerName
        }
    }
}
