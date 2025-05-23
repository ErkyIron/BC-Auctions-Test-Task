# Container information
$containerName = 'bc-w1'
# Path to the folder with app files
$rootPath = "C:\Users\nahav\Downloads\BC-Auctions-Test-Task\app\"
#List of the apps separated by comma
$appNames = "API Auctions Info"

$appPaths = @($appNames.Split(',').Trim() | Foreach-Object { (Get-ChildItem -Path (Join-Path $rootPath ("*_"+$_+"_*.app"))) } ) | % { $_.FullName }

Write-Host "Publishing to tenant"
Publish-BcContainerApp -appFile $appPaths -containerName $containerName -SkipVerification
$appName = @($appNames.Split(',').Trim() | Foreach-Object { (Install-BcContainerApp -appName $_ -containerName $containerName)})