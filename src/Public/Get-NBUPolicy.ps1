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
    [CmdletBinding(DefaultParameterSetName = "NoParam")]
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
        if (-not (Test-Path "$NBUbin\admincmd\"))
        {
            Throw "This command needs to run on a master or media server"
        }

        $IgnoreList = ('KEY', 'BCMD', 'RCMD', 'FOE', 'SHAREGROUP', 'SCHEDFOE', 'NAMES')
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
        $ScheduleTypes = @{
            0 = 'Full'
            1 = 'Differential incremental'
            2 = 'Cumulative incremental'
            3 = 'User Backup'
            4 = 'User Archive'
        }

    }
    PROCESS
    {
        TRY
        {
            if ($PSCmdlet.ParameterSetName -eq 'AllPolicies')
            {
                # List the Policies
                Write-Verbose -Message "[PROCESS] PARAM: AllPolicies"
                $bppllist = & "$NBUbin\admincmd\bppllist.exe" -allpolicies
            }
            elseif ($PSCmdlet.ParameterSetName -eq 'byPolicy')
            {
                Write-Verbose -Message "[PROCESS] PARAM: Policy $Policy"
                $bppllist = & "$NBUbin\admincmd\bppllist.exe" $policy -l
                #$bpplinfo = & "$NBUbin\admincmd\bpplinfo.exe" $Policy -l
            }

            if ($PSCmdlet.ParameterSetName -eq 'NoParam')
            {
                # List the Policies
                Write-Verbose -Message "[PROCESS] NO PARAM"
                $bppllist = & "$NBUbin\admincmd\bppllist.exe"
                FOREACH ($policy in $bppllist)
                {
                    New-Object -TypeName PSObject -Property @{
                        PolicyName = $policy
                    }
                }
            }
            else
            {
                # Add an end of file tag
                $bppllist = $bppllist + "EOF"

                Write-Verbose "Parsing Policy"
                $PolicyHash = @{}
                # https://www.veritas.com/content/support/en_US/doc/123533878-127136857-0/v123542189-127136857
                # https://social.technet.microsoft.com/Forums/ie/en-US/c581523b-d54d-46da-bca4-f9e750dee8a8/netbackup-bppllist-output-array?forum=winserverpowershell
                foreach ($Line in $bppllist)
                {
                    Write-Verbose "$Line"
                    $header = ($Line -split " ")[0]
                    switch ($Header)
                    {
                        {$_ -in $IgnoreList}
                        {
                            # We're ignoring these! Might want to move the array
                            break
                        }
                        'CLASS'
                        {
                            Write-Verbose "Parsing Class Line"

                            # Now Capture the stuff on this line
                            $Class = $Line -split ' '
                            $PolicyName = $Class[1]
                            Write-Verbose "Policy: $PolicyName"
                            $PolicyHash["PolicyName"] = $PolicyName
                            $InRecord = $True
                        }
                        'INFO'
                        {
                            $info = $Line -split ' '
                            $PolicyHash["PolicyType"] = $PolicyTypes[[int]$info[1]]
                            $PolicyHash["FollowNFS"] = $info[2]
                            $PolicyHash["ClientSideCompress"] = $info[3]
                            $PolicyHash["Priority"] = $info[4]
                            # Skipping Proxy Client
                            $PolicyHash["ClientSideEncryption"] = [bool]$info[6]
                            $PolicyHash["DisasterRecovery"] = [bool]$info[7]
                            $PolicyHash["MaxJobsPerClient"] = $info[8]
                            $PolicyHash["CrossMountPoints"] = [bool]$info[9]
                            # Skipping Field 10
                            $PolicyHash["Active"] = [bool]$info[11]
                            $PolicyHash["CollectTrueImageRestore"] = $info[12] # Triple State 0,1,2
                            $PolicyHash["BlockLevelIncremental"] = [bool]$info[13]
                            $PolicyHash["EffectiveDate"] = $info[19]
                            $PolicyHash["EnableCheckpoints"] = [bool]$info[22]
                            $PolicyHash["CheckpointInterval"] = $info[23]

                            $PolicyHash["EnableAccelerator"] = [bool]$info[36]
                        }
                        'RES'
                        {
                            $Residence = $Line -split ' '
                            $PolicyHash["Residence"] = @($Residence[1..($Residence.count - 1)])
                        }
                        'POOL'
                        {
                            $Pool = $Line -split ' '
                            $PolicyHash["Pool"] = @($Pool[1..($Pool.count - 1)])
                        }
                        'DATACLASSIFICATION'
                        {
                            $DataClass = $Line -split ' '
                            $PolicyHash["DataClassification"] = $DataClass[1]
                        }
                        'CLIENT'
                        {
                            if ((test-path variable:global:ClientsCollection) -eq $false)
                            {
                                $Global:ClientsCollection = @()
                            }
                            # accumulate an array of Client objects
                            $ThisClient = $Line -split ' '
                            $Global:ClientsCollection = $Global:ClientsCollection + [pscustomobject]@{
                                "Name" = $ThisClient[1]
                                "HW"   = $ThisClient[2]
                                "OS"   = $ThisClient[3]
                            }
                        }
                        'INCLUDE'
                        {
                            # INCLUDE always follows the CLIENT entries, so we know we are done with Clients
                            if ((test-path Variable:Global:ClientsCollection) -eq $true)
                            {
                                $Client = $Global:ClientsCollection
                                $PolicyHash["Client"] = $Client

                                Remove-Variable -Scope 'Global' -Name 'ClientsCollection'
                            }
                            # Accumulate an array of Include objects (strings)
                            if ((Test-Path Variable:Global:IncludesCollection) -eq $false)
                            {
                                $Global:IncludesCollection = @()
                            }
                            # accumulate an array of inclusion directives
                            $ThisInclude = $line -replace ('INCLUDE ', '')
                            $Global:IncludesCollection = $Global:IncludesCollection + $ThisInclude
                        }
                        'SCHED'
                        {
                            # SCHED always follows the INCLUDE entries, so we know we are done with Includes
                            if ((test-path Variable:Global:IncludesCollection) -eq $true)
                            {
                                $Include = $Global:IncludesCollection
                                $PolicyHash["Include"] = $Include

                                Remove-Variable -Scope 'Global' -Name 'IncludesCollection'
                            }
                            if ((Test-Path Variable:Global:ScheduleCollection) -eq $false)
                            {
                                $Global:ScheduleCollection = @()
                            }
                            # Now it gets really tricky as we are collecting info about this schedule until we get to the next SCHED line
                            $sched = $line -split ' '
                            $SchedName = $sched[1]
                            $SchedType = $Sched[2]
                            $SchedCalType = $Sched[11]

                        }
                        'SCHEDCALEDATES'
                        {

                        }
                        'SCHEDCALENDAR' {
                            # Indicates that it's a Calendar Schedule
                        }
                        'SCHEDCALDAYOWEEK' {
                            $SchedCalDayOfWeek = $line -split ' '
                            $SchedCalDayOfWeek = $SchedCalDayOfWeek[1 .. ($SchedCalDayOfWeek.count - 1)] -split ';'
                            # Make a collection of pscustomobject here eventually

                        }
                        'SCHEDWIN' {
                            # 7 pairs of numbers, each pair is
                            # seconds past midnight to start, and length in seconds
                            $schedWin = $line -split ' '
                            $ScheduleWindow = [pscustomobject]@{
                                SunStart = $schedWin[1]
                                SunDuration = $schedWin[2]
                                MonStart = $schedWin[3]
                                MonDuration = $schedWin[4]
                                TueStart = $schedWin[5]
                                TueDuration = $schedWin[6]
                                WedStart = $schedWin[7]
                                WedDuration = $schedWin[8]
                                ThuStart = $schedWin[9]
                                ThuDuration = $schedWin[10]
                                FriStart = $schedWin[11]
                                FriDuration = $schedWin[12]
                                SatStart = $schedWin[13]
                                SatDuration = $schedWin[14]
                            }
                        }
                        'SCHEDRES' {
                            $SchedRes = $Line -split ' '
                            $ScheduleResidence = @($SchedRes[1..($SchedRes.count - 1)])
                        }
                        'SCHEDPOOL' {}
                        'SCHEDRL' {}
                        'SCHEDSG'
                        {
                            # Deal with the Share Group (we don't use that)
                            $ThisSchedule = [pscustomobject]@{
                                Name = $SchedName
                                Type = $ScheduleTypes[[int]$SchedType]
                                Window = $ScheduleWindow
                                Residence = $ScheduleResidence
                                Calendar = $SchedCalType
                            }

                            # This is the end of a schedule object.
                            $ScheduleCollection = $ScheduleCollection + $ThisSchedule
                            $SchedDone = $True
                        }
                        'EOF' {
                            if ($InRecord -eq $True)
                            {
                                # You're about to start a new record, so output the one you've already compiled
                                $PolicyHash["Schedule"] = $ScheduleCollection
                                [PSCustomObject]$PolicyHash
                                $PolicyHash = @{}
                                $SchedDone = $false
                                Remove-Variable ScheduleCollection
                                $InRecord = $false
                            }
                        }
                        Default
                        {
                            # Need to save Default for real errors
                        }
                    }


<#
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

                    } #>
                }
            }

        } #TRY
        CATCH
        {
            Write-Warning -Message "[PROCESS] Something wrong happened"
            #Write-Warning -Message $Error[0].Exception.Message
            $_
        }
    } #PROCESS
    END { Write-Verbose -Message "[END] Function Get-NetBackupPolicy" }
} #Get-NetBackupPolicy
