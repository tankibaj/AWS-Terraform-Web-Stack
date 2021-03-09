# ****************************************************************
# EC2 Instances Security Group
# ****************************************************************
module "ec2_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "3.17.0"

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

  tags = {
    Env         = var.env.public.env_type
    Description = var.env.public.description
  }
}

# ****************************************************************
# Application Load Balancer Security Group
# ****************************************************************
module "alb_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "3.17.0"

  name        = "alb-sg-${random_pet.name.id}"
  description = "Allow HTTP publicly"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp"]

  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]

  tags = {
    Env         = var.env.public.env_type
    Description = var.env.public.description
  }
}

# ****************************************************************
# RDS Security Group
# ****************************************************************
module "rds_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "3.17.0"

  name        = "rds-sg-${random_pet.name.id}"
  description = "Allow 3306 within vps public subnets"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = module.vpc.public_subnets_cidr_blocks
  ingress_rules       = ["all-icmp", "mysql-tcp"]

  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]

  tags = {
    Env         = var.env.private.env_type
    Description = var.env.private.description
  }
}