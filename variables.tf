variable "region" {
  description = "Define a variable for AWS region"
  type        = string
  default     = "eu-central-1"
}

variable "env" {
  description = "Map of environment names to configuration"
  type        = map(any)
  default = {
    public = {
      subnet_count        = 3,
      instance_count      = 1,
      ami_id              = "ami-0502e817a62226e03" # Ubuntu Server 20.04 LTS (HVM)
      associate_public_ip = true
      instance_type       = "t2.micro", # Free tier
      monitoring          = true,
      key_name            = "thenaim",
      env_type            = "Public Subnet"
      description         = "Managed by Terraform"
    },
    private = {
      subnet_count   = 3,
      instance_count = 1,
      ami_id         = "ami-0502e817a62226e03" # Ubuntu Server 20.04 LTS (HVM)
      instance_type  = "t2.micro",             # Free tier
      monitoring     = false,
      key_name       = "thenaim",
      env_type       = "Private Subnet"
      description    = "Managed by Terraform"
    }
  }
}

variable "vpc_cidr_block" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr_blocks" {
  description = "Available cidr blocks for public subnets"
  type        = list(string)
  default = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24",
    "10.0.4.0/24",
    "10.0.5.0/24",
    "10.0.6.0/24",
    "10.0.7.0/24",
    "10.0.8.0/24",
    "10.0.9.0/24",
    "10.0.10.0/24",
    "10.0.11.0/24",
    "10.0.12.0/24",
    "10.0.13.0/24",
    "10.0.14.0/24",
    "10.0.15.0/24",
    "10.0.16.0/24"
  ]
}

variable "private_subnet_cidr_blocks" {
  description = "Available cidr blocks for private subnets"
  type        = list(string)
  default = [
    "10.0.101.0/24",
    "10.0.102.0/24",
    "10.0.103.0/24",
    "10.0.104.0/24",
    "10.0.105.0/24",
    "10.0.106.0/24",
    "10.0.107.0/24",
    "10.0.108.0/24",
    "10.0.109.0/24",
    "10.0.110.0/24",
    "10.0.111.0/24",
    "10.0.112.0/24",
    "10.0.113.0/24",
    "10.0.114.0/24",
    "10.0.115.0/24",
    "10.0.116.0/24"
  ]
}

variable "database_subnets_cidr_blocks" {
  description = "Available cidr blocks for database subnets"
  type        = list(string)
  default = [
    "10.0.201.0/24",
    "10.0.202.0/24",
    "10.0.203.0/24",
    "10.0.204.0/24",
    "10.0.205.0/24",
    "10.0.206.0/24",
    "10.0.207.0/24",
    "10.0.208.0/24",
    "10.0.209.0/24",
    "10.0.210.0/24",
    "10.0.211.0/24",
    "10.0.212.0/24",
    "10.0.213.0/24",
    "10.0.214.0/24",
    "10.0.215.0/24",
    "10.0.216.0/24"
  ]
}