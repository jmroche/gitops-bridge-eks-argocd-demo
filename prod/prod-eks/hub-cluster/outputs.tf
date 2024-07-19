output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = <<-EOT
    aws eks --region ${local.region} update-kubeconfig --name ${module.hub_eks_cluster.cluster_name} --alias hub
  EOT
}

output "cluster_name" {
  description = "Cluster Hub name"
  value       = module.hub_eks_cluster.cluster_name
}
output "cluster_endpoint" {
  description = "Cluster Hub endpoint"
  value       = module.hub_eks_cluster.cluster_endpoint
}
output "cluster_certificate_authority_data" {
  description = "Cluster Hub certificate_authority_data"
  value       = module.hub_eks_cluster.cluster_certificate_authority_data
}
output "cluster_region" {
  description = "Cluster Hub region"
  value       = "us-east-2"
}
# output "hub_node_security_group_id" {
#   description = "Cluster SG"
#   value       = module.hub_eks_cluster.node_security_group_id
# }
output "cluster_version"{
  description = "Cluster Hub version"
  value       = module.hub_eks_cluster.cluster_version
}

output "oidc_provider_arn"{
  description = "OIDC Provider ARN"
  value       = module.hub_eks_cluster.oidc_provider_arn
}