
terraform {
  required_version = ">= 1.4.0"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

provider "local" {}

# Main webserver directory
variable "web_dir" {
  type        = string
  default     = "C:/webserver"
  description = "Main directory for the webserver."
}

# Create the webserver directory
resource "terraform_data" "webserver_directory" {
  provisioner "local-exec" {
    command = "New-Item -ItemType Directory -Force -Path '${var.web_dir}'"
    interpreter = ["PowerShell", "-Command"]
  }
}

# Display the webserver directory path
output "webserver_path" {
  value       = var.web_dir
  description = "Location of the webserver directory."
}
