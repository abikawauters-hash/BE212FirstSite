param(
    [int]$Port = 55001
)

Write-Host "Starting simple TCP static server on 127.0.0.1:$Port"
Write-Host "Serving files from: $(Get-Location)"

$listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Loopback, $Port)
$listener.Start()
Write-Host "Listening... Press Ctrl+C to stop."

while ($true) {
    $client = $listener.AcceptTcpClient()
    Start-Job -ArgumentList $client -ScriptBlock {
        param($client)
        try {
            $ns = $client.GetStream()
            $reader = New-Object System.IO.StreamReader($ns)
            $requestLine = $reader.ReadLine()
            if (-not $requestLine) { $client.Close(); return }
            # Read and discard headers
            while ($true) {
                $line = $reader.ReadLine()
                if ($line -eq '') { break }
            }

            $parts = $requestLine.Split(' ')
            $path = $parts[1]
            if ($path -eq '/') { $path = '/run_axe_local.html' }
            $path = $path.TrimStart('/')
            $file = Join-Path -Path (Get-Location) -ChildPath $path
            if (-not (Test-Path $file)) {
                $body = "Not found"
                $resp = "HTTP/1.1 404 Not Found`r`nContent-Length: $($body.Length)`r`nContent-Type: text/plain; charset=utf-8`r`nConnection: close`r`n`r`n$body"
                $buf = [System.Text.Encoding]::UTF8.GetBytes($resp)
                $ns.Write($buf,0,$buf.Length)
                $ns.Flush()
                $client.Close()
                return
            }

            $ext = [IO.Path]::GetExtension($file).ToLower()
            switch ($ext) {
                '.html' { $ct = 'text/html; charset=utf-8' }
                '.htm'  { $ct = 'text/html; charset=utf-8' }
                '.js'   { $ct = 'application/javascript' }
                '.css'  { $ct = 'text/css' }
                '.json' { $ct = 'application/json' }
                '.png'  { $ct = 'image/png' }
                '.jpg'  { $ct = 'image/jpeg' }
                '.jpeg' { $ct = 'image/jpeg' }
                '.svg'  { $ct = 'image/svg+xml' }
                default { $ct = 'application/octet-stream' }
            }

            $bytes = [System.IO.File]::ReadAllBytes($file)
            $hdr = "HTTP/1.1 200 OK`r`nContent-Length: $($bytes.Length)`r`nContent-Type: $ct`r`nConnection: close`r`n`r`n"
            $hdrBytes = [System.Text.Encoding]::ASCII.GetBytes($hdr)
            $ns.Write($hdrBytes,0,$hdrBytes.Length)
            $ns.Write($bytes,0,$bytes.Length)
            $ns.Flush()
            $client.Close()
        } catch {
            try { $client.Close() } catch {}
        }
    } | Out-Null
}
