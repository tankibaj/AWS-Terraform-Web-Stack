resource "aws_instance" "this" {
  count                       = var.instance_count
  ami                         = var.ami_id
  associate_public_ip_address = var.associate_public_ip
  instance_type               = var.instance_type
  key_name                    = var.key_name
  monitoring                  = var.monitoring
  vpc_security_group_ids      = var.security_group_ids
  subnet_id                   = var.subnet_ids[count.index % length(var.subnet_ids)]
  user_data                   = var.user_data

  tags = merge(
    {
      "Name" = var.name
    },
    var.tags,
  )
}