resource "aws_lb_target_group_attachment" "this" {
  count = var.create_attachment ? var.number_of_instances : 0

  target_group_arn = element(var.target_group_arn, count.index)
  target_id        = element(var.instance_ids, count.index)
  port             = var.port
}