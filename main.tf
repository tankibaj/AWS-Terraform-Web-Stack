# Configure the AWS Provider
provider "aws" {
  region                  = var.region
  shared_credentials_file = "$HOME/.aws/credentials"
}

provider "random" {}

resource "random_pet" "name" {}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  for_each = var.environment

  name = "vpc-${each.key}"
  cidr = var.vpc_cidr_block

  azs             = data.aws_availability_zones.available.names
  private_subnets = slice(var.private_subnet_cidr_blocks, 0, each.value.private_subnet_count)
  public_subnets  = slice(var.public_subnet_cidr_blocks, 0, each.value.public_subnet_count)

  enable_nat_gateway = true
  enable_vpn_gateway = false
}

module "ec2_security_group" {
  source = "terraform-aws-modules/security-group/aws"

  for_each = var.environment

  name        = "ec2-sg-${each.key}"
  description = "Allow HTTP within VPC and SSH public"
  vpc_id      = module.vpc[each.key].vpc_id

  ingress_cidr_blocks = module.vpc[each.key].public_subnets_cidr_blocks
  ingress_rules       = ["http-80-tcp", "ssh-tcp"]

  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]
}

module "elb_security_group" {
  source = "terraform-aws-modules/security-group/aws"

  for_each = var.environment

  name        = "load-balancer-sg-${each.key}"
  description = "Allow HTTP publicly"
  vpc_id      = module.vpc[each.key].vpc_id

  ingress_rules       = ["http-80-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]

  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]
}

resource "random_string" "lb_id" {
  length  = 4
  special = false
}

module "elb" {
  source = "terraform-aws-modules/elb/aws"

  for_each = var.environment

  # Comply with ELB name restrictions 
  # https://docs.aws.amazon.com/elasticloadbalancing/2012-06-01/APIReference/API_CreateLoadBalancer.html
  name     = trimsuffix(substr(replace(join("-", ["lb", random_string.lb_id.result, each.key]), "/[^a-zA-Z0-9-]/", ""), 0, 32), "-")
  internal = false

  security_groups = [module.elb_security_group[each.key].this_security_group_id]
  subnets         = module.vpc[each.key].public_subnets

  number_of_instances = length(module.ec2_cluster[each.key].instance_ids)
  instances           = module.ec2_cluster[each.key].instance_ids

  listener = [{
    instance_port     = "80"
    instance_protocol = "HTTP"
    lb_port           = "80"
    lb_protocol       = "HTTP"
  }]

  health_check = {
    target              = "HTTP:80/index.php"
    interval            = 10
    healthy_threshold   = 3
    unhealthy_threshold = 10
    timeout             = 5
  }
}


module "ec2_cluster" {
  source = "./modules/ec2-instance"

  for_each = var.environment

  instance_count     = each.value.instance_count
  instance_type      = each.value.instance_type
  availability_zone  = data.aws_availability_zones.available.names
  key_name           = each.value.key_name
  subnet_ids         = module.vpc[each.key].public_subnets[*]
  security_group_ids = [module.ec2_security_group[each.key].this_security_group_id]
  monitoring         = each.value.monitoring

  # name        = random_pet.name.id
  name        = "instance-${each.key}"
  environment = each.key
  description = each.value.description
}