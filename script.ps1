# Parameters for paths
param (
    [string]$LogPath = "C:\webserver\logs\install.log",
    [string]$WebPath = "C:\webserver\index.html"
)

# 1. FUNCTION: Handles timestamped logging
function Write-CustomLog {
    param ([string]$Message)
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "[$Timestamp] $Message" | Out-File -FilePath $LogPath -Append
}

# 2. FUNCTION: Generates the HTML web page
function New-WebPage {
    $HtmlContent = "<html><body><h1>Webserver Active</h1></body></html>"
    Set-Content -Path $WebPath -Value $HtmlContent
    Write-CustomLog "Created index.html web page at $WebPath"
}

# 3. FUNCTION: Checks service health using LOOP, CONDITION, and TRY/CATCH
function Test-ServiceStatus {
    # Array of Windows services to inspect
    $Services = @("W3SVC", "Spooler")

    # LOOP: Iterate through each service in the array
    foreach ($Service in $Services) {
        try {
            $Status = Get-Service -Name $Service -ErrorAction Stop
            
            # CONDITION: Check if the service is actively running
            if ($Status.Status -eq 'Running') {
                Write-CustomLog "Service $Service is active and running cleanly."
            } else {
                Write-CustomLog "Service $Service exists but state is: $($Status.Status)."
            }
        }
        catch {
            # ERROR HANDLING: Catches non-existent services cleanly
            Write-CustomLog "Error inspecting service $Service : $_"
        }
    }
}

# --- Execution Flow ---
Write-CustomLog "Starting Automated Web Server Deployment..."
New-WebPage
Test-ServiceStatus
Write-CustomLog "Deployment & Verification Completed Successfully."