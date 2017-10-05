Function Get-NBUPolicyClient
{
    #requires -version 4
    [CmdletBinding()]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $false,
            Position = 0)]
        [String]
        $PolicyName
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
        $raw = & "$admincmd\bpplclients.exe" $PolicyName | Select -Skip 2
        $raw | ConvertFrom-String -PropertyNames "Hardware", "OperatingSystem", "ComputerName"
    }
}