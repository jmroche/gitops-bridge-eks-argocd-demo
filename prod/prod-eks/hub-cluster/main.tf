provider "aws" {
    region = "us-east-2"
}

data "aws_caller_identity" "current" {}

locals {
  cluster_name = "gitops-bridge-hub"
  region       = "us-east-2"
  cluster_version = "1.30"
  name = "gitops-bridge-hub"
}


module "hub_eks_cluster" {
    source = "../../../modules/eks"
    environment_name = local.name 
    vpc_id = data.terraform_remote_state.prod_vpc.outputs.vpc_id
    private_subnets = data.terraform_remote_state.prod_vpc.outputs.private_subnets 
    kubernetes_version = local.cluster_version
    
}


# Set up the K8s provider to install ArgoCD

provider "helm" {
  kubernetes {
    host                   = module.hub_eks_cluster.cluster_endpoint
    cluster_ca_certificate = base64decode(module.hub_eks_cluster.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", module.hub_eks_cluster.cluster_name, "--region", local.region]
    }
  }
}

provider "kubernetes" {
  host                   = module.hub_eks_cluster.cluster_endpoint
  cluster_ca_certificate = base64decode(module.hub_eks_cluster.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.hub_eks_cluster.cluster_name, "--region", local.region]
  }
}

locals{
  argocd_namespace = "argocd" 
  environment     = "hub"
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = local.argocd_namespace
  }
}

# GitOps Bridge local variables to setup appofapps

locals{
  argocd_apps = {
    appofapps   = file("${path.module}/appofapps/appofapps-applicationset.yaml")
  }
}

# Initial labels and annotations to be added to the hub cluster

locals{
  aws_addons = {
    enable_aws_argocd                            = try(var.addons.enable_aws_argocd, false)    
    enable_cluster_autoscaler                    = try(var.addons.enable_cluster_autoscaler, false)
    enable_external_dns                          = try(var.addons.enable_external_dns, false)
    enable_external_secrets                      = try(var.addons.enable_external_secrets, false)
    enable_aws_load_balancer_controller          = try(var.addons.enable_aws_load_balancer_controller, false)
  
  }
  oss_addons = {
    enable_argocd                          = try(var.addons.enable_argocd, false)
    enable_gatekeeper                      = try(var.addons.enable_gatekeeper, false)
    enable_kyverno                         = try(var.addons.enable_kyverno, false)
    enable_kube_prometheus_stack           = try(var.addons.enable_kube_prometheus_stack, false)
    enable_metrics_server                  = try(var.addons.enable_metrics_server, false)
    enable_prometheus_adapter              = try(var.addons.enable_prometheus_adapter, false)
    enable_vpa                             = try(var.addons.enable_vpa, false)
  }
  addons = merge(
    local.aws_addons,
    local.oss_addons,
    { kubernetes_version = local.cluster_version },
    { aws_cluster_name = module.hub_eks_cluster.cluster_name },
    { workloads = true }
    #enablewebstore,{ workload_webstore = true }      
  )


  gitops_addons_url      = var.gitops_addons_url 
  gitops_addons_basepath = var.gitops_addons_basepath
  gitops_addons_path     = var.gitops_addons_path
  gitops_addons_revision = var.gitops_addons_revision

  gitops_platform_url      = var.gitops_platform_url
  gitops_platform_basepath = var.gitops_platform_basepath
  gitops_platform_path     = var.gitops_platform_path
  gitops_platform_revision = var.gitops_platform_revision


  addons_metadata = merge(
     module.eks_blueprints_addons.gitops_metadata,
    {
      aws_cluster_name = module.hub_eks_cluster.cluster_name
      aws_region       = local.region
      aws_account_id   = data.aws_caller_identity.current.account_id
      aws_vpc_id       = data.terraform_remote_state.prod_vpc.outputs.vpc_id 
    },
    {
      #enableirsarole argocd_iam_role_arn = aws_iam_role.argocd_hub.arn
      argocd_namespace    = local.argocd_namespace
    },
    {
       addons_repo_url      = local.gitops_addons_url
       addons_repo_basepath = local.gitops_addons_basepath
       addons_repo_path     = local.gitops_addons_path
       addons_repo_revision = local.gitops_addons_revision
    },
    {
       platform_repo_url      = local.gitops_platform_url
       platform_repo_basepath = local.gitops_platform_basepath
       platform_repo_path     = local.gitops_platform_path
       platform_repo_revision = local.gitops_platform_revision
    }


  )
  tags = {
    Blueprint  = local.name
    GithubRepo = "github.com/jmroche/gitops-bridge-eks-argocd-demo"
    auto-delete = "never"
  }  
}

################################################################################
# EKS Blueprints Addons
################################################################################
module "eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.16.3"

  cluster_name      = module.hub_eks_cluster.cluster_name
  cluster_endpoint  = module.hub_eks_cluster.cluster_endpoint
  cluster_version   = module.hub_eks_cluster.cluster_version
  oidc_provider_arn = module.hub_eks_cluster.oidc_provider_arn

  # Using GitOps Bridge (Skip Helm Install in Terraform)
  create_kubernetes_resources = false

  # EKS Blueprints Addons
  enable_cert_manager                 = var.addons.enable_cert_manager
  enable_aws_efs_csi_driver           = var.addons.enable_aws_efs_csi_driver
  enable_aws_fsx_csi_driver           = var.addons.enable_aws_fsx_csi_driver
  enable_aws_cloudwatch_metrics       = var.addons.enable_aws_cloudwatch_metrics
  enable_aws_privateca_issuer         = var.addons.enable_aws_privateca_issuer
  enable_cluster_autoscaler           = var.addons.enable_cluster_autoscaler
  enable_external_dns                 = var.addons.enable_external_dns
  enable_external_secrets             = var.addons.enable_external_secrets
  enable_aws_load_balancer_controller = var.addons.enable_aws_load_balancer_controller
  enable_fargate_fluentbit            = var.addons.enable_fargate_fluentbit
  enable_aws_for_fluentbit            = var.addons.enable_aws_for_fluentbit
  enable_aws_node_termination_handler = var.addons.enable_aws_node_termination_handler
  enable_karpenter                    = var.addons.enable_karpenter
  enable_velero                       = var.addons.enable_velero
  enable_aws_gateway_api_controller   = var.addons.enable_aws_gateway_api_controller

  tags = local.tags

  depends_on = [module.hub_eks_cluster]
}

################################################################################
# GitOps Bridge: Bootstrap
################################################################################
module "gitops_bridge_bootstrap" {
  source  = "gitops-bridge-dev/gitops-bridge/helm"
  version = "0.1.0"
  cluster = {
    cluster_name = module.hub_eks_cluster.cluster_name
    environment  = local.environment
    metadata     = local.addons_metadata
    addons       = local.addons
  }
  apps = local.argocd_apps
  argocd = {
    namespace        = local.argocd_namespace
    chart_version    = "7.3.8"
    timeout          = 600
    create_namespace = false
    set = [
      {
        name  = "server.service.type"
        value = "LoadBalancer"
      }
    ]
  }
  
}