variable "kubernetes_version" {
  description = "EKS version"
  type        = string
  default     = "1.28"
}

# variable "eks_admin_role_name" {
#   description = "EKS admin role"
#   type        = string
#   default     = "WSParticipantRole"
# }

variable "addons" {
  description = "EKS addons"
  type        = any
  default = {
    enable_aws_load_balancer_controller = false
    enable_aws_argocd = false
  }
}

variable "authentication_mode" {
  description = "The authentication mode for the cluster. Valid values are CONFIG_MAP, API or API_AND_CONFIG_MAP"
  type        = string
  default     = "API_AND_CONFIG_MAP"
}

variable "environment_name" {
  description = "The name of environment Infrastructure stack."
  type        = string
  default     = "eks-gitops-bridge-terraform"
}

variable "vpc_id" {
  description = "The Id of the VPC to palce the clsuter in"
  type        = string 
}

variable "private_subnets" {
  description = "Private Subnets Ids for the cluster"
  type        = any
}