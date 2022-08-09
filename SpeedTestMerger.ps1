Clear-Host
$directory = "C:\Users\bmccormack\Desktop\test_folder"
$output = "C:\Users\bmccormack\Desktop\output\output.csv"
$header = "User, Date, Time, Computer Name, Public IP, Server, ISP, Latency, Download, Upload, Packet Loss, Result URL, Registered Organization, City"
$fileOut = ""


if (! (Test-Path $output -PathType leaf)) {
    $header | Out-File -FilePath $output -Encoding ascii
}

$files = @(Get-ChildItem "$directory\*.csv")
foreach ($file in $files | Select-Object -Property name) {
    $name = $file.name -replace "-speedtestlog.csv"
    $temp = Get-Content "$directory\$name-speedtestlog.csv"
    foreach ($line in ($temp | Select-Object -skip 1)) {
        $fileOut = $fileOut + ($name + ", " + $line) + "`n"
    }
    Remove-Item "$directory\$name-speedtestlog.csv"
}
$fileOut | Out-File -FilePath $output -Append -Encoding ascii


exit 0