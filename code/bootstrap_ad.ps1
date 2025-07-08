param(
    [int]$Users = 5,
    [int]$Groups = 2,
    [int]$Admins = 1,
    [string]$LabCredsUploadUrl
)

# # Install AD DS Role
# Install-WindowsFeature -Name AD_Domain-Services -IncludeManagementTools

# # Promote server to  Domain Controller
# Install-ADDSForest `
#     -DomainName "cyberlab.local" `
#     -SafeModeAdministratorPassword (ConvertTo-SecureString 'P@ssw0rd123' -AsPlainText -Force) `
#     -Force $true

# # Everything after this will NOT run until after reboot unless you handle that with scheduled task or second stage script


$logPath = "C:\cyberlab\AD\AD.log"
Start-Transcript -Path $logPath -Append

Start-Sleep -Seconds 300

Write-Host "Generating AD environment JSON..."

Set-Location -Path "C:\cyberlab\AD\code"

.\random_domain.ps1 -OutputJSONFile .\env.json -UserCount $Users -GroupCount $Groups -LocalAdminCount $Admins

Write-Host "Creating AD environment from JSON schema..."

.\gen_ad.ps1 -JSONFile .\env.json

Write-Host "Uploading first AD users credentials to blob storage..."

$json = Get-Content .\env.json | ConvertFrom-Json
$firstUser = $json.users[0]

$firstname, $lastname = $firstUser.Split(" ")
$username = ($firstname[0] + $lastname).ToLower()

$uploadObj = @{
    username = $username
    password = $firstUser.password
} | ConvertTo-Json -Depth 2

$uploadPath = "$env:TEMP\lab-creds.json"
$uploadObj | Out-File -FilePath $uploadPath -Encoding utf8

Invoke-RestMethod -Uri $LabCredsUploadUrl -Method PUT -InFile $uploadPath -ContentType "application/json"

Write-Host "lab-creds.json uploaded for user $username"

Stop-Transcript 