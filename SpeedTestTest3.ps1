#This clears the screen.
Clear-Host
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
#This is a string with the url to a ookla speed test. That is the same speed test Andy showed but just not online.
$DownloadURL = "https://install.speedtest.net/app/cli/ookla-speedtest-1.0.0-win64.zip"
#This is a string for paths to be used in the ....
$DownloadPath = "c:\temp\SpeedTest.Zip"
$ExtractToPath = "c:\temp\SpeedTest"
$SpeedTestExePath = "c:\temp\SpeedTest\speedtest.exe"
$LogPath = "c:\temp\SpeedTestLog.txt"
#Error output will not be displayed and the script executes the next commands in the pipeline. yyyy-MM-dd-HH-mm"
$ErrorActionPreference = "SilentlyContinue"
#The Stop-Transcript cmdlet stops a transcript.
#The pipe character is used between commands to create the pipeline. We work from left to right down the pipeline.
#The output of one command effectively becomes the input of the next command.
#The Out-Null cmdlet sends its output to NULL, in effect, removing it from the pipeline and preventing the output to be displayed at the screen.
Stop-Transcript | out-null
#Determines how PowerShell responds to a non-terminating error: (Continue(Default)) Displays the error message and continues executing.
$ErrorActionPreference = "Continue"
#Creates a record of all or part of a PowerShell session to a text file in the LogPath
#Append: Indicates that this cmdlet adds the new transcript to the end of an existing file. Use the Path parameter to specify the file. Idk the specifics of the false meaning but I can guess
Start-Transcript -path $LogPath -Append:$false
#A powershell function (RunTest). The & executes the ensuing executable and accepts its liscense.
function RunTest() {
    #defines test
    $test = & $SpeedTestExePath --accept-license
    #runs test?
    $test
}
#Determines whether all elements of a path exist. The leaf part just means it is the last item or in this case the file.
if (Test-Path $SpeedTestExePath -PathType leaf) {
    #Writes customized output to a host. Also specify the color of text by using the ForegroundColor parameter.
    Write-Host "Speedtest EXE Exists, starting test" -ForegroundColor Green
    #Runs the RunTestFunction
    RunTest
}
else {
    #Writes customized output to a host.
    Write-Host "SpeedTest EXE Doesn't Exist, starting file download"
    #The PowerShell Wget is a non-interactive utility that sends the request to the web page and parses the response and returns the items. It also helps to download the files from the webpage.
    Invoke-WebRequest $DownloadURL -outfile $DownloadPath
    #Adds a Microsoft .NET class to a PowerShell session.
    #Specifies the full name of an assembly that includes the types.
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    #A unzip function from stackoverflow
    function Unzip {
        #I wasn't able to find the best documentation but I think param is what lets this function take the zipfile and outpath when Unzip is called as strings.
        param([string]$zipfile,[string]$outpath)
        #I believe the first part is the path to the zipfile class and the second half extracts the file to the given directory.
        #Also the left operand to the static member accessor (::) is required to be a type
        [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
    }
    #Runs the Unzip function passing the .zip path and where it will be extracted too.
    Unzip $DownloadPath $ExtractToPath
    #Runs the RunTest function.
    RunTest
}
#This should work???? It doesn't fix it on monday though.
#IPAddress = Get-NetIPAddress -AddressFamily IPv4
$ip = New-Object System.Net.IPAddress(0x1521A8C0)
$stringOne = (Get-Content -Path $LogPath) -join "`n"
$list = $ip, $stringOne
$outputString = ($list) -join "`n"
#idk something like this
#$b = New-PSSession B
#Copy-Item -FromSession $b C:\temp\SpeedTestLog.txt -Destination C:\Programs\temp\SpeedTestLog.txt
#or somethingl ike this
#Copy-Item -Path \\serverb\c$\temp\SpeedTestLog.txt -Destination \\servera\c$\programs\temp\SpeedTestLog.txt;
#This command returns a single string (the computer name of the local computer).
$Hostname = hostname
#stop logging
Stop-Transcript
#Including the exit keyword in a script and exit terminates only the script and not the entire console session from where the script runs.
exit 0