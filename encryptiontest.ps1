
$username = Read-Host "Please enter your username"                  #prompts for a plaintext username
$secureStringPwd = Read-Host "Enter a Password" -AsSecureString     #prompts for a sercure string password

$secureStringText = $secureStringPwd | ConvertFrom-SecureString     #converts the secure string into text that is still secure
Set-Content "C:\temp\ExportedPassword.txt" $secureStringText        #adds that secure string as text to a text file

$pwdTxt = Get-Content "C:\temp\ExportedPassword.txt"                #grabs the secure string from the text file
$securePwd = $pwdTxt | ConvertTo-SecureString                       #converts the string back into a secure string data type
$credObject = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $securePwd  #Creates a credential object type with the user name and password



$AESKey = New-Object Byte[] 32
$AESKeyFilePath = "c:\creds\key.txt"
[Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($AESKey)

# Store the AESKey into a file. This file should be protected!  (e.g. ACL on the file to allow only select people to read)
Set-Content $AESKeyFilePath $AESKey   # Any existing AES Key file will be overwritten

$password = $passwordSecureString | ConvertFrom-SecureString -Key $AESKey   #converts the secure string into text that is still secure
Add-Content $credentialFilePath $password



# $username = "reasonable.admin@acme.com.au"
$AESKey = Get-Content $AESKeyFilePath
$pwdTxt = Get-Content $SecurePwdFilePath
$securePwd = $pwdTxt | ConvertTo-SecureString -Key $AESKey
$credObject = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $securePwd