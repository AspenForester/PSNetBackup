<#
.SYNOPSIS
    Sets properties of an existing Policy
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
function Set-NBUPolicy {
    [CmdletBinding(DefaultParameterSetName='Parameter Set 1',
                   SupportsShouldProcess=$true,
                   PositionalBinding=$false,
                   HelpUri = 'http://www.microsoft.com/',
                   ConfirmImpact='Medium')]
    [Alias()]
    [OutputType([String])]
    Param (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   Position=0,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   ValueFromRemainingArguments=$false)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [String]
        $Name,
        
        # Param2 help description
        [Parameter(Mandatory=$true)]
        [ValidateSet('MS-ExchangeServer','MS-Windows','Standard','VMWare')]
        [String]
        $PolicyType,
        
        # Get the Storage Unit label from Get-NBUStorageUnit
        [Parameter(ParameterSetName='Another Parameter Set')]
        [Alias('Residence')]
        [String]
        $StorageUnit
    )
    
    begin {
        $NBUbin = "C:\Program Files\Veritas\NetBackup\bin"
        if (-not (Test-Path "$NBUbin\admincmd\bppolicynew.exe"))
        {
            Throw "This command needs to run on a master or media server"
        }
    }
    
    process {
        if ($pscmdlet.ShouldProcess("Target", "Operation")) {
            
        }
    }
    
    end {
    }
}