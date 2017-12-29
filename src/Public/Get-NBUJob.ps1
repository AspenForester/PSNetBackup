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
function Get-NBUJob
{
    [CmdletBinding(DefaultParameterSetName = 'Default')]

    Param (
        # ID of the job to retrieve
        [Parameter(Mandatory = $false,
            ParameterSetName = 'JobID')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [int]
        $JobID
    )

    begin
    {
        $bin = 'C:\Program Files\Veritas\NetBackup\bin'
        $admincmd = "$bin\admincmd"

        If (-not (test-path $admincmd))
        {
            Throw "You don't seem to have NetBackup installed on this computer"
        }

        $JobTypes = @{
            0  = 'Backup'
            1  = 'Archive'
            2  = 'Restore'
            3  = 'Verify'
            4  = 'Duplicate'
            5  = 'Import'
            6  = 'Catalog Backup'
            7  = 'Vault'
            8  = 'Label'
            9  = 'Erase'
            10 = 'Tape Request'
            11 = 'Cleaning'
            12 = 'Tape Formatting'
            13 = 'Physical Inventory'
            14 = 'Qualification'
            15 = 'Catalog Recovery'
            16 = 'Media Contents'
            17 = 'Image Cleanup'
            18 = 'Live Update'
            20 = 'AIR Duplication'
            21 = 'AIR Import'
            22 = 'Backup from Snapshot'
            23 = 'Replication Snap'
            24 = 'Import Snap'
            25 = 'Application State Capture'
            26 = 'Indexing'
            27 = 'Index Cleanup'
            28 = 'Snapshot'
            29 = 'Snap Index'
            30 = 'Activate Instant Recovery'
            31 = 'Deactivate Instant Recovery'
            32 = 'Reactivate Instant Recovery'
            33 = 'Stop Instant Recovery'
            34 = 'Instant Recovery'
        }
        $JobStates = @{
            0 = 'Queued'
            1 = 'Active'
            2 = 'Requeued'
            3 = 'Done'
            4 = 'Suspended'
            5 = 'Incomplete'
        }
    }
    process
    {
        if ($PSCmdlet.ParameterSetName -eq 'JobID')
        {
            $Jobs = & $admincmd\bpdbjobs.exe -most_columns -jobid $JobID
        }
        else
        {
            $Jobs = & $admincmd\bpdbjobs.exe -most_columns
        }

        foreach ($Job in $jobs)
        {
            $Job = $Job -split ','

            # If a job is in progress
            If ($job[10] -eq '0000000000')
            {
                $ended = ''
            }
            else
            {
                $ended = ConvertFrom-Unixdate -UnixDate $Job[10]
            }

            [PSCustomObject]@{
                JobID       = $Job[0]
                JobType     = $JobTypes[[int]$Job[1]]
                State       = $JobStates[[int]$Job[2]]
                Status      = $Job[3]
                Policy      = $Job[4]
                Schedule    = $Job[5]
                Client      = $Job[6]
                MediaServer = $Job[7]
                Start       = ConvertFrom-Unixdate -UnixDate $Job[8]
                Elapsed     = [int]$Job[9]
                Ended       = $Ended
                StorageUnit = $Job[11]
                Tries       = $Job[12]
                Kilobytes   = $Job[14]
                Files       = $Job[15]
                Percent     = $Job[17]
                Priority    = $Job[23]
            }
        }
    }

    end
    {
    }
}








