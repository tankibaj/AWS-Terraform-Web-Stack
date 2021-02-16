variable "isPolicyEnabled" {
  description = "Create dynamic autoscaling policy or not"
  type        = bool
  default     = true
}

variable "isAlarmEnabled" {
  description = "Create cpu autoscaling policy or not"
  type        = bool
  default     = true
}

variable "autoscaling_group_name" {
  description = "Autoscaling group name, where scaling policy's will be assigned"
  type        = string
}

locals {
  policy = {
    ScaleUpCpu = {
      alarm_name          = "ScaleUpCpu"
      comparison_operator = "GreaterThanOrEqualToThreshold"
      evaluation_periods  = "2"
      metric_name         = "CPUUtilization"
      namespace           = "AWS/EC2"
      period              = "120" # The period in seconds over which the specified stat is applied.
      statistic           = "Average"
      threshold           = "80" # The value against which the specified statistic is compared.
      alarm_description   = "This metric monitors ec2 cpu utilization"
      dimensions_key      = "AutoScalingGroupName"
      dimensions_value    = var.autoscaling_group_name
      alarm_actions       = aws_autoscaling_policy.policy_scale_up.*.arn
    },
    ScaleDownCpu = {
      alarm_name          = "ScaleDownCpu"
      comparison_operator = "LessThanOrEqualToThreshold"
      evaluation_periods  = "2"
      metric_name         = "CPUUtilization"
      namespace           = "AWS/EC2"
      period              = "120" # The period in seconds over which the specified stat is applied.
      statistic           = "Average"
      threshold           = "30" # The value against which the specified statistic is compared.
      alarm_description   = "This metric monitors ec2 cpu utilization"
      dimensions_key      = "AutoScalingGroupName"
      dimensions_value    = var.autoscaling_group_name
      alarm_actions       = aws_autoscaling_policy.policy_scale_down.*.arn
    }
  }
  cpu = var.isPolicyEnabled && var.isAlarmEnabled ? local.policy : {}
}