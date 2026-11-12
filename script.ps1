param(
    [string]$DestinationPath = "C:\webserver"
)

# PowerShell function
function Initialize-DirectoryStructure {
    param([string]$BasePath)
    
    # An array of target directories required for the web server setup
    $targetDirectories = @(
        $BasePath,
        "$BasePath\logs",
        "$BasePath\dsc"
    )

    Write-Host "Starting pre-flight directory validation..." -ForegroundColor Yellow

    #  A meaningful loop that iterates through and checks paths
    foreach ($dir in $targetDirectories) {
        if (-not (Test-Path $dir)) {
            Write-Host "Target directory verified for creation: $dir" -ForegroundColor Cyan
        } else {
            Write-Host "Target directory already present: $dir" -ForegroundColor DarkCyan
        }
    }
}

# Execute the function
Initialize-DirectoryStructure -BasePath $DestinationPath

try {
    # Define the DSC Configuration block
    Configuration WebServerConfig {
        Import-DscResource -ModuleName PsDesiredStateConfiguration

        Node "localhost" {
            # 1. Ensure the main webserver directory exists
            File WebServerDirectory {
                Ensure          = "Present"
                Type            = "Directory"
                DestinationPath = $DestinationPath
            }

            # 2. Ensure the logs directory exists
            File LogsDirectory {
                Ensure          = "Present"
                Type            = "Directory"
                DestinationPath = "$DestinationPath\logs"
                DependsOn       = "[File]WebServerDirectory"
            }

            # 3. Ensure the index.html file exists with correct content
            File WebPageFile {
                Ensure          = "Present"
                Type            = "File"
                DestinationPath = "$DestinationPath\index.html"
                Contents        = "<html><body><h1>Webserver Active via PowerShell DSC</h1></body></html>"
                DependsOn       = "[File]WebServerDirectory"
            }
        }
    }

    # Compile the configuration to generate the MOF file
    WebServerConfig -OutputPath "$DestinationPath\dsc"

    # Apply the DSC configuration to the system
    Start-DscConfiguration -Path "$DestinationPath\dsc" -Wait -Verbose -Force
    
    # Verification step
    if (Test-Path "$DestinationPath\index.html") {
        Write-Host "DSC Configuration applied and verified successfully." -ForegroundColor Green
    } else {
        throw "Verification failed: index.html was not found after apply."
    }
}
catch {
    Write-Error "An error occurred during DSC configuration: $_"
    exit 1
}