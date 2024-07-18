output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.prod_vpc.vpc_id
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.prod_vpc.private_subnets
}