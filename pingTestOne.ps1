Clear-Host

$IPList = "C:\temp\_computers.txt"
$Output = "C:\temp\pingOutput.csv"


$computers = foreach($m in (Get-Content $IPList)){
    $name = (Get-Content "C:\temp\computers.csv" | Select-String "^($m)") -replace "$m,"
    If(Test-Connection -ComputerName $m -Count 1 -Quiet){
        Write-output "$m ,Active,$((get-date).ToString("MM-dd-yyyy HH:mm")),$name"
    }else{
        Write-output "$m ,Inactive,$((get-date).ToString("MM-dd-yyyy HH:mm")),$name"
    }
}

$computers | Out-File $Output -Append







Clear-Host

$IPList = "C:\temp\computers.csv"
$Output = "C:\temp\pingOutput.csv"


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
