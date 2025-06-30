param(
    [int]$Users = 5,
    [int]$Groups = 2,
    [int]$Admins = 1
)

Write-Host "Generating AD environment JSON..."

.\random_domain.ps1 -OutputJSONFile .\env.json -UserCount $Users -GroupCount $Groups -LocalAdminCount $Admins

Write-Host "Creating AD environment from JSON schema..."

.\gen_ad.ps1 -JSONFile .\env.json