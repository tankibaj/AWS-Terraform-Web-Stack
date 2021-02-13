resource "aws_instance" "this" {
  count                       = var.instance_count
  ami                         = data.aws_ami.ubuntu.id
  associate_public_ip_address = true
  instance_type               = var.instance_type
  # availability_zone      = element(var.availability_zone, count.index)
  key_name               = var.key_name
  monitoring             = var.monitoring
  vpc_security_group_ids = var.security_group_ids
  subnet_id              = var.subnet_ids[count.index % length(var.subnet_ids)]
  user_data              = file("user-data.yml")

  tags = {
    Name        = var.name
    Environment = var.environment
    Description = var.description
  }
}