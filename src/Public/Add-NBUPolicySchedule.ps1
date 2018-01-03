<#
.SYNOPSIS
    Short description
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
function Add-NBUPolicySchedule {
    [CmdletBinding(DefaultParameterSetName='Parameter Set 1',
                   SupportsShouldProcess=$true)]
    [Alias()]
    [OutputType([String])]
    Param (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   Position=0,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   ValueFromRemainingArguments=$false)]
        $PolicyName,

        # Param2 help description
        [Parameter(ParameterSetName='Parameter Set 1')]
        [String]
        $ScheduleName,

        # Param3 help description
        [Parameter(Mandatory = $true)]
        [ValidateSet('Full','Incremental','Cumulative','TransactionLog','UserBackup','UserArchive')]
        [String]
        $Type,

        # Calendar Type
        [Parameter(Mandatory=$false)]
        [ValidateRange(0,2)]
        [int]
        $CalendarType = 0,

        # Residence for the scheduled backups
        [Parameter(Mandatory=$false)]
        [String]
        $Residence = '*Null*',

        # Window - represented as pairs of numbers: a start time and a duration.
        [Parameter(Mandatory = $false)]
        [psobject[]]
        $Window,

        # Passthru switch
        [Parameter(Mandatory = $false)]
        [switch]
        $Passthru
    )

    begin {
        $bin = 'C:\Program Files\Veritas\NetBackup\bin'
        $admincmd = "$bin\admincmd"

        If (-not (test-path $admincmd))
        {
            Throw "You don't seem to have NetBackup installed on this computer"
        }

    }

    process {


        if ($pscmdlet.ShouldProcess("Target", "Operation")) {
            Try
            {
                $ErrorActionPreference = 'Stop'
                & $admincmd\bpplsched.exe $PolicyName -add $ScheduleName
                $ErrorActionPreference = 'Continue'
            }
            catch
            {
                Write-Error "Unable to add $path to $PolicyName"
            }
        }
    }

    end {
        if ($PSBoundParameters['Passthru'])
        {
            [pscustomobject]@{
                PolicyName = $PolicyName
            }
        }
    }
}