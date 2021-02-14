# output "ec2_public_ip" {
#   description = "List of public IP addresses assigned to the public cluster"
#   value       = module.ec2_cluster_public.public_ip
# }

# output "ec2_private_ip" {
#   description = "List of private IP addresses assigned to the private cluster"
#   value       = module.ec2_cluster_private.private_ip
# }

output "alb_dns" {
  description = "The DNS name of the load balancer"
  value       = module.alb.this_lb_dns_name
}