# Configure the AWS Provider
provider "aws" {
  region                  = var.region
  shared_credentials_file = "$HOME/.aws/credentials"
}

provider "random" {}

resource "random_pet" "name" {}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "vpc-${random_pet.name.id}"
  cidr = var.vpc_cidr_block

  azs             = data.aws_availability_zones.available.names
  private_subnets = slice(var.private_subnet_cidr_blocks, 0, var.environment.public.subnet_count)
  public_subnets  = slice(var.public_subnet_cidr_blocks, 0, var.environment.private.subnet_count)

  enable_nat_gateway = true

  # single_nat_gateway     = false
  # one_nat_gateway_per_az = true
  single_nat_gateway = true

  enable_vpn_gateway = false
}

module "ec2_security_group" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "ec2-sg-${random_pet.name.id}"
  description = "Allow HTTP within VPC and SSH public"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = module.vpc.public_subnets_cidr_blocks
  ingress_rules       = ["all-icmp", "http-80-tcp"]
  ingress_with_cidr_blocks = [
    {
      rule        = "ssh-tcp"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]
}

module "alb_security_group" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "load-balancer-sg-${random_pet.name.id}"
  description = "Allow HTTP publicly"
  vpc_id      = module.vpc.vpc_id

  ingress_rules       = ["http-80-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]

  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]
}

resource "random_string" "lb_id" {
  length  = 4
  special = false
}

module "alb" {
  source = "terraform-aws-modules/alb/aws"

  name     = trimsuffix(substr(replace(join("-", ["alb", random_string.lb_id.result, random_pet.name.id]), "/[^a-zA-Z0-9-]/", ""), 0, 32), "-")
  internal = false

  load_balancer_type = "application"

  vpc_id          = module.vpc.vpc_id
  subnets         = module.vpc.public_subnets
  security_groups = [module.alb_security_group.this_security_group_id]

  target_groups = [
    {
      name_prefix          = "alb-"
      backend_protocol     = "HTTP"
      backend_port         = 80
      target_type          = "instance"
      deregistration_delay = 250
      health_check = {
        enabled             = true
        interval            = 10
        path                = "/"
        port                = "traffic-port"
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout             = 5
        protocol            = "HTTP"
        matcher             = "200-399"
      }
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  tags = {
    name        = random_pet.name.id
    environment = "public"
    description = var.environment.public.description
  }
}

module "ec2_cluster_public" {
  source = "./modules/ec2-instance"

  instance_count     = var.environment.public.instance_count
  instance_type      = var.environment.public.instance_type
  availability_zone  = data.aws_availability_zones.available.names
  key_name           = var.environment.public.key_name
  subnet_ids         = module.vpc.public_subnets[*]
  security_group_ids = [module.ec2_security_group.this_security_group_id]
  monitoring         = var.environment.public.monitoring

  name        = random_pet.name.id
  environment = "public"
  description = var.environment.public.description
}

module "lb_tg_attachment" {
  source = "./modules/lb-target-group-attachment"

  number_of_instances = length(module.ec2_cluster_public.instance_ids)
  target_group_arn    = module.alb.target_group_arns
  instance_ids        = module.ec2_cluster_public.instance_ids
  port                = 80

  depends_on = [module.alb, module.ec2_cluster_public]
}

# module "ec2_cluster_private" {
#   source = "./modules/ec2-instance"

#   instance_count     = var.environment.private.instance_count
#   instance_type      = var.environment.private.instance_type
#   availability_zone  = data.aws_availability_zones.available.names
#   key_name           = var.environment.private.key_name
#   subnet_ids         = module.vpc.private_subnets[*]
#   security_group_ids = [module.ec2_security_group.this_security_group_id]
#   monitoring         = var.environment.private.monitoring

#   name        = random_pet.name.id
#   environment = "private"
#   description = var.environment.private.description
# }