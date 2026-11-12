terraform {
  required_version = ">= 1.0.0"
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

provider "local" {}

# Input Variable for web server directory path
variable "web_dir" {
  type        = string
  default     = "C:\\webserver"
  description = "The target root directory for the webserver infrastructure."
}

# Resource to provision the base webserver directory/placeholder
resource "local_file" "create_folder" {
  filename = "${var.web_dir}\\.placeholder"
  content  = "Base webserver directory initialization placeholder"
}

# Resource to provision the logs sub-directory/placeholder
resource "local_file" "create_logs_folder" {
  filename = "${var.web_dir}\\logs\\.placeholder"
  content  = "Logs directory initialization placeholder"
}

# Output block to display the provisioned path
output "webserver_path" {
  value       = var.web_dir
  description = "The path where the web server infrastructure was initialized."
}