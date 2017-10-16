# bppolicynew - creates the framework
# - just needs a policy name
# - will fail if a policy with the same name already exists.

# Don't try and mush this into one command!

# bpplinfo - updates the attributes
# - has about a thousand parameters!!!  And the dumbass didn't know to show which are mutually exclusive.
# - Going to need Parameter Sets!!!

# bpplclients - adds the clients

# bpplinclude - adds the backup selection

# bpplsched - adds the schedules

# Whew!!!

<#
  .SYNOPSIS
    Creates a new NetBackup Policy
  .DESCRIPTION
    Creates the shell of a new NetBackup Policy.  This needs to be followed up by Set-NBUPolicy
  .EXAMPLE
    PS C:\> New-NBUPolicy -Name "My_New_Policy"
  .EXAMPLE
    Another example of how to use this cmdlet
  .INPUTS
    Inputs to this cmdlet (if any)
  .OUTPUTS
    PSCustomObject: Name property equal to the name of the policy.
  .NOTES
    General notes
  .COMPONENT
    The component this cmdlet belongs to
  .ROLE
    The role this cmdlet belongs to
  .FUNCTIONALITY
    The functionality that best describes this cmdlet
#>
function New-NBUPolicy
{
    [CmdletBinding(SupportsShouldProcess = $true)]

    Param (
        # Param1 help description
        [Parameter(Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            ValueFromRemainingArguments = $false)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Name
    )
    
    begin
    {
        $NBUbin = "C:\Program Files\Veritas\NetBackup\bin"
        if (-not (Test-Path "$NBUbin\admincmd\bppolicynew.exe"))
        {
            Throw "This command needs to run on a master or media server"
        }
    }
    process
    {
        if ($pscmdlet.ShouldProcess("Target", "Operation"))
        {
            try
            {
                $ErrorActionPreference = 'Stop'
                & "$NBUbin\admincmd\bppolicynew.exe" $Name
                $ErrorActionPreference = 'Continue'
                [pscustomobject]@{
                    Name = $Name
                }
            }
            catch
            {
                Write-Warning "Unable to create new Policy"
                Write-Warning $error[0]
            } 
        }
    }
    
    end
    {
    }
}