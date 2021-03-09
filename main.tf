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