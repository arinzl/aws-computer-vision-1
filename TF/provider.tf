provider "aws" {
  region = var.region


  default_tags {
    tags = {
      deployedBy     = "Terraform"
      terraformStack = "mycode"
    }
  }
}
