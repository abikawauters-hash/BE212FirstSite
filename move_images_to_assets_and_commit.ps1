Set-Location -Path 'D:\LocalBE212'
Write-Host "Repository root files:"
Get-ChildItem -Path . -File | Select-Object Name | Format-Table -AutoSize

# Show git remotes if available
if (Test-Path .git) {
    Write-Host "\nGit remotes:"
    git remote -v
} else {
    Write-Host "\nNo .git folder found in repo root."
}

# Ensure assets folder exists
$assets = Join-Path (Get-Location) 'assets'
if (-not (Test-Path $assets)) { New-Item -ItemType Directory -Path $assets | Out-Null; Write-Host "Created assets/ folder" }

# Move photos and logo into assets
$patterns = @('photo*.jpg','photo*.jpeg','logo.png','logo.jpg')
foreach ($p in $patterns) {
    $items = Get-ChildItem -Path . -Filter $p -File -ErrorAction SilentlyContinue
    foreach ($it in $items) {
        $dest = Join-Path $assets $it.Name
        Move-Item -Path $it.FullName -Destination $dest -Force
        Write-Host "Moved: $($it.Name) -> assets/$($it.Name)"
    }
}

# Show assets contents
Write-Host "\nAssets folder now contains:"
Get-ChildItem -Path $assets | Select-Object Name, Length | Format-Table -AutoSize

# Commit changes if git repo
if (Test-Path .git) {
    git add .
    $status = git status --porcelain
    if ($status) {
        git commit -m "Move images into assets/ to match HTML paths" || Write-Host "No changes to commit or commit failed"
        Write-Host "Attempting to push to origin/main (may prompt for credentials)..."
        git push origin main 2>&1 | Write-Host
    } else {
        Write-Host "No changes staged for commit."
    }
} else {
    Write-Host "Not a git repo — created assets folder and moved files locally. Please commit and push to your remote repo so Vercel redeploys." 
}
