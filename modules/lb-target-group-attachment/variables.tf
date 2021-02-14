variable "create_attachment" {
  description = "Create the elb attachment or not"
  type        = bool
  default     = true
}

variable "number_of_instances" {
  description = "Number of instances ID to place in the ELB pool"
  type        = number
}

variable "target_group_arn" {
  type = list(string)
}

variable "instance_ids" {
  type = list(string)
}

variable "port" {
  type = number
}