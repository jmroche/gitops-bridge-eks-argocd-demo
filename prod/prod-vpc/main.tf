provider "aws" {
    region = "us-east-2"
}

module "prod_vpc" {
    source = "../../modules/vpc"
    environment_name = "gitops-bridge-prod-vpc"
}