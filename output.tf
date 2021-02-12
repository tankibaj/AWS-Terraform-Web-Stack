output "ec2_public_dns" {
  description = "Public DNS of the ec2 instances for each project"
  value       = { for p in sort(keys(var.environment)) : p => module.ec2-cluster[p].public_dns }
}

output "ec2_public_ip" {
  description = "Public IP of the ec2 instances for each project"
  value       = { for p in sort(keys(var.environment)) : p => module.ec2-cluster[p].public_ip }
}