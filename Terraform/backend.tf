terraform {
  backend "s3" {
    bucket = " "
    region = "eu-west-1"
    key    = "global/terraform.tfstate"
  }
}
