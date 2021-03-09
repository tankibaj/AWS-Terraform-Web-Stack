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