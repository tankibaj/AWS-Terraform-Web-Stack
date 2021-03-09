# ****************************************************************
# Select all availability zones in the region
# ****************************************************************
data "aws_availability_zones" "available" {
  state = "available"
}

# ****************************************************************
# Random Name Generator
# ****************************************************************
resource "random_pet" "name" {}

# ****************************************************************
# Random ID Generator for Load Balancer
# ****************************************************************
resource "random_string" "lb_id" {
  length  = 4
  special = false
}

# ****************************************************************
# VPC
# ****************************************************************
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.70.0"

  name = "vpc-${random_pet.name.id}"
  cidr = var.vpc_cidr_block

  azs              = data.aws_availability_zones.available.names
  public_subnets   = slice(var.public_subnet_cidr_blocks, 0, var.env.public.subnet_count)
  private_subnets  = slice(var.private_subnet_cidr_blocks, 0, var.env.private.subnet_count)
  database_subnets = slice(var.database_subnets_cidr_blocks, 0, 3)

  enable_nat_gateway = false # If false.. Private subnet will have not intenet access.
  # single_nat_gateway     = false    # If true... One shared NAT gateway will be created for multiple AZ. (if NAT AZ goes down, private subnet in other AZs will lose Internet Access)
  # one_nat_gateway_per_az = true     # If true... For each AZ a NAT Gateway will be created. (NAT Gateway High Availability)

  enable_vpn_gateway = false
}

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

# ****************************************************************
# Application Load Balancer
# ****************************************************************
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "5.10.0"

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
      deregistration_delay = 60
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
    Env         = var.env.public.env_type
    Description = var.env.public.description
  }
  depends_on = [module.vpc]
}

# ****************************************************************
# EC2 Cluster for Public Subnets
# ****************************************************************
module "ec2_cluster_public" {
  source = "./modules/ec2-instance"

  name                = random_pet.name.id
  instance_count      = var.env.public.instance_count
  ami_id              = var.env.public.ami_id
  associate_public_ip = var.env.public.associate_public_ip
  instance_type       = var.env.public.instance_type
  availability_zone   = data.aws_availability_zones.available.names
  key_name            = var.env.public.key_name
  subnet_ids          = module.vpc.public_subnets[*]
  security_group_ids  = [module.ec2_security_group.this_security_group_id]
  monitoring          = var.env.public.monitoring
  user_data           = file("user-data.yml")

  tags = {
    Env         = var.env.public.env_type
    Description = var.env.public.description
  }
}

# ****************************************************************
# EC2 Cluster for Private Subnets
# ****************************************************************
# module "ec2_cluster_private" {
#   source = "./modules/ec2-instance"

#   name               = random_pet.name.id
#   instance_count     = var.env.private.instance_count
#   ami_id             = var.env.private.ami_id
#   instance_type      = var.env.private.instance_type
#   availability_zone  = data.aws_availability_zones.available.names
#   key_name           = var.env.private.key_name
#   subnet_ids         = module.vpc.private_subnets[*]
#   security_group_ids = [module.ec2_security_group.this_security_group_id]
#   monitoring         = var.env.private.monitoring
#   user_data          = file("user-data.yml")

#   tags = {
#     Env         = var.env.private.env_type
#     Description = var.env.private.description
#   }
# }

# ****************************************************************
# Target Group for Application Load Balancer
# ****************************************************************
module "target_group_alb" {
  source = "./modules/lb-target-group-attachment"

  number_of_instances = length(module.ec2_cluster_public.instance_ids)
  target_group_arn    = module.alb.target_group_arns
  instance_ids        = module.ec2_cluster_public.instance_ids
  port                = 80

  depends_on = [module.alb, module.ec2_cluster_public]
}






# # ****************************************************************
# # Auto Scaling Group - Public Subnets 
# # ****************************************************************
# module "asg_public" {
#   source  = "terraform-aws-modules/autoscaling/aws"
#   version = "3.8.0"

#   name = "asg-${random_pet.name.id}"

#   # Launch configuration
#   lc_name = random_pet.name.id

