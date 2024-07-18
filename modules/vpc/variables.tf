variable "environment_name" {
  description = "The name of environment Infrastructure stack."
  type        = string
  default     = "eks-gitops-bridge-terraform"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}