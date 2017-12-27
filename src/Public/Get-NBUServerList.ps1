<#
.SYNOPSIS
    Gets the list of NBU servers on the specified "Host" aka "Client" computer.
.DESCRIPTION
    Retrieves the list of NBU servers, starting with the Master Server from the target computer.
.EXAMPLE
    PS C:>Get-NBUServerList -Computername MyServer

    Sets the Server list 'NBUMaster','serverA','serverB','serverC' on MyServer
.EXAMPLE
    PS C:>Set-NBUServerList -Computername MyServer `
                            -Credential MyDomain\MyAdminAccount

    Gets the Server list on MyServer using the MyAdminAccount Credentials
.EXAMPLE
    PS C:>Get-NBUServerList -Computername MyServer1, MyServer2, MyOtherServer -MasterServer NBUMaster -AdditionalServers 'serverA','serverB','serverC'

    Gets the Server list on MyServer, MyServer2, & MyOtherServer
.EXAMPLE
    PS C:>@('MyServer1', 'MyServer2', 'MyOtherServer') | Get-NBUServerList 

    Sets the Server list on MyServer, MyServer2, & MyOtherServer
.INPUTS
    Strings
.OUTPUTS
    custom object of the target computer name and a collection of NBU Servers
.NOTES
    General notes
.COMPONENT
    The component this cmdlet belongs to
.ROLE
    The role this cmdlet belongs to
.FUNCTIONALITY
    The functionality that best describes this cmdlet
#>
function Get-NBUServerList
{
    [CmdletBinding(DefaultParameterSetName = 'Parameter Set 1')]

    [OutputType([String])]
    Param (
        # Name of the computer to set the NBU information on
        [Parameter(Mandatory = $true,
            Position = 0,
            ParameterSetName = 'Parameter Set 1',
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [Alias('Host')]
        [String[]]
        $ComputerName,

        # Credential for target computer
        [Parameter(Mandatory = $false,
            ParameterSetName = 'Parameter Set 1')]
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )
    
    begin
    {
    }
    
    process
    {
        foreach ($Computer in $ComputerName)
        {
            Write-Verbose "Processing $Computer"
            if (Test-Connection -ComputerName $ComputerName -Count 1 -Quiet)
            {
                
                # This splat contains the ComputerName, and, optionally, the Credential Parameters
                $Splat = @{ComputerName = $Computer}
                if ($Credential -ne [System.Management.Automation.PSCredential]::Empty)
                {
                    $Splat['Credential'] = $Credential
                }

                #TODO: Deal with errors from computers that don't have WinRM enabled.
                $Servers = Invoke-Command -ScriptBlock {
                    (Get-ItemProperty -Path "HKLM:\SOFTWARE\VERITAS\NetBackup\CurrentVersion\Config" `
                            -Name "Server").server 
                } @Splat 
                
                [pscustomobject]@{
                    ComputerName      = $Computer;
                    MasterServer      = $Servers[0]
                    AdditionalServers = $Servers[1..($Servers.Count - 1)]
                }
            }
            else 
            {
                Write-Warning "Unable to reach $Computer"
            }
        }
    }
    
    end
    {
    }
}