#   image_id        = var.env.public.ami_id
#   instance_type   = var.env.public.instance_type
#   security_groups = [module.ec2_security_group.this_security_group_id]
#   key_name        = var.env.public.key_name
#   user_data       = file("user-data.yml")

#   ebs_block_device = [
#     {
#       device_name           = "/dev/xvdz"
#       volume_type           = "gp2"
#       volume_size           = "20"
#       delete_on_termination = true
#     },
#   ]

#   root_block_device = [
#     {
#       volume_size = "8"
#       volume_type = "gp2"
#     },
#   ]

#   # Auto scaling group
#   asg_name                  = random_pet.name.id
#   vpc_zone_identifier       = module.vpc.public_subnets
#   health_check_type         = "EC2"
#   min_size                  = 1
#   max_size                  = 4
#   desired_capacity          = 2
#   wait_for_capacity_timeout = 0
#   health_check_grace_period = 120
#   default_cooldown          = 120
#   target_group_arns         = module.alb.target_group_arns

#   tags = [
#     {
#       key                 = "Env"
#       value               = var.env.public.env_type
#       propagate_at_launch = true
#     },
#     {
#       key                 = "Description"
#       value               = var.env.public.description
#       propagate_at_launch = true
#     },
#   ]
#   depends_on = [module.alb]
# }

# # ****************************************************************
# # Dynamic Auto Scaling Policy
# # ****************************************************************
# module "dynamic_autoscaling_policy" {
#   source = "./modules/dynamic-autoscaling-policy"

#   name                   = random_pet.name.id
#   autoscaling_group_name = module.asg_public.this_autoscaling_group_name

#   depends_on = [module.asg_public]
# }

# ****************************************************************
# MySQL Master
# ****************************************************************
module "mysql_master" {
  source  = "./modules/mysql"

  identifier = "master-${random_pet.name.id}"

  # All available versions: http://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_MySQL.html#MySQL.Concepts.VersionMgmt
  engine               = "mysql"
  engine_version       = "8.0.21"
  instance_class       = "db.t3.micro"
  allocated_storage    = 20
  storage_encrypted    = false
  multi_az             = true
  name                 = "" # Keep empty string to start without a database

  # Creds
  username = "admin"
  password = "YourPwdShouldBeLongAndSecure!"
  # kms_key_id        = "arm:aws:kms:<region>:<account id>:key/<kms key id>"
  iam_database_authentication_enabled = false

  # Network
  port                   = "3306"
  vpc_security_group_ids = [module.rds_security_group.this_security_group_id]
  subnet_ids             = module.vpc.database_subnets[*] # DB subnet group
  publicly_accessible    = false                          # Bool to control if instance is publicly accessible

  # Backup
  maintenance_window        = "Mon:00:00-Mon:03:00"
  backup_window             = "03:00-06:00"
  backup_retention_period   = 1                                # [0] disable backups to create DB faster | Backups are required in order to create a replica [1] days
  deletion_protection       = false                            # Database Deletion Protection
  skip_final_snapshot       = true                             # Determines whether a final DB snapshot is created before the DB instance is deleted
  final_snapshot_identifier = "${random_pet.name.id}-snapshot" # Snapshot name upon DB deletion

  # Logs
  enabled_cloudwatch_logs_exports = ["general", "slowquery"]
}

# ****************************************************************
# MySQL Replica
# ****************************************************************
module "mysql_replica" {
  source  = "./modules/mysql"

  identifier = "replica-${random_pet.name.id}"

  # Source database. For cross-region use this_db_instance_arn
  replicate_source_db = module.mysql_master.this_db_instance_id

  engine         = "mysql"
  engine_version = "8.0.21"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  storage_encrypted = false
  multi_az          = false

  # Creds
  username = "" # Username and password should not be set for replicas
  password = ""

  # Network
  port                   = "3306"
  vpc_security_group_ids = [module.rds_security_group.this_security_group_id]
  create_db_subnet_group = false # Not allowed to specify a subnet group for replicas in the same region

  # Backup
  maintenance_window      = "Tue:00:00-Tue:03:00"
  backup_window           = "03:00-06:00"
  backup_retention_period = 0 # [0] disable backups to create DB faster

  # Logs
  enabled_cloudwatch_logs_exports = ["general", "slowquery"]
}