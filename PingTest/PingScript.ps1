Clear-Host

#Runs the speed test and exports it to results.txt
$IPList = "C:\scripts\PingTest\computers.csv"                   #a csv file with ip to name coralation
$Results = 'C:\scripts\PingTest\results.txt'                     #output csv
$job = Start-Job -ScriptBlock {                     #this can't access variables outside of itself
    $IPList = "C:\scripts\PingTest\computers.csv"               #a path variable for inside the scriptblock
    foreach($m in (Get-Content $IPList)){
        $address = $m -replace ",.*"
        Test-Connection -ComputerName $address -Ping
    }
}
$Output = Receive-Job $job -Wait
$Output | Export-Csv $Results

##############################################################################
#Cleans up results.txt such that non important collumns are removed.

foreach($m in (Get-Content $IPList)){
    $address = $m -replace ",.*"
    $name = $m -replace "($address),"

    $date = ((get-date).ToString("MM-dd-yyyy HH:mm"))
    $x = Get-Content $Results

    for($i=0; $i -lt $x.Count; $i++) {
        if ($x[$i] -like "*$address*") {
            $tempArray = $x[$i].Split(",")      #This array deal lets me pick and drop certain variables. I append a delimiter to the end so I can put it back in below with the 13.
            $tempArray += ","
            $x[$i] = "`"$date`",`"$name`"," + $tempArray[5,13,6,13,8,13,4,13,9,13,10,13,11]
        }
    }
    $x | Set-Content $Results
}

##############################################################################
#This converts the txt file to a csv and handles appending to it without repeating headers.

$ParsedResults = "C:\scripts\PingTest\results.csv"
#$header = "PSComputerName,RunspaceId,PSShowComputerName,PSSourceJobInstanceId,Ping,Source,Destination,Address,DisplayAddress,Latency,Status,BufferSize,Reply"
$header = "Date ,Name, Source, Destination, DisplayAddress, Ping, Latency, Status, BufferSize"
$outputLine = ""

#Checks to see if the .txt file exists which it should always exist now that I combined the scripts.
if (Test-Path $Results -PathType leaf) {
    #If the csv file doesn't exist it makes it and adds the header as the first line.
    if (! (Test-Path $ParsedResults -PathType leaf)) {
        $header | Out-File -FilePath $ParsedResults
    }
    foreach($line in Get-Content $Results | Select-Object -Skip 1) {
        $outputLine = $outputLine + $line + "`n"
    }
    #This code appends the line made from the txt file to a row in the csv file and then deletes the txt file
    $outputLine | Out-File -FilePath $ParsedResults -Append
    Remove-Item $Results
}

##############################################################################

exit 0