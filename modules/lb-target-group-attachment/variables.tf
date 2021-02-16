variable "isEnabled" {
  description = "Create the lb target group or not"
  type        = bool
  default     = true
}

variable "number_of_instances" {
  description = "Number of instances ID to place in the LB pool"
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