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

variable "name" {
  description = "Name prefix"
  type        = string
}

variable "autoscaling_group_name" {
  description = "Autoscaling group name, where scaling policy's will be assigned"
  type        = string
}

locals {
  default_alarm = {
    CpuScaleUp = {
      alarm_name          = "${var.name}-CpuScaleUp"
      comparison_operator = "GreaterThanOrEqualToThreshold"
      evaluation_periods  = "2"
      metric_name         = "CPUUtilization"
      namespace           = "AWS/EC2"
      period              = "120" # The period in seconds over which the specified stat is applied.
      statistic           = "Average"
      threshold           = "80" # The value against which the specified statistic is compared.
      alarm_description   = "This metric monitors ec2 high cpu utilization of the autoscaling group"
      dimensions_key      = "AutoScalingGroupName"
      dimensions_value    = var.autoscaling_group_name
      alarm_actions       = aws_autoscaling_policy.policy_scale_up.*.arn
    },
    CpuScaleDown = {
      alarm_name          = "${var.name}-CpuScaleDown"
      comparison_operator = "LessThanOrEqualToThreshold"
      evaluation_periods  = "2"
      metric_name         = "CPUUtilization"
      namespace           = "AWS/EC2"
      period              = "120" # The period in seconds over which the specified stat is applied.
      statistic           = "Average"
      threshold           = "25" # The value against which the specified statistic is compared.
      alarm_description   = "This metric monitors ec2 low cpu utilization of the autoscaling group"
      dimensions_key      = "AutoScalingGroupName"
      dimensions_value    = var.autoscaling_group_name
      alarm_actions       = aws_autoscaling_policy.policy_scale_down.*.arn
    },
    RamScaleUp = {
      alarm_name          = "${var.name}-RamScaleUp"
      comparison_operator = "GreaterThanOrEqualToThreshold"
      evaluation_periods  = "2"
      metric_name         = "MemoryUtilization"
      namespace           = "System/Linux"
      period              = "120" # The period in seconds over which the specified stat is applied.
      statistic           = "Average"
      threshold           = "80" # The value against which the specified statistic is compared.
      alarm_description   = "This metric monitors ec2 high ram utilization of the autoscaling group"
      dimensions_key      = "AutoScalingGroupName"
      dimensions_value    = var.autoscaling_group_name
      alarm_actions       = aws_autoscaling_policy.policy_scale_down.*.arn
    },
    RamScaleDown = {
      alarm_name          = "${var.name}-RamScaleDown"
      comparison_operator = "LessThanOrEqualToThreshold"
      evaluation_periods  = "2"
      metric_name         = "MemoryUtilization"
      namespace           = "System/Linux"
      period              = "120" # The period in seconds over which the specified stat is applied.
      statistic           = "Average"
      threshold           = "25" # The value against which the specified statistic is compared.
      alarm_description   = "This metric monitors ec2 low ram utilization of the autoscaling group"
      dimensions_key      = "AutoScalingGroupName"
      dimensions_value    = var.autoscaling_group_name
      alarm_actions       = aws_autoscaling_policy.policy_scale_down.*.arn
    },
  }
  alarm = var.isPolicyEnabled && var.isAlarmEnabled ? local.default_alarm : {}
}
