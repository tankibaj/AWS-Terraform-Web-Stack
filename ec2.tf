# ****************************************************************
# EC2 Cluster for Public Subnets
# ****************************************************************
# module "ec2_cluster_public" {
#   source = "./modules/ec2-instance"

#   name                = random_pet.name.id
#   instance_count      = var.env.public.instance_count
#   ami_id              = var.env.public.ami_id
#   associate_public_ip = var.env.public.associate_public_ip
#   instance_type       = var.env.public.instance_type
#   availability_zone   = data.aws_availability_zones.available.names
#   key_name            = var.env.public.key_name
#   subnet_ids          = module.vpc.public_subnets[*]
#   security_group_ids  = [module.ec2_security_group.this_security_group_id]
#   monitoring          = var.env.public.monitoring
#   user_data           = file("user-data.yml")

#   tags = {
#     Env         = var.env.public.env_type
#     Description = var.env.public.description
#   }
# }

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
# module "target_group_alb" {
#   source = "./modules/lb-target-group-attachment"

#   number_of_instances = length(module.ec2_cluster_public.instance_ids)
#   target_group_arn    = module.alb.target_group_arns
#   instance_ids        = module.ec2_cluster_public.instance_ids
#   port                = 80

#   depends_on = [module.alb, module.ec2_cluster_public]
# }