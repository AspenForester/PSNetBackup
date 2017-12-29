Function ConvertFrom-Unixdate
{
    param(
        # UnixDate as input
        [Parameter(Mandatory = $true,
        ValueFromPipeline = $true,
        Position = 0)]
        [String]
        $UnixDate,

        # Perform the conversion to UTC
        [Parameter(Mandatory = $false)]
        [Switch]
        $ToUTC
    )
    $UnixDate = $UnixDate.substring(0, 10)

    $Date = ([datetime]'1/1/1970').AddSeconds($UnixDate)

    if ($PSBoundParameters['ToUTC'])
    {
        $Date = [timezone]::CurrentTimeZone.ToUniversalTime($Date)
    }

    Write-Output $Date
}