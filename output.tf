output "ec2_public_dns" {
  description = "Public DNS of the ec2 instances for each project"
  value       = module.ec2_cluster_public.public_dns
}

output "ec2_public_ip" {
  description = "List of public IP addresses assigned to the instances, if applicable"
  value       = module.ec2_cluster_public.public_ip
}

output "ec2_private_ip" {
  description = "List of public IP addresses assigned to the instances, if applicable"
  value       = module.ec2_cluster_private.private_ip
}