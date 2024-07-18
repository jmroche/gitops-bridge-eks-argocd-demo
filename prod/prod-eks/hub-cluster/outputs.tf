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