<#
.SYNOPSIS
    Adds items to the list of files/paths backed up by the policy
.DESCRIPTION
    Long description
.EXAMPLE
    Example of how to use this cmdlet
.EXAMPLE
    Another example of how to use this cmdlet
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
function Add-NBUPolicyInclude
{
    [CmdletBinding(DefaultParameterSetName = 'Parameter Set 1',
        SupportsShouldProcess = $true)]

    Param (
        # Param1 help description
        [Parameter(Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            ValueFromRemainingArguments = $false)]
        [ValidateNotNullOrEmpty()]
        $PolicyName,

        # Param2 help description
        [Parameter(ParameterSetName = 'Path',
            Mandatory = $true)]
        [String]
        $Path,

        # Param3 help description
        [Parameter(ParameterSetName = 'Directive',
            Mandatory = $true)]
        [String]
        $Directive
    )

    begin
    {
        $bin = 'C:\Program Files\Veritas\NetBackup\bin'
        $admincmd = "$bin\admincmd"

        If (-not (test-path $admincmd))
        {
            Throw "You don't seem to have NetBackup installed on this computer"
        }
    }

    process
    {
        if ($pscmdlet.ParameterSetName -eq 'Path')
        {
            if ($pscmdlet.ShouldProcess("to $PolicyName", "Add $path"))
            {
                Try
                {
                    $ErrorActionPreference = 'Stop'
                    & $admincmd\bpplinclude.exe $PolicyName -add $Path
                    $ErrorActionPreference = 'Continue'
                }
                catch
                {
                    Write-Error "Unable to add $path to $PolicyName"
                }
            }
        }
        else {
            Write-Warning "We haven't implemented Directives yet"
        }
    }

    end
    {
    }
}