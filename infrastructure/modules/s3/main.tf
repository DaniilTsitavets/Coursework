resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
  numeric  = true
}

resource "aws_s3_bucket" "s3-coursework-bucket" {
  bucket = var.s3_bucket_name != null ? var.s3_bucket_name : "coursework-bucket-${random_string.suffix.result}"
}

//TODO create vars for paths
resource "aws_s3_object" "etl1" {
  bucket       = aws_s3_bucket.s3-coursework-bucket.bucket
  key          = "etl1/etl1.sql"
  source       = "../sql/etl1.sql"
  etag = filemd5("../sql/etl1.sql")
}

resource "aws_s3_object" "test-csv" {
  bucket       = aws_s3_bucket.s3-coursework-bucket.bucket
  key          = "data/test.csv"
  source       = "../data/test.csv"
  etag = filemd5("../data/test.csv")
}

resource "aws_s3_object" "init-oltp-tables" {
  bucket       = aws_s3_bucket.s3-coursework-bucket.bucket
  key          = "init/init-oltp-tables.sql"
  source       = "../sql/init-oltp-tables.sql"
  etag = filemd5("../sql/init-oltp-tables.sql")
}

resource "aws_s3_object" "etl2" {
  bucket       = aws_s3_bucket.s3-coursework-bucket.bucket
  key          = "etl2/etl2.sql"
  source       = "../sql/etl2.sql"
  etag = filemd5("../sql/etl2.sql")
}

resource "aws_s3_object" "init-olap-tables" {
  bucket       = aws_s3_bucket.s3-coursework-bucket.bucket
  key          = "init/init-olap-tables.sql"
  source       = "../sql/init-olap-tables.sql"
  etag = filemd5("../sql/init-olap-tables.sql")
}
