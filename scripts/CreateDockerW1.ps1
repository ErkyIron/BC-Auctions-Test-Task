# Import and Update the BcContainerHelper module that is used to work with Business Central in docker containers
Import-Module BcContainerHelper
Update-Module BcContainerHelper

# Set the variables for the Container
$containerName = 'bc-w1'
$login = 'admin'
$password = '123qweasD'
$auth = 'UserPassword'

#Set the BC version and country
$artifactUrl = Get-BcArtifactUrl -country w1 -select Latest
Write-Host $artifactUrl

Write-Host -ForegroundColor Yellow @'
====================================== PARAMETERS =========================================
'@
Write-Host -NoNewLine -ForegroundColor Yellow "Container name: "; Write-Host $containerName
Write-Host -NoNewLine -ForegroundColor Yellow "Instance name: "; Write-Host "BC"
Write-Host -NoNewLine -ForegroundColor Yellow "BC Login: "; Write-Host $login
Write-Host -NoNewLine -ForegroundColor Yellow "BC Password: "; Write-Host $password
Write-Host -NoNewLine -ForegroundColor Yellow "BC Authentication: "; Write-Host $auth
Write-Host -NoNewLine -ForegroundColor Yellow "BC Artifact URL: "; Write-Host $artifactUrl
Write-Host -ForegroundColor Yellow @'
===========================================================================================
'@

# Create the credantials for the BC login
$securePassword = ConvertTo-SecureString -String $password -AsPlainText -Force
$credential = New-Object pscredential $login, $securePassword

# Create the container
New-BcContainer `
    -accept_eula `
    -containerName $containerName `
    -credential $credential `
    -auth $auth `
    -artifactUrl $artifactUrl `
    -imageName 'bcw1' `
    -multitenant:$false `
    -includeTestToolkit `
    -includeTestLibrariesOnly `
    -includePerformanceToolkit `
    -memoryLimit 8G `
    -vsixFile (Get-LatestAlLanguageExtensionUrl) `
    -updateHosts `
    -isolation hyperv `
    -dns '8.8.8.8'

# Create the user in BC
Setup-BcContainerTestUsers -containerName $containerName -Password $credential.Password -credential $credential
