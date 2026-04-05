$runner = 'http://localhost:8000/run_axe_local.html'
$target = 'http://localhost:8000/BE212WEBv1_refined.html'
$outFile = 'D:\LocalBE212\axe-report.json'

$ie = New-Object -ComObject InternetExplorer.Application
$ie.Visible = $true
$ie.Navigate($runner)
Write-Host "Navigating to runner..."

# wait for the runner page to load
while ($ie.Busy -or $ie.ReadyState -ne 4) { Start-Sleep -Milliseconds 200 }
Start-Sleep -Milliseconds 500
$doc = $ie.Document

# set the URL and click Run
try {
    $urlInput = $doc.getElementById('url')
    if ($null -eq $urlInput) { Throw 'Runner input element not found' }
    $urlInput.value = $target
    Start-Sleep -Milliseconds 200
    $runBtn = $doc.getElementById('run')
    if ($null -eq $runBtn) { Throw 'Run button not found' }
    Write-Host 'Clicking Run button...'
    $runBtn.click()
} catch {
    Write-Host "Error preparing run: $_"
    $ie.Quit()
    exit 1
}

# wait for results: poll the #summary and #output elements
$summaryText = ''
$outputText = ''
$maxWait = 90  # seconds
$elapsed = 0
while ($elapsed -lt $maxWait) {
    Start-Sleep -Seconds 1
    $elapsed += 1
    try {
        $summaryEl = $doc.getElementById('summary')
        $outputEl = $doc.getElementById('output')
        if ($summaryEl -ne $null) { $summaryText = $summaryEl.innerText }
        if ($outputEl -ne $null) { $outputText = $outputEl.innerText }
        if ($outputText -and $outputText.Trim().Length -gt 10) { break }
    } catch {
        # ignore transient errors
    }
}

if (-not $outputText -or $outputText.Trim().Length -le 10) {
    Write-Host "Timed out waiting for axe results. Summary: $summaryText"
    $ie.Quit()
    exit 2
}

# Save the JSON result
Set-Content -Path $outFile -Value $outputText -Encoding UTF8
Write-Host "Axe run completed. Summary: $summaryText"
Write-Host "Saved report to: $outFile"

# optionally show the first 400 chars
Write-Host "--- report snippet ---"
Write-Host ($outputText.Substring(0, [Math]::Min(400, $outputText.Length)))

# Keep the IE window open for a short while so user can inspect, then quit
Start-Sleep -Seconds 2
$ie.Quit()
exit 0
