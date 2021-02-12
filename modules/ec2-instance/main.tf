resource "aws_instance" "this" {
  count                  = var.instance_count
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  availability_zone      = element(var.availability_zone, count.index)
  key_name               = var.key_name
  vpc_security_group_ids = var.vpc_security_group_ids
  user_data              = file("user-data.yml")
  monitoring             = var.monitoring

  tags = {
    Name        = var.name
    Environment = var.environment
    Description = var.description
  }
}