param(
    [int]$Users = 5,
    [int]$Groups = 2,
    [int]$Admins = 1
)

# # Install AD DS Role
# Install-WindowsFeature -Name AD_Domain-Services -IncludeManagementTools

# # Promote server to  Domain Controller
# Install-ADDSForest `
#     -DomainName "cyberlab.local" `
#     -SafeModeAdministratorPassword (ConvertTo-SecureString 'P@ssw0rd123' -AsPlainText -Force) `
#     -Force $true

# # Everything after this will NOT run until after reboot unless you handle that with scheduled task or second stage script


Write-Host "Generating AD environment JSON..."

.\random_domain.ps1 -OutputJSONFile .\env.json -UserCount $Users -GroupCount $Groups -LocalAdminCount $Admins

Write-Host "Creating AD environment from JSON schema..."

.\gen_ad.ps1 -JSONFile .\env.json