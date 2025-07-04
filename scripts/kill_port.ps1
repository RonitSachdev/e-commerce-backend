param(
    [Parameter(Mandatory=$true)]
    [int]$Port
)

Write-Host "Looking for processes using port $Port..."

$processIds = @()
$connections = netstat -ano | findstr ":$Port"

if ($connections) {
    # Extract PIDs using regex
    $connections | ForEach-Object {
        if ($_ -match "LISTENING\s+(\d+)") {
            $processIds += $matches[1]
        }
    }

    # Remove duplicates
    $processIds = $processIds | Select-Object -Unique

    if ($processIds.Count -gt 0) {
        foreach ($processId in $processIds) {
            $process = Get-Process -Id $processId -ErrorAction SilentlyContinue
            if ($process) {
                Write-Host "Killing process: $($process.ProcessName) (PID: $processId)"
                taskkill /PID $processId /F
            }
        }
        Write-Host "Successfully killed all processes using port $Port"
    } else {
        Write-Host "No LISTENING processes found on port $Port"
    }
} else {
    Write-Host "No processes found using port $Port"
} 