resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
  numeric  = true
}

resource "aws_s3_bucket" "s3-coursework-bucket" {
  bucket = var.s3_bucket_name != null ? var.s3_bucket_name : "coursework-bucket-${random_string.suffix.result}"

}

resource "aws_s3_object" "etl1" {
  bucket       = aws_s3_bucket.s3-coursework-bucket.bucket
  key          = "etl1/from-staging-to-main.sql"
  source       = "../data/from-staging-to-main.sql"
  etag = filemd5("../data/from-staging-to-main.sql")
}

resource "aws_s3_object" "test-csv" {
  bucket       = aws_s3_bucket.s3-coursework-bucket.bucket
  key          = "data/test.csv"
  source       = "../data/test.csv"
  etag = filemd5("../data/test.csv")
}

resource "aws_s3_object" "init-tables" {
  bucket       = aws_s3_bucket.s3-coursework-bucket.bucket
  key          = "init/init-tables.sql"
  source       = "../data/init-tables.sql"
  etag = filemd5("../data/init-tables.sql")
}
