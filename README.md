# Terraform AWS Web Application Infrastructure

A quick terraform tutorial for setting up Application Load Balancer, Auto Scaling Group, and MySQL in AWS.



### Resources:

- [EC2 instance](https://www.terraform.io/docs/providers/aws/r/instance.html)
- [EC2-VPC Security Group](https://www.terraform.io/docs/providers/aws/r/security_group.html)
- [EC2-VPC Security Group Rule](https://www.terraform.io/docs/providers/aws/r/security_group_rule.html)
- [VPC](https://www.terraform.io/docs/providers/aws/r/vpc.html)
- [Subnet](https://www.terraform.io/docs/providers/aws/r/subnet.html)
- [Route](https://www.terraform.io/docs/providers/aws/r/route.html)
- [Route table](https://www.terraform.io/docs/providers/aws/r/route_table.html)
- [Internet Gateway](https://www.terraform.io/docs/providers/aws/r/internet_gateway.html)
- [Network ACL](https://www.terraform.io/docs/providers/aws/r/network_acl.html)
- [NAT Gateway](https://www.terraform.io/docs/providers/aws/r/nat_gateway.html)
- [VPN Gateway](https://www.terraform.io/docs/providers/aws/r/vpn_gateway.html)
- [VPC Flow Log](https://www.terraform.io/docs/providers/aws/r/flow_log.html)
- [VPC Endpoint](https://www.terraform.io/docs/providers/aws/r/vpc_endpoint.html)
- [Launch Configuration](https://www.terraform.io/docs/providers/aws/r/launch_configuration.html)
- [Auto Scaling Group](https://www.terraform.io/docs/providers/aws/r/autoscaling_group.html)
- [Load Balancer](https://www.terraform.io/docs/providers/aws/r/lb.html)
- [Load Balancer Listener](https://www.terraform.io/docs/providers/aws/r/lb_listener.html)
- [Load Balancer Listener Certificate](https://www.terraform.io/docs/providers/aws/r/lb_listener_certificate.html)
- [Load Balancer Listener default actions](https://www.terraform.io/docs/providers/aws/r/lb_listener.html) - All actions supported.
- [Load Balancer Listener Rule](https://www.terraform.io/docs/providers/aws/r/lb_listener_rule.html)
- [Target Group](https://www.terraform.io/docs/providers/aws/r/lb_target_group.html)
- [DB Instance](https://www.terraform.io/docs/providers/aws/r/db_instance.html)
- [DB Subnet Group](https://www.terraform.io/docs/providers/aws/r/db_subnet_group.html)
- [DB Parameter Group](https://www.terraform.io/docs/providers/aws/r/db_parameter_group.html)
- [DB Option Group](https://www.terraform.io/docs/providers/aws/r/db_option_group.html)



## Quickstart

- Clone this repo

- Set up aws credentials in `provider.tf`

- Initialize and run terraform:

  ```bash
  terraform init
  terraform plan
  ```

- If you're ready to deploy:

  ```bash
  terraform apply
  ```