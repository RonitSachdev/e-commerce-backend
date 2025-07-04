# Stop any running Go processes
Write-Host "Stopping Go processes..."
Get-Process | Where-Object { $_.ProcessName -match "^go$" } | ForEach-Object {
    Write-Host "Killing Go process: $($_.Id)"
    Stop-Process -Id $_.Id -Force
}

# Get port from .env file
$envContent = Get-Content ../.env -ErrorAction SilentlyContinue
$port = 8080 # default port

if ($envContent) {
    $portLine = $envContent | Where-Object { $_ -match "^PORT=" }
    if ($portLine -match "^PORT=(\d+)") {
        $port = $matches[1]
    }
}

Write-Host "Cleaning up port $port..."
# Kill processes using the port
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
& "$scriptPath\kill_port.ps1" -Port $port

Write-Host "Server stopped successfully" 