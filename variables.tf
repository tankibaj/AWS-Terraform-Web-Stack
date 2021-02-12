variable "region" {
  description = "Define a variable for AWS region"
  type        = string
  default     = "eu-central-1"
}

variable "environment" {
  description = "Map of environment names to configuration"
  type        = map(any)
  default = {
    production = {
      instance_count = 2,
      instance_type  = "t2.micro",
      monitoring     = true,
      key_name       = "thenaim",
      description    = "Managed by Terraform"
    },
    development = {
      instance_count = 1,
      instance_type  = "t2.micro",
      key_name       = "thenaim",
      monitoring     = false,
      description    = "Managed by Terraform"
    }
  }
}