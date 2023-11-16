 terraform {
  backend "s3" {
    bucket = "${s3-bucket}"
    region = "${region}"
    key = "global/terraform.tfstate"
  }
 }

