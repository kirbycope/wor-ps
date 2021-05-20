# Note: Editing the WIM file requires that this script is ran with elevated priviledges (as an Administrator)

$startTime = Get-Date

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

## TODO: Edit file so it doesnt wait to close

Write-Host "Running CMD file from UUP..." -ForegroundColor Yellow
$isoFileName = "21382.1000.210511-1436.CO_RELEASE_SVC_PROD1_CLIENTPRO_OEMRET_A64FRE_EN-US.iso"
if (-Not (Test-Path -Path "$downloadsFolder\$isoFileName")) {
    cmd /c start "$downloadsFolder\$uupFileName"
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

Write-Host "Disabling Optional Features..." -ForegroundColor Yellow
#Get-WindowsOptionalFeature -Path "$downloadsFolder\wim" | FT -AutoSize
$featuresToDisable = @(
    "WindowsMediaPlayer"
)
foreach ($featureName in $featuresToDisable) {
    Disable-WindowsOptionalFeature -Path "$downloadsFolder\wim" -FeatureName $featureName > null
}
Write-Host "Complete!" -ForegroundColor Green

Write-Host "Removing Provisioned Applications..." -ForegroundColor Yellow
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

Write-Host "Downloading Preset file..." -ForegroundColor Yellow
$031zipFileName = "0.3.1.zip"
$031zipDownloadUrl = "https://github.com/kirbycope/wor-ps/raw/main/$031zipFileName"
if (-Not (Test-Path -Path "$downloadsFolder\$031zipFileName")) {
    Invoke-WebRequest $031zipDownloadUrl -OutFile "$downloadsFolder\$031zipFileName"
    Write-Host "Complete!" -ForegroundColor Green
}
else {
    Write-Host "Preset file already exists!" -ForegroundColor Green
}

Write-Host "Extracting Presets from file..." -ForegroundColor Yellow
if (-Not (Test-Path -Path "$downloadsFolder\0.3.1")) {
    Expand-Archive "$downloadsFolder\$031zipFileName" -DestinationPath "$downloadsFolder\0.3.1" -Force
    Write-Host "Complete!" -ForegroundColor Green
}
else {
    Write-Host "Presets folder already exists!" -ForegroundColor Green
}

Write-Host "Applying presets..." -ForegroundColor Yellow
Copy-Item -Path "$downloadsFolder\0.3.1\Web" -Destination "$downloadsFolder\wim\Windows\Web" -Force > null
Write-Host "Complete!" -ForegroundColor Green

Write-Host "Removing the bloatware..." -ForegroundColor Yellow
#takeown /a /r /d Y /f "$downloadsFolder\wim" > null
Remove-Item "$downloadsFolder\wim\Windows\System32\Recovery" -Recurse > null
Remove-Item "$downloadsFolder\wim\Windows\System32\BingMaps.dll" > null
Remove-Item "$downloadsFolder\wim\Windows\SysWoW64\OneDriveSetup.exe" > null
Remove-Item "$downloadsFolder\wim\Windows\SysWoW64\BingMaps.dll" > null
Remove-Item "$downloadsFolder\wim\Windows\SysArm32\BingMaps.dll" > null
Remove-Item "$downloadsFolder\wim\Users\Default\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk" > null
Remove-Item "$downloadsFolder\wim\Program Files (x86)\Internet Explorer" -Recurse > null
Remove-Item "$downloadsFolder\wim\Program Files (Arm)\Internet Explorer" -Recurse > null
Remove-Item "$downloadsFolder\wim\Program Files (Arm)\Windows Defender" -Recurse > null
Remove-Item "$downloadsFolder\wim\Program Files (Arm)\Windows Mail" -Recurse > null
Remove-Item "$downloadsFolder\wim\Program Files\Internet Explorer" -Recurse > null
Write-Host "Complete!" -ForegroundColor Green

Write-Host "Saving WIM file..." -ForegroundColor Yellow
Dismount-WindowsImage -Path "$downloadsFolder\wim" -save > null
Write-Host "Complete!" -ForegroundColor Green

Write-Host "Cleaning up..." -ForegroundColor Yellow
Remove-Item "$downloadsFolder\$uupFileName" -Force -ErrorAction SilentlyContinue
Remove-Item "$downloadsFolder\0.3.1" -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item "$downloadsFolder\0.3.1.zip" -Force -ErrorAction SilentlyContinue
Remove-Item "$downloadsFolder\bin" -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item "$downloadsFolder\uup" -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item "$downloadsFolder\wim" -Force -Recurse -ErrorAction SilentlyContinue
Write-Host "Complete!" -ForegroundColor Green

$elapsedTime = $(get-date) - $startTime
"Total Process Time was " + "{0:HH:mm:ss}" -f ([datetime]$elapsedTime.Ticks)