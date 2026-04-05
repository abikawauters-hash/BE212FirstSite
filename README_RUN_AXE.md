Run axe-core locally (Windows)

This workspace contains three HTML files:
- run_axe_local.html  — a small runner page that loads axe-core and runs a scan against a target URL.
- BE212WEBv1_refined.html — the page you want to scan.

Quick steps (recommended): serve the folder over HTTP and use the runner.

1) Download a local copy of axe-core (optional but recommended):
   Open PowerShell in this folder (d:\LocalBE212) and run:

   .\download_axe.ps1

   This will fetch `axe.min.js` into the folder so the runner can load it without depending on the CDN.

2) Start a local static server (one of these):

   Using Python 3 (recommended if installed):

```powershell
python -m http.server 8000
```

   Or using npx (Node.js):

```powershell
npx http-server -p 8000
```

   Or run the helper script which will attempt to detect Python/npx and start a server:

```powershell
.\start-server.ps1
```

3) Open the runner in Chrome:

   http://localhost:8000/run_axe_local.html

   In the "Page URL to scan" field enter:

   http://localhost:8000/BE212WEBv1_refined.html

   Click "Run scan". Results will appear in the page and you can download the JSON report.

If you prefer to open files directly (file:///), it might work but can fail due to browser security restrictions. Serving over HTTP is the most reliable.

Troubleshooting
- If the runner reports it can't load axe-core, ensure `axe.min.js` exists in this folder (downloaded) or that you have internet access for the CDN fallback.
- If iframe errors say "Permission denied" or report cross-origin issues, make sure both pages are served from the same origin (http://localhost:8000).

If you want, I can:
- modify the runner further (for example provide a dropdown of local HTML files), or
- create a one-click PowerShell that downloads axe, installs Python via winget, and starts the server (will prompt before installing).

