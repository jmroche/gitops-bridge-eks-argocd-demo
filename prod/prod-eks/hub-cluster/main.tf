provider "aws" {
    region = "us-east-2"
}


module "hub_eks_cluster" {
    source = "../../../modules/eks"
    environment_name = "gitops-bridge-hub"
    vpc_id = data.terraform_remote_state.prod_vpc.outputs.vpc_id
    private_subnets = data.terraform_remote_state.prod_vpc.outputs.private_subnets 
    

}