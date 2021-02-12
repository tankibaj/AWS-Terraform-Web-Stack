# Configure the AWS Provider
provider "aws" {
  region                  = var.region
  shared_credentials_file = "$HOME/.aws/credentials"
}

provider "random" {}

resource "random_pet" "name" {}

resource "aws_security_group" "foobar-sg" {
  name        = "ec2-${random_pet.name.id}"
  description = "Allow SSH HTTP"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = random_pet.name.id
  }
}

module "ec2-cluster" {
  source = "./modules/ec2-instance"

  for_each = var.environment

  # Inputs
  instance_count         = each.value.instance_count
  instance_type          = each.value.instance_type
  availability_zone      = data.aws_availability_zones.available.names
  key_name               = each.value.key_name
  vpc_security_group_ids = [aws_security_group.foobar-sg.id]
  monitoring             = each.value.monitoring

  # Tags
  name        = random_pet.name.id
  environment = each.key
  description = each.value.description
}