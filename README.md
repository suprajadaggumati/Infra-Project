# Local Web-Root Automation

## Project overview

This project demonstrates local infrastructure and configuration automation on Windows. Terraform uses the HashiCorp `local` provider to create placeholder files in a web-root directory. A PowerShell script uses Desired State Configuration (DSC) to ensure that the web-root directory, its logs directory, and an HTML page are present.

The project creates an HTML file; it does **not** install or start IIS or another web server, so the page is not served over HTTP.

## Technologies and prerequisites

- Windows
- Terraform CLI (version 1.0 or later)
- Windows PowerShell 5.1
- Administrator permissions to apply the local DSC configuration
- Git

Terraform downloads the `hashicorp/local` provider during initialization. The DSC configuration uses the `PSDesiredStateConfiguration` module available in Windows PowerShell.

## Project files

```text
.
|-- main.tf               # Terraform provider, variable, local files, and output
|-- script.ps1            # PowerShell function, preflight checks, and DSC configuration
|-- README.md             # Project documentation
|-- .gitignore            # Excludes local Terraform working data
`-- .terraform.lock.hcl   # Locks the Terraform provider version
```

Terraform also creates a `.terraform` working directory and a state file when initialized and applied. These are local working data and should not be committed. Keep `.terraform.lock.hcl` in Git so provider selections are reproducible.

## How it works

1. `main.tf` declares the `hashicorp/local` provider and requires Terraform 1.0 or later.
2. The `web_dir` input variable sets the target directory; its default is `C:\webserver`.
3. Two `local_file` resources create placeholder files in the web root and its `logs` subdirectory.
4. The `webserver_path` output displays the configured web-root path.
5. `script.ps1` accepts `DestinationPath` (default `C:\webserver`) and rejects an empty value.
6. The `Initialize-DirectoryStructure` function loops through the web root, `logs`, and `dsc` paths and reports whether each already exists. It does not create these directories; DSC creates the desired directories.
7. The script compiles and applies the `WebServerConfig` DSC configuration for `localhost`. DSC ensures the root directory, logs directory, and `index.html` file are present.
8. The script checks whether `index.html` exists after the apply and reports an error if it does not.

## Run the project

From the repository directory, initialize and validate Terraform, then apply it:

```powershell
terraform init
terraform validate
terraform apply
```

Review the plan and enter `yes` when prompted. Then open **Windows PowerShell 5.1 as Administrator** and run the DSC script:

```powershell
.\script.ps1
```

Terraform and DSC both default to `C:\webserver`. To use another directory, provide the same path to both:

```powershell
$WebRoot = 'C:\webserver-test'
terraform apply -var="web_dir=$WebRoot"
.\script.ps1 -DestinationPath $WebRoot
```

Check the result:

```powershell
Test-Path 'C:\webserver\logs'
Get-Content 'C:\webserver\index.html'
terraform output webserver_path
```

`Test-Path` should return `True`, and `Get-Content` should display the generated HTML.

## Expected files

With the default path, the project creates:

```text
C:\webserver\
|-- .placeholder
|-- index.html
|-- dsc\
`-- logs\
    `-- .placeholder
```

Terraform creates the placeholder files. The PowerShell script compiles a local DSC MOF under `dsc` and applies the configuration that creates or maintains the directories and `index.html`.

## Assignment requirements and current status

- **PowerShell script:** Present. It accepts a parameter, validates it, defines and calls a function, uses a loop and conditions, applies DSC, handles errors, and checks for the generated page.
- **Terraform:** Present. `main.tf` defines the `web_dir` input variable and `webserver_path` output.
- **README:** Describes the project's goal, method, result, structure, limitations, and reflection, and includes the GitHub link.
- **VG extras:** No Python script or Ansible playbook is included. These are listed as extra files for VG in the supplied project specification, not the required G files.

## Limitations and verification

This is a local filesystem automation demonstration, not a complete web server deployment. The script checks that `index.html` exists after applying DSC; it does not run `Test-DscConfiguration` or check an HTTP endpoint. Terraform's local provider manages files on the machine where Terraform runs.

Terraform validation, formatting, PowerShell syntax parsing, and DSC configuration compilation can be checked without applying changes. A full end-to-end test still requires running `terraform apply` and `script.ps1` on the intended Windows machine, then confirming the files and DSC result. Apply DSC only in an elevated PowerShell session.

## Reflection

The project separates filesystem provisioning from configuration management: Terraform creates the initial placeholder files and DSC declares the desired web-root content. This keeps the example small and makes the roles of the two tools visible. A future extension could add a web server and an HTTP health check.

## AI and external sources

AI assistance was used to review the project requirements and help draft the DSC configuration and documentation. The project author is responsible for reviewing, testing, and understanding all submitted code. No other external code sources are documented here.

## GitHub repository

[https://github.com/suprajadaggumati/Infra-Project](https://github.com/suprajadaggumati/Infra-Project)
