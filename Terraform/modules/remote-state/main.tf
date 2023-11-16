resource "random_id" "this" {
  byte_length = "10"
}

################# CREATING THE REMOTE S3 BUCKET
resource "aws_s3_bucket" "remote-state" {
  bucket = "${var.region}-terraform-state-${random_id.this.hex}"
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
    command     = "sleep 10;cat > ../../backend.tf <<EOL\n${data.template_file.remote-state.rendered}"
    working_dir = path.module
  }
}