terraform {
  backend "s3" {
    bucket = "eu-west-1-terraform-state-a5365e1ac9e2e4c43f15"
    region = "eu-west-1"
    key = "global/terraform.tfstate"
  }
}    
