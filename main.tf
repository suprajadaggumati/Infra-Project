terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

provider "local" {}

# Creates the main webserver directory
resource "local_file" "create_folder" {
  filename = "C:\\webserver\\.placeholder"
  content  = "Directory initialization placeholder"
}

# Creates the logs directory
resource "local_file" "create_logs_folder" {
  filename = "C:\\webserver\\logs\\.placeholder"
  content  = "Logs directory initialization placeholder"
}