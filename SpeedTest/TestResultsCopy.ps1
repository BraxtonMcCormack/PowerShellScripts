Clear-Host

$user = $env:UserName
$to = "\\mt-fs-1\shareddata\AccountingAndIT\Inventory\RemoteNetworkPerformance\$user-speedtestlog.csv"
$from = "c:\scripts\speedtest\results\parsedspeedtestlog.csv"

if (Test-Path $from -PathType leaf) {
    if (Test-Path $to -PathType Leaf) {
        Copy-Item $from -Destination $to -Force
    }
    else {
        Copy-Item $from -Destination $to
    }
}
else {
    Write-Host "The is no speedtest."
}
Remove-Item $from