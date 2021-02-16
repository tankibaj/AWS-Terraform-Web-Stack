resource "aws_autoscaling_policy" "policy_scale_up" {
  count                  = var.isPolicyEnabled ? 1 : 0
  name                   = "ScaleUp"
  scaling_adjustment     = 1 # The number of instances by which to scale
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 120
  autoscaling_group_name = var.autoscaling_group_name
}

resource "aws_autoscaling_policy" "policy_scale_down" {
  count                  = var.isPolicyEnabled ? 1 : 0
  name                   = "ScaleDown"
  scaling_adjustment     = -1 # The number of instances by which to scale
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 120
  autoscaling_group_name = var.autoscaling_group_name
}

resource "aws_cloudwatch_metric_alarm" "cpu" {

  for_each = local.cpu

  alarm_name          = each.value.alarm_name
  comparison_operator = each.value.comparison_operator
  evaluation_periods  = each.value.evaluation_periods
  metric_name         = each.value.metric_name
  namespace           = each.value.namespace
  period              = each.value.period
  statistic           = each.value.statistic
  threshold           = each.value.threshold
  alarm_description   = each.value.alarm_description

  dimensions = {
    (each.value.dimensions_key) = (each.value.dimensions_value)
  }
  alarm_actions = each.value.alarm_actions
}


# resource "aws_cloudwatch_metric_alarm" "cpu_scale_up" {
#   alarm_name          = "ScaleUpCpu"
#   comparison_operator = "GreaterThanOrEqualToThreshold"
#   evaluation_periods  = "2"
#   metric_name         = "CPUUtilization"
#   namespace           = "AWS/EC2"
#   period              = "120" # The period in seconds over which the specified stat is applied.
#   statistic           = "Average"
#   threshold           = "80" # The value against which the specified statistic is compared.
#   alarm_description   = "This metric monitors ec2 cpu utilization"

#   dimensions = {
#     AutoScalingGroupName = module.asg_public.this_autoscaling_group_name
#   }
#   alarm_actions = [aws_autoscaling_policy.policy_scale_up.arn]
# }

# resource "aws_cloudwatch_metric_alarm" "cpu_scale_down" {
#   alarm_name          = "ScaleDownCpu"
#   comparison_operator = "LessThanOrEqualToThreshold"
#   evaluation_periods  = "2"
#   metric_name         = "CPUUtilization"
#   namespace           = "AWS/EC2"
#   period              = "120" # The period in seconds over which the specified stat is applied.
#   statistic           = "Average"
#   threshold           = "70" # The value against which the specified statistic is compared.
#   alarm_description   = "This metric monitors ec2 cpu utilization"

#   dimensions = {
#     AutoScalingGroupName = module.asg_public.this_autoscaling_group_name
#   }
#   alarm_actions = [aws_autoscaling_policy.policy_scale_down.arn]
# }