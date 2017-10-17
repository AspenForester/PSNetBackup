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
                    $bppllist = (& "$NBUbin\admincmd\bppllist.exe" -allpolicies) -as [String]

                    # Split the Policies
                    $bppllist = $bppllist -split "CLASS\s"

                    FOREACH ($policy in $bppllist)
                    {
                        ####  !!!!  This doesn't really work.  It's not line by line
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
                }
                'byPolicy'
                {
                    Write-Verbose -Message "[PROCESS] PARAM: AllPolicies"
                    $bpplinfo = & "$NBUbin\admincmd\bpplinfo.exe" $Policy -

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
