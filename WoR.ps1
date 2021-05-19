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
if (-Not $driveLetter){
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
    Write-Host "Complete!" -ForegroundColor Green
}
else {
    Write-Host "WIM file already exists!" -ForegroundColor Green
}

Write-Host "Dismounting the ISO..." -ForegroundColor Yellow
$dismountResult = Dismount-DiskImage -ImagePath "$downloadsFolder\$isoFileName"
Write-Host "Complete!" -ForegroundColor Green

Write-Host "Downloading NTLite..." -ForegroundColor Yellow
$ntLiteFileName = "NTLite_setup_x64.exe"
$ntLiteDownloadUrl = "https://downloads.ntlite.com/files/NTLite_setup_x64.exe"
if (-Not (Test-Path -Path "$downloadsFolder\$ntLiteFileName")) {
    Invoke-WebRequest $ntLiteDownloadUrl -OutFile "$downloadsFolder\$ntLiteFileName"
    Write-Host "Complete!" -ForegroundColor Green
}
else {
    Write-Host "NTLite file already exists!" -ForegroundColor Green
}

# todo get the preset
# Note, NTLite doesn't have a silent install?
# "C:\Program Files\NTLite\NTLite.exe"