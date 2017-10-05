<#
.SYNOPSIS
    Short description
.DESCRIPTION
    Long description
.EXAMPLE
    PS C:\> Get-NBUPolicyClient -PolicyName "SomePolicy"
    outputs a collection of objects representing the clients in the specified policy

    Hardware    OperatingSystem ComputerName
    --------    --------------- ------------
    Windows-x86 Windows2003     abba
.INPUTS
    String
.OUTPUTS
    PSCustomObject
.NOTES
    General notes
#>
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