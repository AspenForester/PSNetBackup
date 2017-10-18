Function Get-NetBackupPolicy
{
    <#
    .SYNOPSIS
       The function Get-NetBackupPolicy list all the policies from the Master Server
    .DESCRIPTION
       The function Get-NetBackupPolicy list all the policies from the Master Server
    .PARAMETER AllPolicies
        List all the Policies with all properties
    .EXAMPLE
        Get-NetBackupPolicy
        List all the policies name
    .EXAMPLE
        Get-NetBackupPolicy -AllPolicies
        List all the Policies with all properties
    .NOTES
        Francois-Xavier Cat
        LazyWinAdmin.com
        @Lazywinadm
        https://github.com/lazywinadmin/NetBackupPS
        HISTORY
        1.0 2014/06/01	 Initial Version
        1.1 2014/09/20	 Add Errors handling and Verbose
                         Add Blocks BEGIN,PROCESS,END
        1.1.1 2016/02/24 Reformatted PSObject Constructor - AspenForester
        1.2 2017/10/17   Implement byPolicy Parameter set
    #>
    [CmdletBinding(DefaultParameterSetName = "AllPolicies")]
    PARAM (
        [parameter(ParameterSetName = "AllPolicies")]
        [switch]
        $AllPolicies,

        [Parameter(ParameterSetName = "byPolicy",
                   Mandatory = $true)]
        [string]
        $Policy
        <#	[parameter(ParameterSetName = "hwos")]
            [switch]$HardwareAndOS,
            [parameter(ParameterSetName = "FullListing")]
            [switch]$FullListing,
            [parameter(ParameterSetName = "Raw")]
            [switch]$RawOutputMode,
            [parameter(ParameterSetName = "byclient", Mandatory)]
            [Switch]$ByClient,
            [parameter(ParameterSetName = "byclient", Mandatory)]
            [String]$ClientName
        #>
    )
    BEGIN
    {
        Write-Verbose -Message "[BEGIN] Function Get-NetBackupPolicy - bppllist.exe"
        $NBUbin = "C:\Program Files\Veritas\NetBackup\bin"
        if (-not (Test-Path "$NBUbin\admincmd\bppolicynew.exe"))
        {
            Throw "This command needs to run on a master or media server"
        }

        $IgnoreList = ('KEY','BCMD','RCMD','FOE','SHAREGROUP','SCHEDFOE','NAMES')
        $PolicyTypes = @{
            0  = 'Standard'
            1  = 'Proxy'
            4  = 'Oracle'
            6  = 'Informix-On-BAR'
            7  = 'Sybase'
            8  = 'MS-SharePoint'
            11 = 'DataTools-SQL-BackTrack'
            13 = 'MS-Windows'
            15 = 'MS-SQL-Server'
            16 = 'MS-Exchange-Server'
            17 = 'SAP'
            18 = 'DB2'
            19 = 'NDMP'
            20 = 'FlashBackup'
            21 = 'Splitmirror'
            25 = 'Notes'
            29 = 'FlashBackup-Windows'
            35 = 'NBU-Catalog'
            36 = 'Generic'
            38 = 'PureDisk export'
            39 = 'Enterprise_Vault'
            40 = 'VMware'
            41 = 'Hyper-V'
        }

    }
    PROCESS
    {
        TRY
        {
            switch ($PSboundparameters.Keys)
            {
                'AllPolicies'
                {
                    # List the Policies
                    Write-Verbose -Message "[PROCESS] PARAM: AllPolicies"
                    $bppllist = & "$NBUbin\admincmd\bppllist.exe" -allpolicies

                    # Add an end of file tag
                    $bppllist = $bppllist + "EOF"

                    $PolicyHash = @{}

                        foreach ($Line in $bppllist)
                        {
                            $header = ($Line -split " ")[0]
                            switch ($Header)
                            {
                                {$_ -in $IgnoreList}
                                {
                                     # We're ignoring these! Might want to move the array
                                     break
                                }
                                {$_ -in ('CLASS','EOF')}
                                {
                                    if ($InRecord -eq $True)
                                    {
                                        # You're about to start a new record, so output the one you've already compiled
                                        [PSCustomObject]$PolicyHash
                                        $PolicyHash = @{}
                                    }
                                        # Now Capture the stuff on this line
                                        $Class = $Line -split ' '
                                        $PolicyName = $Class[1]
                                        $PolicyHash["PolicyName"] = $PolicyName
                                        $InRecord = $True
                                }
                                'INFO'
                                {
                                    $info = $Line -split ' '
                                    $PolicyHash["PolicyType"] = $PolicyTypes[$info[1]]
                                    $PolicyHash["FollowNFS"] = $info[2]
                                    $PolicyHash["ClientSideCompress"] = $info[3]
                                    $PolicyHash["Priority"] = $info[4]
                                    # Skipping Proxy Client
                                    $PolicyHash["ClientSideEncryption"] = [bool]$info[6]
                                    $PolicyHash["DisaterRecovery"] = [bool]$info[7]
                                    $PolicyHash["MaxJobsPerClient"] = $info[8]
                                    $PolicyHash["CrossMountPoints"] = [bool]$info[9]
                                    # Skipping Field 10
                                    $PolicyHash["Active"] = [bool]$info[11]
                                    $PolicyHash["CollectTrueImageRestore"] = $info[12] # Triple State 0,1,2
                                    $PolicyHash["BlockLevelIncremental"] = [bool]$info[13]
                                }
                                'RES' {}
                                'POOL' {}
                                'DATACLASSIFICATION' {}
                                'CLIENT'
                                {
                                    # accumulate an array of Client objects
                                }
                                'INCLUDE'
                                {
                                    # accumulate an array of inclusion directives
                                }
                                'SCHED' {}
                                'SCHEDWIN' {}
                                'SCHEDRES' {}
                                'SCHEDPOOL' {}
                                'SCHEDRL' {}
                                'SCHEDSG'
                                {
                                    # This is the end of a schedule object.
                                }

                                Default
                                {
                                    # Need to save Default for reall errors
                                }
                            }
                        }


                        #http://www.symantec.com/business/support/index?page=content&id=HOWTO90333
                        [pscustomobject] @{
                            PolicyName = ($policy[0] -split " ")[0]
                            CLASS      = ($policy[0] -split " ")
                            NAMES      = ($policy[1] -split " ")
                            INFO       = ($policy[2])[5..($policy[2].count)] -split " "
                            KEY        = ($policy[3])[4..($policy[3].count)] -split " "
                            BCMD       = ($policy[4])[5..($policy[4].count)] -split " "
                            RCMD       = ($policy[5])[5..($policy[5].count)] -split " "
                            RES        = ($policy[6])
                            POOL       = ($policy[7])[5..($policy[7].count)] -split " "
                        }

                }
                'byPolicy'
                {
                    Write-Verbose -Message "[PROCESS] PARAM: AllPolicies"
                    $bpplinfo = & "$NBUbin\admincmd\bpplinfo.exe" $Policy -l

                }
                Default
                {
                    # List the Policies
                    Write-Verbose -Message "[PROCESS] NO PARAM"
                    $bppllist = bppllist
                    FOREACH ($policy in $bppllist)
                    {
                        New-Object -TypeName PSObject -Property @{
                            PolicyName = $policy
                        }
                    }
                }
            }

        } #TRY
        CATCH
        {
            Write-Warning -Message "[PROCESS] Something wrong happened"
            Write-Warning -Message $Error[0].Exception.Message
        }
    } #PROCESS
    END { Write-Verbose -Message "[END] Function Get-NetBackupPolicy" }
} #Get-NetBackupPolicy
