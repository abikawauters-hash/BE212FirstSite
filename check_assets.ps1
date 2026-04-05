$urls = @(
  'http://localhost:8000/assets/photo1.jpg',
  'http://localhost:8000/assets/photo10.jpg',
  'http://localhost:8000/assets/photo11.jpg',
  'http://localhost:8000/BE212WEBv1_refined.html'
)
foreach($u in $urls){
  try{
    $req = [System.Net.WebRequest]::Create($u)
    $req.Method = 'HEAD'
    $resp = $req.GetResponse()
    $len = 0
    try { $len = $resp.ContentLength } catch {}
    Write-Host "$u -> HTTP $($resp.StatusCode) Length: $len"
    $resp.Close()
  } catch {
    $err = $_.Exception
    if ($err.Response -ne $null){
      $code = $err.Response.StatusCode
      Write-Host "$u -> HTTP $code (error)"
    } else {
      Write-Host "$u -> ERROR: $($err.Message)"
    }
  }
}