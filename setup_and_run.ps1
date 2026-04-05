<#
setup_and_run.ps1

One-click helper for Windows (PowerShell):
- Downloads axe.min.js into the current folder if not present.
- Ensures Python is available (offers to install via winget if missing).
- Starts a Python static server on the chosen port (default 8000) in a new console window.
- Opens the runner page in the default browser.

Run from the folder containing your HTML files:
  .\setup_and_run.ps1

Notes:
- This script may call winget to install Python if you agree. winget must be available for automatic install.
- If your system blocks script execution, run PowerShell as the current user with:
    powershell -ExecutionPolicy Bypass -File .\setup_and_run.ps1
#>

param(
    [int]$Port = 8000
)

function Write-Info($m) { Write-Host $m -ForegroundColor Cyan }
function Write-OK($m) { Write-Host $m -ForegroundColor Green }
function Write-Err($m) { Write-Host $m -ForegroundColor Red }

function Download-Axe {
    $out = Join-Path -Path (Get-Location) -ChildPath 'axe.min.js'
    if (Test-Path $out) {
        Write-Info "axe.min.js already exists in this folder. Skipping download."
        return $true
    }

    $url = 'https://unpkg.com/axe-core@4.8.4/axe.min.js'
    Write-Info "Downloading axe-core from $url ..."
    try {
        Invoke-WebRequest -Uri $url -OutFile $out -UseBasicParsing -ErrorAction Stop
        Write-OK "Downloaded axe.min.js"
        return $true
    } catch {
        Write-Err "Failed to download axe-core: $_"
        Write-Info "If you are offline, download $url in a browser and save it as axe.min.js in this folder."
        return $false
    }
}

function Ensure-Python {
    if (Get-Command python -ErrorAction SilentlyContinue) {
        Write-Info "Python is available."
        return $true
    }

    Write-Host "Python 3 was not found on PATH." -ForegroundColor Yellow
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Err "winget is not available, so this script cannot auto-install Python."
        Write-Info "Please install Python 3 (from https://www.python.org/) or install Node.js and use npx http-server as an alternative."
        return $false
    }

    $ans = Read-Host "Install Python 3 now using winget? (y/N)"
    if ($ans -ne 'y' -and $ans -ne 'Y') {
        Write-Info "Skipping automatic installation. You can install Python and re-run this script."
        return $false
    }

    Write-Info "Installing Python via winget (this may require network and take a few minutes)..."
    try {
        winget install -e --id Python.Python.3
    } catch {
        Write-Err "winget install failed: $_"
        return $false
    }

    # give the system a moment to update PATH in new shells; re-check
    Start-Sleep -Seconds 2
    if (Get-Command python -ErrorAction SilentlyContinue) {
        Write-OK "Python installed successfully."
        return $true
    }

    Write-Info "Python may have been installed but is not yet available in this session's PATH. Close and re-open PowerShell and re-run this script, or run python with its full path."
    return $false
}

function Start-Server($port) {
    Write-Info "Starting Python HTTP server on port $port in a new window..."
    try {
        $proc = Start-Process -FilePath python -ArgumentList "-m","http.server","$port" -WindowStyle Normal -PassThru
        Start-Sleep -Milliseconds 500
        Write-OK "Server started (PID $($proc.Id))."
        return $proc.Id
    } catch {
        Write-Err "Failed to start Python server: $_"
        return $null
    }
}

function Open-Runner($port) {
    $u = "http://localhost:$port/run_axe_local.html"
    Write-Info "Opening $u in your default browser..."
    Start-Process $u
}

# --- main
Write-Host "One-click setup: download axe, ensure Python, start server, open runner." -ForegroundColor Magenta

$downloaded = Download-Axe
if (-not $downloaded) {
    $cont = Read-Host "Download failed. Continue anyway (if you have axe.min.js already)? (y/N)"
    if ($cont -ne 'y' -and $cont -ne 'Y') { Write-Err "Aborting."; exit 1 }
}

$hasPy = Ensure-Python
if (-not $hasPy) {
    $tryAlt = Read-Host "Would you like to try using npx http-server instead? (requires Node.js and npx) (y/N)"
    if ($tryAlt -eq 'y' -or $tryAlt -eq 'Y') {
        if (Get-Command npx -ErrorAction SilentlyContinue) {
            Write-Info "Starting npx http-server on port $Port..."
            Start-Process -FilePath npx -ArgumentList "http-server","-p","$Port"
            Start-Sleep -Milliseconds 500
            Open-Runner -port $Port
            exit 0
        } else {
            Write-Err "npx not found. Please install Node.js or install Python and re-run this script."
            exit 1
        }
    }
    Write-Err "Cannot continue without a static server. Exiting."; exit 1
}

$pid = Start-Server -port $Port
if ($pid) { Open-Runner -port $Port }

Write-Host "Done. To stop the server, close the server console window or run: taskkill /PID <pid> /F" -ForegroundColor Cyan
