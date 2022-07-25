#if the script doesn't run on your machine try the following:
#Set-Item WSMan:\localhost\Client\TrustedHosts *
#Enable-PSRemoting -Force
Clear-Host      #This just clears the terminal.


#variables to be used later when I put the speed test code back
$DownloadURL = "https://install.speedtest.net/app/cli/ookla-speedtest-1.0.0-win64.zip"
$DownloadPath = "c:\temp\SpeedTest.Zip"
$ExtractToPath = "c:\temp\SpeedTest"
$SpeedTestExePath = "C:\temp\SpeedTest\speedtest.exe"
$LogPath = 'c:\temp\SpeedTestLog.txt'


#for each line in computers.txt it will run a speed test and copy the resulting speed test log to this computer.
$computers = Get-Content C:\temp\computers.txt
foreach ($line in $computers) {                                             #$line is the address
    if (Test-Connection -TargetName $line -Quiet) {                         #if ping responds then it remotes in for the speed test.
        $hostname = [System.Net.Dns]::GetHostByAddress($line).Hostname      #Gets the host name for PSSession from the ip address in the computers.txt file.
        $s = New-PSSession -ComputerName $hostname -Credential $cred -Authentication Default    #$hostname is what it is trying to connect to.
        Enter-PSSession $s

        #This logs the speed test.
        $ErrorActionPreference = "SilentlyContinue"
        Stop-Transcript | out-null
        $ErrorActionPreference = "Continue"
        Start-Transcript -path $SpeedTestExePath -Append:$false

        #This is the code for the actual speed test.
        function RunTest() {
            $test = & $SpeedTestExePath --accept-license
            $test
        }
        #check if file exists
        if (Test-Path $SpeedTestExePath -PathType leaf) {
            Write-Host "Speedtest EXE Exists, starting test" -ForegroundColor Green
            RunTest
        }
        else {
            Write-Host "SpeedTest EXE Doesn't Exist, starting file download"
            Invoke-WebRequest $DownloadURL -outfile $DownloadPath
            Add-Type -AssemblyName System.IO.Compression.FileSystem
            function Unzip {
                param([string]$zipfile,[string]$outpath)
                [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
            }
            Unzip $DownloadPath $ExtractToPath
            RunTest
        }

        #stop logging
        Stop-Transcript



        Exit-PSSession

        #This copies the speed test data from the PSSession and timestamps the file.
        Copy-Item -FromSession $s C:\temp\SpeedTestLog.txt -Destination "C:\temp\SpeedTestLog$((get-date).ToString("MM-dd-yyyy-HH-mm")).txt"
    }
}


exit 0