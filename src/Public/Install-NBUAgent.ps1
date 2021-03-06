<#
.SYNOPSIS
    Installs NetBackup Agent on a named target Computer
.DESCRIPTION
    Copies the installer bits to the target computer, runs a silent install, and then deletes the installer bits.
.EXAMPLE
    PS C:\> Install-NBUAgent -Computername MyServer
    Installs the NetBackup 8 agent on MyServer
.EXAMPLE
    PS C:\> Install-NBUAgent -Computername MyServer, MyOtherServer
    Installs the NetBackup 8 agent on MyServer and MyOtherServer
.INPUTS
    Name of Computers to install agent on
    Name of Master Server
    Names of additional media servers
.NOTES
    General notes
#>

Function Install-NBUAgent
{
    [CmdletBinding()]
    param (
        # Name of Computer to install the agent on.
        [Parameter(Mandatory = $true,
            Position = 0)]
        [String[]]
        $Computername,

        # Name of the NBU Master Server
        [Parameter(Mandatory = $false)]
        [String]
        $master = 'itnbupw001',

        # One or more names of additional servers in the NBU domain
        [Parameter(Mandatory = $false)]
        [String[]]
        $Additional = 'sharptail,itsymap002,itnbupw004,itnbupw005,itnbupw006,itnbupl001,itnbupl002',

        # Path to the source files.  Should be accessible by the running context, not just the additional context provided by the Credential parameter
        [Parameter(Mandatory = $false)]
        [String]
        $Source = "\\itnbupw001\Deploy\NBU-8\NetBackup_8.0_Win\PC_Clnt\x64",

        # Credentials
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )
    begin
    {
        if (-not (Test-Path $Source))
        {
            Throw "Unable to access $Source to install from"
        }
    }

    process
    {
        foreach ($Computer in $Computername)
        {
            #region herestring
            $response = @"
INSTALLDIR:C:\Program Files\Veritas\
MASTERSERVERNAME:$master
ADDITIONALSERVERS:$Additional
NETBACKUPCLIENTINSTALL:1
SERVERS:$master,$Additional
CLIENTNAME:$Computer
NBSTARTTRACKER:0
STARTUP:Automatic
VNETD_PORT:13724
CLIENTSLAVENAME:$Computer
SILENTINSTALL:1
ISPUSHINSTALL:1
ISCUSTOMINSTALL:1
REBOOT:ReallySuppress
NUMERICINSTALLTYPE:1
STOP_NBU_PROCESSES:0
ABORT_REBOOT_INSTALL:0
PBXCONFIGURECS:FALSE
"@
            #endregion

            if (Test-Connection -ComputerName $Computer)
            {
                # Assuming we are writing to a remote server
                $ResponsePath = "\\$Computer\c`$\temp"
                $ResponseFile = Join-Path $ResponsePath "Response.txt"

                if ($PSBoundParameters['Credential'])
                {
                    Write-Verbose "Openning authenticated channel to $Computer"
                    $CredBits = $Credential.GetNetworkCredential()
                    $null = & net use "\\$Computer\IPC`$" /u:"$($Credbits.Domain)\$($Credbits.UserName)" $($Credbits.Password)
                }

                If (-not (Test-Path $ResponsePath))
                {
                    $NewItemSplat = @{
                        Path     = $ResponsePath
                        ItemType = 'Directory'
                    }
                    $null = New-Item @NewItemSplat
                    Write-Verbose "C:\temp didn't exist, created it"
                }

                $SetContentSplat = @{
                    Value    = $response
                    Path     = $ResponseFile
                    Encoding = 'Ascii'
                }
                Set-Content @SetContentSplat
                Write-Verbose "Wrote the response file"

                # Copy the installer (Should take about 15 sec)
                $null = Robocopy.exe $Source (Join-path $ResponsePath "x64") /mt:12 /w:5 /r:1
                Write-Verbose "Completed copying the installer"

                if ($PSBoundParameters['Credential'])
                {
                    $null = & net use "\\$Computer\IPC`$" /D
                }
                Write-Verbose "Closing authenticated channel to $Computer"

                $ScriptBlock = {
                    try
                    {
                        Set-Location C:\temp\x64 -ErrorAction Stop
                        # The --% tells Powershell to not parse what comes after
                        & .\Setup.exe --% -s /REALLYLOCAL /RESPFILE:'c:\temp\response.txt'

                        # We know we have to wait, so it doesn't hurt to wait 1 second before we start watching setup.exe
                        Start-Sleep -Seconds 1

                        while (Get-Process -Name Setup -ErrorAction SilentlyContinue)
                        {
                            Start-Sleep -Seconds 1
                        }

                        Set-Location C:\

                        Write-Verbose "Setup.exe exited with a $LASTEXITCODE"

                        Remove-Item 'C:\temp\x64' -Recurse -Force -confirm:$False
                        Remove-Item 'c:\temp\response.txt'
                    }
                    catch
                    {
                        # Something went wrong inside the remoting session.
                        $_
                    }
                }

                $InvokeHash = @{
                    ScriptBlock  = $ScriptBlock
                    ComputerName = $Computer
                }

                if ($PSBoundParameters['Credential'])
                {
                    $InvokeHash.Add('Credential', $Credential)
                }
                Write-Verbose "Starting installation"
                Invoke-Command @InvokeHash
            }
            else
            {
                # Leave it non-terminating
                Write-Error "Could not reach $Computer!"
            }
        }
    }
}