output "ec2_public_ip" {
  description = "List of public IP addresses assigned to the public cluster"
  value       = module.ec2_cluster_public.public_ip
}

# output "ec2_private_ip" {
#   description = "List of private IP addresses assigned to the private cluster"
#   value       = module.ec2_cluster_private.private_ip
# }

output "alb_dns" {
  description = "The DNS name of the load balancer"
  value       = module.alb.this_lb_dns_name
}

# output "db_instance_address" {
#   description = "The address of the RDS instance"
#   value       = module.rds.this_db_instance_address
# }

# output "db_instance_availability_zone" {
#   description = "The availability zone of the RDS instance"
#   value       = module.rds.this_db_instance_availability_zone
# }

# output "db_instance_arn" {
#   description = "The ARN of the RDS instance"
#   value       = module.rds.this_db_instance_arn
# }

# output "db_instance_address" {
#   description = "The address of the RDS instance"
#   value       = rds.db_instance_address
# }

output "mysql_master" {
  description = "The connection endpoint"
  value       = module.mysql_master.this_db_instance_endpoint
}

output "mysql_replica" {
  description = "The connection endpoint"
  value       = module.mysql_replica.this_db_instance_endpoint
}