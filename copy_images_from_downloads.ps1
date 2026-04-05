$dl = Get-ChildItem -Path "$env:USERPROFILE\Downloads" -Include *.jpg,*.jpeg,*.png -File | Sort-Object LastWriteTime -Descending | Select-Object -First 12
if(-not $dl -or $dl.Count -eq 0){ Write-Host "No images found in Downloads"; exit 0 }
New-Item -ItemType Directory -Path "D:\LocalBE212\assets" -Force | Out-Null
$i=1
foreach($f in $dl){
    $dest = "D:\LocalBE212\assets\photo$($i).jpg"
    Copy-Item -Path $f.FullName -Destination $dest -Force
    Write-Host "Copied: $($f.Name) -> assets\photo$($i).jpg"
    $i++
}
$logo = $dl | Where-Object { $_.Name -match 'logo|be212' } | Select-Object -First 1
if(-not $logo){ $logo = $dl[0] }
Copy-Item -Path $logo.FullName -Destination "D:\LocalBE212\assets\logo.png" -Force
Write-Host "Copied: $($logo.Name) -> assets\logo.png"
Start-Process "http://localhost:8000/run_axe_local.html"