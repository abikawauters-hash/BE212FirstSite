# download_axe.ps1
# Downloads a local copy of axe-core (minified) into the current folder as axe.min.js
# Usage: run this from the folder containing your HTML files.

$axeUrl = 'https://unpkg.com/axe-core@4.8.4/axe.min.js'
$outFile = Join-Path -Path (Get-Location) -ChildPath 'axe.min.js'

Write-Host "Downloading $axeUrl to $outFile ..."
try {
    Invoke-WebRequest -Uri $axeUrl -OutFile $outFile -UseBasicParsing -ErrorAction Stop
    Write-Host "Downloaded axe.min.js"
} catch {
    Write-Host "Failed to download axe-core: $_" -ForegroundColor Red
    Write-Host "If you are offline, you can manually download $axeUrl in a browser and save it as axe.min.js in this folder."
}
