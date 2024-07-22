################################################################################
# EKS Cluster
################################################################################

data "aws_caller_identity" "current" {}
data "aws_iam_session_context" "current" {
  # This data source provides information on the IAM source role of an STS assumed role
  # For non-role ARNs, this data source simply passes the ARN through issuer ARN
  # Ref https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2327#issuecomment-1355581682
  # Ref https://github.com/hashicorp/terraform-provider-aws/issues/28381
  arn = data.aws_caller_identity.current.arn
}

locals{
    name = "${var.environment_name}-eks-cluster"
    cluster_version = var.kubernetes_version
    vpc_id = var.vpc_id 
    private_subnets = var.private_subnets 
    authentication_mode = var.authentication_mode
    tags = {
        Environment = "prod"
        auto-delete = "never"
    }

}

module "eks" {
  source = "terraform-aws-modules/eks/aws"
  version = "~> 20.19.0"

  cluster_name  = local.name
  cluster_version = local.cluster_version
  cluster_endpoint_public_access = true

  vpc_id = local.vpc_id 
  subnet_ids = local.private_subnets 

  authentication_mode = local.authentication_mode
  kms_key_administrators = distinct(concat([
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"],
    [data.aws_iam_session_context.current.issuer_arn]
  ))

  enable_cluster_creator_admin_permissions = true


  eks_managed_node_groups = {
    cluster_node = {
      instance_types = ["t3.medium"]

      min_size     = 3
      max_size     = 10
      desired_size = 3
    }
  }

  cluster_addons = {
    eks-pod-identity-agent = {
      most_recent = true
    }
    vpc-cni = {
      # Specify the VPC CNI addon should be deployed before compute to ensure
      # the addon is configured before data plane compute resources are created
      # See README for further details
      before_compute = true
      most_recent    = true # To ensure access to the latest settings provided
      configuration_values = jsonencode({
        env = {
          # Reference docs https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html
          ENABLE_PREFIX_DELEGATION = "true"
          WARM_PREFIX_TARGET       = "1"
        }
      })
    }
  } 

}