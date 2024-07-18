data "terraform_remote_state" "prod_vpc"{
    backend = "local"

    config = {
      path = "${path.module}/../../prod-vpc/terraform.tfstate"
    }

}