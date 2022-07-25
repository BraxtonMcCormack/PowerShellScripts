##############################################################################
Clear-Host

$IPList = "C:\temp\_computers.txt"
$Output = "C:\temp\pingOutputs\pingOutput.csv"


$computers = foreach($m in (Get-Content $IPList)){
    $name = (Get-Content "C:\temp\computers.csv" | Select-String "^($m)") -replace "$m,"
    If(Test-Connection -ComputerName $m -Count 1 -Quiet){
        Write-output "$m ,Active,$((get-date).ToString("MM-dd-yyyy HH:mm")),$name"
    }else{
        Write-output "$m ,Inactive,$((get-date).ToString("MM-dd-yyyy HH:mm")),$name"
    }
    $computers | Out-File $Output -Append
}

$computers | Out-File $Output -Append

##############################################################################
Clear-Host

$IPList = "C:\temp\computers.csv"
$Output = "C:\temp\pingOutputs\pingOutput.csv"


$computers = foreach($m in (Get-Content $IPList)){
    $address = $m -replace ",.*"
    $name = $m -replace "($address),"
    If(Test-Connection -ComputerName $address -Count 1 -Quiet){
        Write-output "$address ,Active,$((get-date).ToString("MM-dd-yyyy HH:mm")),$name"
    }else{
        Write-output "$address ,Inactive,$((get-date).ToString("MM-dd-yyyy HH:mm")),$name"
    }
}

$computers | Out-File $Output -Append

##############################################################################
Clear-Host

$IPList = "C:\temp\computers.csv"
$Output = "C:\temp\pingOutputs\"


$computers = foreach($m in (Get-Content $IPList)){
    $address = $m -replace ",.*"
    $name = $m -replace "($address),"
    If(Test-Connection -ComputerName $address -Count 1 -Quiet){
        ("$address ,Active,$((get-date).ToString("MM-dd-yyyy HH:mm")),$name") | Out-File -FilePath "$Output$name.csv" -Append
    }else{
        ("$address ,Inactive,$((get-date).ToString("MM-dd-yyyy HH:mm")),$name") | Out-File -FilePath "$Output$name.csv" -Append
    }
}

##############################################################################

$IPList = "C:\temp\computers.csv"
$Output = "C:\temp\pingOutputs\PingLog.txt"

Start-Transcript -path $Output -Append


$computers = foreach($m in (Get-Content $IPList)){
    $address = $m -replace ",.*"
    $name = $m -replace "($address),"
    $date = ((get-date).ToString("MM-dd-yyyy HH:mm"))
    $address
    $name
    $date
    Test-Connection -ComputerName $address -Ping
}

Stop-Transcript

##############################################################################

Clear-Host

$IPList = "C:\temp\_computers.txt"
$Output = "C:\temp\pingOutputs\PingLog.txt"

$ErrorActionPreference = "SilentlyContinue"
Stop-Transcript | out-null
$ErrorActionPreference = "Continue"
Start-Transcript -path $Output -Append:$false

foreach ($line in Get-Content $IPList) {
    ((get-date).ToString("`nMM-dd-yyyy HH:mm"))
    Test-Connection -ComputerName $line -Ping
}
Stop-Transcript

##############################################################################

Clear-Host

$IPList = "C:\temp\computers.csv"
$Output = "C:\temp\pingOutputs\PingLog($((get-date).ToString("MM-dd-yyyy HHmm"))).txt"

Start-Transcript -path $Output -Append -UseMinimalHeader


foreach($m in (Get-Content $IPList)){
    $address = $m -replace ",.*"
    $name = $m -replace "($address),"
    $date = ((get-date).ToString("MM-dd-yyyy HH:mm"))
    "******************************`n$name"
    $date
    Test-Connection -ComputerName $address -Ping
}

##############################################################################