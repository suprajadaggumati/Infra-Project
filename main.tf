
terraform {
  required_version = ">= 1.4.0"
}

variable "web_dir" {
  type        = string
  default     = "C:/webserver"
  description = "Main web-root directory."
}

# Create the web-root directory on the machine running Terraform.
resource "terraform_data" "webserver_directory" {
  triggers_replace = [var.web_dir]

  provisioner "local-exec" {
    command     = "New-Item -ItemType Directory -Force -Path '${var.web_dir}' | Out-Null"
    interpreter = ["PowerShell", "-NoProfile", "-NonInteractive", "-Command"]
  }
}

output "webserver_path" {
  value       = var.web_dir
  description = "Location of the web-root directory."
}
