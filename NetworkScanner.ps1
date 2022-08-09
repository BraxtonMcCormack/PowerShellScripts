
#This block grabs the SubnetMask
$output = "c:\scripts\SpeedTest\results\tempParse.txt"
ipconfig /all | Out-File -FilePath $output

foreach($line in Get-Content $output) {
    if ($line -like "*Subnet Mask . . . . . . . . . . . : *") {
        $line = $line -replace "Subnet Mask . . . . . . . . . . . : "
        $subnet = $line
    }
}
Remove-Item $output


#This block does a network scan
$ips= 0..255 | ForEach-Object{$subnet};

#optional: add ports to scan. 22=ssh, 80=http, 443=https, 135=smb, 3389=rdp
$ports= 22, 80, 443, 135, 3389;

#optional: change batch size to speed up / slow down (warning: too high will throw errors)
$batchSize=64;

$ips += Get-NetNeighbor | ForEach-Object{$_.IPAddress}
$ips = $ips | Sort-Object | Get-Unique;
$ips | ForEach-Object -Throttlelimit $batchSize -Parallel {
    $ip=$_;
    $activePorts = $using:ports | ForEach-Object{ if(Test-Connection $ip -quiet -TcpPort $_ -TimeoutSeconds 1){ $_ } }
    if(Test-Connection $ip -quiet -TimeoutSeconds 1 -count 1){
        [array]$activePorts+="(ping)";
    }
    if($activePorts){
        $dns=(Resolve-DnsName $ip -ErrorAction SilentlyContinue).NameHost;
        $mac=((Get-NetNeighbor |?{$_.State -ne "Incomplete" -and $_.State -ne "Unreachable" -and $_.IPAddress -match $ip}|%{$_}).LinkLayerAddress )
        return [pscustomobject]@{dns=$dns; ip=$ip; ports=$activePorts; mac=$mac}
    }
} | Tee-Object -variable "dvcResults"
#Some of the output values are array like objects and this fixes that so they display correctly.
$dvcResults | Select-Object -Property @{Name="dns";Expression={$_.dns -join '; '}}, ip, @{Name="ports";Expression={$_.ports -join '; '}},@{Name="mac";Expression={$_.mac -join '; '}} | Export-Csv -Path "c:\scripts\SpeedTest\results\IPScanner.csv"

