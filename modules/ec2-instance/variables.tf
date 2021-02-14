variable "name" {
  description = "Instance name"
  type        = string
}

variable "instance_count" {
  description = "Number of EC2 instances to deploy"
  type        = number
}

variable "ami_id" {
  description = "Define a variable for AMI id"
  type        = string
}

variable "associate_public_ip" {
  description = "Whether to associate a public IP address with an instance in a VPC"
  type        = bool
  default     = false
}

variable "instance_type" {
  description = "Define a variable for instance type"
  type        = string
}

variable "availability_zone" {
  description = "Define multiple availability zones"
  type        = list(string)
}

variable "key_name" {
  description = "Key name of the Key Pair to use for the instance"
  type        = string
}

variable "monitoring" {
  description = "If true, the launched EC2 instance will have detailed monitoring enabled"
  type        = bool
  default     = false
}

variable "subnet_ids" {
  description = "A list of subnet IDs for EC2 instances"
  type        = list(string)
}

variable "security_group_ids" {
  description = "A list of security group IDs to associate with EC2 instances"
  type        = list(string)
}

variable "user_data" {
  description = "The user data to provide when launching the instance"
  type        = string
  default     = null
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}