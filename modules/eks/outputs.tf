output "cluster_name" {
  description = "Cluster Hub name"
  value       = module.eks.cluster_name
}
output "cluster_endpoint" {
  description = "Cluster Hub endpoint"
  value       = module.eks.cluster_endpoint
}
output "cluster_certificate_authority_data" {
  description = "Cluster Hub certificate_authority_data"
  value       = module.eks.cluster_certificate_authority_data
}
output "cluster_region" {
  description = "Cluster Hub region"
  value       = "us-east-2"
}
output "hub_node_security_group_id" {
  description = "Cluster Hub SG"
  value       = module.eks.node_security_group_id
}

output "cluster_version"{
  description = "Cluster Hub version"
  value       = module.eks.cluster_version
}

output "oidc_provider_arn"{
  description = "OIDC Provider ARN"
  value       = module.eks.oidc_provider_arn
}