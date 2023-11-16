
resource "random_id" "this" {
  byte_length = "10"
}

################# CREATING THE REMOTE S3 BUCKET
resource "aws_s3_bucket" "remote-state" {
  #count         = var.create ? 0 : 1
  bucket        = "${var.region}-terraform-state-${random_id.this.hex}"
  # acl           = "private"
  # region        = var.region
  # force_destroy = var.force_destroy

  # server_side_encryption_configuration {
  #   rule {
  #     apply_server_side_encryption_by_default {
  #       sse_algorithm = "AES256"
  #     }
  #   }
  # }
  # versioning {
  #   enabled = var.versioning
  # }
}

# ################# CREATING THE DYNAMODB STATE LOCK  #######
# resource "aws_dynamodb_table" "terraform_locks" {
#   #count         = var.create ? 0 : 1
#   name         = "${var.region}-dynamodb-locking-${random_id.this.hex}"
#   billing_mode = "PAY_PER_REQUEST"
#   hash_key     = "LockID"
#   attribute {
#     name = "LockID"
#     type = "S"
#   }
# }


################# AUTOMATING REMOTE STATE LOCKING
# data "template_file" "remote-state" {
#   template = "${file("${path.module}/scripts/remote-state.tpl")}"
#   # template = "${file("./scripts/remote-state.tpl")}"
#   vars = {
#     s3-bucket      = aws_s3_bucket.remote-state.id
#     region = aws_s3_bucket.remote-state.region
#     # dynamodb_table = module.remote-state-locking.dynamodb_table
#   }
# }

data "template_file" "remote-state" {
  template = <<-EOT
    terraform {
      backend "s3" {
        bucket = "${aws_s3_bucket.remote-state.id}"
        region = "${aws_s3_bucket.remote-state.region}"
        key = "global/terraform.tfstate"
      }
    }    
  EOT  
}
resource "null_resource" "remote-state-locks" {
  # triggers = {
  #   timestamp = timestamp()
  # }
  provisioner "local-exec" {
    command = "sleep 10;cat > ../../backend.tf <<EOL\n${data.template_file.remote-state.rendered}"
    working_dir = path.module
  }
}