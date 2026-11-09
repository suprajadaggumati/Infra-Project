param(
    [string]$ServerName = "W3SVC",
    [string]$LogPath = "C:\webserver\logs\install.log"
)

# Function 1: Write messages with timestamps to a log file
function Write-CustomLog {
    param ([string]$Message)
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogEntry = "[$Timestamp] $Message"
    Add-Content -Path $LogPath -Value $LogEntry
    Write-Host $LogEntry -ForegroundColor Cyan
}

# Function 2: Create a simple HTML index file in our webserver folder
function New-WebPage {
    param ([string]$Path)
    try {
        $HtmlContent = "<html><body><h1>Hello from Automated Infra Project!</h1></body></html>"
        Set-Content -Path "$Path\index.html" -Value $HtmlContent -ErrorAction Stop
        Write-CustomLog "Successfully created index.html web page."
    }
    catch {
        Write-CustomLog "ERROR: Could not create web page. Details: $_"
    }
}

# Function 3: Check the status of a Windows service using Try/Catch error handling
function Test-ServiceStatus {
    param ([string]$ServiceName)
    try {
        $Service = Get-Service -Name $ServiceName -ErrorAction Stop
        Write-CustomLog "Service '$ServiceName' status is: $($Service.Status)"
    }
    catch {
        Write-CustomLog "ERROR: Failed to find service '$ServiceName'. Details: $_"
    }
}

# --- Execution Flow ---
Write-CustomLog "Starting PowerShell infrastructure script..."

# Run Function 2
New-WebPage -Path "C:\webserver"

# Run Function 3
Test-ServiceStatus -ServiceName $ServerName

Write-CustomLog "Script execution completed successfully."