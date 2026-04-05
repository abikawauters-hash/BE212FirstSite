# Copy WhatsApp images and BE212LOGO from Downloads into project assets with site filenames
New-Item -ItemType Directory -Path 'D:\LocalBE212\assets' -Force | Out-Null
$files = Get-ChildItem -Path "$env:USERPROFILE\Downloads" -Include 'WhatsApp Image*.jpeg','WhatsApp Image*.jpg','WhatsApp Image*.png','BE212LOGO.*' -File -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending
if(-not $files -or $files.Count -eq 0){ Write-Host "No matching WhatsApp/BE212 images found in Downloads"; exit 0 }
$i = 1
foreach($f in $files){
    if($f.Name -match 'BE212LOGO'){
        Copy-Item -Path $f.FullName -Destination 'D:\LocalBE212\assets\logo.png' -Force
        Write-Host "Copied logo: $($f.Name) -> assets\logo.png"
        continue
    }
    $ext = $f.Extension.ToLower()
    $dest = "D:\LocalBE212\assets\photo$($i)$ext"
    Copy-Item -Path $f.FullName -Destination $dest -Force
    Write-Host "Copied: $($f.Name) -> assets\photo$($i)$ext"
    $i++
}
Write-Host "\nAssets folder contents:"
Get-ChildItem -Path 'D:\LocalBE212\assets' | Select-Object Name, Length | Format-Table -AutoSize