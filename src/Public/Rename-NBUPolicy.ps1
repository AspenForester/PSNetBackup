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
    Renames a NetBackup Policy
  .DESCRIPTION
    Renames an existing netBackup Policy, changing the name to value provided in the NewName parameter
  .EXAMPLE
    PS C:\> Copy-NBUPolicy -Name "My_Policy" -NewName "Not_a_different_Policy"
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
function Rename-NBUPolicy
{
    [CmdletBinding(SupportsShouldProcess = $true)]

    Param (
        # Name of policy being copied
        [Parameter(Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            ValueFromRemainingArguments = $false)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Name,

        # Name of new policy being created
        [Parameter(Mandatory=$true,
            Position = 1,
            ValueFromPipelineByPropertyName = $true)]
        [String]
        $NewName
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
        if ($pscmdlet.ShouldProcess("to $NewName", "Renaming $Name "))
        {
            try
            {
                $ErrorActionPreference = 'Stop'
                & "$NBUbin\admincmd\bppolicynew.exe" $Name -renameto $NewName
                $ErrorActionPreference = 'Continue'
                [pscustomobject]@{
                    Name = $NewName
                }
            }
            catch
            {
                Write-Warning "Unable to Rename Policy"
                Write-Warning $error[0]
            }
        }
    }

    end
    {
    }
}