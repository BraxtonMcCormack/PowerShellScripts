#if the script doesn't run on your machine try the following:
Clear-Host      #This just clears the terminal.


#variables to be used later when I put the speed test code back
$DownloadURL = "https://install.speedtest.net/app/cli/ookla-speedtest-1.0.0-win64.zip"
$DownloadPath = "c:\scripts\SpeedTest\SpeedTest.Zip"
$ExtractToPath = "c:\scripts\SpeedTest"
$SpeedTestExePath = "c:\scripts\SpeedTest\speedtest.exe"
$LogPath = 'c:\scripts\SpeedTest\results\SpeedTestLog.txt'


#This logs the speed test.
$ErrorActionPreference = "SilentlyContinue"
Stop-Transcript | out-null
$ErrorActionPreference = "Continue"
Start-Transcript -path $LogPath -Append

#This function gets various variables from an ip address. The variables I use are the City and Registered Organization of the IP address which go in the ParsedSpeedTestLog.csv
#I did not make this function I recieved it from Andy and I did not make any changes except to comment out the variables I did not use.
Function Get-WhoIs {
    [cmdletbinding()]
    [OutputType("WhoIsResult")]
    Param (
        [parameter(Position = 0,
            Mandatory,
            HelpMessage = "Enter an IPV4 address to lookup with WhoIs",
            ValueFromPipeline,
            ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern("^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$")]
         [ValidateScript( {
            #verify each octet is valid to simplify the regex
                $test = ($_.split(".")).where({[int]$_ -gt 254})
                if ($test) {
                    Throw "$_ does not appear to be a valid IPv4 address"
                    $false
                }
                else {
                    $true
                }
            })]
        [string]$IPAddress
    )

    Begin {
        Write-Verbose "Starting $($MyInvocation.Mycommand)"
        $baseURL = 'http://whois.arin.net/rest'
        #default is XML anyway
        $header = @{"Accept" = "application/xml"}

    } #begin

    Process {
        Write-Verbose "Getting WhoIs information for $IPAddress"
        $url = "$baseUrl/ip/$ipaddress"
        Try {
            $r = Invoke-Restmethod $url -Headers $header -ErrorAction stop
            Write-verbose ($r.net | Out-String)
        }
        Catch {
            $errMsg = "Sorry. There was an error retrieving WhoIs information for $IPAddress. $($_.exception.message)"
            $host.ui.WriteErrorLine($errMsg)
        }

        if ($r.net) {
            Write-Verbose "Creating result"
            [pscustomobject]@{
                #PSTypeName             = "WhoIsResult"
                IP                     = $ipaddress
                RegisteredOrganization = $r.net.orgRef.name
                City                   = (Invoke-RestMethod $r.net.orgRef.'#text').org.city
                #StartAddress           = $r.net.startAddress
                #EndAddress             = $r.net.endAddress
                #NetBlocks              = $r.net.netBlocks.netBlock | foreach-object {"$($_.startaddress)/$($_.cidrLength)"}
                #Updated                = $r.net.updateDate -as [datetime]
            }
        } #If $r.net
    } #Process

    End {
        Write-Verbose "Ending $($MyInvocation.Mycommand)"
    } #end
}


#This is the code for the actual speed test.
#It runs the speed test exe and writes out things such as User, Computer Name, and IP so that they will show up on the log.
function RunTest() {
    $publicIP = (Invoke-WebRequest -uri "https://api.ipify.org/" -UseBasicParsing).Content
    $hostname = HOSTNAME.EXE
    Write-Host "Computer Name: " $hostname
    Write-Host "Public IP: " $publicIP
    $test = & $SpeedTestExePath --accept-license
    $test
}

#check if file exists and if it does not it downloads the zip and unzips it to the correct path.
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
#This outputs the Organization and City for the log. They are at the bottom beceause I wanted them to be the last column of the speed test log.
"Registered Organization: $(Get-WhoIs ((Invoke-WebRequest -uri "https://api.ipify.org/" -UseBasicParsing).Content) | Select-Object -Property registeredOrganization)"
"City: $(Get-WhoIs ((Invoke-WebRequest -uri "https://api.ipify.org/" -UseBasicParsing).Content) | Select-Object -Property city)"
#Stop logging to the speed test log.
Stop-Transcript

#I stop the transcript before these functions beceause I do not want them logged since they are not relevant.

#This section of code parses the speedtestlog.txt into a csv
$inputLog = "c:\scripts\SpeedTest\results\SpeedTestLog.txt"
$output = "c:\scripts\SpeedTest\results\ParsedSpeedTestLog.csv"
$header = "`"Date`",`"Time`",`"Computer Name`",`"Public IP`",`"Server`",`"ISP`",`"Latency`",`"Download`",`"Upload`",`"Packet Loss`",`"Result URL`",`"Registered Organization`",`"City`""
$outputLine = ""

#Checks to see if the .txt file exists which it should always exist now that I combined the scripts.
if (Test-Path $inputLog -PathType leaf) {
    #If the csv file doesn't exist it makes it and adds the header as the first line.
    if (! (Test-Path $output -PathType leaf)) {
        $header | Out-File -FilePath $output -Encoding ascii
    }
    foreach($line in Get-Content $inputLog) {
                                                    #These if functions check the line to see if it has what i needs then cleans the line of delemiters and unnecessary text.
        if ($line -like "*Start time: *") {
            $line = $line -replace "Start time: "
            $line = $line.Insert(4,'-').Insert(7,'-').insert(10,',').Insert(11,' ').Insert(14,':').Insert(17,':')
            $outputLine = $outputLine + $line
        }
        if ($line -like "*Computer Name: *") {
            $line = $line -replace "Computer Name: " -replace ","
            $outputLine = $outputLine + ",$line"
        }
        if ($line -like "*Public IP: *") {
            $line = $line -replace "Public IP: " -replace ","
            $outputLine = $outputLine + ",$line"
        }
        if ($line -like "*Server: *") {
            $line = $line -replace "Server: " -replace ","
            $outputLine = $outputLine + ",$line"
        }
        if ($line -like "*ISP: *") {
            $line = $line -replace "ISP: " -replace ","
            $outputLine = $outputLine + ",$line"
        }
        if ($line -like "*Latency: *") {
            $line = $line -replace "Latency: " -replace ","
            $outputLine = $outputLine + ",$line"
        }
        if ($line -like "*Download: *") {
            $line = $line -replace "Download: " -replace ","
            $outputLine = $outputLine + ",$line"
        }
        if ($line -like "*Upload: *") {
            $line = $line -replace "Upload: " -replace ","
            $outputLine = $outputLine + ",$line"
        }
        if ($line -like "*Packet Loss: *") {
            $line = $line -replace "Packet Loss: " -replace ","
            $outputLine = $outputLine + ",$line"
        }
        if ($line -like "*Result URL: *") {
            $line = $line -replace "Result URL: " -replace ","
            $outputLine = $outputLine + ",$line"
        }
        if ($line -like "*Registered Organization: *") {
            $line = $line -replace "Registered Organization: @{RegisteredOrganization=" -replace "," -replace "}"
            $outputLine = $outputLine + ",$line"
        }
        if ($line -like "*City: *") {
            $line = $line -replace "City: @{City=" -replace "," -replace  "}"
            $outputLine = $outputLine + ",$line"
        }
    }
    #This code appends the line made from the txt file to a row in the csv file and then deletes the txt file
    $outputLine | Out-File -FilePath $output -Append -Encoding ascii
    Remove-Item $inputLog
}



exit 0