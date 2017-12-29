Function ConvertTo-Unixdate ([DateTime]$Date)
{
    [math]::Round((New-TimeSpan -Start '1/1/1970' -End $Date).TotalSeconds,0)
}