resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
  numeric  = true
}

resource "aws_s3_bucket" "s3-coursework-bucket" {
  bucket = var.s3_bucket_name != null ? var.s3_bucket_name : "coursework-bucket-${random_string.suffix.result}"

}