
param (
    [string]$BasePath = "C:\webserver"
)

$ErrorActionPreference = "Stop"

# Check that the base path is provided
if ([string]::IsNullOrWhiteSpace($BasePath)) {
    throw "Base path cannot be empty."
}

# Check the required directories
function Initialize-DirectoryStructure {
    param (
        [string]$TargetPath
    )

    Write-Host "Checking webserver directories..." -ForegroundColor Cyan

    $directories = @(
        $TargetPath,
        (Join-Path $TargetPath "logs")
    )

    foreach ($dir in $directories) {
        if (Test-Path -LiteralPath $dir -PathType Container) {
            Write-Host "Directory already exists: $dir" -ForegroundColor Green
        }
        else {
            Write-Host "Directory will be created by DSC: $dir" -ForegroundColor Yellow
        }
    }
}

# Define the DSC configuration
Configuration WebServerConfig {
    param (
        [string]$BasePath
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration

    Node "localhost" {

        # Create the main webserver folder
        File WebRootFolder {
            Ensure          = "Present"
            Type            = "Directory"
            DestinationPath = $BasePath
        }

        # Create the logs folder
        File LogsFolder {
            Ensure          = "Present"
            Type            = "Directory"
            DestinationPath = "$BasePath\logs"
            DependsOn       = "[File]WebRootFolder"
        }

        # Create the website index file
        File IndexFile {
            Ensure          = "Present"
            Type            = "File"
            DestinationPath = "$BasePath\index.html"
            Contents        = "<html><body><h1>Welcome to ITINF25 Infrastructure Project</h1></body></html>"
            DependsOn       = "[File]WebRootFolder"
        }
    }
}

try {
    # Check the directory structure
    Initialize-DirectoryStructure -TargetPath $BasePath

    # Compile the DSC configuration
    $OutputDirectory = Join-Path $PSScriptRoot "DSC_Output"

    Write-Host "Compiling DSC configuration..." -ForegroundColor Cyan

    WebServerConfig -BasePath $BasePath -OutputPath $OutputDirectory

    # Apply the configuration
    Write-Host "Applying DSC configuration..." -ForegroundColor Cyan

    Start-DscConfiguration -Path $OutputDirectory -Wait -Verbose -Force

    # Verify that the index file exists
    $IndexPath = Join-Path $BasePath "index.html"

    if (-not (Test-Path -LiteralPath $IndexPath -PathType Leaf)) {
        throw "Verification failed: index.html was not created."
    }

    Write-Host "DSC configuration completed successfully!" -ForegroundColor Green
}
catch {
    [Console]::Error.WriteLine("Configuration failed: $($_.Exception.Message)")
    exit 1
}
