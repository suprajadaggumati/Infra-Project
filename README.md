# Local Web-Root Automation

## Project overview

This project demonstrates local infrastructure and configuration automation on Windows. Terraform creates a configurable web-root directory on the machine where Terraform runs. A PowerShell script uses Desired State Configuration (DSC) to ensure that the web-root directory, its logs directory, and an HTML page are present.

The project creates an HTML file; it does **not** install or start IIS or another web server, so the page is not served over HTTP.

## Technologies and prerequisites

- Windows
- Terraform CLI (version 1.4 or later; `terraform_data` is used)
- Windows PowerShell 5.1
- Administrator permissions to apply the local DSC configuration
- Git

## Project files

```text
.
|-- main.tf       # Terraform directory creation, variable, and output
|-- script.ps1    # PowerShell preflight checks and DSC configuration
|-- README.md     # Project documentation
|-- .gitignore    # Excludes local state and generated files
`-- .terraform.lock.hcl
```

Terraform creates local working data in `.terraform` and state files. The PowerShell script compiles its DSC MOF files into `DSC_Output`. These generated files should not be submitted or committed; `.gitignore` excludes them. `.terraform.lock.hcl` is retained from the earlier local-provider configuration; the current `main.tf` uses Terraform's built-in `terraform_data` resource and does not require an external provider.

## How it works

1. `main.tf` declares the `web_dir` variable, which defaults to `C:/webserver`.
2. The built-in `terraform_data` resource runs a local PowerShell command to create the web-root directory. It is replaced and runs again if `web_dir` changes.
3. The `webserver_path` output displays the configured directory.
4. `script.ps1` accepts `BasePath` (default `C:\webserver`) and checks that it is not blank.
5. `Initialize-DirectoryStructure` loops over the web root and its `logs` directory and reports whether each already exists.
6. The DSC configuration ensures the web root, `logs` directory, and `index.html` exist, then applies the configuration to `localhost`.
7. The script checks that `index.html` exists after DSC completes. Errors are reported and the script exits unsuccessfully.

Terraform uses a local-exec provisioner to create a directory. Provisioners run commands on the machine executing Terraform; this is a small educational example rather than a cloud or remote infrastructure deployment.

## Run the project

Run these commands from the repository directory in PowerShell:

```powershell
terraform init
terraform validate
terraform plan
terraform apply
```

Review the Terraform plan and confirm the apply when prompted. Then open **Windows PowerShell 5.1 as Administrator** and run the DSC script:

```powershell
.\script.ps1
```

Both tools default to `C:\webserver`. To use another directory, provide the same path to Terraform and the script:

```powershell
$WebRoot = 'C:\webserver-test'
terraform apply -var="web_dir=$WebRoot"
.\script.ps1 -BasePath $WebRoot
```

Verify the result:

```powershell
Test-Path 'C:\webserver'
Test-Path 'C:\webserver\logs'
Get-Content 'C:\webserver\index.html'
terraform output webserver_path
```

The `Test-Path` commands should return `True`, and `Get-Content` should display the generated HTML.

## Expected result

With the default path, the project creates:

```text
C:\webserver\
|-- index.html
`-- logs\
```

The DSC configuration files are compiled under the repository's `DSC_Output` directory.

## Assignment requirements

- **PowerShell:** The script includes a parameter, function, loop, conditions, DSC configuration, error handling, and a post-apply check.
- **Terraform:** The configuration uses a `web_dir` input variable and a `webserver_path` output.
- **README:** Documents the project purpose, tools, workflow, expected result, limitations, and AI assistance.
- **VG extras:** No Python script or Ansible playbook is included. These are extras for VG in the supplied project specification, not listed as required files for G.

## Limitations and testing

This is local web-root filesystem automation, not a running web-server deployment. It does not install a server, expose the page over HTTP, or verify an HTTP response. Terraform's local-exec command runs on the machine executing Terraform and requires PowerShell to be available there. DSC application should be tested in an elevated PowerShell session.

`terraform validate`, `terraform fmt -check`, and PowerShell syntax parsing are non-destructive checks. A full end-to-end test requires running Terraform and DSC on the Windows machine where the project will be demonstrated, then checking that the expected paths and files exist.

## Reflection

The project uses Terraform to provision the base directory and DSC to describe and apply the desired local filesystem state. This demonstrates how IaC and configuration management can complement each other. A future extension could install and configure a real web server and verify it through an HTTP health check.

## AI and external sources

AI assistance was used to review the project requirements and help with parts of the PowerShell script and README. The project author should review, test, and be able to explain all submitted code. No other external code sources are documented here.

## GitHub repository

[https://github.com/suprajadaggumati/Infra-Project](https://github.com/suprajadaggumati/Infra-Project)
