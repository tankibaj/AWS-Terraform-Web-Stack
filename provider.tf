terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.28.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.0.1"
    }
  }
}

# ****************************************************************
# AWS Provider
# ****************************************************************
provider "aws" {
  region                  = var.region
  shared_credentials_file = "$HOME/.aws/credentials"
}

# ****************************************************************
# Random Provider
# ****************************************************************
provider "random" {}