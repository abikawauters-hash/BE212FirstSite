param(
    [int]$Port = 8000
)

Add-Type -AssemblyName System.Net.HttpListener
$listener = New-Object System.Net.HttpListener
$prefix = "http://localhost:$Port/"
$listener.Prefixes.Add($prefix)

try {
    $listener.Start()
} catch {
    Write-Host "Failed to start HttpListener. Try running PowerShell as Administrator or choose a different port." -ForegroundColor Red
    throw
}

Write-Host "Simple PowerShell static server listening on $prefix"
Write-Host "Serving files from: $(Get-Location)"
Write-Host "Press Ctrl+C or close this window to stop."

while ($listener.IsListening) {
    try {
        $context = $listener.GetContext()
    } catch {
        break
    }

    Start-Job -ScriptBlock {
        param($context)
        $req = $context.Request
        $resp = $context.Response
        try {
            $path = $req.Url.LocalPath.TrimStart('/')
            if ([string]::IsNullOrEmpty($path)) { $path = 'index.html' }
            $file = Join-Path -Path (Get-Location) -ChildPath $path

            if (-not (Test-Path $file)) {
                $resp.StatusCode = 404
                $resp.ContentType = 'text/plain'
                $buf = [System.Text.Encoding]::UTF8.GetBytes("Not found: $path")
                $resp.OutputStream.Write($buf,0,$buf.Length)
                $resp.Close()
                return
            }

            switch ([IO.Path]::GetExtension($file).ToLower()) {
                '.html' { $ct = 'text/html' }
                '.htm'  { $ct = 'text/html' }
                '.js'   { $ct = 'application/javascript' }
                '.css'  { $ct = 'text/css' }
                '.json' { $ct = 'application/json' }
                '.png'  { $ct = 'image/png' }
                '.jpg'  { $ct = 'image/jpeg' }
                '.jpeg' { $ct = 'image/jpeg' }
                '.svg'  { $ct = 'image/svg+xml' }
                default { $ct = 'application/octet-stream' }
            }

            $resp.ContentType = $ct
            $bytes = [System.IO.File]::ReadAllBytes($file)
            $resp.ContentLength64 = $bytes.Length
            $resp.OutputStream.Write($bytes,0,$bytes.Length)
            $resp.Close()
        } catch {
            try { $resp.StatusCode = 500; $resp.Close() } catch {}
        }
    } -ArgumentList $context | Out-Null
}

$listener.Stop()
Write-Host "Server stopped." -ForegroundColor Yellow
