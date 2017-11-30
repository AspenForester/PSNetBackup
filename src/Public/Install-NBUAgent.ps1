<#
.SYNOPSIS
    Installs NetBackup Agent on a named target Computer
.DESCRIPTION
    Copies the installer bits to the target computer, runs a silent install, and then deletes the installer bits.
.EXAMPLE
    PS C:\> Install-NBUAgent -Computername MyServer
    Installs the NetBackup 8 agent on MyServer
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

        # 
        [Parameter(Mandatory = $false)]
        [String]  
        $master = 'itnbupw001',

        [Parameter(Mandatory = $false)]
        [String[]]  
        $Additional = 'sharptail,itsymap002,itnbupw004,itnbupw005,itnbupw006,itnbupl001,itnbupl002'
    )

    process
    {
        #region herestring
        $response = @"
INSTALLDIR:C:\Program Files\Veritas\
MASTERSERVERNAME:$master
ADDITIONALSERVERS:$Additional
NETBACKUPCLIENTINSTALL:1
SERVERS:$master,$Additional
CLIENTNAME:$Computername
NBSTARTTRACKER:0
STARTUP:Automatic
VNETD_PORT:13724
CLIENTSLAVENAME:$Computername
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

        if (Test-Connection -ComputerName $Computername)
        {
            # Assuming we are writing to a remote server
            $ResponsePath = "\\$Computername\c`$\temp"
            $ResponseFile = Join-Path $ResponsePath "Response.txt"

            If (-not (Test-Path $ResponsePath))
            {
                $null = New-Item -Path $ResponsePath  -ItemType Directory 
                Write-Verbose "C:\temp didn't exist, created it"
            }

            Set-Content -Value $response -Path $ResponseFile -Encoding Ascii
            Write-Verbose "Wrote the response file"

            $DeployPath = "\\itnbupw001\Deploy\NBU-8\NetBackup_8.0_Win\PC_Clnt\x64"

            # Copy the installer (Should take about 15 sec)
            $null = Robocopy.exe $DeployPath (Join-path $ResponsePath "x64") /mt:12 /w:5 /r:1 
            Write-Verbose "Completed copying the installer"

            $ScriptBlock = {
                try 
                {
                    Set-Location C:\temp\x64 -ErrorAction Stop
                    & .\Setup.exe --% -s /REALLYLOCAL /RESPFILE:'c:\temp\response.txt'

                    # We know we have to wait, so it doesn't hurt to wait 1 second before we start watching setup.exe
                    Start-Sleep -Seconds 1

                    while (Get-Process -Name Setup -ErrorAction SilentlyContinue)
                    {
                        Start-Sleep -Seconds 1
                    }

                    Set-Location C:\

                    Remove-Item 'C:\temp\x64' -Recurse -Force -confrim:$False
                    Remove-Item 'c:\temp\response.txt'
                }
                catch
                {
                    # Basically couldn't map the drive
                    $_
                }
                # Now we need to figure out how to do all this remotely!  But we're getting closer!!
            }

            Invoke-Command -ScriptBlock $ScriptBlock -ComputerName $Computername 
        }
        else
        {
            # Leave it non-terminating
            Write-Error "Could not reach $Computername!"
        }
    }
}