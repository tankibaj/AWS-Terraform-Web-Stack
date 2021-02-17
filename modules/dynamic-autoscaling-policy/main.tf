resource "aws_autoscaling_policy" "policy_scale_up" {
  count                  = var.isPolicyEnabled ? 1 : 0
  name                   = "${var.name}-ScaleUp"
  scaling_adjustment     = 1 # The number of instances by which to scale
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 120
  autoscaling_group_name = var.autoscaling_group_name
}

resource "aws_autoscaling_policy" "policy_scale_down" {
  count                  = var.isPolicyEnabled ? 1 : 0
  name                   = "${var.name}-ScaleDown"
  scaling_adjustment     = -1 # The number of instances by which to scale
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 120
  autoscaling_group_name = var.autoscaling_group_name
}

resource "aws_cloudwatch_metric_alarm" "policy_alarm" {

  for_each = local.alarm

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