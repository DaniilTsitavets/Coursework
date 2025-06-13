output "bucket_name" {
  description = "Name of the created S3 bucket"
  value       = aws_s3_bucket.s3-coursework-bucket.bucket
}

output "s3_key_oltp_etl" {
  value = aws_s3_object.etl1.key
}

output "s3_key_test_csv" {
  value = aws_s3_object.test-csv.key
}

output "s3_key_init_oltp_tables" {
  value = aws_s3_object.init-oltp-tables.key
}

output "s3_key_olap_etl" {
  value = aws_s3_object.etl2.key
}

output "s3_key_init_olap_tables" {
  value = aws_s3_object.init-olap-tables.key
}