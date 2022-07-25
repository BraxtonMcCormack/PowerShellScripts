Clear-Host      #This just clears the terminal.

$DownloadURL = "https://install.speedtest.net/app/cli/ookla-speedtest-1.0.0-win64.zip"
#location to save on the computer. Path must exist or it will error
$DownloadPath = "c:\temp\SpeedTest.Zip"
$ExtractToPath = "c:\temp\SpeedTest"
$SpeedTestExePath = "C:\temp\SpeedTest\speedtest.exe"
#Log File Path
$LogPath = 'c:\temp\SpeedTestLog.txt'

#HERE *****
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
#TO HERE *****

exit 0