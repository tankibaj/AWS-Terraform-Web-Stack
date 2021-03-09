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