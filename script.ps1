# Parameters
param (
    [string]$LogPath = "C:\webserver\logs\install.log",
    [string]$WebPath = "C:\webserver\index.html"
)

# 1. Function with parameter: Logging
function Write-CustomLog {
    param (
        [string]$Message
    )
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "[$Timestamp] $Message" | Out-File -FilePath $LogPath -Append
}

# 2. Function with parameter: Webpage creation
function New-WebPage {
    param (
        [string]$FilePath
    )
    $HtmlContent = "<html><body><h1>Webserver Active</h1><p>Automated deployment completed successfully.</p></body></html>"
    Set-Content -Path $FilePath -Value $HtmlContent
    Write-CustomLog -Message "Created web page at $FilePath"
}

# 3. Function with parameter: Service status verification (Loop + Condition + Try/Catch)
function Test-ServiceStatus {
    param (
        [string[]]$ServiceList
    )
    
    # LOOP: Iterate through each service in the array
    foreach ($Service in $ServiceList) {
        try {
            # Attempt to retrieve service status
            $Status = Get-Service -Name $Service -ErrorAction Stop
            
            # CONDITION: Check if service is running or stopped
            if ($Status.Status -eq 'Running') {
                Write-CustomLog -Message "Service check: $Service is currently RUNNING."
            } else {
                Write-CustomLog -Message "Service check: $Service exists but is $($Status.Status)."
            }
        }
        catch {
            # FELHANTERING: Catch non-existent services or access permissions errors
            Write-CustomLog -Message "Service check ERROR: Could not query service '$Service'. Details: $_"
        }
    }
}

# --- Execution Flow ---
Write-CustomLog -Message "Starting automation pipeline..."

# Run function to create web page
New-WebPage -FilePath $WebPath

# Run function to test services
$ServicesToTest = @("W3SVC", "Spooler", "FakeTestService")
Test-ServiceStatus -ServiceList $ServicesToTest

Write-CustomLog -Message "Automation script execution finished successfully."