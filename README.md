# ITINF25 Infrastructure Project: Local Web Server Automation

## Project Overview
This project automates the deployment of a local web server environment using an **Infrastructure as Code (IaC)** pipeline combining **Terraform** and **PowerShell**.

## Architecture & Workflow
1. **Terraform (`main.tf`)**: Provisions the core folder structure (`C:\webserver` and `C:\webserver\logs`) on the local machine using the local provider.
2. **PowerShell (`script.ps1`)**: Performs system administration tasks, including:
   - Dynamic logging with custom timestamps (`Write-CustomLog`).
   - Automated HTML web page generation (`New-WebPage`).
   - Windows service health monitoring with `try/catch` error handling (`Test-ServiceStatus`).

## How to Run the Project
1. **Provision Infrastructure:**
```powershell
   terraform init
   terraform apply
    terraform ok