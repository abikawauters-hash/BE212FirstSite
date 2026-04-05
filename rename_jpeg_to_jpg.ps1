$folder = 'D:\LocalBE212\assets'
$files = Get-ChildItem -Path $folder -Filter *.jpeg -File -ErrorAction SilentlyContinue
if(-not $files -or $files.Count -eq 0){ Write-Host 'No .jpeg files found to rename'; exit 0 }
foreach($f in $files){
    $oldName = $f.FullName
    $newName = [System.IO.Path]::ChangeExtension($oldName,'.jpg')
    $newLeaf = Split-Path $newName -Leaf
    Rename-Item -Path $oldName -NewName $newLeaf -Force
    Write-Host "Renamed: $($f.Name) -> $newLeaf"
}
Write-Host ''
Get-ChildItem -Path $folder | Select-Object Name,Length | Format-Table -AutoSize
Start-Process 'http://localhost:8000/BE212WEBv1_refined.html' -ErrorAction SilentlyContinue