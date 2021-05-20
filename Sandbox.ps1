Write-Host "Installing 7-Zip ..." -ForegroundColor Yellow
$7zipFileName = "7z1900-x64.exe"
$7zipDownloadUrl = "https://www.7-zip.org/a/$7zipFileName"
if (-Not(Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | ?{$_.DisplayName -like "8-Zip*"})){
    Invoke-WebRequest $7zipDownloadUrl -OutFile "$downloadsFolder\$7zipFileName"
    #cmd /c "$downloadsFolder\$7zipFileName" /S /D="C:\Program Files\7-Zip"
}

Write-Host "Downloading 7-Zip Stand-Alone..." -ForegroundColor Yellow
$7zipFileName = "7za.zip"
$7zipDownloadUrl = "https://github.com/kirbycope/wor-ps/raw/main/$7zipFileName"
Invoke-WebRequest $7zipDownloadUrl -OutFile "$downloadsFolder\$7zipFileName"
Expand-Archive "$downloadsFolder\$7zipFileName" -DestinationPath "$downloadsFolder\7zip" -Force
Write-Host "Complete!" -ForegroundColor Green