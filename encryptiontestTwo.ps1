Clear-Host      #clears the host

#the directory paths already have to pre-exist for now I can polish this more if it works for what we are doing
#the secure key .txt file has to be deleted each time since it won't override
$passFilePath = "C:\temp\secureTest\ExportedPassword.txt"       #where the secure string password will be stored
$userFilePath = "C:\temp\secureTest\ExportedUsername.txt"       #where the plaintext username will be stored
$AESKeyFilePath = "c:\temp\secureTest\key.txt"            #where the randomly generated AESKey will be stored
$AESKey = New-Object Byte[] 32                                  #generates a byte array with 10 elements whose values are initialized to 0
[Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($AESKey)    #fills the key array with "cryptographically Strong RNG in .NET 6" (random numbers)
#If using an older version of powershell and the above doesn't work try "Security.Cryptography.RNGCryptoServiceProvider"
Set-Content $AESKeyFilePath $AESKey                                     #adds the key to a text file


$username = Read-Host "Please enter your username"                      #prompts for a plaintext username
$passwordSecureString = Read-Host "Enter a Password" -AsSecureString    #prompts for a sercure string password


$password = $passwordSecureString | ConvertFrom-SecureString -Key $AESKey   #converts the secure string type into text
Add-Content $passFilePath $password                                         #adds the secure string to a text file
Add-Content $userFilePath $username                                         #adds the username to a textfile






#code to unlock credential information, it will need the paths above wherever it is used as well
$AESKey = Get-Content $AESKeyFilePath                           #gets the key from the .txt file
$pwdTxt = Get-Content $passFilePath                             #gets the password secure string from the text file
$user = Get-Content $userFilePath                               #gets the username from the .txt file
$securePwd = $pwdTxt | ConvertTo-SecureString -Key $AESKey      #converts the secure string text back into a secure string type using the AESKey
$credObject = New-Object System.Management.Automation.PSCredential -ArgumentList $user, $securePwd  #creates a credential object with the username, password