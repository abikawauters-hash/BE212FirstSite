# start-server.ps1
# Tries to start a simple static server for the current folder on port 8000.
# If Python is available it uses `python -m http.server`.
# Otherwise, if npx is available it uses `npx http-server`.
# If neither is available it prints instructions to install them via winget.

param(
    [int]$Port = 8000
)

function Start-PythonServer($port) {
    Write-Host "Starting Python HTTP server on http://localhost:$port"
    # Start in a new window so logs remain visible
    Start-Process -FilePath python -ArgumentList "-m", "http.server", "$port"
}

function Start-NodeServer($port) {
    Write-Host "Starting http-server (npx) on http://localhost:$port"
    Start-Process -FilePath npx -ArgumentList "http-server", "-p", "$port"
}

if (Get-Command python -ErrorAction SilentlyContinue) {
    Start-PythonServer -port $Port
    Write-Host "Done. Open http://localhost:$Port/run_axe_local.html in your browser."
    return
}

if (Get-Command npx -ErrorAction SilentlyContinue) {
    Start-NodeServer -port $Port
    Write-Host "Done. Open http://localhost:$Port/run_axe_local.html in your browser."
    return
}

Write-Host "Neither Python nor npx were found in PATH." -ForegroundColor Yellow
Write-Host "You can install one of them and re-run this script. Recommended quick options:"
Write-Host "  - Install Python 3:  winget install -e --id Python.Python.3"
Write-Host "  - Install Node.js (includes npx): winget install -e --id OpenJS.NodeJS"

$tryInstall = Read-Host "Do you want this script to try installing Python using winget now? (y/N)"
if ($tryInstall -ne 'y' -and $tryInstall -ne 'Y') {
    Write-Host "No installation performed. After installing, re-run this script." -ForegroundColor Cyan
    return
}

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "winget is not available on this machine. Please install Python or Node manually." -ForegroundColor Red
    return
}

Write-Host "Attempting to install Python via winget..."
winget install -e --id Python.Python.3
Write-Host "If installation completed successfully, re-run this script to start the server." -ForegroundColor Green
