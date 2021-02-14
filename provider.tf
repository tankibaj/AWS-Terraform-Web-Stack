terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      /* version = "~> 3.27.0" */
    }
    random = {
      source = "hashicorp/random"
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