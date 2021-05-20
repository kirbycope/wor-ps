# Note: Editing the WIM file requires that this srcipt is ran with elevated priviledges (as an Administrator)

$downloadsFolder = "$HOME\Downloads"

Write-Host "Downloading CMD file from UUP..." -ForegroundColor Yellow
$uupFileName = "creatingISO_21382.1000_en-us_arm64_professional.cmd"
$uupDownloadUrl = "https://uup.rg-adguard.net/dl/tmp/81716d1f-4b55-4bda-ba95-77fa13847f7a/$uupFileName"
if (-Not (Test-Path -Path "$downloadsFolder\$uupFileName")) {
    Invoke-WebRequest $uupDownloadUrl -OutFile "$downloadsFolder\$uupFileName"
    Write-Host "Complete!" -ForegroundColor Green
}
else {
    Write-Host "CMD file already exists!" -ForegroundColor Green
}

Write-Host "Running CMD file from UUP..." -ForegroundColor Yellow
$isoFileName = "21382.1000.210511-1436.CO_RELEASE_SVC_PROD1_CLIENTPRO_OEMRET_A64FRE_EN-US.iso"
if (-Not (Test-Path -Path "$downloadsFolder\$isoFileName")) {
    Invoke-Item "$downloadsFolder\$uupFileName"
    Write-Host "Complete!" -ForegroundColor Green
}
else {
    Write-Host "ISO file already exists!" -ForegroundColor Green
}

Write-Host "Mounting the ISO..." -ForegroundColor Yellow
$driveLetter = (Get-DiskImage -ImagePath "$downloadsFolder\$isoFileName" | Get-Volume).DriveLetter
if (-Not $driveLetter) {
    $mountResult = Mount-DiskImage -ImagePath "$downloadsFolder\$isoFileName" -PassThru
    $driveLetter = ($mountResult | Get-Volume).DriveLetter
    Write-Host "Mounted to $driveLetter drive!" -ForegroundColor Green
}
else {
    Write-Host "ISO file already mounted to $driveLetter drive!" -ForegroundColor Green 
}

Write-Host "Extracting WIM file..." -ForegroundColor Yellow
if (-Not (Test-Path -Path "$downloadsFolder\Install.wim")) {
    Copy-Item "${driveLetter}:\Sources\Install.wim" -Destination "$downloadsFolder\Install.wim"
    Set-ItemProperty "$downloadsFolder\Install.wim" -name IsReadOnly -value $false
    Write-Host "Complete!" -ForegroundColor Green
}
else {
    Write-Host "WIM file already exists!" -ForegroundColor Green
}

Write-Host "Dismounting the ISO..." -ForegroundColor Yellow
Dismount-DiskImage -ImagePath "$downloadsFolder\$isoFileName" > null
Write-Host "Complete!" -ForegroundColor Green

Write-Host "Mounting the WIM..." -ForegroundColor Yellow
$imageIndex = (Get-WindowsImage -ImagePath "$downloadsFolder\Install.wim" | ? { $_.ImageName -like "Windows 10 Pro" }).ImageIndex
New-Item -ItemType Directory -Force -Path "$downloadsFolder\wim" > null
Mount-WindowsImage -Path "$downloadsFolder\wim" -ImagePath "$downloadsFolder\Install.wim" -Index $imageIndex > null
Write-Host "Complete!" -ForegroundColor Green

Write-Host "Disabling optional features..." -ForegroundColor Yellow
# Get a list of optional Windows features
#Get-WindowsOptionalFeature -Path "$downloadsFolder\wim" | FT -AutoSize
$featuresToDisable = @(
    "WindowsMediaPlayer"
)
foreach ($featureName in $featuresToDisable) {
    Disable-WindowsOptionalFeature -Path "$downloadsFolder\wim" -FeatureName $featureName > null
}
Write-Host "Complete!" -ForegroundColor Green

Write-Host "Removing Provisioned Applications..." -ForegroundColor Yellow
# Get a list of povisioned apps
#Get-AppxProvisionedPackage -Path "$downloadsFolder\wim" | select Displayname | ft -AutoSize
$appsToRemove = @(
    "Microsoft.BingNews",
    "Microsoft.BingWeather",
    "Microsoft.MicrosoftOfficeHub",
    "Microsoft.MicrosoftSolitaireCollection",
    "Microsoft.MicrosoftStickyNotes",
    "Microsoft.People",
    "Microsoft.ScreenSketch",
    "Microsoft.SecHealthUI",
    "Microsoft.SkypeApp",
    "Microsoft.StorePurchaseApp",
    "Microsoft.Todos",
    "Microsoft.Windows.Photos",
    "Microsoft.WindowsAlarms",
    "Microsoft.WindowsCamera",
    "microsoft.windowscommunicationsapps",
    "Microsoft.WindowsFeedbackHub",
    "Microsoft.WindowsMaps",
    "Microsoft.Xbox.TCUI",
    "Microsoft.XboxGameOverlay",
    "Microsoft.XboxGamingOverlay",
    "Microsoft.XboxIdentityProvider",
    "Microsoft.XboxSpeechToTextOverlay",
    "Microsoft.YourPhone",
    "Microsoft.ZuneMusic",
    "Microsoft.ZuneVideo"	
)
foreach ($appName in $appsToRemove) {
    Get-AppxProvisionedPackage -Path "$downloadsFolder\wim" | ? { $_.DisplayName -like $appName } | Remove-AppxProvisionedPackage -Path "$downloadsFolder\wim" > null
}
Write-Host "Complete!" -ForegroundColor Green

Write-Host "Saving WIM file..." -ForegroundColor Yellow
Dismount-WindowsImage -Path "$downloadsFolder\wim" -save -Verbose
Remove-Item "$downloadsFolder\wim" -Force > null
Write-Host "Complete!" -ForegroundColor Green