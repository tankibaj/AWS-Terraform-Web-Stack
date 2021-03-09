# ****************************************************************
# Auto Scaling Group - Public Subnets 
# ****************************************************************
module "asg_public" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "3.8.0"

  name = "asg-${random_pet.name.id}"

  # Launch configuration
  lc_name = random_pet.name.id

  image_id        = var.env.public.ami_id
  instance_type   = var.env.public.instance_type
  security_groups = [module.ec2_security_group.this_security_group_id]
  key_name        = var.env.public.key_name
  user_data       = file("user-data.yml")

  ebs_block_device = [
    {
      device_name           = "/dev/xvdz"
      volume_type           = "gp2"
      volume_size           = "20"
      delete_on_termination = true
    },
  ]

  root_block_device = [
    {
      volume_size = "8"
      volume_type = "gp2"
    },
  ]

  # Auto scaling group
  asg_name                  = random_pet.name.id
  vpc_zone_identifier       = module.vpc.public_subnets
  health_check_type         = "EC2"
  min_size                  = 1
  max_size                  = 4
  desired_capacity          = 2
  wait_for_capacity_timeout = 0
  health_check_grace_period = 60
  default_cooldown          = 60
  target_group_arns         = module.alb.target_group_arns

  tags = [
    {
      key                 = "Env"
      value               = var.env.public.env_type
      propagate_at_launch = true
    },
    {
      key                 = "Description"
      value               = var.env.public.description
      propagate_at_launch = true
    },
  ]
  depends_on = [module.alb]
}

# ****************************************************************
# Dynamic Auto Scaling Policy
# ****************************************************************
module "dynamic_autoscaling_policy" {
  source = "./modules/dynamic-autoscaling-policy"

  name                   = random_pet.name.id
  autoscaling_group_name = module.asg_public.this_autoscaling_group_name

  depends_on = [module.asg_public]
}