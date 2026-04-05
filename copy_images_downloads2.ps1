# Robust copy script: find WhatsApp images and BE212LOGO in Downloads and copy into project assets
$srcFolder = "$env:USERPROFILE\Downloads"
$destFolder = 'D:\LocalBE212\assets'
New-Item -ItemType Directory -Path $destFolder -Force | Out-Null
$files = Get-ChildItem -Path $srcFolder -File | Where-Object { $_.Name -imatch 'WhatsApp Image' -or $_.Name -imatch 'BE212LOGO' } | Sort-Object LastWriteTime -Descending
if(-not $files -or $files.Count -eq 0){ Write-Host "No matching WhatsApp/BE212 images found in Downloads"; exit 0 }
$i = 1
foreach($f in $files){
    if($f.Name -imatch 'BE212LOGO'){
        Copy-Item -Path $f.FullName -Destination (Join-Path $destFolder 'logo.png') -Force
        Write-Host "Copied logo: $($f.Name) -> assets\\logo.png"
        continue
    }
    $ext = $f.Extension.ToLower()
    $dest = Join-Path $destFolder ("photo{0}{1}" -f $i, $ext)
    Copy-Item -Path $f.FullName -Destination $dest -Force
    Write-Host "Copied: $($f.Name) -> assets\\$(Split-Path $dest -Leaf)"
    $i++
}
Write-Host "\nAssets folder contents:"
Get-ChildItem -Path $destFolder | Select-Object Name, Length | Format-Table -AutoSize
Start-Process 'http://localhost:8000/run_axe_local.html' -ErrorAction SilentlyContinue